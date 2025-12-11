library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;

package fixed_point is
    -- Don't go too crazy or else it will go above the integer limit.
    constant FRACTIONAL_LENGTH : natural := 10;  

    subtype fixed_point_t is word;

    function to_fixed_point(r : real) return fixed_point_t;
    function to_fixed_point(i : integer) return fixed_point_t;
    function from_fixed_point_r(fp : fixed_point_t) return real;
    function from_fixed_point_i(fp : fixed_point_t) return integer;

    function floor(fp : fixed_point_t) return fixed_point_t;
    function ceil(fp : fixed_point_t) return fixed_point_t;
    function sqrt(fp : fixed_point_t) return fixed_point_t;

    function "+"(left, right : fixed_point_t) return fixed_point_t;
    function "-"(left, right : fixed_point_t) return fixed_point_t;
    function "*"(left, right : fixed_point_t) return fixed_point_t;
    function "/"(left, right : fixed_point_t) return fixed_point_t;
    function "mod"(left, right : fixed_point_t) return fixed_point_t;
    function "<"(left, right : fixed_point_t) return boolean;

    type samples_t is array(0 to SAMPLE_BUFFER_SIZE - 1) of fixed_point_t;

    constant EPSILON : real := 1.0e-5;
end package fixed_point;

package body fixed_point is
    function to_fixed_point(r : real) return fixed_point_t is
    begin
        return fixed_point_t(to_signed(integer(r * (2.0 ** FRACTIONAL_LENGTH)), fixed_point_t'length));
    end function to_fixed_point;

    function to_fixed_point(i : integer) return fixed_point_t is
    begin
        return fixed_point_t(resize(to_signed((i), fixed_point_t'length) * to_signed(2 ** FRACTIONAL_LENGTH, fixed_point_t'length), fixed_point_t'length));
    end function to_fixed_point;

    function from_fixed_point_r(fp : fixed_point_t) return real is
        variable r : real := 0.0;
    begin
        for i in 0 to fixed_point_t'length - 2 loop
            if (fp(i) = '1') then
                r := r + (2.0 ** (i - FRACTIONAL_LENGTH));
            end if;
        end loop;

        if (fp(fixed_point_t'length - 1) = '1') then
            r := -r;
        end if;

        return r;
    end function from_fixed_point_r;

    function from_fixed_point_i(fp : fixed_point_t) return integer is
    begin
        return to_integer(signed(fp)) / (2 ** FRACTIONAL_LENGTH);
    end function;

    function floor(fp : fixed_point_t) return fixed_point_t is
        constant ALL_ZEROS : fixed_point_t := (others => '0');
        variable floored : fixed_point_t := fp;
    begin
        if (floored(FRACTIONAL_LENGTH - 1 downto 0) = ALL_ZEROS(FRACTIONAL_LENGTH - 1 downto 0)) then
            return fp;
        end if;

        floored(FRACTIONAL_LENGTH - 1 downto 0) := (others => '0');
        floored(FRACTIONAL_LENGTH) := '0';

        return floored;
    end function;

    function ceil(fp : fixed_point_t) return fixed_point_t is
        constant ALL_ZEROS : fixed_point_t := (others => '0');
        variable ceiled : fixed_point_t := fp;
    begin
        if (ceiled(FRACTIONAL_LENGTH - 1 downto 0) = ALL_ZEROS(FRACTIONAL_LENGTH - 1 downto 0)) then
            return fp;    
        end if;
        
        ceiled(FRACTIONAL_LENGTH - 1 downto 0) := (others => '0');
        ceiled(FRACTIONAL_LENGTH) := '1';

        return ceiled;
    end function;

    function sqrt(fp : fixed_point_t) return fixed_point_t is
        constant ITERATIONS : natural := 6;
        variable approx : fixed_point_t := fp;
    begin
        for i in 1 to ITERATIONS loop
            approx := (approx + fp / approx) / to_fixed_point(2.0);
        end loop;

        return approx;
    end function;

    function "+"(left, right : fixed_point_t) return fixed_point_t is
        variable left_signed, right_signed, result : signed(fixed_point_t'length - 1 downto 0);
    begin
        left_signed := signed(left);
        right_signed := signed(right);

        result := left_signed + right_signed;

        return fixed_point_t(result);
    end function "+";

    function "-"(left, right : fixed_point_t) return fixed_point_t is
        variable left_signed, right_signed, result : signed(fixed_point_t'length - 1 downto 0);
    begin
        left_signed := signed(left);
        right_signed := signed(right);

        result := left_signed - right_signed;

        return fixed_point_t(result);
    end function "-";

    function "*"(left, right : fixed_point_t) return fixed_point_t is
        variable left_signed, right_signed, result : signed(fixed_point_t'length - 1 downto 0);
    begin
        left_signed := signed(left);
        right_signed := signed(right);

        result := resize(left_signed * right_signed / to_signed(2 ** FRACTIONAL_LENGTH, fixed_point_t'length), fixed_point_t'length);

        return fixed_point_t(result);
    end function "*";

    function "/"(left, right : fixed_point_t) return fixed_point_t is
        variable left_signed, right_signed, result : signed(fixed_point_t'length - 1 downto 0);
    begin
        left_signed := signed(left);
        right_signed := signed(right);

        result := resize(left_signed * to_signed(2 ** FRACTIONAL_LENGTH, fixed_point_t'length) / right_signed, fixed_point_t'length);

        return fixed_point_t(result);
    end function "/";

    function "mod"(left, right : fixed_point_t) return fixed_point_t is
        variable left_signed, right_signed, result : signed(fixed_point_t'length - 1 downto 0);
    begin
        left_signed := signed(left);
        right_signed := signed(right);

        result := left_signed mod right_signed;

        return fixed_point_t(result);
    end function "mod";

    function "<"(left, right : fixed_point_t) return boolean is
        variable left_signed, right_signed : signed(fixed_point_t'length - 1 downto 0);
    begin
        left_signed := signed(left);
        right_signed := signed(right);

        return left_signed < right_signed;
    end function "<";
end package body fixed_point;