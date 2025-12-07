library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

-- The ADC quantizes an input audio voltage into a word.
-- This is non-synthesizable and will always be as its input is analog.
entity adc is
    port (
        raw : in audio_voltage_t;
        quantized : out word
    );
end entity adc;

architecture arch of adc is
begin
    quantized <= word(to_signed(integer(map_from_voltage(raw, 0.0, 2.0 ** WORD_LENGTH - 1.0)), word'length));
end architecture arch;