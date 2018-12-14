library IEEE;
use IEEE.std_logic_1164.all;

package Utils is
	function and_reducer(i_vet: std_logic_vector(natural range<>)) return std_logic;
end package;


package body Utils is

	function and_reducer(i_vet: std_logic_vector(natural range<>)) return std_logic is
		variable v_acc: std_logic;
	begin
		v_acc := i_vet(0);
		for i in 1 to i_vet'length-1 loop
			v_acc := v_acc and i_vet(i);
		end loop;
		return v_acc;
	end function;
	
end package body;
