library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

use work.types.all;
use work.fixed_point.all;
use work.angle.all;
use work.frequency.all;

entity istft is
    port (
        clk, en : in std_logic;
        
        freq_amp : in frequency_amplitudes_t;
        -- r_sample : out samples_t;
        sample_out : out samples_t;
        sample_ready : out std_logic;
        done : out std_logic;
        
        angle_index : out angle_index_t;
        cosine : in fixed_point_t
    );
end entity istft;

architecture rtl of istft is
    type istft_state_t is (ISTFT_IDLE, ISTFT_CALCULATING, ISTFT_DONE);
    signal state: istft_state_t := ISTFT_IDLE;
begin
    calculate : process(clk) is
        variable frequency, raw_angle : fixed_point_t;
        variable frequency_index : natural := 0;
        variable sample_index : natural := 0;
        variable sample_sum : fixed_point_t := to_fixed_point(0.0);
    begin
        if rising_edge(clk) then
            case state is
                when ISTFT_IDLE =>
                    if en = '1' then
                        frequency_index := 0;
                        sample_index := 0;
                        sample_sum := to_fixed_point(0.0);
                        state <= ISTFT_CALCULATING;
                    end if;
                when ISTFT_CALCULATING =>
                    sample_ready <= '0';
                    frequency := FREQUENCIES(frequency_index);
                
                    raw_angle := FP_2_PI * frequency * to_fixed_point(sample_index) / to_fixed_point(SAMPLE_BUFFER_SIZE);
                    angle_index <= to_angle_index_cos(raw_angle);

                    sample_sum := sample_sum + freq_amp(frequency_index) * adjust_sign_cos(cosine, get_quadrant(raw_angle)) / to_fixed_point(FREQUENCY_COUNT);

                    frequency_index := frequency_index + 1;

                    if (frequency_index = FREQUENCY_COUNT) then
                        sample_out(sample_index) <= sample_sum;
                        sample_ready <= '1';

                        sample_index := sample_index + 1;
                        frequency_index := 0;
                        sample_sum := to_fixed_point(0.0);
                    end if;

                    if (sample_index = SAMPLE_BUFFER_SIZE) then
                        done <= '1';
                        state <= ISTFT_DONE;
                    end if;

                when ISTFT_DONE =>
                    done <= '0';
                    state <= ISTFT_IDLE;
            end case;

        end if;
    end process calculate;
end architecture rtl;