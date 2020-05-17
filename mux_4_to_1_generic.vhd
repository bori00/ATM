---------------------------------------------------------------------------------------------------
--
-- Title       : MUX_4_to_1_generic
-- Design      : display
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : MUX_4_to_1_generic.vhd
-- Generated   : Wed May 13 02:08:33 2020
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
--{entity {MUX_4_to_1_generic} architecture {ARCH_MUX_4_to_1_generic}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUX_4_to_1_generic is 
	generic(DATA_WIDTH : natural);
	port(SEL: in std_logic_vector(1 downto 0);
	I0, I1, I2, I3: in std_logic_vector(data_width-1 downto 0);  
	Y: out std_logic_vector(data_width-1 downto 0));
end MUX_4_to_1_generic;

--}} End of automatically maintained section

architecture ARCH_MUX_4_to_1_generic of MUX_4_to_1_generic is
begin
 	  y <= i0 when (sel = "00") else
			i1 when (sel = "01") else
			i2 when (sel = "10") else
			i3 when (sel = "11") else
			i0;
       
end ARCH_MUX_4_to_1_generic;
