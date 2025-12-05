library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity audio_equalizer is
    port (
        input : in audio_voltage
    );
end entity audio_equalizer;

architecture arch of audio_equalizer is
    constant CLOCK_FREQUENCY : natural := 100_000_000;
    constant CLOCK_PERIOD : time := 1 / CLOCK_FREQUENCY;
    signal clock : std_logic;

    signal quantized_input : word;
    signal sample : word;

    constant SAMPLE_BUFFER_SIZE : natural := 16;
    type sample_array is array (0 to SAMPLE_BUFFER_SIZE - 1) of word;

    signal samples : sample_array;
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
        generic map (
            buffer_size => SAMPLE_BUFFER_SIZE
        )
        port map (
            clock => clock,
            hold => '0',
            input => sample,
            output => samples
        );
end architecture arch;