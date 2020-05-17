---------------------------------------------------------------------------------------------------
--
-- Title       : SHIFT_REG_LEFT
-- Design      : SEQUENCE_DETECTOR
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : SHIFT_REG_LEFT.vhd
-- Generated   : Wed Apr  8 16:41:39 2020
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
--{entity {SHIFT_REG_LEFT} architecture {ARCH_SHIFT_REG_LEFT}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SHIFT_REG_LEFT is 
	generic(NO_BITS: natural);
	port(
		CLK, LOAD, SHIFT: in std_logic; 
		D: in std_logic_vector(NO_BITS-1 downto 0); --for load functionality --> has priority over shift functionality
		SIN: in std_logic; --for shift functionality
		Q: out std_logic_vector(NO_BITS-1 downto 0));
end SHIFT_REG_LEFT;


architecture ARCH_SHIFT_REG_LEFT of SHIFT_REG_LEFT is
 begin
	process(CLK) 
		variable internal : std_logic_vector(NO_BITS-1 downto 0);
	begin
		if(CLK'EVENT) and (CLK='1') then
			if(load = '1') then
				INTERNAL := D;
			elsif(shift = '1') then
				for i in NO_BITS-1 downto 1 loop  
					INTERNAL(i) := INTERNAL(i-1);	
				end loop;	     
				INTERNAL(0) := SIN;
			end if;	
			Q <= INTERNAL; 
		end if;	
	end process;	
end ARCH_SHIFT_REG_LEFT;
