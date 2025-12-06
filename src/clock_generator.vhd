library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity clock_generator is
    port (
        clock : out std_logic
    );
end entity clock_generator;


architecture rtl of clock_generator is
    constant CLOCK_PERIOD : time := 10 ns;
begin
    generate_clock : process is
    begin
        clock <= '0';
        wait for CLOCK_PERIOD / 2;
        clock <= '1';
        wait for CLOCK_PERIOD / 2;
    end process generate_clock;
end architecture rtl;