library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use STD.textio.all;

use work.types.all;
use work.fixed_point.all;

entity audio_equalizer_tb is
end audio_equalizer_tb;

architecture rtl of audio_equalizer_tb is
    signal analog_in  : audio_voltage_t;
    signal analog_out : audio_voltage_buffer_t;
    signal start, done, sampling, output_ready : std_logic;

    file input_file : text open READ_MODE is "input_samples.txt";
    shared variable input_line: line;
    file output_file : text open WRITE_MODE is "output_samples.txt";
    shared variable output_line : line;
begin
    audio_equalizer_inst: entity work.audio_equalizer(arch)
        port map (
            audio_input  => analog_in,
            audio_output => analog_out,
            start => start,
            done => done,
            output_ready => output_ready,
            sampling => sampling
        );

        test: process
            variable sample : real;
        begin

            start <= '1';

            while not endfile(input_file) loop
                wait for 10 ns;

                start <= '0';

                readline(input_file, input_line);
                read(input_line, sample);

                analog_in <= sample * 5.0;


                if (sampling = '0') then
                    wait until done = '1';
                end if;
            end loop;

            file_close(input_file);
        wait;
        end process;    

        output : process (done) is
        begin
            if (done = '1') then
                for output_index in 0 to UPPER_INDEX - LOWER_INDEX loop
                    write(output_line, analog_out(output_index), left, 0, 7);
                    writeline(output_file, output_line);
                end loop;
            end if;
        end process;
end architecture rtl;