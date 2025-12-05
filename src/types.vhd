library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
    subtype audio_voltage is natural range 0 to 5;

    function map_voltage (voltage : audio_voltage; low : integer; high : integer) return integer;

    subtype word is std_logic_vector(15 downto 0);
end package types;

package body types is 
    function map_voltage (voltage : audio_voltage; low : integer; high : integer) return integer is
    begin
        return (voltage - audio_voltage'low) / (audio_voltage'high - audio_voltage'low) * (high - low) + low;        
    end function map_voltage;
end package body types;