library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;

entity cos_lookup_table is
    port (
        -- Mapped to 0 - 90.
        angle : in angle_t;
        cosine : out fixed_point_t
    );

    subtype angle_t is std_logic_vector(ANGLE_LENGTH - 1 downto 0);
end entity cos_lookup_table;

architecture arch of cos_lookup_table is
    constant ANGLES : natural := 2 ** ANGLE_LENGTH;

    type rom_t is array (0 to ANGLES - 1) of fixed_point_t;
    signal rom : rom_t;
begin
    generate_rom : for i in 0 to ANGLES - 1 generate
        rom(i) <= to_fixed_point(cos(real(to_integer(unsigned(angle), angle_t'length)) * MATH_PI_OVER_2 / real(ANGLES)));
    end generate;

    cosine <= rom(to_integer(unsigned(angle), angle_t'length));
end architecture arch;