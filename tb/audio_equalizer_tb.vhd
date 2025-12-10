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
    signal start, done, sampling : std_logic;

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
            sampling => sampling
        );

        test: process
            variable sample : real;
            variable finish : boolean := false;
        begin
            if (not finish) then
                start <= '1';

                wait for 10 ns;

                start <= '0';

                while not endfile(input_file) loop
                    readline(input_file, input_line);
                    read(input_line, sample);

                    analog_in <= sample * 5.0;

                    if (sampling = '0') then
                        wait until done = '1';
                    else
                        wait for 10 ns;
                    end if;
                end loop;

                file_close(input_file);
                finish := true;
            end if;
            wait;
        end process;    

        output : process (done) is
        begin
            if (done = '1') then
                for output_index in 0 to SAMPLE_BUFFER_SIZE - 1 loop
                    write(output_line, analog_out(output_index) * 5.0, left, 0, 7);
                    writeline(output_file, output_line);
                end loop;

                file_close(output_file);
            end if;
        end process;
end architecture rtl;