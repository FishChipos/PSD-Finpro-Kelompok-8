library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.types.all;

package frequencies is
    type frequency_t is (
        FREQ_20HZ,
        FREQ_25HZ,
        FREQ_31HZ5,
        FREQ_40HZ,
        FREQ_50HZ,
        FREQ_63HZ,
        FREQ_80HZ,
        FREQ_100HZ,
        FREQ_125HZ,
        FREQ_160HZ,
        FREQ_200HZ,
        FREQ_250HZ,
        FREQ_315HZ,
        FREQ_400HZ,
        FREQ_500HZ,
        FREQ_630HZ,
        FREQ_800HZ,
        FREQ_1KHZ25,
        FREQ_1KHZ6,
        FREQ_2KHZ,
        FREQ_2KHZ5,
        FREQ_3KHZ15,
        FREQ_4KHZ,
        FREQ_5KHZ,
        FREQ_6KHZ3,
        FREQ_8KHZ,
        FREQ_10KHZ,
        FREQ_12KHZ5,
        FREQ_16KHZ,
        FREQ_20KHZ
    );

    type frequency_values_t is array(frequency_t) of real;
    constant FREQUENCY_VALUES : frequency_values_t := (
        FREQ_20HZ   => 20.0,
        FREQ_25HZ   => 25.0,
        FREQ_31HZ5  => 31.5,
        FREQ_40HZ   => 40.0, 
        FREQ_50HZ   => 50.0,
        FREQ_63HZ   => 63.0,
        FREQ_80HZ   => 80.0,
        FREQ_100HZ  => 100.0,
        FREQ_125HZ  => 125.0,
        FREQ_160HZ  => 160.0,
        FREQ_200HZ  => 200.0,
        FREQ_250HZ  => 250.0,
        FREQ_315HZ  => 315.0,
        FREQ_400HZ  => 400.0,
        FREQ_500HZ  => 500.0,
        FREQ_630HZ  => 630.0,
        FREQ_800HZ  => 800.0,
        FREQ_1KHZ25 => 1_250.0,
        FREQ_1KHZ6  => 1_600.0,
        FREQ_2KHZ   => 2_000.0,
        FREQ_2KHZ5  => 2_500.0,
        FREQ_3KHZ15 => 3_150.0,
        FREQ_4KHZ   => 4_000.0,
        FREQ_5KHZ   => 5_000.0,
        FREQ_6KHZ3  => 6_300.0,
        FREQ_8KHZ   => 8_000.0,
        FREQ_10KHZ  => 10_000.0,
        FREQ_12KHZ5 => 12_500.0,
        FREQ_16KHZ  => 16_000.0,
        FREQ_20KHZ  => 20_000.0
    );

    type frequencies_t is array(frequency_t) of word;
end package frequencies;