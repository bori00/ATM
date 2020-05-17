
library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity counter_with_hold is
	generic(width: INTEGER := 3);
	port(CLK, RST, HOLD: in STD_LOGIC;
	Q: out std_logic_vector(width-1 downto 0));
end counter_with_hold;

architecture arch_counter_with_hold of counter_with_hold is	
	component FULL_ADDER_N is 
		generic(N: natural);
		port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
		CIN: in STD_LOGIC;
		RES: out STD_LOGIC_VECTOR(N-1 downto 0);
		COUT: out STD_LOGIC);
	end component;

	Signal int_q, next_q, number_0: std_logic_vector(width-1 downto 0);	   
	Signal random: std_logic;
begin	
	q <= int_q;
	
	COUNT: process(CLK, RST) 
	begin	
		if(RST = '1') then
			int_q <= number_0;
		elsif (CLK'EVENT and CLK = '1' and hold='0') then 
			int_q <= next_q;	
		end if;					  
	end process;  	 
	
	
	--extend number_0
	process(clk)
	begin
		for i in 0 to width-1 loop
			number_0(i) <= '0';
		end loop;
	end process;	
	
	
	--add 1 to state
	NEXT_STATE: FULL_ADDER_N 
		generic map(N => width)
		port map(A => int_q,  B => number_0,
		CIN => '1',
		RES => next_q,
		COUT => random);
end arch_counter_with_hold;