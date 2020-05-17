---------------------------------------------------------------------------------------------------
--
-- Title       : CONVERTER_bin_to_bcd
-- Design      : CONVERTER_binary_to_bcd
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : CONVERTER_bin_to_bcd.vhd
-- Generated   : Fri Apr 24 13:34:10 2020
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
--{entity {CONVERTER_bin_to_bcd} architecture {ARCH_CONVERTER_bin_to_bcd}} 
	
	--should be slowed down

library IEEE;
use IEEE.STD_LOGIC_1164.all;   
use IEEE.STD_LOGIC_unsigned.all;   
USE ieee.numeric_std.all;

entity CONVERTER_bcd_to_bin is	 
	port(clk: in std_logic;
	bin_number: out std_logic_vector(13 downto 0);
	bcd_number: in std_logic_vector(15 downto 0));
end CONVERTER_bcd_to_bin;

--}} End of automatically maintained section

architecture ARCH_CONVERTER_bcd_to_bin of CONVERTER_bcd_to_bin is  
	component SHIFT_REG_RIGHT is 
	generic(NO_BITS: natural);
	port(
		CLK, LOAD, SHIFT: in std_logic; 
		D: in std_logic_vector(NO_BITS-1 downto 0); --for load functionality
		SIN: in std_logic; --for shift functionality --> default
		Q: out std_logic_vector(NO_BITS-1 downto 0));
	end component;
	
	component CMP is  
		generic (N: natural);
		port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
		EQUAL: out STD_LOGIC;
		GREATER: out STD_LOGIC;
		SMALLER: out STD_LOGIC);
	end component;
	
	component MUX_2_1 is 	
		generic(N : natural);
		port(SEL : in std_logic;
		I0, I1 : in std_logic_vector(N-1 downto 0);
		Y : out std_logic_vector(N-1 downto 0));
	end component;
	
	component FULL_ADDER_N is 
		generic(N: natural);
		port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
		CIN: in STD_LOGIC;
		RES: out STD_LOGIC_VECTOR(N-1 downto 0);
		COUT: out STD_LOGIC);
	end component;	
	
	component ADDER_SUBTRACTOR is	
		generic(N : natural :=3);
		port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0); --positive numbers --> stored in unsigned format
		MODE: in STD_LOGIC; --1 is subtract, 1 if add
		RES: out STD_LOGIC_VECTOR(N-1 downto 0));  --positive number --> stored in unsigned format);
	end component;
	
	component counter_with_hold is
		generic(width: INTEGER);
		port(CLK, RST, HOLD: in STD_LOGIC;
		Q: out std_logic_vector(width-1 downto 0));
	end component;
	
	component D_FF is	
		port(D, CLK: in STD_LOGIC;
		Q: out STD_LOGIC);			
	end component;	
	
	component clk_div is
		generic(width: INTEGER);
		port(RST: in STD_LOGIC;
		CLK_IN: in STD_LOGIC;
		CLK_OUT: out STD_LOGIC);
	end component;	
	
	Signal int_bin_number, prev_bcd_number, bcd_register_number: std_logic_vector(15 downto 0);	
	Signal state: std_logic_vector(4 downto 0); --max state is 16
	Signal bcd_number_to_load, bcd_reg_number_adjusted_to_load: std_logic_vector(15 downto 0);
	Signal load_registerBIN, load_registerBCD, shift_registers: std_logic;		 
	Signal restart, adjusting, shifting, adjusted_recently: std_logic;
	Signal digit1, digit2, digit3, digit4 : integer range 0 to 15; 
	Signal random, equal_prevNumber: std_logic;
	Constant seven_digit: std_logic_vector(3 downto 0) := "0111";  
	Constant three_digit: std_logic_vector(3 downto 0) := "0011";  
	Constant sixteen_number:std_logic_vector(4 downto 0) := "10000";
	Signal digit1_greater, digit2_greater, digit3_greater, digit4_greater : std_logic;	 --must be >= 8 ==> I compare with 7 instead
	Signal digit1_minus3, digit2_minus3, digit3_minus3, digit4_minus3: std_logic_vector(3 downto 0);  
	Signal digit1_toLoad, digit2_toLoad, digit3_toLoad, digit4_toLoad:std_logic_vector(3 downto 0);	
	Signal equal_state_16, equal_state_0, hold_state: std_logic; 
	Signal clk_slow: std_logic;
begin 	 
	bin_number <= int_bin_number(13 downto 0);
		

	restart <= not equal_prevNumber; --if the bcd number has changed, I need to restart 
	adjusting <= (digit1_greater or digit2_greater or digit3_greater or digit4_greater) and (not adjusted_recently) and (not restart) and (not equal_state_16) and (not equal_state_0); -- and (state<16);
	shift_registers <= (not restart) and (not adjusting) and (not equal_state_16); 
	load_registerBCD <= adjusting or restart;
	load_registerBIN <= restart; 
	
	--------------------slow down--------------------- 
	
--	SLOW_DOWN: clk_div
--		generic map(width => 8)
--		port map(RST => '0',
--		CLK_IN => clk,
--		CLK_OUT => clk_slow);	

	clk_slow <= clk;

	
	----------------------state counters-------------------	  
	
	hold_state <= equal_state_16 or adjusting;
	
	STATE_COUNTER: counter_with_hold
		generic map(width => 5)
		port map(CLK => clk_slow, RST => restart, HOLD => hold_state, Q => state);
	
	Compare_State_To_16: CMP  
		generic map(N => 5)
		port map(A => state,
		B => sixteen_number,
		EQUAL => equal_state_16,
		GREATER => random,
		SMALLER => random);
		
	Compare_State_To_0: CMP  
		generic map(N => 5)
		port map(A => state,
		B => "00000",
		EQUAL => equal_state_0,
		GREATER => random,
		SMALLER => random);	
		
	----------------Adjusted recently FF-----------------
	
	Adjusted_recently_ff: D_FF	
		port map(D => adjusting,  CLK => clk_slow, Q => adjusted_recently);			
	
	------registers for the binary and the bcd number-----
	
	BIN_REG: SHIFT_REG_RIGHT
		generic map(NO_BITS => 16)	 
		port map(CLK => CLK_slow, LOAD => load_registerBIN, SHIFT => shift_registers, D => "0000000000000000", SIN => bcd_register_number(0), Q => int_bin_number); 
		
	BCD_REG: SHIFT_REG_RIGHT		
		generic map(NO_BITS => 16)	 
		port map(CLK => CLK_slow, LOAD => load_registerBCD, SHIFT => shift_registers, D => bcd_number_to_load, SIN => '0', Q => bcd_register_number); 	 
		
	PREV_BCD_REG: SHIFT_REG_RIGHT		
		generic map(NO_BITS => 16)	 
		port map(CLK => CLK_slow, LOAD => '1', SHIFT => '0', D => bcd_number, SIN => '0', Q => prev_bcd_number); 
		
	----------------check if restart needed-----------------
		
	Compare_Previous_BCD: CMP  
		generic map(N => 16)
		port map(A => bcd_number,
		B => prev_bcd_number,
		EQUAL => equal_prevNumber,
		GREATER => random,
		SMALLER => random);		
		
	------------------------digit1--------------------------
		
	Compare_Digit1: CMP  
		generic map(N => 4)
		port map(A => bcd_register_number(3 downto 0),
		B => seven_digit,
		EQUAL => random,
		GREATER => digit1_greater,
		SMALLER => random);	
		
	Digit1_Subtract3: ADDER_SUBTRACTOR	
		generic map(N => 4)
		port map(A => bcd_register_number(3 downto 0),
		B => three_digit,
		MODE => '1',
		RES => digit1_minus3);  --positive number --> stored in unsigned format);
		
	Define_Digit1: MUX_2_1	
		generic map(N => 4)
		port map(SEL => digit1_greater,
		I0 => bcd_register_number(3 downto 0),
		I1 => digit1_minus3,
		Y => digit1_toLoad); 
	
	------------------------digit2------------------------
		
	Compare_Digit2: CMP  
		generic map(N => 4)
		port map(A => bcd_register_number(7 downto 4),
		B => seven_digit,
		EQUAL => random,
		GREATER => digit2_greater,
		SMALLER => random);	
		
	Digit2_Subtract3: ADDER_SUBTRACTOR	
		generic map(N => 4)
		port map(A => bcd_register_number(7 downto 4),
		B => three_digit,
		MODE => '1',
		RES => digit2_minus3);  --positive number --> stored in unsigned format);
		
	Define_Digit2: MUX_2_1 	
		generic map(N => 4)
		port map(SEL => digit2_greater,
		I0 => bcd_register_number(7 downto 4),
		I1 => digit2_minus3,
		Y => digit2_toLoad);
		
	------------------------digit3--------------------------	
		
	Compare_Digit3: CMP  
		generic map(N => 4)
		port map(A => bcd_register_number(11 downto 8),
		B => seven_digit,
		EQUAL => random,
		GREATER => digit3_greater,
		SMALLER => random);	
		
	Digit3_Subtract3: ADDER_SUBTRACTOR	
		generic map(N => 4)
		port map(A => bcd_register_number(11 downto 8),
		B => three_digit,
		MODE => '1',
		RES => digit3_minus3);  --positive number --> stored in unsigned format);
		
	Define_Digit3: MUX_2_1	
		generic map(N => 4)
		port map(SEL => digit3_greater,
		I0 => bcd_register_number(11 downto 8),
		I1 => digit3_minus3,
		Y => digit3_toLoad);
											
	-------------------------digit4----------------------	
		
	Compare_Digit4: CMP  
		generic map(N => 4)
		port map(A => bcd_register_number(15 downto 12),
		B => seven_digit,
		EQUAL => random,
		GREATER => digit4_greater,
		SMALLER => random);	 
		
	Digit4_Subtract3: ADDER_SUBTRACTOR	
		generic map(N => 4)
		port map(A => bcd_register_number(15 downto 12),
		B => three_digit,
		MODE => '1',
		RES => digit4_minus3);  --positive number --> stored in unsigned format);
		
	Define_Digit4: MUX_2_1	
		generic map(N => 4)
		port map(SEL => digit4_greater,
		I0 => bcd_register_number(15 downto 12),
		I1 => digit4_minus3,
		Y => digit4_toLoad);
		
	-----------define number to load into bcd register-----------
	
	bcd_reg_number_adjusted_to_load(3 downto 0) <= digit1_toLoad;
	bcd_reg_number_adjusted_to_load(7 downto 4) <= digit2_toLoad; 
	bcd_reg_number_adjusted_to_load(11 downto 8) <= digit3_toLoad;
	bcd_reg_number_adjusted_to_load(15 downto 12) <= digit4_toLoad;
	
	Define_BCD_toLoad: MUX_2_1	
		generic map(N => 16)
		port map(SEL => restart,
		I0 => bcd_reg_number_adjusted_to_load,
		I1 => bcd_number,
		Y => bcd_number_to_load);	
	
end ARCH_CONVERTER_bcd_to_bin;
