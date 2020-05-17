---------------------------------------------------------------------------------------------------
--
-- Title       : JK_FF
-- Design      : d_banknotes_eu
-- Author      : q
-- Company     : UTCN
--
---------------------------------------------------------------------------------------------------
--
-- File        : flar_reg.vhd
-- Generated   : Wed Apr 22 07:55:20 2020
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
--{entity {JK_FF} architecture {A_JK_FF}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity JK_FF is
	port(J,K: in std_logic;
	S,R: in std_logic; -- asynchronous set,reset   on activ high
	CLK: in std_logic;
	Q, nQ: out std_logic);
end JK_FF;


architecture A_JK_FF of JK_FF is
begin

	process(CLK,S,R)
	variable intQ,state : std_logic;
	begin			 		
		if(S = '1') then
			intQ:= '1';	 
		elsif (R = '1') then
			intQ := '0';
		elsif (CLK'EVENT and CLK = '1') then
			if(J = '0' and K = '0') then
				intQ := state;
			elsif (J = '1' and K = '0') then
				intQ := '1';
			elsif (J = '0' and K = '1') then
				intQ := '0'; 
			elsif (J = '1' and K = '1') then
				intQ := not state;
			end if;
		end if;
		state := intQ;
	Q <= intQ;
	nQ <= not intQ;
	end process;

end A_JK_FF;
