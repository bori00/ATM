library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity MUX_BANKNOTES is
	port(I: in std_logic_vector(2 downto 0); -- index (selections)
	BANKNOTES_500, BANKNOTES_200, BANKNOTES_100, BANKNOTES_50, BANKNOTES_20, BANKNOTES_10, BANKNOTES_5: in std_logic_vector(9 downto 0);
	BANKNOTE_NR: out std_logic_vector(9 downto 0);
	BANKNOTE_VAL: out std_Logic_vector(13 downto 0));
end MUX_BANKNOTES;

architecture A_MUX_BANKNOTES of MUX_BANKNOTES is

begin
	
	process(I,BANKNOTES_500, BANKNOTES_200, BANKNOTES_100, BANKNOTES_50, BANKNOTES_20, BANKNOTES_10, BANKNOTES_5)		  
	variable number: std_logic_vector(9 downto 0);
	variable value:	std_logic_vector(13 downto 0); 
	begin										   
		value(13 downto 10) := "0000";
		case I is
			when "000" => number := BANKNOTES_500; value(9 downto 0):= "0111110100";	-- 500
			when "001" => number := BANKNOTES_200; value(9 downto 0):= "0011001000";	-- 200
			when "010" => number := BANKNOTES_100; value(9 downto 0):= "0001100100";	-- 100
			when "011" => number := BANKNOTES_50; value(9 downto 0):= "0000110010";	    -- 50
			when "100" => number := BANKNOTES_20; value(9 downto 0):= "0000010100";	    -- 20
			when "101" => number := BANKNOTES_10; value(9 downto 0):= "0000001010";	    -- 10
			when "110" => number := BANKNOTES_5; value(9 downto 0):= "0000000101";	    -- 5
			when others => number := "ZZZZZZZZZZ";value(9 downto 0):= "0000000000";	
		end case;																 
		BANKNOTE_NR <= number;
		BANKNOTE_VAL <= value;
	end process;
	
end A_MUX_BANKNOTES;

	
	