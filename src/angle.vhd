library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;
use work.fixed_point.all;

package angle is
    subtype quadrant_t is natural range 1 to 4;

    constant FP_2_PI : fixed_point_t := to_fixed_point(MATH_2_PI);
    constant FP_3_PI_OVER_2 : fixed_point_t := to_fixed_point(MATH_3_PI_OVER_2);
    constant FP_PI : fixed_point_t := to_fixed_point(MATH_PI);
    constant FP_PI_OVER_2 : fixed_point_t := to_fixed_point(MATH_PI_OVER_2);
end package angle;

