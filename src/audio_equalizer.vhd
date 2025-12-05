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

    constant CLOCK_FREQUENCY : natural := 100_000_000;
    constant CLOCK_PERIOD : time := 1 / CLOCK_FREQUENCY;
    signal clock : std_logic;

    signal quantized_input : word;
    signal sample : word;

    signal samples : samples_t;

    signal angle_index : angle_index_t;
    signal cosine : fixed_point_t;

    signal start, done : std_logic;
    signal frequency_amplitudes : frequency_amplitudes_t;
begin
    -- Might replace this with a dedicated clock generator entity later.
    generate_clock : process is
    begin
        clock <= '0';
        wait for CLOCK_PERIOD / 2;
        clock <= '1';
        wait for CLOCK_PERIOD / 2;
    end process generate_clock;

    analog_to_digital_converter : entity work.analog_to_digital_converter(arch)
        port map (
            raw => input,
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
            start => start,
            done => done,
            angle_index => angle_index,
            cosine => cosine
        );
end architecture arch;