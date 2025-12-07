library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use STD.textio.all;

use work.types.all;

entity audio_equalizer_tb is
end audio_equalizer_tb;


architecture rtl of audio_equalizer_tb is
    signal analog_in  : audio_voltage_t := 0.0;
    signal analog_out : audio_voltage_t;

begin
    audio_equalizer_inst: entity work.audio_equalizer(arch)
        port map (
            audio_input  => analog_in,
            audio_output => analog_out
        );

        test: process
            file input_file : text open read_mode is "input_samples.txt";
            file output_file : text open write_mode is "output_samples.txt";
            variable input_line: line;
            variable output_line : line;
            variable sample_int : integer;
            variable sample_real : real;
        begin
            wait for 50 ns;
            while not endfile(input_file) loop
                readline(input_file, input_line);
                read(input_line, sample_int);

                sample_real := real(sample_int);
                analog_in <= sample_real  * 5.0;

                wait for 20 ns;  

                write(output_line, analog_out);
                writeline(output_file, output_line);
                wait for 20 ns;  
            end loop;
        wait;
        end process;    
end architecture rtl;