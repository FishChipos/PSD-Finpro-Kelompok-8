library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;
use work.fixed_point.all;
use work.complex.all;
use work.angle.all;
use work.frequency.all;

-- This will perform a Short-Time Fourier Transform (STFT) on input samples to produce an array of amplitudes corresponding to frequencies.
entity stft is
    port (
        clock : in std_logic;

        samples : in samples_t;
        data : out frequency_data_blocks_t;
        start : in std_logic;
        done : out std_logic;

        trig_angle : out fixed_point_t;
        cosine : in fixed_point_t;
        sine : in fixed_point_t;

        window : in window_t
    );
end entity stft;

architecture arch of stft is
    type stft_state_t is (STFT_IDLE, STFT_WINDOWING, STFT_TRIG_LOOKUP, STFT_CALCULATING, STFT_DONE);
    signal state : stft_state_t := STFT_IDLE;
begin
    process (clock) is
        variable windowed_blocks : windowed_blocks_t := (others => (others => (to_fixed_point(0.0))));
        variable windowed_block_index : natural := 0;
        variable windowed_sample_index : natural := 0;

        variable frequency_data : frequency_data_t := (others => to_complex(0.0, 0.0));
        variable frequency : fixed_point_t := to_fixed_point(0.0);
        variable frequency_index : natural := 0;
        variable angle : fixed_point_t := to_fixed_point(0.0);

        function get_window_value(index : natural) return fixed_point_t is
        begin
            if (index < 0 or index > SAMPLE_BUFFER_SIZE - 1) then
                return to_fixed_point(0.0);
            else
                return window(index);
            end if;
        end function get_window_value;
    begin
        if (rising_edge(clock)) then
            case (state) is
                when STFT_IDLE =>
                    if (start = '1') then
                        windowed_blocks := (others => (others => (to_fixed_point(0.0))));
                        windowed_sample_index := 0;
                        frequency_data := (others => to_complex(0.0, 0.0));
                        frequency := to_fixed_point(0.0);
                        frequency_index := 0;
                        angle := to_fixed_point(0.0);
                        state <= STFT_WINDOWING;
                    end if;

                when STFT_WINDOWING =>
                    for gen_windowed_block_index in 0 to SAMPLE_BUFFER_SIZE - 1 loop
                        for sample_index in 0 to SAMPLE_BUFFER_SIZE - 1 loop
                            for sample_index_offset in 0 to SAMPLE_BUFFER_SIZE - 1 loop
                                windowed_blocks(gen_windowed_block_index)(sample_index) := windowed_blocks(gen_windowed_block_index)(sample_index) + samples(sample_index) * get_window_value(sample_index_offset + ((SAMPLE_BUFFER_SIZE - 1) / 2 - gen_windowed_block_index));
                            end loop;
                        end loop;
                    end loop;

                    state <= STFT_TRIG_LOOKUP;

                when STFT_TRIG_LOOKUP =>
                    frequency := FREQUENCIES(frequency_index);

                    angle := FP_2_PI * frequency;
                    angle := angle * (to_fixed_point(windowed_sample_index) / to_fixed_point(SAMPLE_BUFFER_SIZE));
                    trig_angle <= angle;
                    state <= STFT_CALCULATING;

                when STFT_CALCULATING =>

                    for windowed_block_index in 0 to SAMPLE_BUFFER_SIZE - 1 loop
                        frequency_data(windowed_block_index)(frequency_index) := frequency_data(windowed_block_index)(frequency_index) + to_complex(windowed_blocks(windowed_block_index)(windowed_sample_index) * cosine, windowed_blocks(windowed_block_index)(windowed_sample_index) * sine * to_fixed_point(-1.0));
                    end loop;

                    windowed_sample_index := windowed_sample_index + 1;

                    state <= STFT_TRIG_LOOKUP;
                    
                    if (windowed_sample_index >= SAMPLE_BUFFER_SIZE - 1) then
                        windowed_sample_index := 0;
                        frequency_index := frequency_index + 1;
                    end if;

                    if (frequency_index >= FREQUENCY_COUNT - 1) then
                        frequency_index := 0;
                        data <= frequency_data;
                        done <= '1';
                        state <= STFT_DONE;
                    end if;

                when STFT_DONE =>
                    done <= '0';
                    state <= STFT_IDLE;
            end case;
        end if;
    end process;
end architecture arch;