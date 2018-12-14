library Work;
use Work.slogic_package.all;

entity ActivationFunction is
	port(
		i_X: in slogic;
		o_Y: out slogic
	);
end entity;

architecture archReLU of ActivationFunction is
begin
	o_Y <= i_X when i_X > x"00000" else (others => '0');
end architecture;
