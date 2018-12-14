library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library Work;
use Work.NetworkConstants.all;

entity WeightPos is
	port(
		i_llayer: in LAYER_COUNTER;
		i_rlayer: in LAYER_COUNTER;
		i_lnode: in NODE_COUNTER;
		i_rnode: in NODE_COUNTER;
		o_position: out WEIGHT_POSITION
	);
end entity;

architecture archWeightPos of WeightPos is
begin
	o_position <= layers_offset(i_llayer) + layers_size(i_rlayer)
		         + i_lnode * layers_size(i_rlayer)
					+ i_rnode;
end;
