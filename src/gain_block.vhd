library ieee;
use ieee.std_logic_1164.all;

use work.types.all;
use work.frequency.all;

entity gain_block is
    port (
        clock : in std_logic;
        gain_enable : in std_logic;
        dft_frequency_data : in frequency_data_t;
        gain : in frequency_data_t;
        gain_frequency_data : out frequency_data_t
    );
end entity gain_block;

architecture arch of gain_block is
begin
    -- to loop gain for each freq
    generate_gain : for i in 0 to FREQUENCY_COUNT-1 generate
    begin
        gain_block : entity work.frequency_gain(rtl)
            PORT MAP (
                en => gain_enable, 
                clk => clock,
                freq_amp  => dft_frequency_data(i),
                gain_val => gain(i),
                eq_amp => gain_frequency_data(i)
            );
    end generate;
end architecture arch;