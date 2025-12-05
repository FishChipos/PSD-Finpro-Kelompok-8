LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY stft_gain IS
    PORT (
        en, clk : IN STD_LOGIC;
        freq_amp : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        gain_val : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        eq_amp : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY stft_gain;
ARCHITECTURE rtl OF stft_gain IS
    SIGNAL product : signed(31 DOWNTO 0);
    signal product_vector : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal shifted_vector : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL scaled_product : signed(31 DOWNTO 0);

    CONSTANT FRACTIONAL_LENGTH : NATURAL := 5;
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF en = '1' THEN
                --multiplying 16 x 16 bit
                product <= resize(signed(freq_amp), 32) * resize(signed(gain_val), 32);

                -- shift to fixed point format
                scaled_product <= shift_Right(product, FRACTIONAL_LENGTH);

                --output
                eq_amp <= STD_LOGIC_VECTOR(scaled_product(15 DOWNTO 0));
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;