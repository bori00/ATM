---------------------------------------------------------------------------------------------------
--
-- Title       : register
-- Design      : registerD
-- Author      : q
-- Company     : UTCN
--
---------------------------------------------------------------------------------------------------
--
-- File        : register.vhd
-- Generated   : Sat Mar 28 15:03:50 2020
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
--{entity {reg} architecture {a_reg}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity reg is
	generic(N: NATURAL := 2);
	port(Enable: in STD_LOGIC; -- enable register
	LD : in STD_LOGIC; -- load
	CLR : in STD_LOGIC;	-- asynchronous clear
	CLK : in STD_LOGIC; -- clock
	DATA: in STD_LOGIC_VECTOR(N-1 downto 0); -- data loaded
	Q: out STD_LOGIC_VECTOR(N-1 downto 0)); -- output
end reg;


architecture a_reg of reg is	

-- function that loads the register with the values on the DATA input
function load_register(data_width : NATURAL; data : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
 variable reg_Q : STD_LOGIC_VECTOR(data_width-1 downto 0);
 begin
	  for i in data_width-1 downto 0 loop
		 reg_Q(i) := data(i);
	  end loop;
  return reg_Q;
 end; 
 
-- function that resets the register
function reset_register(data_width: NATURAL) return STD_LOGIC_VECTOR is	  
 variable reg_Q : STD_LOGIC_VECTOR(data_width-1 downto 0);
 begin
	for i in data_width-1 downto 0 loop
		reg_Q(i) := '0';
	end loop;
 return reg_Q;
end;   

 
begin
	
GEN_REGISTER : process(CLK,Enable,CLR)

variable intQ : STD_LOGIC_VECTOR(N-1 downto 0);

begin						  
	if (CLR = '1') then
			-- asynchronous clear that doesn't depend on the clock
			intQ := reset_register(N);
	elsif(Enable = '1') then
		-- register is enabled
		if(CLK'EVENT and CLK = '1') then	
			if (LD = '1') then
			-- synchronous load
				intQ := load_register(N, DATA);
			end if;
		end if; 
	end if;
		
	Q <= intQ;
	
end process GEN_REGISTER;

end a_reg;
