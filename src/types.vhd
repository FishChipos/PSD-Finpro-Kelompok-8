library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package types is
    subtype audio_voltage_t is natural range 0 to 5;

    function map_voltage(voltage : audio_voltage_t; low : integer; high : integer) return integer;

    constant WORD_LENGTH : natural := 16;
    subtype word is std_logic_vector(WORD_LENGTH - 1 downto 0);

    constant SAMPLE_BUFFER_SIZE : natural := 16;
    type samples_t is array(0 to SAMPLE_BUFFER_SIZE - 1) of word;

    constant ANGLE_LENGTH : natural := 8;
    subtype quadrant_t is natural range 1 to 4;
    subtype angle_t is std_logic_vector(ANGLE_LENGTH - 1 downto 0);

    function get_quadrant(value : real) return quadrant_t;
    function adjust_quadrant_sign_cos(value : real; quadrant : quadrant_t) return real;
    function to_angle_cos(value : real) return angle_t;

    constant FRACTIONAL_LENGTH : natural := 8;
    type fixed_point_t is record
        integral : std_logic_vector(WORD_LENGTH - FRACTIONAL_LENGTH downto 0);
        fractional : std_logic_vector(FRACTIONAL_LENGTH - 1 downto 0);
    end record fixed_point_t;

    function to_fixed_point(value : real) return fixed_point_t;
    function from_fixed_point(value : fixed_point_t) return real;
end package types;

package body types is 
    function map_voltage(voltage : audio_voltage_t; low : integer; high : integer) return integer is
    begin
        return (voltage - audio_voltage_t'low) / (audio_voltage_t'high - audio_voltage_t'low) * (high - low) + low;        
    end function map_voltage;

    function get_quadrant(value : real) return quadrant_t is
        variable angle : real := value;
    begin
        angle := angle mod MATH_2_PI;

        if (angle >= MATH_3_PI_OVER_2) then
            return 4;
        elsif (angle >= MATH_PI) then
            return 3;
        elsif (angle >= MATH_PI_OVER_2) then
            return 2;
        else
            return 1;
        end if;
    end function get_quadrant;

    -- Adjusts the sign returned by the cos lookup table according to which quadrant the angle is in. 
    function adjust_quadrant_sign_cos(value : real; quadrant : quadrant_t) return real is
    begin
        case (quadrant) is
            when 1 | 4 => return value;
            when 2 | 3 => return -value;
        end case;
    end function adjust_quadrant_sign_cos;

    function to_angle_cos(value : real) return angle_t is
        variable angle : real := value;
        variable quadrant : quadrant_t := get_quadrant(angle);
    begin
        angle := angle mod MATH_PI_OVER_2;
        angle := angle / MATH_PI_OVER_2;
        angle := angle * angle_t'length;

        -- Adjust for related angles.
        case (quadrant) is
            when 1 | 3 => null;
            when 2 | 4 => angle := MATH_PI_OVER_2 - angle;
        end case;

        return angle_t(to_unsigned(integer(angle), angle_t'length));
    end function to_angle_cos;

    function to_fixed_point(value : real) return fixed_point_t is
        variable vector : word;
        variable converted : fixed_point_t;
    begin
        vector := word(unsigned(integer(value * (2.0 ** FRACTIONAL_LENGTH))));
        converted.integral := vector(WORD_LENGTH downto FRACTIONAL_LENGTH);
        converted.fractional := vector(FRACTIONAL_LENGTH - 1 downto 0);

        return converted;
    end function to_fixed_point;

    function from_fixed_point(value : fixed_point_t) return real is
        variable integral, fractional : real;
    begin
        integral := real(to_integer(unsigned(value.integral), WORD_LENGTH - FRACTIONAL_LENGTH));
        fractional := real(to_integer(unsigned(value.fractional), FRACTIONAL_LENGTH)) / (2.0 ** FRACTIONAL_LENGTH);

        return integral + fractional;
    end function from_fixed_point;
end package body types;