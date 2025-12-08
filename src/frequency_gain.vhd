LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

use work.types.all;
use work.fixed_point.all;
use work.complex.all;

ENTITY frequency_gain IS
    PORT (
        en, clk : IN STD_LOGIC := '0';
        freq_amp : IN complex_t := to_complex(0.0, 0.0);
        gain_val : IN complex_t := to_complex(0.0, 0.0);
        eq_amp : OUT complex_t := to_complex(0.0, 0.0)
    );
END ENTITY frequency_gain;

ARCHITECTURE rtl OF frequency_gain IS
BEGIN
    eq_amp <= to_complex(freq_amp.re * gain_val.re, freq_amp.im * gain_val.im) when en = '1' else freq_amp;
END ARCHITECTURE rtl;