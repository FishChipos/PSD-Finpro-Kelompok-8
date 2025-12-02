LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fulladder IS
    PORT (
        a, b, cin : IN STD_LOGIC;
        cout, sum : OUT STD_LOGIC
    );
END ENTITY fulladder;

ARCHITECTURE rtl OF fulladder IS
BEGIN
    -- agar tidak ada delay pakai transport after
    sum <= TRANSPORT (a XOR b XOR cin) AFTER 1 ns;
    cout <= TRANSPORT ((a AND b) OR (cin AND (a XOR b))) AFTER 1 ns;
END ARCHITECTURE rtl;