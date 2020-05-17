---------------------------------------------------------------------------------------------------
--
-- Title       : XOR2
-- Design      : GATE_XOR
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : XOR2.vhd
-- Generated   : Fri Mar 27 13:34:28 2020
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
--{entity {XOR2} architecture {XOR2_ARCH}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity XOR2 is	
	port(A, B: in STD_LOGIC;
			RES: out STD_LOGIC);
end XOR2;

--}} End of automatically maintained section

architecture XOR2_ARCH of XOR2 is
begin
	RES <= A xor B;
end XOR2_ARCH;
