library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;
use work.angle.all;
use work.fixed_point.all;

entity cos_lookup_table is
    port (
        -- Mapped to 0 - 90.
        angle_index : in angle_index_t;
        cosine : out fixed_point_t
    );
end entity cos_lookup_table;

architecture arch of cos_lookup_table is
    constant ANGLE_INDICES : natural := 2 ** ANGLE_INDEX_LENGTH;

    type rom_t is array (0 to ANGLE_INDICES - 1) of fixed_point_t;
    signal rom : rom_t;
begin
    generate_rom : for i in 0 to ANGLE_INDICES - 1 generate
        rom(i) <= to_fixed_point(cos(real(i) * MATH_PI_OVER_2 / real(ANGLE_INDICES - 1)));
    end generate;

    cosine <= rom(to_integer(unsigned(angle_index)));
end architecture arch;