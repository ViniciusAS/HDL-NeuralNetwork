library IEEE;
use IEEE.std_logic_1164.all;

library Work;
use Work.slogic_package.all;
use Work.NetworkConstants.all;
use Work.Utils.and_reducer;
use Work.InterLayerCore;

entity InterLayer is
	port(
		i_CLK: in std_logic;
		i_RST: in std_logic;
	
		io_Nodes: inout Nodes;
		i_Weights: in Weights;
		
		i_Calculate: in std_logic;
		
		i_llayer: in LAYER_COUNTER;
		i_rlayer: in LAYER_COUNTER;
		
		o_done: out std_logic
	);
end entity;

architecture il1 of InterLayer is
	type t_STATE is (Waiting, Calculating, Done);
	signal r_CURRENT, r_NEXT: t_STATE;
	
	signal r_each_core_done: std_logic_vector(N_CORES-1 downto 0) := (others => '0');
	signal w_all_done: std_logic;
	
	signal w_calculating: std_logic;
begin	
	u_interlayer_current: process (i_CLK, i_RST)
	begin
		if (i_RST = '0') then
			r_CURRENT <= Waiting;
		elsif (rising_edge(i_CLK)) then
			r_CURRENT <= r_NEXT;
		end if;
	end process;
	
	u_interlayer_next: process(r_CURRENT, i_calculate)
	begin
		case r_CURRENT is
			when Waiting     => if (i_calculate = '1') then r_NEXT <= Calculating; else r_NEXT <= Waiting;     end if;
			when Calculating => if (w_all_done  = '1') then r_NEXT <= Done; 	     else r_NEXT <= Calculating; end if;
			when Done        => if (i_calculate = '0') then r_NEXT <= Waiting;     else r_NEXT <= Done;        end if;
			when Others	     => r_NEXT <= Waiting;
		end case;
	end process;
	
	w_calculating <= '1' WHEN r_CURRENT = Calculating ELSE '0';
	
	w_all_done <= and_reducer(r_each_core_done);
	o_done <= '1' WHEN w_all_done = '1' and r_CURRENT = Done ELSE '0';
	
	u_cores: for it_core in 0 to N_CORES-1 generate
		u_interlayer_core: InterLayerCore port map(
			i_CLK, i_RST,
		
			it_core,
		
			io_Nodes, i_Weights,
			
			w_Calculating,
			
			i_llayer, i_rlayer,
			
			w_all_done,
			r_each_core_done(it_core)
		);
	end generate;
	
end architecture;
