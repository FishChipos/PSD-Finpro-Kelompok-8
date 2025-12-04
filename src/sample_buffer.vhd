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
    procedure shift is
    begin
        samples(1 to SAMPLE_BUFFER_SIZE - 1) <= samples(0 to SAMPLE_BUFFER_SIZE - 2);
        samples(0) <= sample;
    end procedure shift;
begin
    process (clock) is
    begin
        if (rising_edge(clock)) then
            if (hold /= '1') then
                shift;
            end if;
        end if;
    end process;
end architecture arch;