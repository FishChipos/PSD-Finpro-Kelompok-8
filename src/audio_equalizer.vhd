library ieee;
use ieee.std_logic_1164.all;

use work.types.all;
use work.angle.all;
use work.fixed_point.all;
use work.frequency.all;

entity audio_equalizer is
    port (
        audio_input : in audio_voltage_t;
        audio_output : out audio_voltage_t;
        start : in std_logic;
        ready : out std_logic
    );
end entity audio_equalizer;

architecture arch of audio_equalizer is
    type eq_state_t is (EQ_IDLE, EQ_SAMPLING, EQ_STFT, EQ_MIXING, EQ_INVERSE_STFT);
    signal state : eq_state_t := EQ_IDLE;

    constant CLOCK_PERIOD : time := 10 ns;
    signal clock : std_logic;

    signal quantized_input : word;
    signal sample : word;

    signal samples : samples_t;
    signal sample_buffer_enable : std_logic;
    signal sample_buffer_full : std_logic;

    signal angle_index_sel : std_logic;
    signal angle_index_stft, angle_index_istft, angle_index : angle_index_t;
    signal cosine : fixed_point_t;

    signal stft_start, stft_done : std_logic;
    signal stft_frequency_amplitudes : frequency_amplitudes_t;

    signal gain_frequency_amplitudes : frequency_amplitudes_t;

    signal gain : frequency_amplitudes_t :=
    (
        -- default value, unchanged
        others => to_fixed_point(1.0)
    );

    signal gain_enable : std_logic := '1';

    signal istft_start, istft_done, istft_sample_ready : std_logic;
    signal istft_sample_out : samples_t;

    -- proc to change the gain in each freq
    procedure set_gain(
        signal gain_array : inout frequency_amplitudes_t;
        constant index: in natural;
        constant val : in fixed_point_t
    ) is
    begin
        gain_array(index) <= val;
    end procedure;
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
            enable => sample_buffer_enable,
            full => sample_buffer_full,
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
            frequency_amplitudes => stft_frequency_amplitudes,
            start => stft_start,
            done => stft_done,
            angle_index => angle_index_stft,
            cosine => cosine
        );


    -- to loop gain for each freq
    generate_gain : for i in 0 to FREQUENCY_COUNT-1 generate
    begin
        gain_block : entity work.frequency_gain(rtl)
            PORT MAP (
                en => gain_enable, 
                clk => clock,
                freq_amp  => stft_frequency_amplitudes(i),
                gain_val => gain(i),
                eq_amp => gain_frequency_amplitudes(i)
            );
    end generate;

    istft : entity work.istft(rtl) 
        port map(
            clk => clock, 
            en => istft_start,
            freq_amp => gain_frequency_amplitudes,
            sample_out => istft_sample_out,
            sample_ready => istft_sample_ready,
            done => istft_done,
            
            angle_index => angle_index_istft,
            cosine => cosine
        );

    dac : entity work.dac(arch)
        port map(
            digital_in => istft_sample_out(0),
            analog_out => audio_output
        );

    angle_index <= angle_index_stft when angle_index_sel = '0' else angle_index_istft;

    process(clock)
    begin
        if rising_edge(clock) then
            case state is
                when EQ_IDLE =>
                    if (start = '1') then
                        state <= EQ_SAMPLING;
                        ready <= '0';
                        sample_buffer_enable <= '1';
                    end if;
                when EQ_SAMPLING =>
                    if (sample_buffer_full = '1') then
                        sample_buffer_enable <= '0';
                        angle_index_sel <= '0';
                        stft_start <= '1';
                        state <= EQ_STFT;
                    end if;
                when EQ_STFT =>
                    if stft_done = '1' then
                        stft_start <= '0';
                        state <= EQ_MIXING;
                    end if;
                when EQ_MIXING =>
                    state <= EQ_INVERSE_STFT;
                    angle_index_sel <= '1';
                    istft_start <= '1';
                when EQ_INVERSE_STFT =>
                    if istft_done = '1' then
                        istft_start <= '0';
                        state <= EQ_IDLE;
                        ready <= '1';
                    end if;
            end case;
        end if;
    end process;
end architecture arch;