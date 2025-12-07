library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.fixed_point.all;

entity dac is
    port (
        digital_in : in fixed_point_t;
        analog_out : out audio_voltage_t
    );
end entity dac;

architecture arch of dac is
    
begin
    process(digital_in)
        variable int_value: real;
    begin
        int_value := from_fixed_point(digital_in);
        
        analog_out <= map_to_voltage(int_value, 0.0, 2.0 ** (WORD_LENGTH - FRACTIONAL_LENGTH - 1));
    end process;
end architecture arch;