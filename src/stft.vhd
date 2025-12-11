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
        clock : in std_logic := '0';

        samples : in samples_t := (others => to_fixed_point(0.0));
        frequency_datum : out complex_t := to_complex(0.0, 0.0);
        frequency_data : out frequency_data_t := (others => to_complex(0.0, 0.0));
        start : in std_logic := '0';
        done : out std_logic := '0';

        trig_angle : out fixed_point_t := (others => '0');
        cosine : in fixed_point_t := to_fixed_point(0.0);
        sine : in fixed_point_t := to_fixed_point(0.0)
    );
end entity stft;

architecture arch of stft is
    type stft_state_t is (STFT_IDLE, STFT_TRIG_LOOKUP, STFT_CALCULATING, STFT_DONE);
    signal state : stft_state_t := STFT_IDLE;
begin
    calculate : process (clock) is
        variable frequency : fixed_point_t := to_fixed_point(0.0);

        variable frequency_index : natural := 0;
        variable sample_index : natural := 0;
        variable angle : fixed_point_t := to_fixed_point(0.0);
        variable datum : complex_t := to_complex(0.0, 0.0);
    begin
        if (rising_edge(clock)) then
            case (state) is
                when STFT_IDLE =>
                    if (start = '1') then
                        frequency_index := 0;
                        sample_index := 0;
                        datum := to_complex(0.0, 0.0);
                        state <= STFT_TRIG_LOOKUP;
                    end if;

                when STFT_TRIG_LOOKUP =>
                    frequency := FREQUENCIES(frequency_index);

                    angle := FP_2_PI * frequency;
                    angle := angle * (to_fixed_point(sample_index) / to_fixed_point(SAMPLE_BUFFER_SIZE));
                    trig_angle <= angle;
                    state <= STFT_CALCULATING;

                when STFT_CALCULATING =>

                    datum := datum + to_complex(samples(sample_index) * cosine, samples(sample_index) * sine * to_fixed_point(-1.0));

                    state <= STFT_TRIG_LOOKUP;

                    sample_index := sample_index + 1;

                    if (sample_index >= SAMPLE_BUFFER_SIZE) then
                        frequency_datum <= datum;
                        frequency_data(frequency_index) <= datum;

                        frequency_index := frequency_index + 1;
                        sample_index := 0;
                        datum := to_complex(0.0, 0.0);

                        if (frequency_index >= FREQUENCY_COUNT) then
                            done <= '1';
                            state <= STFT_DONE;
                        end if;    
                    end if;

                when STFT_DONE =>
                    done <= '0';
                    state <= STFT_IDLE;
            end case;
        end if;
    end process calculate;
end architecture arch;