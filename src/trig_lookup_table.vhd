library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;
use work.angle.all;
use work.fixed_point.all;

entity trig_lookup_table is
    port (
        clock : in std_logic := '0';
        angle : in fixed_point_t;
        cosine : out fixed_point_t := (others => '0');
        sine : out fixed_point_t := (others => '0')
    );
end entity trig_lookup_table;

architecture arch of trig_lookup_table is
    -- Amount of values between 0 and 90.
    constant ANGLES_IN_90 : natural := 1024;

    type rom_t is array (0 to ANGLES_IN_90) of fixed_point_t;
    signal rom : rom_t;
begin
    generate_rom : for i in 0 to ANGLES_IN_90 generate
        rom(i) <= to_fixed_point(cos(real(i) * MATH_PI_OVER_2 / real(ANGLES_IN_90)));
    end generate;

    process (clock) is
        variable constrained_angle, angle_index_fp : fixed_point_t := to_fixed_point(0.0);
        variable sign_cosine, sign_sine : fixed_point_t := to_fixed_point(1.0);
        variable lower_angle_index, upper_angle_index : natural;
    begin
        if (rising_edge(clock)) then
            constrained_angle := angle mod FP_2_PI;

            if (FP_PI_OVER_2 < constrained_angle and constrained_angle < FP_3_PI_OVER_2) then
                sign_cosine := to_fixed_point(-1.0);
            else
                sign_cosine := to_fixed_point(1.0);
            end if;

            if (FP_PI < constrained_angle) then
                sign_sine := to_fixed_point(-1.0);
            else
                sign_sine := to_fixed_point(1.0);
            end if;

            angle_index_fp := angle mod FP_PI_OVER_2;

            if ((FP_PI_OVER_2 < constrained_angle and constrained_angle < FP_PI) or constrained_angle < FP_3_PI_OVER_2) then
                angle_index_fp := FP_PI_OVER_2 - angle_index_fp;
            end if;

            angle_index_fp := angle_index_fp / FP_PI_OVER_2;
            angle_index_fp := angle_index_fp * to_fixed_point(ANGLES_IN_90);

            lower_angle_index := from_fixed_point_i(floor(angle_index_fp));
            upper_angle_index := from_fixed_point_i(ceil(angle_index_fp));
            
            cosine <= (rom(lower_angle_index) + rom(upper_angle_index)) / to_fixed_point(2.0) * sign_cosine;
            sine <= (rom(ANGLES_IN_90 - lower_angle_index) + rom(ANGLES_IN_90 - upper_angle_index)) / to_fixed_point(2.0) * sign_sine;
        end if;
    end process;
end architecture arch;