library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package types is
    subtype audio_voltage_t is real range 0.0 to 5.0;

    function map_voltage(voltage : audio_voltage_t; low : integer; high : integer) return integer;

    constant WORD_LENGTH : natural := 16;
    subtype word is std_logic_vector(WORD_LENGTH - 1 downto 0);

    constant SAMPLE_BUFFER_SIZE : natural := 16;
    type samples_t is array(0 to SAMPLE_BUFFER_SIZE - 1) of word;
end package types;

package body types is 
    function map_voltage(voltage : audio_voltage_t; low : integer; high : integer) return integer is
    begin
        return integer((voltage - audio_voltage_t'low) / (audio_voltage_t'high - audio_voltage_t'low) * real(high - low) + real(low));        
    end function map_voltage;
end package body types;