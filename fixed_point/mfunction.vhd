library ieee;
use ieee.std_logic_1164.all;

library work;
use work.cnn_package.all;
use work.slogic_package.all;

entity mfunction is 
  generic (
    COEFS : t_COEFS
  );
  port (
    i_X : in slogic;
	 o_Y : out slogic
  );
end entity;

architecture arch of mfunction is
  signal w_M2 : slogic;
  signal w_M1 : slogic;
begin
  w_M2 <= COEFS(2)*i_X*i_X;
  w_M1 <= COEFS(1)*i_X;
  o_Y <=  w_M2 + w_M1 + COEFS(0);
end architecture;


