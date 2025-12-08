library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.fixed_point.all;

-- The ADC quantizes an input audio voltage into a word.
-- This is non-synthesizable and will always be as its input is analog.
entity adc is
    port (
        raw : in audio_voltage_t := 0.0;
        quantized : out fixed_point_t := to_fixed_point(0.0)
    );
end entity adc;

architecture arch of adc is
begin
    quantized <= to_fixed_point(raw);
end architecture arch;