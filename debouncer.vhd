---------------------------------------------------------------------------------------------------
--
-- Title       : DEBOUNCER
-- Design      : Debouncing
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : Debouncer.vhd
-- Generated   : Sat May  2 22:54:39 2020
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
--{entity {DEBOUNCER} architecture {\DEBOUNCER_\}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Debouncer is
Port (
	btn: in std_logic;
	clk : in std_logic;
	pulse_out : out std_logic);
end Debouncer;
 
architecture Arch_Debouncer of Debouncer is  	
	component D_FF is	
		port(D, CLK: in STD_LOGIC;
		Q: out STD_LOGIC);			
	end component; 	
	
	signal internal1_btn, internal2_btn: std_logic;
begin
	DFF1: D_FF
	port map(D => btn, CLK => clk, Q => internal1_btn); 
	
	DFF2: D_FF
	port map(D => internal1_btn, CLK => clk,  Q => internal2_btn);  	
	
	pulse_out <= internal1_btn and not internal2_btn;
 
end Arch_Debouncer;
