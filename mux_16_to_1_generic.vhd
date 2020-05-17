---------------------------------------------------------------------------------------------------
--
-- Title       : MUX_16_to_1
-- Design      : DISPLAY
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : MUX_16_to_1.vhd
-- Generated   : Wed May 13 01:33:18 2020
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
--{entity {MUX_16_to_1} architecture {ARCH_MUX_16_to_1}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUX_16_to_1_generic is 
	generic(DATA_WIDTH : natural);
	port(SEL: in std_logic_vector(3 downto 0);
	I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15: in std_logic_vector(data_width-1 downto 0);  
	Y: out std_logic_vector(data_width-1 downto 0));
end MUX_16_to_1_generic;

--}} End of automatically maintained section

architecture ARCH_MUX_16_to_1_generic of MUX_16_to_1_generic is
begin
 	  y <= i0 when (sel = "0000") else
			i1 when (sel = "0001") else
			i2 when (sel = "0010") else
			i3 when (sel = "0011") else
			i4 when (sel = "0100") else
			i5 when (sel = "0101") else
			i6 when (sel = "0110") else
			i7 when (sel = "0111") else
			i8 when (sel = "1000") else
			i9 when (sel = "1001") else
			i10 when (sel = "1010") else
			i11 when (sel = "1011") else
			i12 when (sel = "1100") else
			i13 when (sel = "1101") else
			i14 when (sel = "1110") else
			i15 when (sel = "1111") else
			i0;
       
end ARCH_MUX_16_to_1_generic;
