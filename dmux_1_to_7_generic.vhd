library IEEE;
use IEEE.STD_LOGIC_1164.all;  

entity MUX_ARRAY is
	port (ENABLE: in std_logic;	 
	SEL: in std_logic_vector(2 downto 0);
	I: in std_logic_vector(9 downto 0);
	Y0,Y1,Y2,Y3,Y4,Y5,Y6: out std_logic_vector(9 downto 0));
end MUX_ARRAY;

architecture A_MUX_ARRAY of MUX_ARRAY is

begin
	
	process(ENABLE,SEL,I)
	begin	  
		if(ENABLE = '1') then
		case SEL is 
			when "000" => Y0 <= I;
			when "001" => Y1 <= I;
			when "010" => Y2 <= I;
			when "011" => Y3 <= I;
			when "100" => Y4 <= I;
			when "101" => Y5 <= I;
			when "110" => Y6 <= I;
			when others => report "invalid index";
		end case; 
		end if;
	end process;

end A_MUX_ARRAY;
