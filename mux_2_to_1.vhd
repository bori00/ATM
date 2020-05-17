---------------------------------------------------------------------------------------------------
--
-- Title       : mux2to1
-- Design      : registerD
-- Author      : q
-- Company     : UTCN
--
---------------------------------------------------------------------------------------------------
--
-- File        : mux_2_to_1.vhd
-- Generated   : Sat Mar 28 19:31:11 2020
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
--{entity {mux2to1} architecture {a_mux2to1}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUX_2_1 is 	
	generic(N : natural := 10);
	port(SEL : in std_logic;
	I0, I1 : in std_logic_vector(N-1 downto 0);
	Y : out std_logic_vector(N-1 downto 0));
end MUX_2_1;

architecture A_MUX_2_1 of MUX_2_1 is

-- function that sets the output to high impedance, when the wrong selection input was entered
function wrong_sel(DATA_WIDTH : natural) return std_logic_vector is
variable intY :	std_logic_vector(N-1 downto 0);
begin
	for i in DATA_WIDTH-1 to 0 loop
		intY(i) := 'Z';
	end loop;
	return intY;
end;

begin			
	
   MUX: process(SEL,I0,I1) 
   begin
	case SEL is
		when '0' => Y <= I0;
		when '1' => Y <= I1;
		when others => Y <= wrong_sel(N);
	end case;
	end process MUX;

end A_MUX_2_1;
