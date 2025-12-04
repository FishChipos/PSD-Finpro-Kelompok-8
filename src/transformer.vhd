library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.types.all;
use work.frequencies.all;

-- This will perform a forward Short-Time Fourier Transform (STFT) on input samples to produce an array of amplitudes corresponding to frequencies.
entity transformer is
    port (
        clock : in std_logic;

        samples : in samples_t;
        frequencies : out frequencies_t;
        start : in std_logic;
        done : out std_logic;

        angle : out angle_t;
        cosine : in fixed_point_t
    );
end entity transformer;

architecture arch of transformer is
    shared variable frequency : frequency_t;
    shared variable term : natural := 0;
    shared variable amplitude : real := 0.0;
begin
    start_calculations : process (start) is
    begin
        if (start = '1') then
            frequency := frequency_t'left;
            term := 0;
            amplitude := 0.0;
        end if;
    end process start_calculations;

    calculate : process (clock) is
    begin
        if (rising_edge(clock)) then
            if (start = '1') then
                -- If we've gotten to the last frequency and we have calculated all the terms, then we're done!
                if (frequency = frequency_t'right and term = SAMPLE_BUFFER_SIZE) then
                    done <= '1';
                -- Else we should continue.
                else
                    angle <= to_angle_cos(MATH_2_PI * FREQUENCY_VALUES(frequency) * term / SAMPLE_BUFFER_SIZE);
                    amplitude := amplitude + samples(term) * adjust_quadrant_sign_cos(cosine, get_quadrant(FREQUENCY_VALUES(frequency)));

                    term := term + 1;

                    if (term = SAMPLE_BUFFER_SIZE) then
                        frequency := frequency'succ;
                        term := 0;

                        frequencies(frequency) <= amplitude;
                        amplitude := 0.0;
                    end if;
                end if;
            end if;
        end if;
    end process calculate;
end architecture arch;