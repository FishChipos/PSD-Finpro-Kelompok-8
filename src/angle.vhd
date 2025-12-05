library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;
use work.fixed_point.all;

package angle is
    constant ANGLE_INDEX_LENGTH : natural := 8;
    subtype quadrant_t is natural range 1 to 4;
    subtype angle_index_t is std_logic_vector(ANGLE_INDEX_LENGTH - 1 downto 0);

    function get_quadrant(a : fixed_point_t) return quadrant_t;
    function adjust_sign_cos(a : fixed_point_t; quadrant : quadrant_t) return fixed_point_t;
    function to_angle_index_cos(a : fixed_point_t) return angle_index_t;

    constant FP_2_PI : fixed_point_t := to_fixed_point(MATH_2_PI);
    constant FP_3_PI_OVER_2 : fixed_point_t := to_fixed_point(MATH_3_PI_OVER_2);
    constant FP_PI : fixed_point_t := to_fixed_point(MATH_PI);
    constant FP_PI_OVER_2 : fixed_point_t := to_fixed_point(MATH_PI_OVER_2);
end package angle;

package body angle is
    function get_quadrant(a : fixed_point_t) return quadrant_t is
        variable constrained_angle : fixed_point_t := a;
    begin
        constrained_angle := constrained_angle mod FP_2_PI;

        if (constrained_angle <= FP_PI_OVER_2) then
            return 1;
        elsif (constrained_angle <= FP_PI) then
            return 2;
        elsif (constrained_angle <= FP_3_PI_OVER_2) then
            return 3;
        else
            return 4;
        end if;
    end function get_quadrant;

    function adjust_sign_cos(a : fixed_point_t; quadrant : quadrant_t) return fixed_point_t is
    begin
        case (quadrant) is
            when 1 | 4 => return a;
            when 2 | 3 => return a * to_fixed_point(-1.0);
        end case;
    end function adjust_sign_cos;

    function to_angle_index_cos(a : fixed_point_t) return angle_index_t is
        variable constrained_angle : fixed_point_t := a;
        variable quadrant : quadrant_t := get_quadrant(a);
    begin
        constrained_angle := constrained_angle mod FP_PI_OVER_2;

        case (quadrant) is
            when 1 | 3 => null;
            when 2 | 4 => constrained_angle := FP_PI_OVER_2 - constrained_angle; 
        end case;

        return angle_index_t(to_unsigned(to_integer(signed(constrained_angle / FP_PI_OVER_2)), angle_index_t'length));
    end function to_angle_index_cos;
end package body angle;

