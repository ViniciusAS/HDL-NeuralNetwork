library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package slogic_package is

  ---------------- Size Constants -------------
  constant MSB : integer := 5;  -- n bits for integer numbers -- MOST  significant bits
  constant LSB : integer := 15; -- n bits for decimal numbers -- LEAST significant bits

  --------------------- Type declaration --------------------
  subtype slogic is std_logic_vector(MSB+LSB-1 downto 0);
  type slogic_vector is array(natural range <>) of slogic;

  -------------------- Functions -----------------
  function "*" (A : slogic; B : slogic) return slogic;
  function "+" (A : slogic; B : slogic) return slogic;
  function "<" (A : slogic; B : slogic) return boolean;
  function "<=" (A : slogic; B : slogic) return boolean;
  function ">" (A : slogic; B : slogic) return boolean;
  function ">=" (A : slogic; B : slogic) return boolean;
  function or_reduce(A : slogic_vector) return slogic;
  function sum_reduce(A : slogic_vector; SIZE : integer) return slogic;
  function sum_reduce2(A : slogic_vector; SIZE : integer) return slogic;
  function partial_sum_reduce(A : slogic_vector; SIZE : integer; STOP_POINT : integer) return slogic_vector;
  function to_slogic(I : integer) return slogic;

  ----------------- Constants -------------
  constant S_MAXVALUE : slogic := '0' & (MSB+LSB-2 downto 0 => '1');
  constant S_MINVALUE : slogic := '1' & (MSB+LSB-2 downto 0 => '0');
  signal test : signed(2*(MSB+LSB)-1 downto 0);

end slogic_package;

package body slogic_package is
  ------------------------------------slogic operations---------------------------------
  ---- performs a fixed point multiplication
  function "*" (A : slogic; B : slogic) return slogic is
    variable v_MULT    : signed(2*(MSB+LSB)-1 downto 0) := (others => '0');
    variable v_RESULT  : signed(MSB+LSB-1 downto 0);
  begin
    v_MULT := signed(A) * signed(B);

    -- check overflow
    if shift_right(v_MULT, LSB) > resize(signed(S_MAXVALUE), 2*MSB+LSB) then
      return S_MAXVALUE;
    end if;

    -- check underflow
    if shift_right(v_MULT, LSB) < resize(signed(S_MINVALUE), 2*MSB+LSB) then
      return S_MINVALUE;
    end if;

    -- round value
    if (unsigned(v_MULT(LSB-1 downto 0)) >= '1' & (LSB-2 downto 0 => '0')) then
      v_RESULT := resize(shift_right(v_MULT, LSB) + 1, MSB+LSB);
      return slogic(v_RESULT);
    end if;
    v_RESULT := resize(shift_right(v_MULT, LSB), MSB+LSB);
    return slogic(v_RESULT);
  end function;


  function "+" (A : slogic; B : slogic) return slogic is
    variable v_SUM : std_logic_vector(MSB+LSB downto 0);
  begin
    v_SUM := std_logic_vector( resize(signed(A), MSB+LSB+1) + resize(signed(B), MSB+LSB+1) );

    -- check overflow
    if signed(v_SUM) > resize(signed(S_MAXVALUE), MSB+LSB+1) then
      return S_MAXVALUE;
    end if;
    -- check underflow
    if signed(v_SUM) < resize(signed(S_MINVALUE), MSB+LSB+1) then
      return S_MINVALUE;
    end if;
    return slogic(resize(signed(v_SUM), MSB+LSB));
  end function;


  function "<" (A : slogic; B : slogic) return boolean is
  begin
    return (signed(A) < signed(B));
  end function;

  function "<=" (A : slogic; B : slogic) return boolean is
  begin
    return (signed(A) <= signed(B));
  end function;

  function ">" (A : slogic; B : slogic) return boolean is
  begin
    return (signed(A) > signed(B));
  end function;

  function ">=" (A : slogic; B : slogic) return boolean is
  begin
    return (signed(A) >= signed(B));
  end function;

  -- make the implementation of or_reduce for slogic
  function or_reduce(A : slogic_vector) return slogic is
    variable acc : slogic := (others => '0');
  begin
    for i in A'range loop
        acc := acc or A(i);
    end loop;
    return acc;
  end function;

  -- make a parallel implementation of add_reduce for slogic --- SIZE must be multiple of 2
  function sum_reduce(A : slogic_vector; SIZE : integer) return slogic is
    variable acc : slogic := (others => '0');
	 --type t_LAYERS is array() of slogic_vector();
	 variable result : slogic_vector(SIZE/2-1 downto 0);
  begin
    if SIZE = 1 then
      return A(0);
    else
      for i in 0 to SIZE/2-1 loop
        result(i) := A(2*i) + A(2*i+1);
      end loop;
      return sum_reduce(result, SIZE/2);
    end if;
  end function;

  function sum_reduce2(A : slogic_vector; SIZE : integer) return slogic is
    variable acc : slogic := (others => '0');
  begin
    for i in 0 to SIZE-1 loop
      acc := acc + A(i);
    end loop;
    return acc;
  end function;

  -- make a partial parallel implementation of add_reduce for slogic
  function partial_sum_reduce(A : slogic_vector; SIZE : integer; STOP_POINT : integer) return slogic_vector is
    variable result : slogic_vector(SIZE/2-1 downto 0);
  begin
    if SIZE = STOP_POINT then
      return A;
    else
      for i in 0 to SIZE/2-1 loop
        result(i) := A(2*i) + A(2*i+1);
      end loop;
      return partial_sum_reduce(result, SIZE/2, STOP_POINT);
    end if;
  end function;

  ---- converts integer without decimal part to slogic
  function to_slogic (I : integer) return slogic is
  begin
    return slogic(shift_left(to_signed(I, MSB+LSB), LSB));
  end function;

end slogic_package;
