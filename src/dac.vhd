library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.fixed_point.all;

entity dac is
    port (
        digital_in : in fixed_point_t := to_fixed_point(0.0);
        analog_out : out audio_voltage_t := 0.0
    );
end entity dac;

architecture arch of dac is
    
begin
    analog_out <= from_fixed_point_r(digital_in);
end architecture arch;