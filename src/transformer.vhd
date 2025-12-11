library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;
use work.fixed_point.all;
use work.complex.all;
use work.angle.all;
use work.frequency.all;

entity transformer is
    port (
        clock : in std_logic;
        mode : in std_logic;
        start : in std_logic;
        done : out std_logic;

        stft_samples : in samples_t;
        stft_frequency_datum : out complex_t;
        stft_frequency_data : out frequency_data_t;

        istft_frequency_data : in frequency_data_t;
        istft_signal_point : out fixed_point_t;
        istft_signal : out samples_t;

        trig_angle : out fixed_point_t;
        cosine : in fixed_point_t;
        sine : in fixed_point_t
    );
end entity transformer;

architecture arch of transformer is
    type stft_state_t is (TRANSFORMER_IDLE, TRANSFORMER_TRIG_LOOKUP, TRANSFORMER_STFT, TRANSFORMER_ISTFT, TRANSFORMER_DONE);
    signal state : stft_state_t := TRANSFORMER_IDLE;
begin
    calculate : process (clock) is
        variable transformer_mode : stft_state_t;
        variable frequency : fixed_point_t := to_fixed_point(0.0);

        variable frequency_index : natural := 0;
        variable sample_index : natural := 0;
        variable angle : fixed_point_t := to_fixed_point(0.0);
        variable datum : complex_t := to_complex(0.0, 0.0);
        variable sample_sum : complex_t := to_complex(0.0, 0.0);
    begin
        if (rising_edge(clock)) then
            case (state) is
                when TRANSFORMER_IDLE =>
                    if (start = '1') then
                        frequency_index := 0;
                        sample_index := 0;
                        datum := to_complex(0.0, 0.0);

                        if (mode = '1') then
                            transformer_mode := TRANSFORMER_ISTFT;
                        else
                            transformer_mode := TRANSFORMER_STFT;
                        end if;
                            
                        state <= TRANSFORMER_TRIG_LOOKUP;
                    end if;

                when TRANSFORMER_TRIG_LOOKUP =>
                    frequency := FREQUENCIES(frequency_index);

                    angle := FP_2_PI * frequency;
                    angle := angle * (to_fixed_point(sample_index) / to_fixed_point(SAMPLE_BUFFER_SIZE));
                    trig_angle <= angle;
                    state <= transformer_mode;

                when TRANSFORMER_STFT =>

                    datum := datum + to_complex(stft_samples(sample_index) * cosine, stft_samples(sample_index) * sine * to_fixed_point(-1.0));

                    state <= TRANSFORMER_TRIG_LOOKUP;

                    sample_index := sample_index + 1;

                    if (sample_index >= SAMPLE_BUFFER_SIZE) then
                        stft_frequency_datum <= datum;
                        stft_frequency_data(frequency_index) <= datum;

                        frequency_index := frequency_index + 1;
                        sample_index := 0;
                        datum := to_complex(0.0, 0.0);

                        if (frequency_index >= FREQUENCY_COUNT) then
                            done <= '1';
                            state <= TRANSFORMER_DONE;
                        end if;    
                    end if;

                when TRANSFORMER_ISTFT =>
                    sample_sum := sample_sum + (istft_frequency_data(frequency_index) * to_complex(cosine, sine) / to_fixed_point(SAMPLE_BUFFER_SIZE));

                    state <= TRANSFORMER_TRIG_LOOKUP;

                    frequency_index := frequency_index + 1;

                    if (frequency_index >= FREQUENCY_COUNT) then
                        istft_signal_point <= mag(sample_sum);
                        istft_signal(sample_index) <= mag(sample_sum);

                        sample_index := sample_index + 1;
                        frequency_index := 0;
                        sample_sum := to_complex(0.0, 0.0);

                        if (sample_index >= SAMPLE_BUFFER_SIZE) then
                            done <= '1';
                            state <= TRANSFORMER_DONE;
                        end if;
                    end if;

                when TRANSFORMER_DONE =>
                    done <= '0';
                    state <= TRANSFORMER_IDLE;
            end case;
        end if;
    end process calculate;
end architecture arch;