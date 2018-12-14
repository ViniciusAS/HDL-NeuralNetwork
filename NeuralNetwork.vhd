library IEEE;
use IEEE.std_logic_1164.all;

library Work;
use Work.NetworkConstants.all;
use Work.InterLayer;

entity NeuralNetwork is
	port(
		i_CLK: in std_logic;
		i_RST: in std_logic;
		i_infer: in std_logic;
		
		o_finished: out std_logic
	);
end entity;

architecture nn of NeuralNetwork is
	type t_STATE is (Idle, Inference, NextLayer, Finished);
	signal r_CURRENT, r_NEXT: t_STATE;
	
	signal w_done, w_calculate: std_logic;
	signal w_layer: LAYER_COUNTER;
	signal w_next_layer: LAYER_COUNTER;
	
	signal w_Nodes: Nodes;
	signal w_Weights: Weights;
	
begin
	u_current: process (i_CLK, i_RST) is
	begin
		if (i_RST = '0') then
			r_CURRENT <= Idle;
		elsif (rising_edge(i_CLK)) then
			r_CURRENT <= r_NEXT;
		end if;
	end process;
	
	u_next: process (i_infer, w_done, w_layer) is
	begin
		case r_CURRENT is
			when Idle      => if i_infer = '1' then r_NEXT <= Inference; else r_NEXT <= Idle;      end if;
			when Finished  => if i_infer = '0' then r_NEXT <= Idle;      else r_NEXT <= Finished;  end if;
			when Inference => if w_done  = '1' then r_NEXT <= NextLayer; else r_NEXT <= Inference; end if;
			
			when NextLayer =>
				if w_done = '0' and w_layer < layers_size'length-1 then
					r_NEXT <= Inference;
				elsif (w_layer = layers_size'length-1) then
					r_NEXT <= Finished;
				else
					r_NEXT <= NextLayer;
				end if;
			
			when others => r_NEXT <= Idle;
		end case;
	end process;
	
	o_finished <= '1' WHEN r_CURRENT = Finished ELSE '0';
	
	w_layer <= 	w_layer		WHEN r_CURRENT = Inference ELSE
					w_layer+1	WHEN r_CURRENT = NextLayer ELSE
					0;
					
	w_calculate <= '1' WHEN r_CURRENT = Inference ELSE '0';
	
	
	u_InterLayer: InterLayer port map (
		i_CLK, i_RST,
		w_Nodes, w_Weights,
		w_calculate,
		w_layer, w_next_layer,
		w_done
	);
	
	
end;
