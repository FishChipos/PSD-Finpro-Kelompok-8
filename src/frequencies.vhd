library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.types.all;
use work.fixed_point.all;

package frequency is
    type frequencies_t is array(natural range <>) of real;
    constant FREQUENCIES : frequencies_t := (
        20.0,
        25.0,
        31.5,
        40.0, 
        50.0,
        63.0,
        80.0,
        100.0,
        125.0,
        160.0,
        200.0,
        250.0,
        315.0,
        400.0,
        500.0,
        630.0,
        800.0,
        1_250.0,
        1_600.0,
        2_000.0,
        2_500.0,
        3_150.0,
        4_000.0,
        5_000.0,
        6_300.0,
        8_000.0,
        10_000.0,
        12_500.0,
        16_000.0,
        20_000.0
    );

    constant FREQUENCY_COUNT : natural := frequencies'right + 1;

    type frequency_amplitudes_t is array(natural range 0 to FREQUENCY_COUNT - 1) of fixed_point_t;
end package frequency;