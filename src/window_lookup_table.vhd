library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;
use work.fixed_point.all;

entity window_lookup_table is
    port (
        window : out window_t
    );
end entity window_lookup_table;

architecture arch of window_lookup_table is
    constant SIGMA : real := 0.5;
    signal rom : window_t := (others => to_fixed_point(0.0));
begin
    generate_rom : for i in 0 to SAMPLE_BUFFER_SIZE - 1 generate
        rom(i) <= to_fixed_point(exp(-0.5 * ((real(i) - real(SAMPLE_BUFFER_SIZE - 1) / 2.0) / (SIGMA * real(SAMPLE_BUFFER_SIZE - 1) / 2.0)) ** 2));
    end generate;

    window <= rom;
end architecture arch;