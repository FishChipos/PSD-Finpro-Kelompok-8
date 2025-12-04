library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity sampler is
    port (
        clock : in std_logic;

        quantized : in word;
        sample : out word
    );
end entity sampler;

architecture arch of sampler is
begin
    discretize : process (clock) is
    begin
        if (rising_edge(clock)) then
            sample <= quantized;
        end if;
    end process discretize;
end architecture arch;