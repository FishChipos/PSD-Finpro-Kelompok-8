library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

-- The ADC quantizes an input audio voltage into a word.
entity analog_to_digital_converter is
    port (
        raw : in audio_voltage_t;
        quantized : out word
    );
end entity analog_to_digital_converter;

architecture arch of analog_to_digital_converter is
begin
    quantized <= word(to_signed(map_voltage(raw, to_integer(word'low), to_integer(word'high)), word'length));
end architecture arch;