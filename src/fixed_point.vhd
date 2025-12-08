library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

package fixed_point is
    constant FRACTIONAL_LENGTH : natural := 8;  

    subtype fixed_point_t is word;

    function to_fixed_point(r : real) return fixed_point_t;
    function to_fixed_point(i : integer) return fixed_point_t;
    function from_fixed_point_r(fp : fixed_point_t) return real;
    function from_fixed_point_i(fp : fixed_point_t) return integer;

    function "+"(left, right : fixed_point_t) return fixed_point_t;
    function "-"(left, right : fixed_point_t) return fixed_point_t;
    function "*"(left, right : fixed_point_t) return fixed_point_t;
    function "/"(left, right : fixed_point_t) return fixed_point_t;
    function "mod"(left, right : fixed_point_t) return fixed_point_t;
    function "<"(left, right : fixed_point_t) return boolean;

    type samples_t is array(0 to SAMPLE_BUFFER_SIZE - 1) of fixed_point_t;
end package fixed_point;

package body fixed_point is
    function to_fixed_point(r : real) return fixed_point_t is
    begin
        return fixed_point_t(to_signed(integer(r * (2.0 ** FRACTIONAL_LENGTH)), fixed_point_t'length));
    end function to_fixed_point;

    function to_fixed_point(i : integer) return fixed_point_t is
    begin
        return fixed_point_t(to_signed(i * (2 ** FRACTIONAL_LENGTH), fixed_point_t'length));
    end function to_fixed_point;

    function from_fixed_point_r(fp : fixed_point_t) return real is
    begin
        return real(to_integer(signed(fp))) / (2.0 ** FRACTIONAL_LENGTH);
    end function from_fixed_point_r;

    function from_fixed_point_i(fp : fixed_point_t) return integer is
    begin
        return to_integer(signed(fp)) / (2 ** FRACTIONAL_LENGTH);
    end function;

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

        result := left_integer * right_integer / (2 ** FRACTIONAL_LENGTH);

        return fixed_point_t(to_signed(result, fixed_point_t'length));
    end function "*";

    function "/"(left, right : fixed_point_t) return fixed_point_t is
        variable left_integer, right_integer, result : integer;
    begin
        left_integer := to_integer(signed(left));
        right_integer := to_integer(signed(right));

        result := left_integer * (2 ** FRACTIONAL_LENGTH) / right_integer;

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

    function "<"(left, right : fixed_point_t) return boolean is
        variable left_integer, right_integer : integer;
    begin
        left_integer := to_integer(signed(left));
        right_integer := to_integer(signed(right));

        return left_integer < right_integer;
    end function "<";
end package body fixed_point;