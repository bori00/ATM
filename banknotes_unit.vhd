library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BANKNOTES_UNIT is
	port (
	START_DEPOSIT: in std_logic;
	START_CHECKING: in std_logic;
	AMOUNT : in std_logic_vector(9 downto 0);
	EXTRACT_SUM: in std_logic;
	CLK: in std_logic; 
	RST: in std_logic;	
	ENOUGH_BANKNOTES: out std_logic; 			 
	BANKNOTES_500, BANKNOTES_200, BANKNOTES_100, BANKNOTES_50, BANKNOTES_20, BANKNOTES_10, BANKNOTES_5: out std_logic_vector(9 downto 0);
	FINISHED_DEPOSIT_BANKNOTES: out std_logic;
	FINISHED_CHECKING_BANKNOTES: out std_logic;
	FINISHED_EXTRACT_BANKNOTES: out std_logic);
end BANKNOTES_UNIT;

architecture A_BANKNOTES_UNIT of BANKNOTES_UNIT is


component clk_div is
	generic(width: INTEGER); -- modulo 16 counter
	port(RST: in STD_LOGIC;
	CLK_IN: in STD_LOGIC;
	CLK_OUT: out STD_LOGIC);
end component;

component BANKNOTES_RAM is		 -- banknotes ram memory
	port(CS: in std_logic; -- select ram
	WE : in std_logic; -- enable write
	RESET: in std_logic;
	ADDRESS: in std_logic_vector (2 downto 0);  
	READ_NUMBER, READ_VALUE: out std_logic_vector(9 downto 0);	 -- 2 read ports
	WRITE_NUMBER: in std_logic_vector(9 downto 0));  -- write the new number of baknotes of given type  
end component;
											 
		 
component CMP is
	generic (N: natural := 2);
	port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
	EQUAL: out STD_LOGIC;
	GREATER: out STD_LOGIC;
	SMALLER: out STD_LOGIC);
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

component JK_FF is
	port(J,K: in std_logic;
	S,R: in std_logic; -- asynchronous set,reset   on activ high
	CLK: in std_logic;
	Q, nQ: out std_logic);
end component;

component REG is
	generic(N: natural := 4);
	port(ENABLE: in std_logic;
	LD : in std_logic; -- load
	CLR : in std_logic;	-- asynchronous clear
	CLK : in std_logic; -- clock
	DATA: in std_logic_vector(N-1 downto 0); -- data to be loaded loaded
	Q: out std_logic_vector(N-1 downto 0)); -- output
end component;
 

component ADDER_SUBTRACTOR is	
	generic(N : natural :=3);
	port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0); --positive numbers --> stored in unsigned format
	MODE: in STD_LOGIC; --1 is subtract, 0 if add
	RES: out STD_LOGIC_VECTOR(N-1 downto 0));  --positive number --> stored in unsigned format);
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

component MUX_2_1 is 	
	generic(N : natural := 10);
	port(SEL : in std_logic;
	I0, I1 : in std_logic_vector(N-1 downto 0);
	Y : out std_logic_vector(N-1 downto 0));
end component;	

component MUX_5_1 is 
	port(SEL: in std_logic_vector(2 downto 0);
	I0,I1,I2,I3,I4: in std_logic;
	Y: out std_logic);
end component;

component MUX_7_1 is		
	port(SEL : in std_logic_vector(2 downto 0);
	I0,I1,I2,I3,I4,I5,I6: in std_logic_vector(9 downto 0);
	Y: out std_logic_vector(9 downto 0));
end component;

component MUX_ARRAY is
	port (ENABLE: in std_logic;	 
	SEL: in std_logic_vector(2 downto 0);
	I: in std_logic_vector(9 downto 0);
	Y0,Y1,Y2,Y3,Y4,Y5,Y6: out std_logic_vector(9 downto 0));
end component;	
			
component DMUX_1_7 is
	port(SEL : in std_logic_vector(2 downto 0);
	I: in std_logic;
	Y0,Y1,Y2,Y3,Y4,Y5,Y6: out std_logic);  
end component;		   
	  

component  PRIORITY is     		 -- priority encoder to compute the address	 of the banknote
	port(DATA : in std_logic_vector (6 downto 0);  -- priority encoder on activ low logic
        CODE :out std_logic_vector (2 downto 0));  
end component ; 
   
signal REG_500,REG_200,REG_100,REG_50,REG_20,REG_10,REG_5: std_logic_vector(9 downto 0); -- 7 registers for each banknote

signal LD_500,LD_200,LD_100,LD_50,LD_20,LD_10,LD_5: std_logic;		   -- load signals for each register

signal DATA_BANKNT: std_logic_vector(9 downto 0); 			-- data to be loaded to the banknotes register

signal B: std_logic_vector(9 downto 0); -- holds banknote number used for the operations

signal CURR_BANKNOTE: std_logic_vector(9 downto 0); -- current banknote that is computed													

--AMOUNT register
signal REG_A,CURRENT_A: std_logic_vector(9 downto 0); 

-- index counter
signal INDEX: std_logic_vector(2 downto 0);	 -- index/ address

-- compare signals
signal INDEX_EQ_7,INDEX_GR_7,INDEX_LE_7: std_logic;										   
signal A_EQUAL_VALUE,A_GREATER_VALUE, A_SMALLER_VALUE: std_logic;  
signal A_ZERO,A_GREATER_0,A_SMALLER_0: std_logic;
signal B_ZERO,B_GREATER_0,B_SMALLER_0: std_logic; 				 													  

-- RAM signals
signal READ_RAM_NUMBER: std_logic_vector(9 downto 0);
signal READ_RAM_VALUE: std_logic_vector(9 downto 0);
signal WRITE_RAM_NUMBER: std_logic_vector(9 downto 0);	
-- address signal for ram
signal ADDRESS: STD_LOGIC_VECTOR(2 downto 0); -- address of memory

-- states
type t_banknotes_states is (IDLE, INIT_DEPOSIT, GET_CURRENT_NUMBER,UPDATE_RAM_DEPOSIT, FINISH_DEPOSIT, -- deposit	banknote
INIT_CHECK, LOAD_CURRENT_BANKNOTE, COMPUTE_BANKNOTE_NUMBER, COUNT_CHECK, FINISH_CHECK,WAIT_FOR_EXTRACT,		  -- check if enough banknotes
INIT_EXTRACT, UPDATE_RAM_EXTRACT, COUNT_EXTRACT, FINISH_EXTRACT);     -- extract sum
signal CURR_STATE, NEXT_STATE: t_banknotes_states;	   

-- constants
constant c_ZERO: std_logic_vector(9 downto 0) := "0000000000";
constant c_ONE: std_logic_vector(9 downto 0) := "0000000001";
																  
-- incremented value at deposit
signal ADDED, ADDED_BANKNOTE: STD_LOGIC_VECTOR(9 downto 0);	

signal ENABLE_COMPUTE, NOT_ENOUGH: std_logic;	

--control signals
signal LD_REG, LD_AMOUNT, SEL_DATA, LD_BANKNOTE, LD_DEPOSIT, CE, LD_ADDRESS, RST_INDEX,RST_BANKNOTES, WE,SEL_INPUT_RAM: std_logic;

-- enable enough_banknotes validation signal to be displayed
signal ENABLE_VALID: std_logic;

begin										
	
	------------------------------------------- CU -------------------------------------------
  
	GENERATE_OUTPUTS : process(CURR_STATE, START_DEPOSIT,START_CHECKING, EXTRACT_SUM, ENABLE_COMPUTE, INDEX_EQ_7)
	begin
	                    LD_REG <= '0';	
						LD_AMOUNT <= '0';
						SEL_DATA <= '0'; 
						LD_BANKNOTE <= '0'; 
						LD_DEPOSIT <= '0';
						CE<= '0'; 
						RST_INDEX <= '0'; 
						LD_ADDRESS <='0';  
						RST_BANKNOTES<='0';
						WE<='0';	
						SEL_INPUT_RAM<='0';	
					    FINISHED_DEPOSIT_BANKNOTES <= '1'; 
						FINISHED_CHECKING_BANKNOTES <= '1';
						FINISHED_EXTRACT_BANKNOTES <= '1';
					    ENABLE_VALID <= '1';
						
		case CURR_STATE is
			-----------------------idle----------------------------
			when IDLE =>							   
						if(START_DEPOSIT = '1') then NEXT_STATE <= INIT_DEPOSIT;
													
						elsif(START_CHECKING = '1') then NEXT_STATE <= INIT_CHECK; FINISHED_CHECKING_BANKNOTES <= '0';
			  						else NEXT_STATE <= IDLE; 
			  			end if;	  
			-----------------------deposit-------------------------------  
			
			when INIT_DEPOSIT => LD_ADDRESS <='1'; 
								FINISHED_DEPOSIT_BANKNOTES <= '0'; 
								 NEXT_STATE <= GET_CURRENT_NUMBER;
								 
			when GET_CURRENT_NUMBER =>	LD_DEPOSIT <= '1';  	   
										FINISHED_DEPOSIT_BANKNOTES <= '0'; 
										NEXT_STATE <= UPDATE_RAM_DEPOSIT; 
								
			when UPDATE_RAM_DEPOSIT => WE <= '1';						   
									FINISHED_DEPOSIT_BANKNOTES <= '0'; 
									NEXT_STATE <= FINISH_DEPOSIT;	 
									
			when FINISH_DEPOSIT =>   NEXT_STATE <= IDLE;				
			
									
			---------------------check enough banknotes----------------------------------		  
			
			when INIT_CHECK => 	    ENABLE_VALID <= '0'; 
			                        RST_INDEX <= '1';
									RST_BANKNOTES<='1';
									LD_AMOUNT <= '1';  
									FINISHED_CHECKING_BANKNOTES <= '0';
									FINISHED_EXTRACT_BANKNOTES <= '0';
									NEXT_STATE <= LOAD_CURRENT_BANKNOTE;	  
									
									
			when LOAD_CURRENT_BANKNOTE => 	LD_REG<='1'; 
											LD_BANKNOTE <='1';
											FINISHED_CHECKING_BANKNOTES <= '0';
											FINISHED_EXTRACT_BANKNOTES <= '0';
											NEXT_STATE <= COMPUTE_BANKNOTE_NUMBER;
										
						
			when COMPUTE_BANKNOTE_NUMBER => LD_BANKNOTE <= '1';	
			                                FINISHED_CHECKING_BANKNOTES <= '0';
											FINISHED_EXTRACT_BANKNOTES <= '0';
							if(ENABLE_COMPUTE = '0') then 
									LD_REG<='1';
			                        LD_AMOUNT<='1';
									SEL_DATA<='1';
									NEXT_STATE <= COMPUTE_BANKNOTE_NUMBER;
								else 	
									if(INDEX_EQ_7 = '0') then 	CE<='1';    
									end if;
									NEXT_STATE <= COUNT_CHECK;		
							end if;
				
			when COUNT_CHECK =>	if(INDEX_EQ_7 = '1') then	 NEXT_STATE <= FINISH_CHECK;
									else NEXT_STATE <= LOAD_CURRENT_BANKNOTE;								 
								end if;	
								LD_BANKNOTE <= '1'; 
			                    FINISHED_CHECKING_BANKNOTES <= '0';
								FINISHED_EXTRACT_BANKNOTES <= '0';
						
			when FINISH_CHECK => FINISHED_EXTRACT_BANKNOTES <= '0';
			                     FINISHED_CHECKING_BANKNOTES <= '0';
								 NEXT_STATE <= WAIT_FOR_EXTRACT;	   
								 
								
			when WAIT_FOR_EXTRACT => if(EXTRACT_SUM = '1') then NEXT_STATE <= INIT_EXTRACT;
										else NEXT_STATE <= IDLE;     
										end if;		
							          FINISHED_EXTRACT_BANKNOTES <= '0';
								
			--------------------- extract( update ram) ------------------------------------	   
			
			when INIT_EXTRACT => RST_INDEX<='1';	
								SEL_INPUT_RAM<='1';
			 					FINISHED_EXTRACT_BANKNOTES <= '0';
								NEXT_STATE <= UPDATE_RAM_EXTRACT;
			when UPDATE_RAM_EXTRACT => 	WE<='1';
										SEL_INPUT_RAM<='1';
										FINISHED_EXTRACT_BANKNOTES <= '0';
										NEXT_STATE <= COUNT_EXTRACT;
			when COUNT_EXTRACT =>SEL_INPUT_RAM<='1';					   
								 FINISHED_EXTRACT_BANKNOTES <= '0';
			                     if(INDEX_EQ_7 = '1') then	NEXT_STATE <= FINISH_EXTRACT;
								else CE<='1';
									NEXT_STATE <= UPDATE_RAM_EXTRACT;
									end if;	
			when FINISH_EXTRACT =>  SEL_INPUT_RAM<='1';
									NEXT_STATE <= IDLE;
			when others =>	NEXT_STATE <= IDLE;
			end case;
			end process;	 
	
	STATE_TRANSITION: process(CLK,RST)
	begin
	if(RST = '1') then CURR_STATE <= IDLE;
		 elsif(CLK'EVENT and CLK = '1') then CURR_STATE <= NEXT_STATE;
		end if;
	end process;
	
	-------------------------------------------- EU --------------------------------------------
	
    ENOUGH_BANKNOTES <= A_ZERO and ENABLE_VALID;
    	
	-- banknotes stored in ram
	MEMORY: BANKNOTES_RAM port map(CS => '1',WE => WE,RESET => RST, ADDRESS => INDEX, READ_NUMBER => READ_RAM_NUMBER, READ_VALUE => READ_RAM_VALUE, WRITE_NUMBER => WRITE_RAM_NUMBER);  -- main banknotes memory
	-- select input data for ram
	SELECT_INPUT_DATA: MUX_2_1 generic map(10) port map(SEL => SEL_INPUT_RAM,I0 => ADDED_BANKNOTE,I1 => B,Y => WRITE_RAM_NUMBER);	  																									  
	
	----------------------------------- index counter-----------------------------------------	  

 	INDEX_COUNTER: COUNTER generic map(3) port map(CU => CE,LD => LD_ADDRESS,DATA => ADDRESS,RST => RST_INDEX ,CLK => CLK, Q => INDEX);	-- generates the index (address) of banknote	   
	
	 ---------------------------------------- amount ----------------------------------------
	 
	-- stores the amount
	AMOUNT_REG: MUX_REG generic map(10) port map(ENABLE => '1',LD => LD_AMOUNT,WS => SEL_DATA,CLR => RST,CLK => CLK,DATA0 => AMOUNT,DATA1 => CURRENT_A, Q => REG_A);		
	--reduce amount
	COMPUTE_A: ADDER_SUBTRACTOR generic map(10) port map(A => REG_A, B => READ_RAM_VALUE, MODE => '1', RES => CURRENT_A);
	
	------------------------------------- banknotes -------------------------------------------
	
	-- store the banknotes
	REGISTER_500: MUX_REG generic map(10) port map(ENABLE => '1',LD => LD_500,WS => SEL_DATA, CLR => RST_BANKNOTES,CLK => CLK,DATA0 => READ_RAM_NUMBER, DATA1 => DATA_BANKNT, Q=> REG_500);	
	
	REGISTER_200: MUX_REG generic map(10) port map(ENABLE => '1',LD => LD_200,WS => SEL_DATA,CLR => RST_BANKNOTES,CLK => CLK,DATA0 => READ_RAM_NUMBER,DATA1 => DATA_BANKNT,Q => REG_200);   
	
	REGISTER_100: MUX_REG generic map(10) port map(ENABLE => '1',LD => LD_100, WS => SEL_DATA,CLR => RST_BANKNOTES,CLK => CLK, DATA0 => READ_RAM_NUMBER,DATA1 => DATA_BANKNT, Q => REG_100);   
	
	REGISTER_50: MUX_REG generic map(10) port map(ENABLE => '1',LD => LD_50,WS => SEL_DATA,CLR => RST_BANKNOTES,CLK => CLK,DATA0 => READ_RAM_NUMBER,DATA1 => DATA_BANKNT, Q => REG_50);	  
	
	REGISTER_20: MUX_REG generic map(10) port map(ENABLE => '1',LD => LD_20,WS => SEL_DATA,CLR => RST_BANKNOTES,CLK => CLK,DATA0 => READ_RAM_NUMBER,DATA1 => DATA_BANKNT,Q => REG_20);	 
	
	REGISTER_10: MUX_REG generic map(10) port map(ENABLE => '1',LD => LD_10, WS => SEL_DATA,CLR => RST_BANKNOTES,CLK => CLK,DATA0 => READ_RAM_NUMBER,DATA1 => DATA_BANKNT,Q => REG_10);	 
	
	REGISTER_5: MUX_REG generic map(10) port map(ENABLE => '1',LD => LD_5,WS => SEL_DATA,CLR => RST_BANKNOTES,CLK => CLK,DATA0 => READ_RAM_NUMBER,DATA1 => DATA_BANKNT,Q => REG_5);
	
	-- choose load signals 
	CHOOSE_LOAD: DMUX_1_7 port map(SEL => INDEX, I => LD_REG,Y0 => LD_500,Y1 => LD_200,Y2 => LD_100,Y3 => LD_50,Y4 => LD_20,Y5  => LD_10,Y6 => LD_5); 
	-- chose current banknote to be decreased
	CHOOSE_REGISTER_CURRENT_VALUE: MUX_7_1 port map(SEL => INDEX, I0 => REG_500,I1 => REG_200,I2 => REG_100,I3 => REG_50,I4 => REG_20,I5 => REG_10,I6 => REG_5,Y => B);
	-- banknote processed
	COMPUTE_B: ADDER_SUBTRACTOR generic map(10) port map(A => B, B => c_ONE, MODE => '1', RES => DATA_BANKNT);  -- B = B-1
	 
	---------------------------------tests----------------------------------------------   
	
	COMPARE_INDEX_WITH_7: CMP generic map(3) port map(A => INDEX,B  => "111",EQUAL => INDEX_EQ_7,GREATER => INDEX_GR_7,SMALLER => INDEX_LE_7);  -- check if it reached the last index
	-- see if B = 0
	COMPARE_B_WITH_0: CMP generic map(10) port map(A => B,B => c_ZERO,EQUAL => B_ZERO,GREATER => B_GREATER_0,SMALLER => B_SMALLER_0); 
	-- see if A = 0	=> ENOUGH_BANKNOTES
	COMPARE_A_WITH_0: CMP generic map(10) port map(A => REG_A,B => c_ZERO,EQUAL => A_ZERO,GREATER => A_GREATER_0,SMALLER =>A_SMALLER_0); 
	-- see if A < banknotes.value
	COMPARE_A_WITH_VALUE: CMP generic map(10) port map(A => REG_A,B => READ_RAM_VALUE, EQUAL => A_EQUAL_VALUE,GREATER => A_GREATER_VALUE,SMALLER =>  A_SMALLER_VALUE); 
	
	ENABLE_COMPUTE <= B_ZERO or A_SMALLER_VALUE or INDEX_EQ_7;			 
																								
	
	-------------------------------- select banknote --------------------------------------------  
	

	-- choose the banknote to be changed
	CHOOSE_ELEMENT_FROM_ARRAY: MUX_ARRAY port map(ENABLE => LD_BANKNOTE,SEL => INDEX,I => CURR_BANKNOTE,Y0 => BANKNOTES_500,Y1 => BANKNOTES_200, Y2 => BANKNOTES_100,Y3 => BANKNOTES_50, Y4 => BANKNOTES_20,Y5 => BANKNOTES_10, Y6 => BANKNOTES_5); 	   
	
	-- compute new value of banknote chosen
	GENERATE_RETURN_BANKNOTE: ADDER_SUBTRACTOR generic map(10) port map(A => READ_RAM_NUMBER,B => B,MODE => '1',RES => CURR_BANKNOTE); 
	
	--------------------------------- deposit money ---------------------------------------------
	
	ENCODE_ADDRESS: PRIORITY port map(DATA => AMOUNT(8 downto 2),CODE => ADDRESS);		  --get address of given banknote 
	
	ADD_BANKNOTE: ADDER_SUBTRACTOR generic map(10) port map(A => READ_RAM_NUMBER,B=> c_ONE,MODE => '0', RES => ADDED);	-- increment banknote nr	
	
	DEPOSIT_BANKNOTE_REG: REG generic map(10) port map(ENABLE => '1', LD => LD_DEPOSIT,CLR => RST,CLK =>  CLK, DATA => ADDED, Q => ADDED_BANKNOTE);	-- store the new number

end A_BANKNOTES_UNIT;
