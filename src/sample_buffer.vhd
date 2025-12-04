library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity sample_buffer is
    generic (
        buffer_size : natural
    );
    port (
        clock : in std_logic;

        hold : in std_logic;

        input : in word;
        output : out output_array
    );

    type output_array is array (0 to buffer_size - 1) of word;
end entity sample_buffer;

architecture arch of sample_buffer is
    procedure shift is
    begin
        output(1 to buffer_size - 1) <= output(0 to buffer_size - 2);
        output(0) <= input;
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