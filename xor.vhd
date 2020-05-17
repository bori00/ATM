---------------------------------------------------------------------------------------------------
--
-- Title       : XOR_GATE
-- Design      : GATE_XOR
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : xor.vhd
-- Generated   : Fri Mar 27 13:32:09 2020
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
--{entity {XOR_GATE} architecture {XOR_GATE_ARCH}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity XOR_GATE is	 
	generic (N: natural);
	port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
	REZ: out STD_LOGIC_VECTOR(N-1 downto 0));
end XOR_GATE;

--}} End of automatically maintained section

architecture XOR_GATE_ARCH of XOR_GATE is	
    component XOR2 is
	   port(A, B: in STD_LOGIC;
	   RES: out STD_LOGIC);
	end component;
begin 
		L1: for i in 0 to N-1 generate
			L2: XOR2 port map(A(i), B(i), REZ(i));
		end generate;	
   
end XOR_GATE_ARCH;
