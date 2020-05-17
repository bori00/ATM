---------------------------------------------------------------------------------------------------
--
-- Title       : ADDER_SUBTRACTOR
-- Design      : ADDER_SUBTRACTOR
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : ADDER_SUBTRACTOR.vhd
-- Generated   : Fri Mar 27 14:31:25 2020
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.20
--
---------------------------------------------------------------------------------------------------
--
-- Description : 
--
---------------------------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {ADDER_SUBTRACTOR} architecture {ADDER_SUBTRACTOR_ARCH}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;	

--!!! can only perform addition/subtraction on positive values with positive results in unsigned binary format. no Carry Out is provided(it's not needed)

entity ADDER_SUBTRACTOR is	
	generic(N : natural);
	port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0); --positive numbers --> stored in unsigned format
	MODE: in STD_LOGIC; --1 is subtract, 1 if add
	RES: out STD_LOGIC_VECTOR(N-1 downto 0));  --positive number --> stored in unsigned format);
end ADDER_SUBTRACTOR;

--}} End of automatically maintained section

architecture ADDER_SUBTRACTOR_ARCH of ADDER_SUBTRACTOR is		
	component XOR_GATE is	 
		generic (N: natural);
		port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
		REZ: out STD_LOGIC_VECTOR(N-1 downto 0));
	end component; 
	
	component FULL_ADDER_N is 
		generic(N: natural);
		port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
		CIN: in STD_LOGIC;
		RES: out STD_LOGIC_VECTOR(N-1 downto 0);
		COUT: out STD_LOGIC);
	end component;	 
	
	--given that the adder-subtractor works in C2 format, I need to add a 0 bit to A and a MODE bit to B
	
	SIGNAL EXTENDED_A : STD_LOGIC_VECTOR(N downto 0);
	SIGNAL EXTENDED_B : STD_LOGIC_VECTOR(N downto 0);	
	SIGNAL EXTENDED_RES : STD_LOGIC_VECTOR(N downto 0);
	SIGNAL MODE_VECTOR : STD_LOGIC_VECTOR(N downto 0); --used for XOR-ing B
	SIGNAL INT_B : STD_LOGIC_VECTOR(N downto 0);   --the negated/unchanged B, depending on the mode	 
	SIGNAL UNUSED_COUT :STD_LOGIC;
begin	
	
	Extend_A : process(A)
	begin
		for i in 0 to N-1 loop
			EXTENDED_A(i) <= A(i);
		end loop;
		EXTENDED_A(N) <= '0';  
	end process;  
	
	Extend_B : process(B, MODE)
	begin
		for i in 0 to N-1 loop
			EXTENDED_B(i) <= B(i);
		end loop;
		EXTENDED_B(N) <= MODE; --sign extension  
	end process;
	
	
	
	process(MODE) 
	begin
		for i in 0 to N loop
			MODE_VECTOR(i) <= MODE;
		end loop;  
		EXTENDED_B(N) <= MODE;
	end process;	
	
	process(EXTENDED_RES) 
	begin
		for i in 0 to N-1 loop
			RES(i) <= EXTENDED_RES(i);
		end loop;  
	end process;	
	
	C1: XOR_GATE 
		generic map(N+1)
		port map(EXTENDED_B, MODE_VECTOR,INT_B); 
		
	C2: FULL_ADDER_N
		generic map(N+1)
		port map(EXTENDED_A, INT_B, MODE, EXTENDED_RES, UNUSED_COUT);	

end ADDER_SUBTRACTOR_ARCH;
