---------------------------------------------------------------------------------------------------
--
-- Title       : banknotes_ram
-- Design      : d_banknotes_eu
-- Author      : q
-- Company     : UTCN
--
---------------------------------------------------------------------------------------------------
--
-- File        : BANKNOTES_RAM.vhd
-- Generated   : Wed Apr 15 18:01:12 2020
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
--{entity {banknotes_ram} architecture {a_banknotes_ram}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_UNSIGNED.all;
library work;


entity BANKNOTES_RAM is
	port(CS: in std_logic; -- select ram
	WE : in std_logic; -- enable write
	RESET: in std_logic;
	ADDRESS: in std_logic_vector (2 downto 0);  
	READ_NUMBER, READ_VALUE: out std_logic_vector(9 downto 0);	 
	WRITE_NUMBER: in std_logic_vector(9 downto 0));-- write the new number of baknotes of given type  
end BANKNOTES_RAM;

architecture A_BANKNOTES_RAM of BANKNOTES_RAM is

type mem is array(0 to 7) of std_logic_vector(9 downto 0);
signal numbers, values : mem; 												   

	function initialize_banknote_number return mem is
	
	constant c_number : mem := (0 => "0001100100", 1 => "0001100100", 2 => "0001100100", 3 => "0001100100", 4 => "0001100100", 5 => "0001100100", 6 => "0001100100", others => "ZZZZZZZZZZ");
	variable return_number: mem;     
	begin	 
		for i in 0 to 6 loop
	    	return_number(i) := c_number(i);
		end loop;
	    return return_number;
	end;
	
	 function initialize_banknote_value return mem is
	constant c_value: mem := (0 => "0111110100", 1 => "0011001000", 2 => "0001100100", 3 =>  "0000110010", 4 => "0000010100", 5 => "0000001010", 6 => "0000000101", others => "0000000000");
	variable return_number, return_value: mem;
	begin	  
		for i in 0 to 6 loop
			return_value(i) := c_value(i);
		end loop; 
	    return return_value;
	end; 
	
begin												  
	
	-- ram process			
	p_ram: process(CS, WE, RESET, ADDRESS, WRITE_NUMBER)	
	
	constant c_UNDEFINED_BANKNOTE: std_logic_vector(9 downto 0) := "ZZZZZZZZZZ";
	begin  
		if(RESET = '1') then 	
				-- load memory with initial values 
				numbers <= initialize_banknote_number;	
				values <= initialize_banknote_value;	
				READ_NUMBER <= c_UNDEFINED_BANKNOTE;
				READ_VALUE <= c_UNDEFINED_BANKNOTE;
		elsif (CS = '1') then
			if (WE = '0') then
					-- read data from memory
					READ_VALUE <= values(conv_integer(ADDRESS));	
					READ_NUMBER <= numbers(conv_integer(ADDRESS));	
					else
						-- write new value in memory						  
						numbers(conv_integer(ADDRESS))<= WRITE_NUMBER;
						READ_NUMBER <= WRITE_NUMBER;	
			end if;
		else
				READ_NUMBER <= c_UNDEFINED_BANKNOTE;
				READ_VALUE <= c_UNDEFINED_BANKNOTE;
		end if;											
		
	end process p_ram;
end A_BANKNOTES_RAM;



