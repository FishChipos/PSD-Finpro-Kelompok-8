library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.types.all;
use work.frequencies.all;

-- This will perform a Short-Time Fourier Transform (STFT) on input samples to produce an array of amplitudes corresponding to frequencies.
entity stft is
    port (
        clock : in std_logic;

        samples : in samples_t;
        frequencies : out frequency_amplitudes_t;
        start : in std_logic;
        done : out std_logic;

        angle : out angle_t;
        cosine : in fixed_point_t
    );
end entity stft;

architecture arch of stft is
    type transformer_state_t is (STFT_IDLE, STFT_CALCULATING, STFT_DONE);
    signal state : transformer_state_t := STFT_IDLE;
begin
    calculate : process (clock) is
        variable frequency, raw_angle : real;

        variable frequency_index : natural range 0 to FREQUENCIES'right := 0;
        variable term : natural := 0;
        variable amplitude : real := 0.0;
    begin
        if (rising_edge(clock)) then
            case (state) is
                when STFT_IDLE =>
                    done <= '0';

                    if (start = '1') then
                        frequency_index := 0;
                        term := 0;
                        amplitude := 0.0;
                        state <= STFT_CALCULATING;
                    end if;

                when STFT_CALCULATING =>
                    frequency := FREQUENCIES(frequency_index);
                
                    raw_angle := MATH_2_PI * frequency * term / SAMPLE_BUFFER_SIZE;
                    angle <= to_angle_cos(raw_angle);
                    amplitude := amplitude + samples(term) * adjust_quadrant_sign_cos(from_fixed_point(cosine), get_quadrant(raw_angle));

                    term := term + 1;

                    if (term = SAMPLE_BUFFER_SIZE) then
                        frequency_index := frequency_index + 1;
                        term := 0;

                        frequencies(frequency_index) <= amplitude;
                        amplitude := 0.0;
                    end if;

                    if (frequency_index = FREQUENCY_COUNT) then
                        state <= STFT_DONE;
                    end if;

                when STFT_DONE =>
                    done <= '1';
                    state <= STFT_IDLE;
            end case;
        end if;
    end process calculate;
end architecture arch;