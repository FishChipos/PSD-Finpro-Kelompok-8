library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package types is
    constant SAMPLE_BUFFER_SIZE : natural := 64;

    -- Zero-padding for the STFT
    constant LOWER_INDEX : natural := SAMPLE_BUFFER_SIZE / 4;
    constant UPPER_INDEX : natural := SAMPLE_BUFFER_SIZE * 3 / 4 - 1;

    subtype audio_voltage_t is real range 0.0 to 5.0;
    type audio_voltage_buffer_t is array(0 to UPPER_INDEX - LOWER_INDEX) of audio_voltage_t;

    function map_from_voltage(voltage : audio_voltage_t; low : real; high : real) return real;
    function map_to_voltage(val : real; low : real; high : real) return audio_voltage_t;

    constant WORD_LENGTH : natural := 32;
    subtype word is std_logic_vector(WORD_LENGTH - 1 downto 0);
end package types;

package body types is 
    function map_from_voltage(voltage : audio_voltage_t; low : real; high : real) return real is
    begin
        return (voltage - audio_voltage_t'low) / (audio_voltage_t'high - audio_voltage_t'low) * (high - low) + low;        
    end function map_from_voltage;

    function map_to_voltage(val : real; low : real; high : real) return audio_voltage_t is
    begin
        return audio_voltage_t((val - low) / (high - low) * (audio_voltage_t'high - audio_voltage_t'low) + audio_voltage_t'low);
    end function;
end package body types;