library ieee;
use ieee.std_logic_1164.all;

use work.types.all;
use work.fixed_point.all;

entity sampler is
    port (
        clock : in std_logic := '0';

        quantized : in fixed_point_t := to_fixed_point(0.0);
        sample : out fixed_point_t := to_fixed_point(0.0)
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