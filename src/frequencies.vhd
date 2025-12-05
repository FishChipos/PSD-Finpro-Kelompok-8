library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.types.all;
use work.fixed_point.all;

package frequency is
    type frequencies_t is array(natural range <>) of fixed_point_t;
    constant FREQUENCIES : frequencies_t := (
        to_fixed_point(20.0),
        to_fixed_point(25.0),
        to_fixed_point(31.5),
        to_fixed_point(40.0), 
        to_fixed_point(50.0),
        to_fixed_point(63.0),
        to_fixed_point(80.0),
        to_fixed_point(100.0),
        to_fixed_point(125.0),
        to_fixed_point(160.0),
        to_fixed_point(200.0),
        to_fixed_point(250.0),
        to_fixed_point(315.0),
        to_fixed_point(400.0),
        to_fixed_point(500.0),
        to_fixed_point(630.0),
        to_fixed_point(800.0),
        to_fixed_point(1_250.0),
        to_fixed_point(1_600.0),
        to_fixed_point(2_000.0),
        to_fixed_point(2_500.0),
        to_fixed_point(3_150.0),
        to_fixed_point(4_000.0),
        to_fixed_point(5_000.0),
        to_fixed_point(6_300.0),
        to_fixed_point(8_000.0),
        to_fixed_point(10_000.0),
        to_fixed_point(12_500.0),
        to_fixed_point(16_000.0),
        to_fixed_point(20_000.0)
    );

    constant FREQUENCY_COUNT : natural := frequencies'right + 1;

    type frequency_amplitudes_t is array(natural range 0 to FREQUENCY_COUNT - 1) of fixed_point_t;
end package frequency;