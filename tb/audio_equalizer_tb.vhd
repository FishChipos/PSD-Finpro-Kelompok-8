library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use STD.textio.all;

use work.types.all;

entity audio_equalizer_tb is
end audio_equalizer_tb;

architecture rtl of audio_equalizer_tb is
    signal analog_in  : audio_voltage_t;
    signal analog_out : audio_voltage_t;
    signal start, ready : std_logic;
begin
    audio_equalizer_inst: entity work.audio_equalizer(arch)
        port map (
            audio_input  => analog_in,
            audio_output => analog_out,
            start => start,
            ready => ready
        );

        test: process
            file input_file : text open READ_MODE is "input_samples.txt";
            file output_file : text open WRITE_MODE is "output_samples.txt";
            variable input_line: line;
            variable output_line : line;
            variable sample : real;
        begin
            while not endfile(input_file) loop
                readline(input_file, input_line);
                read(input_line, sample);

                analog_in <= sample  * 5.0;
                start <= '1';

                wait for 10 ns;

                start <= '0';

                wait until ready = '1';

                write(output_line, analog_out);
                writeline(output_file, output_line);
                wait for 10 ns;  
            end loop;
            file_close(input_file);
            file_close(output_file);
        wait;
        end process;    
end architecture rtl;