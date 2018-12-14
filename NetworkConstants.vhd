library Work;
use Work.slogic_package.all;

package NetworkConstants is
	
	type LAYERS_DATA is array(natural range<>) of integer;
	
	constant layers_size : LAYERS_DATA := (
		40,
		30,
		20
	);
	
	constant N_CORES: integer := 20;
	
	function max_layer    (layers_size: LAYERS_DATA) return integer;
	function count_nodes  (layers_size: LAYERS_DATA) return integer;
	function count_weights(layers_size: LAYERS_DATA) return integer;
	function setup_layers_offset(layers_size: LAYERS_DATA) return LAYERS_DATA;
	
	constant layers_offset: LAYERS_DATA := setup_layers_offset(layers_size);

	type Nodes
		is array(count_nodes(layers_size) downto 0)
		of slogic;
	
	type Weights
		is array(count_weights(layers_size) downto 0)
		of slogic;
	
	subtype LAYER_COUNTER is integer range layers_size'length       downto 0;
	subtype NODE_COUNTER  is integer range max_layer(layers_size)+1 downto 0;
	
	subtype NODE_POSITION   is integer range count_nodes  (layers_size)+1 downto 0;
	subtype WEIGHT_POSITION is integer range count_weights(layers_size)   downto 0;
	
end NetworkConstants;

package body NetworkConstants is
	
	
	-- count number of NODES
	function count_nodes(layers_size: LAYERS_DATA) return integer is
		variable counter: integer;
   begin
		counter := 0;
      for i in 0 to layers_size'length-1 loop
			counter := counter + layers_size(i);
      end loop;
		report "Number of Nodes: " & integer'image(counter);
      return counter;
	end function;
	
	
	-- count number of WEIGHTS
   function count_weights(layers_size: LAYERS_DATA) return integer is
		variable counter: integer;
	begin
		counter := 0;
      for i in 0 to layers_size'length-2 loop
			counter := counter + layers_size(i) * (layers_size(i+1) + 1);
      end loop;
		report "Number of Weights: " & integer'image(counter);
      return counter;
	end function;
	
	
	-- maximum layer size
	function max_layer(layers_size: LAYERS_DATA) return integer is
		variable max: integer;
   begin
		max := 0;
      for i in 0 to layers_size'length-1 loop
			if layers_size(i) > max then
				max := layers_size(i);
			end if;
      end loop;
		report "Maximum layer size: " & integer'image(max);
      return max;
	end function;
	
	
	-- setup layers offset
	function setup_layers_offset(layers_size: LAYERS_DATA) return LAYERS_DATA is
		variable layers_offset: LAYERS_DATA(layers_size'length downto 0);
   begin
		report "Number of Layers: " & integer'image(layers_size'length);
      for i in 0 to layers_size'length-1 loop
			layers_offset(i) := 0;
			for j in 0 to i loop
				layers_offset(i) := layers_offset(i) + layers_size(j);
			end loop;
			report "Layer "        & integer'image(i)
				  & " starting at " & integer'image(layers_offset(i));
      end loop;
      return layers_offset;
	end function;
	
end package body;
