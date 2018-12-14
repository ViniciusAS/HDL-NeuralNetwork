library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library Work;
use Work.NetworkConstants.all;

entity NodePos is
	port(
		i_layer: in LAYER_COUNTER;
		i_node: in NODE_COUNTER;
		o_position: out NODE_POSITION
	);
end entity;

architecture archNodePos of NodePos is
begin
	o_position <= layers_offset(i_layer) + i_node;
end;
