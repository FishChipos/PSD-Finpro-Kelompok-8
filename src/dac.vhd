library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity dac is
    port (
        digital_in : in word;
        analog_out : out audio_voltage_t
    );
end entity dac;

architecture arch of dac is
    function map_to_voltage(val : integer; low : real; high : real; max_int : integer) return real is
    begin
        return real(val) / real(max_int) * (high - low) + low;
    end function;
begin
    process(digital_in)
        variable int_value: integer;
    begin
        int_value := to_integer(signed(digital_in));
        
        analog_out <= map_to_voltage(int_value, audio_voltage_t'low, audio_voltage_t'high, 2**WORD_LENGTH-1);
    end process;
end architecture arch;