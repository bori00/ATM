library ieee;  
use ieee.std_logic_1164.all;  

entity PRIORITY is     
	port(DATA : in std_logic_vector (6 downto 0);  -- priority encoder on activ low logic
        CODE :out std_logic_vector (2 downto 0));  
end PRIORITY ;  

architecture A_PRIORITY of PRIORITY  is  
begin  
	process(DATA) 
	variable intCODE: std_logic_vector(2 downto 0);
	begin			 
		if(DATA(6) = '1') then	
			intCODE := "000";
		elsif(DATA(5) = '1') then
			intCode := "001";
		elsif(DATA(4) = '1') then
			intCode := "010";
		elsif(DATA(3) = '1') then
			intCode := "011";
		elsif(DATA(2) = '1') then
			intCode := "100";
		elsif(DATA(1) = '1') then
			intCode := "101";
		elsif(DATA(0) = '1') then
			intCode := "110";
		end if;			
		CODE <= intCode;			
	 end process;
end A_PRIORITY; 