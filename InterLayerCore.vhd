library IEEE;
use IEEE.std_logic_1164.all;

library Work;
use Work.slogic_package.all;
use Work.NetworkConstants.all;
use Work.NodePos;
use Work.WeightPos;
use Work.ActivationFunction;

entity InterLayerCore is
	port(
		i_CLK: in std_logic;
		i_RST: in std_logic;
		
		i_core_num: in integer;
	
		io_Nodes: inout Nodes;
		i_Weights: in Weights;
		
		i_Calculating: in std_logic;
		
		i_llayer: in LAYER_COUNTER;
		i_rlayer: in LAYER_COUNTER;
		
		i_all_done: in std_logic;
		o_core_done: out std_logic
	);
end entity;

architecture archInterLayerCore of InterLayerCore is

	type t_core_STATE is (Idle, Multiplications, Bias, Activation, Store, Ended);
	signal r_core_CURRENT, r_core_NEXT: t_core_STATE;
	
	signal r_lnode_counter  : NODE_COUNTER;
	signal r_rnode_counter  : NODE_COUNTER;
	signal r_weight_counter : NODE_COUNTER;
	
	signal w_lnode_position  : NODE_POSITION;
	signal w_rnode_position  : NODE_POSITION;
	signal w_weight_position : WEIGHT_POSITION;
	
	signal w_activated: slogic;
	signal r_calc_res : slogic;
begin

	u_core_current: process (i_CLK, i_RST)
	begin
		if (i_RST = '0') then
			r_core_CURRENT <= Idle;
		elsif (rising_edge(i_CLK)) then
			r_core_CURRENT <= r_core_NEXT;
		end if;
	end process;
	
	u_core_next: process (i_calculating, r_core_CURRENT, r_lnode_counter, r_rnode_counter, i_all_done)
	begin
		case r_core_CURRENT is
			when Idle =>
				if (i_calculating = '1') then
					r_core_NEXT <= Multiplications;
				else
					r_core_NEXT <= Idle;
				end if;
				
			when Multiplications =>
				if (r_lnode_counter = layers_size(i_llayer)) then
					r_core_NEXT <= Bias;
				else
					r_core_NEXT <= Multiplications;
				end if;
				
			when Bias => r_core_NEXT <= Activation;
			when Activation => r_core_NEXT <= Store;
			
			when Store =>
				if (r_rnode_counter >= layers_size(i_rlayer)) then
					r_core_NEXT <= Ended;
				else
					r_core_NEXT <= Multiplications;
				end if;
				
			when Ended =>
				if (i_all_done = '1') then
					r_core_NEXT <= Idle;
				else
					r_core_NEXT <= Ended;
				end if;
			
			when others => r_core_NEXT <= Idle;
			
		end case;
	end process;
	
	u_calc_pos_lnode: NodePos port map (i_llayer, r_lnode_counter, w_lnode_position);
	u_calc_pos_rnode: NodePos port map (i_rlayer, r_rnode_counter, w_rnode_position);
	u_calc_pos_weight: WeightPos port map (
		i_llayer, i_rlayer,
		w_lnode_position, w_rnode_position,
		w_weight_position
	);
	u_activation: ActivationFunction port map (r_calc_res, w_activated);
	
	r_lnode_counter <= 	r_lnode_counter+1 		WHEN r_core_CURRENT = Multiplications	ELSE 
								0								WHEN r_core_CURRENT = Store				ELSE r_lnode_counter;
								
	r_rnode_counter <= 	i_core_num					WHEN r_core_CURRENT = Idle 				ELSE
								r_rnode_counter+N_CORES WHEN r_core_CURRENT = Store				ELSE r_rnode_counter;
	
	
	r_calc_res <= 	r_calc_res + i_Weights(w_weight_position) * io_Nodes(w_lnode_position)
							WHEN r_core_CURRENT = Multiplications ELSE
							
						r_calc_res + i_Weights(w_weight_position)
							WHEN r_core_CURRENT = Bias ELSE
						
						w_activated
							WHEN r_core_CURRENT = Activation ELSE
						
						(others => '0');
						
	io_Nodes(w_rnode_position) <= r_calc_res WHEN r_core_CURRENT = Store ELSE io_Nodes(w_rnode_position);
	
	o_core_done <= '1' WHEN r_core_CURRENT = Ended ELSE '0';
end architecture;
