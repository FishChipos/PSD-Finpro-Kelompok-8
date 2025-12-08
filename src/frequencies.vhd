library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.types.all;
use work.fixed_point.all;
use work.complex.all;

package frequency is
    type frequencies_t is array(natural range <>) of fixed_point_t;
    constant FREQUENCY_COUNT : natural := 128;

    impure function fill_frequencies return frequencies_t;
    constant FREQUENCIES : frequencies_t := fill_frequencies;

    type frequency_data_t is array(natural range 0 to FREQUENCY_COUNT - 1) of complex_t;
end package frequency;

package body frequency is
    impure function fill_frequencies return frequencies_t is
        variable freqs : frequencies_t(0 to FREQUENCY_COUNT - 1);
    begin
        for freq in 1 to FREQUENCY_COUNT loop
            freqs(freq - 1) := to_fixed_point(freq);
        end loop;

        return freqs;
    end function fill_frequencies;
end package body frequency;