library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

package fixed_point is
    constant FRACTIONAL_LENGTH : natural := 5;  

    subtype fixed_point_t is word;

    subtype fixed_point_sign_t is fixed_point_t(fixed_point_t'length - 1);
    subtype fixed_point_integral_t is fixed_point_t(fixed_point_t'length - 2 downto FRACTIONAL_LENGTH);
    subtype fixed_point_fractional_t is fixed_point_t(FRACTIONAL_LENGTH - 1 downto 0);

    function get_fixed_point_sign(fp : fixed_point_t) return fixed_point_sign_t;
    function get_fixed_point_integral(fp : fixed_point_t) return fixed_point_integral_t;
    function get_fixed_point_fractional(fp : fixed_point_t) return fixed_point_fractional_t;

    function to_fixed_point(r : real) return fixed_point_t;
    function from_fixed_point(fp : fixed_point_t) return real;

    function "+"(left, right : fixed_point_t) return fixed_point_t;
    function "-"(left, right : fixed_point_t) return fixed_point_t;
    function "*"(left, right : fixed_point_t) return fixed_point_t;
    function "/"(left, right : fixed_point_t) return fixed_point_t;
    function "mod"(left, right : fixed_point_t) return fixed_point_t;
end package fixed_point;

package body fixed_point is
    function get_fixed_point_sign(fp : fixed_point_t) return fixed_point_sign_t is
    begin
        return fp(fixed_point_t'length - 1);
    end function get_fixed_point_sign;

    function get_fixed_point_integral(fp : fixed_point_t) return fixed_point_integral_t is
    begin
        return fp(fixed_point_t'length - 2 downto FRACTIONAL_LENGTH);
    end function get_fixed_point_integral;

    function get_fixed_point_fractional(fp : fixed_point_t) return fixed_point_fractional_t is
    begin
        return fp(FRACTIONAL_LENGTH - 1 downto 0);
    end function get_fixed_point_fractional;

    function to_fixed_point(r : real) return fixed_point_t is
    begin
        return fixed_point_t(to_signed(integer(r * (2 ** FRACTIONAL_LENGTH)), fixed_point_t'length));
    end function to_fixed_point;

    function to_fixed_point(i : integer) return fixed_point_t is
    begin
        return fixed_point_t(to_signed(i), fixed_point_t'length);
    end function to_fixed_point;

    function from_fixed_point(fp : fixed_point_t) return real is
    begin
        return real(to_integer(signed(fp))) / (2 ** FRACTIONAL_LENGTH);
    end function from_fixed_point;

    function "+"(left, right : fixed_point_t) return fixed_point_t is
        variable left_integer, right_integer, result : integer;
    begin
        left_integer := to_integer(signed(left));
        right_integer := to_integer(signed(right));

        result := left_integer + right_integer;

        return fixed_point_t(to_signed(result, fixed_point_t'length));
    end function "+";

    function "-"(left, right : fixed_point_t) return fixed_point_t is
        variable left_integer, right_integer, result : integer;
    begin
        left_integer := to_integer(signed(left));
        right_integer := to_integer(signed(right));

        result := left_integer - right_integer;

        return fixed_point_t(to_signed(result, fixed_point_t'length));
    end function "-";

    function "*"(left, right : fixed_point_t) return fixed_point_t is
        variable left_integer, right_integer, result : integer;
    begin
        left_integer := to_integer(signed(left));
        right_integer := to_integer(signed(right));

        result := left_integer * right_integer;

        return fixed_point_t(to_signed(result, fixed_point_t'length));
    end function "*";

    function "/"(left, right : fixed_point_t) return fixed_point_t is
        variable left_integer, right_integer, result : integer;
    begin
        left_integer := to_integer(signed(left));
        right_integer := to_integer(signed(right));

        result := left_integer / right_integer;

        return fixed_point_t(to_signed(result, fixed_point_t'length));
    end function "/";

    function "mod"(left, right : fixed_point_t) return fixed_point_t is
        variable left_integer, right_integer, result : integer;
    begin
        left_integer := to_integer(signed(left));
        right_integer := to_integer(signed(right));

        result := left_integer mod right_integer;

        return fixed_point_t(to_signed(result, fixed_point_t'length));
    end function "mod";
end package body fixed_point;