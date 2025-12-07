library ieee;
use ieee.std_logic_1164.all;

use work.types.all;
use work.angle.all;
use work.fixed_point.all;
use work.frequency.all;

entity audio_equalizer is
    port (
        audio_input : in audio_voltage_t;
        audio_output : out audio_voltage_t
    );
end entity audio_equalizer;

architecture arch of audio_equalizer is
    type eq_state_t is (EQ_SAMPLING, EQ_STFT, EQ_MIXING, EQ_INVERSE_STFT);
    signal state : eq_state_t := EQ_SAMPLING;

    constant CLOCK_PERIOD : time := 10 ns;
    signal clock : std_logic;

    signal quantized_input : word;
    signal sample : word;

    signal samples : samples_t;
    signal digital_out : word;
    signal istft_sample_out : word;
    signal istft_sample_valid: std_logic;

    signal angle_index : angle_index_t;
    signal cosine : fixed_point_t;

    signal start_stft, done_stft : std_logic;
    signal start_istft, done_istft: std_logic;
    signal frequency_amplitudes : frequency_amplitudes_t;

    signal eq_freq_amp : frequency_amplitudes_t;
    signal gain : frequency_amplitudes_t :=
    (
        -- default value, unchanged
        others =>to_fixed_point(1.0)
    );

    signal gain_enable : std_logic := '1';
    signal sample_count : natural := 0;
    signal buffer_full  : std_logic := '0';

    -- proc to change the gain in each freq
    PROCEDure set_gain(
        signal gain_array : inout frequency_amplitudes_t;
        constant index: in natural;
        constant val : in fixed_point_t
    ) is
    begin
        gain_array(index) <= val;
    end PROCEDure;
    -- usage : set_gain(gain, 10, to_fixed_point(0.7))
    -- might change it to its own gain controller block if needed

begin
    -- Might replace this with a dedicated clock generator entity later.
    -- generate_clock : process is
    -- begin
    --     clock <= '0';
    --     wait for CLOCK_PERIOD / 2;
    --     clock <= '1';
    --     wait for CLOCK_PERIOD / 2;
    -- end process generate_clock;
    clock_gen: entity work.clock_generator(rtl)
        port map (
            clock => clock
        );

    adc : entity work.adc(arch)
        port map (
            raw => audio_input,
            quantized => quantized_input
        );

    sampler : entity work.sampler(arch)
        port map (
            clock => clock,
            quantized => quantized_input,
            sample => sample
        );
    
    sample_buffer : entity work.sample_buffer(arch)
        port map (
            clock => clock,
            hold => '0',
            sample => sample,
            samples => samples
        );

    cos_lookup_table : entity work.cos_lookup_table(arch)
        port map (
            angle_index => angle_index,
            cosine => cosine
        );

    stft : entity work.stft(arch)
        port map (
            clock => clock,
            samples => samples,
            frequency_amplitudes => frequency_amplitudes,
            start => start_stft,
            done => done_stft,
            angle_index => angle_index,
            cosine => cosine
        );


    -- to loop gain for each freq
    generate_gain: for i in 0 to FREQUENCY_COUNT-1 generate
        signal freq_amp_vec : std_logic_vector(15 downto 0);
        signal gain_val_vec : std_logic_vector(15 downto 0);
    begin
        --convert before mapping to gain block
        freq_amp_vec <= std_logic_vector(frequency_amplitudes(i));
        gain_val_vec <= std_logic_vector(gain(i));
        gain_block : entity work.stft_gain(rtl)
            PORT MAP (
            en => gain_enable, 
            clk => clock,
            freq_amp  => freq_amp_vec,
            gain_val => gain_val_vec,
            eq_amp => eq_freq_amp(i)
            );
    end generate;

    istft : entity work.istft(rtl)
        port map(
        clk => clock, 
        en => start_istft,
        freq_amp => eq_freq_amp,
        sample_out => istft_sample_out,
        sample_valid => istft_sample_valid,
        done => done_istft,
        
        angle_index => angle_index,
        cosine => cosine
        );

    dac : entity work.dac(arch)
        port map(
            digital_in => istft_sample_out,
            analog_out => audio_output
        );
    sample_counter_proc : process(clock)
begin
    if rising_edge(clock) then
        if sample_count < SAMPLE_BUFFER_SIZE then
            sample_count <= sample_count + 1;
        else
            buffer_full <= '1';
        end if;
    end if;
end process;

    process(clock)
    begin
        if rising_edge(clock) then
            case state is
                
                when EQ_SAMPLING =>
                    start_istft <= '0';
                    if buffer_full = '1' then
                        start_stft <= '1';
                        state <= EQ_STFT;
                    else
                        start_stft <= '0';
                    end if;
                when EQ_STFT =>
                    start_stft <= '1';
                    if done_stft = '1' then
                        start_stft <= '0';
                        state <= EQ_INVERSE_STFT;
                    end if;
                when EQ_MIXING =>
                    set_gain(gain, 10, to_fixed_point(0.7));
                    state <= EQ_INVERSE_STFT;
                when EQ_INVERSE_STFT =>
                    start_istft <= '1';
                    if done_istft = '1' then
                        digital_out <= samples(0);
                        state <= EQ_SAMPLING;
                    end if;
            end case;
        end if;
    end process;
end architecture arch;