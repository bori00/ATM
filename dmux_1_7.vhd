library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity DMUX_1_7 is
	port(SEL : in std_logic_vector(2 downto 0);
	I: in std_logic;
	Y0,Y1,Y2,Y3,Y4,Y5,Y6: out std_logic);
end DMUX_1_7;

architecture A_DMUX_1_7 of DMUX_1_7 is
begin
	process(SEL,I)
	begin 
		case SEL is
			when "000" => Y0 <= I; Y1 <= '0'; Y2 <= '0'; Y3 <= '0'; Y4 <= '0'; Y5 <= '0'; Y6 <= '0'; 
			when "001" => Y1 <= I; Y0 <= '0'; Y2 <= '0'; Y3 <= '0'; Y4 <= '0'; Y5 <= '0'; Y6 <= '0'; 
			when "010" => Y2 <= I; Y0 <= '0'; Y1 <= '0'; Y3 <= '0'; Y4 <= '0'; Y5 <= '0'; Y6 <= '0'; 
			when "011" => Y3 <= I; Y0 <= '0'; Y1 <= '0'; Y2 <= '0'; Y4 <= '0'; Y5 <= '0'; Y6 <= '0'; 
			when "100" => Y4 <= I; Y0 <= '0'; Y1 <= '0'; Y2 <= '0'; Y3 <= '0'; Y5 <= '0'; Y6 <= '0'; 
			when "101" => Y5 <= I; Y0 <= '0'; Y1 <= '0'; Y2 <= '0'; Y3 <= '0'; Y4 <= '0'; Y6 <= '0'; 
			when "110" => Y6 <= I; Y0 <= '0'; Y1 <= '0'; Y2 <= '0'; Y3 <= '0'; Y4 <= '0'; Y5 <= '0';
			when others => report "error";
		end case;
	end process;
	
end A_DMUX_1_7;


	