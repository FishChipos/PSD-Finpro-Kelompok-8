library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity audio_equalizer is
    port (
        input : in audio_voltage_t
    );
end entity audio_equalizer;

architecture arch of audio_equalizer is
    constant CLOCK_FREQUENCY : natural := 100_000_000;
    constant CLOCK_PERIOD : time := 1 / CLOCK_FREQUENCY;
    signal clock : std_logic;

    signal quantized_input : word;
    signal sample : word;

    signal samples : samples_t;
begin
    -- Might replace this with a dedicated clock generator entity later.
    generate_clock : process is
    begin
        clock <= '0';
        wait for CLOCK_PERIOD / 2;
        clock <= '1';
        wait for CLOCK_PERIOD / 2;
    end process generate_clock;

    analog_to_digital_converter : entity analog_to_digital_converter(arch)
        port map (
            raw => input,
            quantized => quantized_input
        );

    sampler : entity sampler(arch)
        port map (
            clock => clock,
            quantized => quantized_input,
            sample => sample
        );
    
    sample_buffer : entity sample_buffer(arch)
        port map (
            clock => clock,
            hold => '0',
            sample => sample,
            samples => samples
        );
end architecture arch;