---------------------------------------------------------------------------------------------------
--
-- Title       : bank_display
-- Design      : display
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : bank-display.vhd
-- Generated   : Thu Apr 23 19:43:13 2020
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
--{entity {bank_display} architecture {arch_bank_display}}

library IEEE;
use IEEE.STD_LOGIC_1164.all; 

entity bank_display is	
	port (clk: in std_logic; 
	display_enable: in std_logic;
	mode: in std_logic_vector(3 downto 0);	
	bin_display_number: in std_logic_vector(13 downto 0);
	seg: out std_logic_vector(6 downto 0);
	an: out std_logic_vector(3 downto 0));
end bank_display;


architecture arch_bank_display of bank_display is  
signal STATE, NEXT_STATE: std_logic_vector(1 downto 0);	--shows which display out of the 4 is currently active
signal INTERNAL_CLK_DISPLAY, INTERNAL_CLK_CONVERTER: std_logic;
signal number: std_logic_vector(15 downto 0); --the bcd number, converted from binary	   
signal seg_digit1, seg_digit2, seg_digit3, seg_digit4, seg1, seg2, seg3, seg4: std_logic_vector(6 downto 0); 
signal an_enabled: std_logic_vector(3 downto 0);
signal seg_enabled: std_logic_vector(6 downto 0);

--letters
Constant A : std_logic_vector(6 downto 0) := "0001000";
Constant C : std_logic_vector(6 downto 0) := "0110001";	
Constant D : std_logic_vector(6 downto 0) := "1000010";
Constant E : std_logic_vector(6 downto 0) := "0110000";
Constant G : std_logic_vector(6 downto 0) := "0100001";
Constant I : std_logic_vector(6 downto 0) :=  "1001111";	 
Constant L : std_logic_vector(6 downto 0) :=  "1110001";	
Constant K : std_logic_vector(6 downto 0) :=  "0101000";
Constant N : std_logic_vector(6 downto 0) :=  "1101010";
Constant O : std_logic_vector(6 downto 0) :=  "0000001";
Constant P : std_logic_vector(6 downto 0) :=  "0011000";	
Constant R : std_logic_vector(6 downto 0) :=  "1111010";
Constant S : std_logic_vector(6 downto 0) :=  "0100100";	 
Constant T : std_logic_vector(6 downto 0) :=  "1110000";
Constant V : std_logic_vector(6 downto 0) :=  "1100011";	
Constant ZERO : std_logic_vector(6 downto 0) :=  "1111111"; 
Constant Middle_Line : std_logic_vector(6 downto 0) :=  "1111110";	

--Digits
Constant dig0 : std_logic_vector(6 downto 0) := "0000001";
Constant dig1 : std_logic_vector(6 downto 0) := "1001111";	
Constant dig2 : std_logic_vector(6 downto 0) := "0010010";
Constant dig3 : std_logic_vector(6 downto 0) := "0000110";
Constant dig4 : std_logic_vector(6 downto 0) := "1001100";
Constant dig5 : std_logic_vector(6 downto 0) := "0100100";	 
Constant dig6 : std_logic_vector(6 downto 0) := "0100000";	
Constant dig7 : std_logic_vector(6 downto 0) := "0001111";
Constant dig8 : std_logic_vector(6 downto 0) := "0000000";
Constant dig9 : std_logic_vector(6 downto 0) := "0000100";
Constant dont_care: std_logic_vector(6 downto 0) := "-------";

component clk_div is
	generic(width: INTEGER); -- modulo 16 counter
	port(RST: in STD_LOGIC;
	CLK_IN: in STD_LOGIC;
	CLK_OUT: out STD_LOGIC);
end component; 

component CONVERTER_bin_to_bcd is	 
	port(clk: in std_logic;
	bin_number: in std_logic_vector(13 downto 0);
	bcd_number: out std_logic_vector(15 downto 0));
end component;	 

component MUX_16_to_1_generic is 
	generic(DATA_WIDTH : natural);
	port(SEL: in std_logic_vector(3 downto 0);
	I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15: in std_logic_vector(data_width-1 downto 0);  
	Y: out std_logic_vector(data_width-1 downto 0));
end component; 

component counter_with_hold is
	generic(width: INTEGER := 3);
	port(CLK, RST, HOLD: in STD_LOGIC;
	Q: out std_logic_vector(width-1 downto 0));
end component; 

component MUX_4_to_1_generic is 
	generic(DATA_WIDTH : natural);
	port(SEL: in std_logic_vector(1 downto 0);
	I0, I1, I2, I3: in std_logic_vector(data_width-1 downto 0);  
	Y: out std_logic_vector(data_width-1 downto 0));
end component;	   

component MUX_2_to_1_generic is	
	generic(DATA_WIDTH : natural);
	port(SEL: in std_logic;
	I0, I1: in std_logic_vector(data_width-1 downto 0);  
	Y: out std_logic_vector(data_width-1 downto 0));
end component;

begin	

	--the display works at a frequency which is 2^15-times slower
	CLK_GEN_DISPLAY: clk_div 
	generic map(width => 15)
	port map(RST => '0', CLK_IN => clk, CLK_OUT => INTERNAL_CLK_DISPLAY);
	
	--the conversion algorithm works at a frequency which is 2^10-times slower
	CLK_GEN_CONVERTER: clk_div 
	generic map(width => 10)
	port map(RST => '0', CLK_IN => clk, CLK_OUT => INTERNAL_CLK_CONVERTER);
	
	CONVERTER: Converter_bin_to_bcd
	port map(clk => internal_clk_converter, bin_number => bin_display_number, bcd_number => number);
	
	DEFINE_DIGIT_SEG_1: MUX_16_to_1_generic
		generic map(DATA_WIDTH => 7)
		port map(SEL => number(3 downto 0),
		I0 => dig0, I1 => dig1, I2 => dig2, I3 => dig3, 
		I4 => dig4, I5 => dig5, I6 => dig6, I7 => dig7, 
		I8 => dig8, I9 => dig9, I10 => dont_care, I11 => dont_care, 
		I12 => dont_care, I13 => dont_care, I14 => dont_care, I15 => dont_care, 
		Y => seg_digit1);  
		
	DEFINE_DIGIT_SEG_2: MUX_16_to_1_generic
		generic map(DATA_WIDTH => 7)
		port map(SEL => number(7 downto 4),
		I0 => dig0, I1 => dig1, I2 => dig2, I3 => dig3, 
		I4 => dig4, I5 => dig5, I6 => dig6, I7 => dig7, 
		I8 => dig8, I9 => dig9, I10 => dont_care, I11 => dont_care, 
		I12 => dont_care, I13 => dont_care, I14 => dont_care, I15 => dont_care,
		Y => seg_digit2);
		
	DEFINE_DIGIT_SEG_3: MUX_16_to_1_generic
		generic map(DATA_WIDTH => 7)
		port map(SEL => number(11 downto 8),
		I0 => dig0, I1 => dig1, I2 => dig2, I3 => dig3, 
		I4 => dig4, I5 => dig5, I6 => dig6, I7 => dig7, 
		I8 => dig8, I9 => dig9, I10 => dont_care, I11 => dont_care, 
		I12 => dont_care, I13 => dont_care, I14 => dont_care, I15 => dont_care,
		Y => seg_digit3);
		
	DEFINE_DIGIT_SEG_4: MUX_16_to_1_generic
		generic map(DATA_WIDTH => 7)
		port map(SEL => number(15 downto 12),
		I0 => dig0, I1 => dig1, I2 => dig2, I3 => dig3, 
		I4 => dig4, I5 => dig5, I6 => dig6, I7 => dig7, 
		I8 => dig8, I9 => dig9, I10 => dont_care, I11 => dont_care, 
		I12 => dont_care, I13 => dont_care, I14 => dont_care, I15 => dont_care,
		Y => seg_digit4);
		
	DEFINE_SEGMENT_1: MUX_16_to_1_generic
		generic map(DATA_WIDTH => 7)
		port map(SEL => mode,
		I0 => seg_digit1, I1 => K, I2 => T, I3 => P, 
		I4 => T, I5 => T, I6 => N, I7 => T, 
		I8 => P, I9 => G, I10 => C, I11 => MIDDLE_LINE, 
		I12 => R, I13 => dont_care, I14 => dont_care, I15 => dont_care, 
		Y => seg1);	 
		
	DEFINE_SEGMENT_2: MUX_16_to_1_generic
		generic map(DATA_WIDTH => 7)
		port map(SEL => mode,
		I0 => seg_digit2, I1 => O, I2 => O, I3 => E, 
		I4 => E, I5 => S, I6 => I, I7 => R, 
		I8 => O, I9 => O, I10 => O, I11 => MIDDLE_LINE, 
		I12 => N, I13 => dont_care, I14 => dont_care, I15 => dont_care, 
		Y => seg2);
		
	DEFINE_SEGMENT_3: MUX_16_to_1_generic
		generic map(DATA_WIDTH => 7)
		port map(SEL => mode,
		I0 => seg_digit3, I1 => zero, I2 => N, I3 => D, 
		I4 => G, I5 => R, I6 => P, I7 => T, 
		I8 => zero, I9 => L, I10 => R, I11 => MIDDLE_LINE, 
		I12 => zero, I13 => dont_care, I14 => dont_care, I15 => dont_care, 
		Y => seg3);
		
	DEFINE_SEGMENT_4: MUX_16_to_1_generic
		generic map(DATA_WIDTH => 7)
		port map(SEL => mode,
		I0 => seg_digit4, I1 => zero, I2 => zero, I3 => zero, 
		I4 => zero, I5 => zero, I6 => zero, I7 => S, 
		I8 => C, I9 => zero, I10 => P, I11 => MIDDLE_LINE, 
		I12 => C, I13 => dont_care, I14 => dont_care, I15 => dont_care, 
		Y => seg4);	
		
	STATE_COUNTER: counter_with_hold 
		generic map(width => 2)
		port map(CLK => internal_clk_display, RST => '0', HOLD => '0',
		Q => state);

	CHOOSE_SEGMENT: MUX_4_to_1_generic
		generic map(DATA_WIDTH => 7)
		port map(SEL => state,
		I0 => seg1, I1 => seg2, I2 => seg3, I3 => seg4, 
		Y => seg_enabled);	 
		
	CHOOSE_ANODE: MUX_4_to_1_generic
		generic map(DATA_WIDTH => 4)
		port map(SEL => state,
		I0 => "1110", I1 => "1101", I2 => "1011", I3 => "0111", 
		Y => an_enabled);
		
	DISABLE_ANODES: MUX_2_to_1_generic	
		generic map(DATA_WIDTH => 4)
		port map(SEL => display_enable,
		I0 => "1111",  I1 => an_enabled,  
		Y => an);
		
    DISABLE: MUX_2_to_1_generic	
		generic map(DATA_WIDTH => 7)
		port map(SEL => display_enable,
		I0 => "1111111",  I1 => seg_enabled,  
		Y => seg);
end arch_bank_display;
