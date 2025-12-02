library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplier16x16bit is
    port (
        clk, en: in std_logic;
        inputA : in signed(15 downto 0);
        inputB : in signed(15 downto 0);
        result : out signed(31 downto 0);
    );
end entity multiplier16x16bit;

architecture rtl of multiplier16x16bit is
    
begin
    
    
    
end architecture rtl;