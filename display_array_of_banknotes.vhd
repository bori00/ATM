library IEEE;
use IEEE.STD_LOGIC_1164.all; 


entity DISPLAY_BANKNOTES is
	port(ENABLE_DISPLAY_BANKNOTES: in std_logic;
	START_DISPLAYING: in std_logic;
	BANKNOTES_500, BANKNOTES_200, BANKNOTES_100, BANKNOTES_50, BANKNOTES_20, BANKNOTES_10, BANKNOTES_5: in std_logic_vector(9 downto 0);
	clk: in std_logic;		  			
	seg: out std_logic_vector(6 downto 0);
	an: out std_logic_vector(3 downto 0);  
	FINISHED_DISPLAY_BANKNOTES: out std_logic); -- finish displaying the banknotes
end DISPLAY_BANKNOTES;

architecture A_DISPLAY_BANKNOTES of DISPLAY_BANKNOTES is

component bank_display is	
	port (clk: in std_logic; 
	display_enable: in std_logic;
	mode: in std_logic_vector(3 downto 0);	
	bin_display_number: in std_logic_vector(13 downto 0);
	seg: out std_logic_vector(6 downto 0);
	an: out std_logic_vector(3 downto 0));
end component;	
	
component COUNTER is	   
	generic(WIDTH: integer := 3);
	port(
	CU: in std_logic;		-- count 
	LD: in std_logic;
	DATA: in std_logic_vector(WIDTH-1 downto 0);
	RST : in std_logic;	   -- asynchronous reset					
	CLK : in std_logic;
	Q: out std_logic_vector(WIDTH-1 downto 0));
end component;	   

component MUX_REG is 
	generic(N: natural := 10);
	port(ENABLE: in std_logic; -- shift
	LD : in std_logic; -- load	 
	WS : in std_logic; -- selects the input to be loaded
	CLR : in std_logic;	-- asynchronous clear
	CLK : in std_logic; -- clock
	DATA0: in std_logic_vector(N-1 downto 0); -- data0 to be loaded loaded
	DATA1: in std_logic_vector(N-1 downto 0); -- data1 to be loaded loaded
	Q: out std_logic_vector(N-1 downto 0)); -- output
end component;	   

component CMP is  
	generic (N: natural := 2);
	port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
	EQUAL: out STD_LOGIC;
	GREATER: out STD_LOGIC;
	SMALLER: out STD_LOGIC);
end component;

component clk_div is
	generic(width: INTEGER); -- modulo 16 counter
	port(RST: in STD_LOGIC;
	CLK_IN: in STD_LOGIC;
	CLK_OUT: out STD_LOGIC);
end component;

component MUX_BANKNOTES is
	port(I: in std_logic_vector(2 downto 0); -- index (selections)
	BANKNOTES_500, BANKNOTES_200, BANKNOTES_100, BANKNOTES_50, BANKNOTES_20, BANKNOTES_10, BANKNOTES_5: std_logic_vector(9 downto 0);
	BANKNOTE_NR: out std_logic_vector(9 downto 0);
	BANKNOTE_VAL: out std_Logic_vector(13 downto 0));
end component;

component ADDER_SUBTRACTOR is	
	generic(N : natural :=10);
	port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0); --positive numbers --> stored in unsigned format
	MODE: in STD_LOGIC; --1 is subtract, 0 if add
	RES: out STD_LOGIC_VECTOR(N-1 downto 0));  --positive number --> stored in unsigned format);
end component;	

component JK_FF is
	port(J,K: in std_logic;
	S,R: in std_logic; -- asynchronous set,reset   on activ high
	CLK: in std_logic;
	Q, nQ: out std_logic);
end component;




signal INDEX: std_logic_vector(2 downto 0);		-- index

signal CURR_BANKNOTE_NUMBER, B, BANKNOTE_NUMBER: std_logic_vector(9 downto 0);	 

signal BANKNOTE_VALUE: std_logic_vector(13 downto 0);

signal INTERNAL_CLK: std_logic; -- slower clock	 
-- tests
signal B_ZERO,B_GR_ZERO,B_LE_ZERO: std_logic; 
signal INDEX_7,INDEX_GR_7,INDEX_LE_7: std_logic;   	 

 -- control signals	 : C(3) -- display_message_between_banknotes; C(2) : CE -- count enable, C(1) : RST -- reset, C(0) : LD --load
signal C: std_logic_vector(3 downto 0);	
type t_state is(IDLE,INIT,READ,COMPUTE,COUNT,FINISH);	
signal STATE,NEXT_STATE: t_state; -- states	 
signal RST,LD,MESSAGE,CE,SEL: std_logic; 

-- constants
constant c_ZERO: std_logic_vector(9 downto 0) := "0000000000";
constant c_ONE: std_logic_vector(9 downto 0) := "0000000001";

signal NF,FINISHED,START_D: std_logic;
signal RST_FLAG: std_logic;
signal display_mode: std_logic_vector(3 downto 0);


begin	

	CONTROL_SIGNALS: process(STATE,START_D,B_ZERO,INDEX_7)
	begin	
	   MESSAGE<='1'; CE<='0'; RST<='0'; LD<='0'; RST_FLAG<='0';FINISHED_DISPLAY_BANKNOTES<='0';
		case STATE is
				when IDLE => if(START_D = '1') then  NEXT_STATE<= INIT;
									else NEXT_STATE <= IDLE; FINISHED_DISPLAY_BANKNOTES<='1';
							end if;	
							 
				when INIT =>  RST<='1';
							NEXT_STATE <= READ;
							
				when READ => LD<='1'; 
							if(INDEX_7 = '1') then NEXT_STATE<=FINISH;
								else NEXT_STATE <= COMPUTE;
								end if;					   
				when COMPUTE =>  
								if(B_ZERO = '1') then
									if(INDEX_7 = '1') then NEXT_STATE<=FINISH;
									else  NEXT_STATE<=COUNT;	
									end if;				
								else  NEXT_STATE<= READ;  MESSAGE<='0';
								end if;	
								
				when COUNT => CE<='1';
								NEXT_STATE <= READ;
								
				when FINISH => FINISHED_DISPLAY_BANKNOTES <='1'; RST_FLAG <= '1'; 
								NEXT_STATE<= IDLE;	
									
				when others =>  FINISHED_DISPLAY_BANKNOTES <='1'; 
								NEXT_STATE <= IDLE;
			end case; 
	end process;
	
	GENERATE_STATE:process(INTERNAL_CLK) 
	begin	
	if(INTERNAL_CLK'EVENT and INTERNAL_CLK = '1') then
			STATE <= NEXT_STATE;
		end if;
	end process;        
	
	
	-- we need to synchronize the input signal because the interior clock is slower, and the transition to the next state won't happen
	
	FLAG: JK_FF port map(J => '0',K=> '0',S => START_DISPLAYING,R => RST_FLAG,CLK => INTERNAL_CLK,Q => START_D, nQ => NF);
	
	GENERATE_INTERNAL_CLK: clk_div generic map(25) port map(RST => '0', CLK_IN => clk, CLK_OUT => INTERNAL_CLK);  --slower clock for switching between banknotes
	
	INDEX_COUNTER: COUNTER generic map(3) port map(CU => CE, LD => INDEX_7,DATA => "000",RST => RST,CLK => INTERNAL_CLK, Q => INDEX); -- index of the element in the array
	
	
	GET_BANKNOTE: MUX_BANKNOTES port map(I => INDEX,BANKNOTES_500 => BANKNOTES_500, BANKNOTES_200 => BANKNOTES_200, BANKNOTES_100 => BANKNOTES_100, BANKNOTES_50 => BANKNOTES_50, BANKNOTES_20 => BANKNOTES_20, 
	BANKNOTES_10 => BANKNOTES_10, BANKNOTES_5 => BANKNOTES_5, BANKNOTE_NR => BANKNOTE_NUMBER, BANKNOTE_VAL => BANKNOTE_VALUE);		-- get element from array
	
	DECREMENT_NUMBER: ADDER_SUBTRACTOR generic map(10) port map(A => B, B => c_ONE, MODE => '1', RES => CURR_BANKNOTE_NUMBER);	 
	-- hold the number of the current banknote type which is displayed
	SAVE_CURRENT_NUMBER: MUX_REG generic map(10) port map(ENABLE => '1',LD => LD,WS => B_ZERO,CLR => RST,CLK => INTERNAL_CLK, DATA0 => CURR_BANKNOTE_NUMBER, DATA1 => BANKNOTE_NUMBER, Q => B);	
	
	process(message)
	begin
	   if(message='1') then
	       display_mode <= "1011";
       else 
            display_mode <= "0000";
        end if;
    end process;
	
	DISPLAYING: bank_display
	port map(clk => clk,
	display_enable => ENABLE_DISPLAY_BANKNOTES,
	mode => display_mode,
	bin_display_number => banknote_value,
	seg => seg, an => an);	
	
	-- tests
	CHECK_FOR_BANKNOTES: CMP generic map (10) port map(A => B, B => c_ZERO,EQUAL => B_ZERO,GREATER => B_GR_ZERO,SMALLER => B_LE_ZERO);	  
	CHECK_IF_FINISHED: CMP generic map(3) port map(A => INDEX, B => "111", EQUAL => INDEX_7,GREATER => INDEX_GR_7,SMALLER => INDEX_LE_7);
	
										   
end A_DISPLAY_BANKNOTES;

	
	
	
	
	
	
	

	