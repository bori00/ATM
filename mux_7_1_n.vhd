library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUX_7_1 is		
	port(SEL : in std_logic_vector(2 downto 0);
	I0,I1,I2,I3,I4,I5,I6: in std_logic_vector(9 downto 0);
	Y: out std_logic_vector(9 downto 0));
end MUX_7_1;

architecture A_MUX_7_1 of MUX_7_1 is
begin
	process(SEL,I0,I1,I2,I3,I4,I5,I6) 
	begin
		case SEL is
			when "000" => Y <= I0;
			when "001" => Y <= I1;
			when "010" => Y <= I2;
			when "011" => Y <= I3;
			when "100" => Y <= I4;
			when "101" => Y <= I5;
			when "110" => Y <= I6;
			when others => report "error";
		end case;
	end process;
	
end A_MUX_7_1;


	