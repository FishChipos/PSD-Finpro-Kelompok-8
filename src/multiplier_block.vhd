LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY multiplier_block IS
    PORT (
        previous_sum_and_cin : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
        carry_partial : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        result_sum : OUT STD_LOGIC_VECTOR(16 DOWNTO 0)
    );
END ENTITY multiplier_block;

ARCHITECTURE rtl OF multiplier_block IS
    COMPONENT fulladder
        PORT (
            a, b, cin : IN STD_LOGIC;
            cout, sum : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL carry : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    FullAdder_gen : FOR i IN 0 TO 15 GENERATE
    BEGIN
        fa0 : IF i = 0 GENERATE
        BEGIN
            fa_inst : fulladder
            PORT MAP(
                a => previous_sum_and_cin(i + 1),
                b => carry_partial(i),
                cin => '0',
                cout => carry(i),
                sum => result_sum(i)
            );
        END GENERATE;
        fa_other : IF i > 0 GENERATE
        BEGIN
            fa_inst : fulladder
            PORT MAP(
                a => previous_sum_and_cin(i + 1),
                b => carry_partial(i),
                cin => carry(i - 1),
                cout => carry(i),
                sum => result_sum(i)
            );
        END GENERATE;
    END GENERATE FullAdder_gen;
    result_sum(16) <= carry(15);
END ARCHITECTURE rtl;