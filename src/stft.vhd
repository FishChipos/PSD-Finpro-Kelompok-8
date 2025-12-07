library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;
use work.fixed_point.all;
use work.angle.all;
use work.frequency.all;

-- This will perform a Short-Time Fourier Transform (STFT) on input samples to produce an array of amplitudes corresponding to frequencies.
entity stft is
    port (
        clock : in std_logic;

        samples : in samples_t;
        frequency_amplitudes : out frequency_amplitudes_t;
        start : in std_logic;
        done : out std_logic;

        angle_index : out angle_index_t;
        cosine : in fixed_point_t
    );
end entity stft;

architecture arch of stft is
    type stft_state_t is (STFT_IDLE, STFT_CALCULATING, STFT_DONE);
    signal state : stft_state_t := STFT_IDLE;
begin
    calculate : process (clock) is
        variable frequency, raw_angle : fixed_point_t;

        variable frequency_index : natural := 0;
        variable term : natural := 0;
        variable amplitude : fixed_point_t := to_fixed_point(0.0);
    begin
        if (rising_edge(clock)) then
            case (state) is
                when STFT_IDLE =>
                    if (start = '1') then
                        frequency_index := 0;
                        term := 0;
                        amplitude := to_fixed_point(0.0);
                        state <= STFT_CALCULATING;
                    end if;

                when STFT_CALCULATING =>
                    frequency := FREQUENCIES(frequency_index);
                
                    raw_angle := FP_2_PI * frequency * to_fixed_point(term) / to_fixed_point(SAMPLE_BUFFER_SIZE);
                    angle_index <= to_angle_index_cos(raw_angle);
                    amplitude := amplitude + to_fixed_point(to_integer(unsigned(samples(term)))) * adjust_sign_cos(cosine, get_quadrant(raw_angle));

                    term := term + 1;

                    if (term = SAMPLE_BUFFER_SIZE) then
                        frequency_amplitudes(frequency_index) <= amplitude;

                        frequency_index := frequency_index + 1;
                        term := 0;
                        amplitude := to_fixed_point(0.0);
                    end if;

                    if (frequency_index = FREQUENCY_COUNT) then
                        done <= '1';
                        state <= STFT_DONE;
                    end if;

                when STFT_DONE =>
                    done <= '0';
                    state <= STFT_IDLE;
            end case;
        end if;
    end process calculate;
end architecture arch;