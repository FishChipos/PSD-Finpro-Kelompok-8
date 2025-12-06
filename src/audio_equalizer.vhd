library ieee;
use ieee.std_logic_1164.all;

use work.types.all;
use work.angle.all;
use work.fixed_point.all;
use work.frequency.all;

entity audio_equalizer is
    port (
        input : in audio_voltage_t
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

    signal angle_index : angle_index_t;
    signal cosine : fixed_point_t;

    signal start, done : std_logic;
    signal frequency_amplitudes : frequency_amplitudes_t;

    signal eq_freq_amp : frequency_amplitudes_t;
    signal gain : frequency_amplitudes_t :=
    (
        -- default value, unchanged
        others =>to_fixed_point(1.0)
    );

    signal gain_enable : std_logic := '1';

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
    generate_clock : process is
    begin
        clock <= '0';
        wait for CLOCK_PERIOD / 2;
        clock <= '1';
        wait for CLOCK_PERIOD / 2;
    end process generate_clock;

    -- adc : entity work.adc(arch)
    --     port map (
    --         raw => input,
    --         quantized => quantized_input
    --     );

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
            start => start,
            done => done,
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
        en => start,
        freq_amp => frequency_amplitudes,
        r_sample => samples,
        done => done,
        
        angle_index => angle_index,
        cosine => cosine
        );
end architecture arch;