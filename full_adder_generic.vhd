---------------------------------------------------------------------------------------------------
--
-- Title       : FULL_ADDER_N
-- Design      : FULL_ADDER
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : full_adder_generic.vhd
-- Generated   : Fri Mar 27 13:57:08 2020
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
--{entity {FULL_ADDER_N} architecture {FULL_ADDER_N_ARCH}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FULL_ADDER_N is 
	generic(N: natural);
	port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
	CIN: in STD_LOGIC;
	RES: out STD_LOGIC_VECTOR(N-1 downto 0);
	COUT: out STD_LOGIC);
end FULL_ADDER_N;

--}} End of automatically maintained section

architecture FULL_ADDER_N_ARCH of FULL_ADDER_N is 
   component FULL_ADDER1 is 
	port(A, B, CIN: in STD_LOGIC;
		RES, COUT: out STD_LOGIC);
   end component; 
   
   SIGNAL INT: STD_LOGIC_VECTOR(N-2 downto 0);
begin
   L1: for i in 0 to N-1 generate
	  	L2: if i = 0 generate
		   L3: FULL_ADDER1 port map(A(i), B(i), CIN, RES(i), INT(i));
	    end generate;
	   
	   	L4: if(i>0 and i<N-1) generate
		   L5: FULL_ADDER1 port map(A(i), B(i), INT(i-1), RES(i), INT(i));
		end generate;
		
		L6: if(i=N-1) generate
		   L7: FULL_ADDER1 port map(A(i), B(i), INT(i-1), RES(i), COUT);
		end generate;  
	end generate;	
end FULL_ADDER_N_ARCH;
