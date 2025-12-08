library ieee;
use ieee.std_logic_1164.all;

use work.types.all;
use work.fixed_point.all;

entity sample_buffer is
    port (
        clock : in std_logic := '0';

        enable : in std_logic := '0';
        ready : out std_logic := '0';

        sample : in fixed_point_t := to_fixed_point(0.0);
        samples : out samples_t := (others => to_fixed_point(0.0))
    );
end entity sample_buffer;

architecture arch of sample_buffer is
    signal buf : samples_t := (others => to_fixed_point(0.0));
begin
    process (clock) is
        variable sample_count : natural := 0;


        procedure fill is
        begin
            buf(LOWER_INDEX + sample_count) <= sample;
            sample_count := sample_count + 1;
        end procedure fill;

        procedure shift is
        begin
            buf(LOWER_INDEX + 1 to UPPER_INDEX) <= buf(LOWER_INDEX to UPPER_INDEX - 1);
            buf(LOWER_INDEX) <= sample;
        end procedure shift;
    begin
        if (rising_edge(clock)) then
            if (enable = '1') then
                if (LOWER_INDEX + sample_count = UPPER_INDEX) then
                    shift;
                else
                    fill;

                    if (LOWER_INDEX + sample_count = UPPER_INDEX - 1) then
                        ready <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    window : for i in 0 to SAMPLE_BUFFER_SIZE - 1 generate
    begin
        samples(i) <= buf(i);
    end generate;
end architecture arch;