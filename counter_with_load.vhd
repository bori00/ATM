---------------------------------------------------------------------------------------------------
--
-- Title       : index_counter
-- Design      : d_banknotes_eu
-- Author      : q
-- Company     : UTCN
--
---------------------------------------------------------------------------------------------------
--
-- File        : index_counter.vhd
-- Generated   : Wed Apr 15 19:56:12 2020
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
--{entity {index_counter} architecture {a_index_counter}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

entity COUNTER is	   
	generic(WIDTH: integer := 3);
	port(
	CU: in std_logic;		-- count up	   
	LD: in std_logic;
	DATA: in std_logic_vector(WIDTH-1 downto 0);
	RST : in std_logic;	   -- asynchronous reset					
	CLK : in std_logic;
	Q: out std_logic_vector(WIDTH-1 downto 0));
end COUNTER;

-- index counter : direct, synchronous counter	with synchronous reset	and also has a hold function( by desabling CE)

architecture A_COUNTER of COUNTER is 

signal state : std_logic_vector(WIDTH-1 downto 0);  -- 

begin
	
	COUNTER: process(CLK,RST)
	variable intQ : std_logic_vector(WIDTH-1 downto 0);	    
	begin
		if(RST = '1') then
			-- reset index-counter
			for i in WIDTH-1 downto 0 loop
				intQ(i) := '0';
			end loop;
		elsif (CLK'EVENT and CLK = '1') then 
			if(LD = '1') then	  
				-- load
				intQ := DATA;
			elsif (CU = '1') then
				-- count
				intQ := intQ + 1; 
			end if;				
		end if;
		state<= intQ;	-- current state
	Q <= intQ;
	end process;
	
end A_COUNTER;
