library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity sample_buffer is
    port (
        clock : in std_logic;

        hold : in std_logic;

        sample : in word;
        samples : out samples_t
    );
end entity sample_buffer;

architecture arch of sample_buffer is
    signal buf : samples_t;
begin
    process (clock) is
        procedure shift is
        begin
            buf(1 to SAMPLE_BUFFER_SIZE - 1) <= buf(0 to SAMPLE_BUFFER_SIZE - 2);
            buf(0) <= sample;
        end procedure shift;
    begin
        if (rising_edge(clock)) then
            if (hold = '0') then
                shift;
            end if;
        end if;
    end process;

    samples <= buf;
end architecture arch;