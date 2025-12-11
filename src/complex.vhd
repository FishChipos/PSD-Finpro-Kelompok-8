library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.types.all;
use work.fixed_point.all;

package complex is
    type complex_t is record
        re : fixed_point_t;
        im : fixed_point_t;
    end record;

    function to_complex(r, i : real) return complex_t;
    function to_complex(r, i : fixed_point_t) return complex_t;

    function mag(c : complex_t) return fixed_point_t;

    function "+"(left, right : complex_t) return complex_t;
    function "-"(left, right : complex_t) return complex_t;
    function "*"(left, right : complex_t) return complex_t;
    function "/"(left : complex_t; right : fixed_point_t) return complex_t;
end package complex;

package body complex is
    function to_complex(r, i : real) return complex_t is
        variable c : complex_t;
    begin
        c.re := to_fixed_point(r);
        c.im := to_fixed_point(i);
        return c;
    end function to_complex;

    function to_complex(r, i : fixed_point_t) return complex_t is
        variable c : complex_t;
    begin
        c.re := r;
        c.im := i;
        return c;
    end function to_complex;

    -- For now this will use non-synthesizable code.
    function mag(c : complex_t) return fixed_point_t is
    begin
        return sqrt(c.re * c.re + c.im * c.im);
    end function mag;

    function "+"(left, right : complex_t) return complex_t is
        variable c : complex_t;
    begin
        c.re := left.re + right.re;
        c.im := left.im + right.im;
        return c;
    end function "+";

    function "-"(left, right : complex_t) return complex_t is
        variable c : complex_t;
    begin
        c.re := left.re - right.re;
        c.im := left.im - right.im;
        return c;
    end function "-";

    function "*"(left, right : complex_t) return complex_t is
        variable c : complex_t;
    begin
        c.re := left.re * right.re - left.im * right.im;
        c.im := left.re * right.im + left.im * right.re;
        return c;
    end function "*";

    function "/"(left : complex_t; right : fixed_point_t) return complex_t is
        variable c : complex_t;
    begin
        c.re := left.re / right;
        c.im := left.im / right;
        return c;
    end function "/";
end package body complex;