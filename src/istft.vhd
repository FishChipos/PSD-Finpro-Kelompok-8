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
        
        frequency_data : in frequency_data_t := (others => to_complex(0.0, 0.0));
        
        sample : out fixed_point_t := to_fixed_point(0.0);
        samples : out samples_t := (others => to_fixed_point(0.0));
        done : out std_logic := '0';
        
        cos_angle : out fixed_point_t := to_fixed_point(0.0);
        cosine : in fixed_point_t := to_fixed_point(0.0);
        sin_angle : out fixed_point_t := (others => '0');
        sine : in fixed_point_t := to_fixed_point(0.0)
    );
end entity istft;

architecture rtl of istft is
    type istft_state_t is (ISTFT_IDLE, ISTFT_TRIG_LOOKUP, ISTFT_CALCULATING, ISTFT_DONE);
    signal state : istft_state_t := ISTFT_IDLE;
begin
    calculate : process(clk) is
        variable frequency, angle : fixed_point_t := to_fixed_point(0.0);
        variable frequency_index : natural := 0;
        variable sample_index : natural := 0;
        variable sample_sum : complex_t := to_complex(0.0, 0.0);
    begin
        if rising_edge(clk) then
            case state is
                when ISTFT_IDLE =>
                    if en = '1' then
                        frequency_index := 0;
                        sample_index := 0;
                        sample_sum := to_complex(0.0, 0.0);
                        state <= ISTFT_TRIG_LOOKUP;
                    end if;

                when ISTFT_TRIG_LOOKUP =>
                    frequency := FREQUENCIES(frequency_index);
                
                    angle := FP_2_PI * frequency;
                    angle := angle * (to_fixed_point(sample_index) / to_fixed_point(SAMPLE_BUFFER_SIZE));
                    cos_angle <= angle;
                    sin_angle <= angle;

                    state <= ISTFT_CALCULATING;

                when ISTFT_CALCULATING =>
                    sample_sum := sample_sum + (frequency_data(frequency_index) * to_complex(cosine, sine) / to_fixed_point(SAMPLE_BUFFER_SIZE));

                    state <= ISTFT_TRIG_LOOKUP;

                    frequency_index := frequency_index + 1;

                    if (frequency_index >= FREQUENCY_COUNT) then
                        sample <= mag(sample_sum);
                        samples(sample_index) <= mag(sample_sum);

                        sample_index := sample_index + 1;
                        frequency_index := 0;
                        sample_sum := to_complex(0.0, 0.0);

                        if (sample_index >= SAMPLE_BUFFER_SIZE) then
                            done <= '1';
                            state <= ISTFT_DONE;
                        end if;
                    end if;
                when ISTFT_DONE =>
                    done <= '0';
                    state <= ISTFT_IDLE;
            end case;

        end if;
    end process calculate;
end architecture rtl;