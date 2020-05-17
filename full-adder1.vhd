---------------------------------------------------------------------------------------------------
--
-- Title       : FULL_ADDER1
-- Design      : FULL_ADDER
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : full-adder1.vhd
-- Generated   : Fri Mar 27 13:51:47 2020
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
--{entity {FULL_ADDER1} architecture {FULL_ADDER_ARCH}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FULL_ADDER1 is 
	port(A, B, CIN: in STD_LOGIC;
		RES, COUT: out STD_LOGIC);
end FULL_ADDER1;

--}} End of automatically maintained section

architecture FULL_ADDER_ARCH of FULL_ADDER1 is
begin
	RES <= A xor B xor CIN;
	COUT <= (A and B) or (B and CIN) or (A and CIN);
end FULL_ADDER_ARCH;
