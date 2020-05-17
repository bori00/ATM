---------------------------------------------------------------------------------------------------
--
-- Title       : ENT_RAM
-- Design      : RAM
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : RAM.vhd
-- Generated   : Tue Mar 17 23:08:20 2020
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
--{entity {ENT_RAM} architecture {ARCH_RAM}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;


entity RAM is
	generic(DATA_WIDTH : natural;
	ADDR_WIDTH : natural);
	port(ADDRESS: in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);  
	RESET: in STD_LOGIC;
	CS_RAM: in STD_LOGIC;
	WE: in STD_LOGIC;
	READ_DATA: out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	WRITE_DATA: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0));
end RAM;

--}} End of automatically maintained section

architecture ARCH_RAM of RAM is	   

function default_entry_from_width(width: natural; value: STD_LOGIC) return std_logic_vector is
    variable return_vector: std_logic_vector(width-1 downto 0);
begin
    for i in return_vector'range loop
        return_vector(i) := value;
    end loop;
    return (return_vector);
end;

type mem is array(0 to 2**ADDR_WIDTH-1) of STD_LOGIC_VECTOR(0 to DATA_WIDTH-1);
signal values : mem; 
begin		
				
	p_ram: process(ADDRESS, WRITE_DATA, CS_RAM, WE, RESET, values)			  
	begin 
		if(RESET='1') then 
				for i in 0 to 2**ADDR_WIDTH-1 loop	
					values(i) <= default_entry_from_width(DATA_WIDTH, '0');
				end loop;	 
				read_data <= default_entry_from_width(DATA_WIDTH, '0');
		elsif(CS_RAM='1') then	
			if(WE='0') then
				READ_DATA <= values(conv_integer(ADDRESS));	
			elsif(WE='1') then
				values(conv_integer(ADDRESS)) <= WRITE_DATA;
				READ_DATA <= WRITE_DATA;
			end if;
		else 
			READ_DATA <= default_entry_from_width(DATA_WIDTH, 'Z');
		end if;	
	end process p_ram;
end ARCH_RAM;