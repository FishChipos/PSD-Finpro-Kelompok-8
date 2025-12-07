LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

use work.types.all;
use work.fixed_point.all;

ENTITY frequency_gain IS
    PORT (
        en, clk : IN STD_LOGIC;
        freq_amp : IN fixed_point_t;
        gain_val : IN fixed_point_t;
        eq_amp : OUT fixed_point_t
    );
END ENTITY frequency_gain;

ARCHITECTURE rtl OF frequency_gain IS
BEGIN
    eq_amp <= freq_amp * gain_val when en = '1' else freq_amp;
END ARCHITECTURE rtl;