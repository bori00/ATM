---------------------------------------------------------------------------------------------------
--
-- Title       : CMP
-- Design      : CMP
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : Comparator.vhd
-- Generated   : Fri Mar 27 12:45:59 2020
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
--{entity {CMP} architecture {CMP_ARCH}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;   

--changed comparator

entity CMP is  
	generic (N: natural);
	port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
	EQUAL: out STD_LOGIC;
	GREATER: out STD_LOGIC;
	SMALLER: out STD_LOGIC);
end CMP;

--}} End of automatically maintained section

architecture CMP_ARCH of CMP is
begin
	process(A, B)
	variable foundDifference : STD_LOGIC := '0';
	variable i : integer :=N-1;
	begin
		i := N-1;  
		foundDifference := '0';
		while(i>=0 and foundDifference='0') loop 
			if (A(i)='1' and B(i)='0') then 
				foundDifference := '1'; 
				GREATER <= '1';
				SMALLER <= '0';
				EQUAL <= '0';
			elsif(A(i)='0' and B(i)='1')then
				foundDifference := '1'; 
				GREATER <= '0';
				SMALLER <= '1';
				EQUAL <= '0';
			elsif((A(i)/='1' and A(i)/='0') or (B(i)/='1' and B(i)/='0')) then
				foundDifference := '1';
				GREATER <= '0';
				SMALLER <= '0';
				EQUAL <= '0';
			end if;	
			i := i - 1;
		end loop;
		if(foundDifference='0') then 
			GREATER <= '0';
			SMALLER <= '0';
			EQUAL <= '1';
		end if;	
	end process;
end CMP_ARCH;
