---------------------------------------------------------------------------------------------------
--
-- Title       : D_FF
-- Design      : D_FF
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : D_FF.vhd
-- Generated   : Wed Apr  1 16:22:20 2020
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
--{entity {D_FF} architecture {D_FF}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity D_FF is	
	port(D, CLK: in STD_LOGIC;
	Q: out STD_LOGIC);			
end D_FF;

--}} End of automatically maintained section

architecture ARCH_D_FF of D_FF is
begin
   process(CLK)
   begin
	   if(CLK='1') and (CLK'EVENT) then
		   Q <= D;
	   end if;
	end process;	   
end ARCH_D_FF;
