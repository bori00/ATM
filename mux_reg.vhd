---------------------------------------------------------------------------------------------------
--
-- Title       : mux_reg
-- Design      : registerD
-- Author      : q
-- Company     : UTCN
--
---------------------------------------------------------------------------------------------------
--
-- File        : mux_reg.vhd
-- Generated   : Sat Mar 28 20:02:44 2020
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
--{entity {mux_reg} architecture {a_mux_reg}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;  

-- a memory register that can loaded with data from a 2:1 mux

entity MUX_REG is 
	generic(N: natural := 10);
	port(ENABLE: in std_logic; -- shift
	LD : in std_logic; -- load	 
	WS : in std_logic; -- selects the input to be loaded
	CLR : in std_logic;	-- asynchronous clear
	CLK : in std_logic; -- clock
	DATA0: in std_logic_vector(N-1 downto 0); -- data0 to be loaded loaded
	DATA1: in std_logic_vector(N-1 downto 0); -- data1 to be loaded loaded
	Q: out std_logic_vector(N-1 downto 0)); -- output
end MUX_REG;

--}} End of automatically maintained section

architecture A_MUX_REG of MUX_REG is 

component MUX_2_1 is
	generic(N : natural := 10);
	port(SEL : in std_logic;
	I0, I1 : in std_logic_vector(N-1 downto 0);
	Y : out std_logic_vector(N-1 downto 0));
end component;

for all : MUX_2_1 use entity work.MUX_2_1(A_MUX_2_1);

component REG is
	generic(N: natural);
	port(ENABLE: in std_logic;
	LD : in std_logic; -- load
	CLR : in std_logic;	-- asynchronous clear
	CLK : in std_logic; -- clock
	DATA: in std_logic_vector(N-1 downto 0); -- data to be loaded loaded
	Q: out std_logic_vector(N-1 downto 0)); -- output
end component REG;

for all : REG use entity work.REG(A_REG);
	
signal intDATA : std_logic_vector(N-1 downto 0);  

begin

	MUX_PART : MUX_2_1 generic map(N) port map(WS, DATA0, DATA1, intDATA);
	REGISTER_PART : reg generic map(N) port map(ENABLE, LD, CLR, CLK, intDATA, Q);
	
end A_MUX_REG;
