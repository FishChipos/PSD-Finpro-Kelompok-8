library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

use work.types.all;
use work.fixed_point.all;
use work.complex.all;
use work.angle.all;
use work.frequency.all;

entity istft is
    port (
        clk, en : in std_logic := '0';
        
        data : in frequency_data_blocks_t;
        
        sample : out fixed_point_t;
        samples : out samples_t;
        done : out std_logic;
        
        trig_angle : out fixed_point_t;
        cosine : in fixed_point_t;
        sine : in fixed_point_t;

        window_index : out word;
        window : in window_t
    );
end entity istft;

architecture rtl of istft is
    type istft_state_t is (ISTFT_IDLE, ISTFT_TRIG_LOOKUP, ISTFT_CALCULATING, ISTFT_UNWINDOWING, ISTFT_DONE);
    signal state : istft_state_t := ISTFT_IDLE;
begin
    calculate : process(clk) is
        variable windowed_blocks : windowed_blocks_t := (others => (others => to_fixed_point(0.0)));
        variable frequency, angle : fixed_point_t := to_fixed_point(0.0);
        variable frequency_index : natural := 0;
        variable windowed_sample_index : natural := 0;
        variable sample_sum : complex_t := to_complex(0.0, 0.0);
        variable window_sum : fixed_point_t := to_fixed_point(0.0);

        function get_window_value(index : natural) return fixed_point_t is
        begin
            if (index < 0 or index > SAMPLE_BUFFER_SIZE - 1) then
                return to_fixed_point(0.0);
            else
                return window(index);
            end if;
        end function get_window_value;
    begin
        if rising_edge(clk) then
            case state is
                when ISTFT_IDLE =>
                    if en = '1' then
                        frequency_index := 0;
                        windowed_sample_index := 0;
                        sample_sum := to_complex(0.0, 0.0);
                        state <= ISTFT_TRIG_LOOKUP;
                    end if;

                when ISTFT_TRIG_LOOKUP =>
                    frequency := FREQUENCIES(frequency_index);
                
                    angle := FP_2_PI * frequency;
                    angle := angle * (to_fixed_point(windowed_sample_index) / to_fixed_point(SAMPLE_BUFFER_SIZE));
                    trig_angle <= angle;

                    state <= ISTFT_CALCULATING;

                when ISTFT_CALCULATING =>
                    for windowed_block_index in 0 to SAMPLE_BUFFER_SIZE - 1 loop
                        windowed_blocks(windowed_block_index)(windowed_sample_index) := windowed_blocks(windowed_block_index)(windowed_sample_index) + data(frequency_index) * to_complex(cosine, sine) / to_fixed_point(SAMPLE_BUFFER_SIZE);
                    end loop;

                    windowed_sample_index := windowed_sample_index + 1;

                    state <= ISTFT_TRIG_LOOKUP;

                    if (windowed_sample_index >= SAMPLE_BUFFER_SIZE - 1) then
                        windowed_sample_index := 0;
                        frequency_index := frequency_index + 1;
                    end if;

                    if (frequency_index >= FREQUENCY_COUNT - 1) then
                        windowed_sample_index := windowed_sample_index + 1;
                        frequency_index := 0;
                        state <= ISTFT_UNWINDOWING;
                    end if;

                when ISTFT_UNWINDOWING =>
                    for sample_index in 0 to SAMPLE_BUFFER_SIZE - 1 loop
                        sample_sum := to_fixed_point(0.0);
                        window_sum := to_fixed_point(0.0);

                        for windowed_block_index in 0 to SAMPLE_BUFFER_SIZE - 1 loop
                            for windowed_block_index_offset in 0 to SAMPLE_BUFFER_SIZE - 1 loop
                                sample_sum := sample_sum + windowed_blocks(windowed_block_index)(sample_index - windowed_block_index_offset);
                            end loop;
                        end loop;
                    end loop;

                when ISTFT_DONE =>
                    done <= '0';
                    state <= ISTFT_IDLE;
            end case;

        end if;
    end process calculate;
end architecture rtl;