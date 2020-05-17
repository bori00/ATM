library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity clk_div is
	generic(width: INTEGER); -- modulo 16 counter
	port(RST: in STD_LOGIC;
	CLK_IN: in STD_LOGIC;
	CLK_OUT: out STD_LOGIC);
end clk_div;

architecture a_clk_div of clk_div is
Signal state : std_logic_vector(width-1 downto 0);

component counter_with_hold is
	generic(width: INTEGER := 3);
	port(CLK, RST, HOLD: in STD_LOGIC;
	Q: out std_logic_vector(width-1 downto 0));
end component;

begin
    DIVIDER: counter_with_hold
        generic map(width => width)
        port map(clk => clk_in, rst => rst, hold => '0', q => state);
    										
	clk_out <= state(width-1);		
end a_clk_div;