---------------------------------------------------------------------------------------------------
--
-- Title       : CU
-- Design      : CU
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : CU.vhd
-- Generated   : Sat May  2 19:11:28 2020
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
--{entity {CU} architecture {Arch_CU}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CU is   
	port(clk: in std_logic;
	sw: in std_logic_vector(15 downto 0);
	btn_l, btn_r, btn_b, btn_u, btn_m: in std_logic; --left, right, bottom, upper, middle
	seg: out std_logic_vector(6 downto 0);
	an: out std_logic_vector(3 downto 0));
	--led: out std_logic_vector(15 downto 0));
end CU;

--}} End of automatically maintained section

architecture Arch_CU of CU is	 
--state constants		 
type state_type is (S_IDLE, S_INIT, S_INTRODUCE_C_NR, S_INTRODUCE_PIN_CODE, S_INVALID_CARD, S_CHOOSE_OPERATION, S_RESET_PIN,
S_SAVED_PIN, S_DEPOSIT_SUM, S_PROCESS_DEPOSITED_AMOUNT, S_SAVED_BANKNOTE, S_DISPLAY_BALANCE, S_EXTRACT_SUM, 
S_PROCESS_EXTRACTED_AMOUNT, S_DISPLAY_BANKNOTES, S_INVALID_AMOUNT, S_FINISHED_EXTRACTION, S_LOG_OUT);
--state signals
signal current_state, next_state : state_type;
--buttons
signal start_btn, next_btn, cancel_btn, back_r_btn, choose_init_btn, choose_reset_pin_btn, choose_display_balance_btn : std_logic;
signal choose_extract_sum_btn, choose_deposit_sum_btn, save_btn, back_l_btn, extract_btn, exit_btn: std_logic;
--debounced buttons
signal debounced_btn_m, debounced_btn_l, debounced_btn_r, debounced_btn_b, debounced_btn_u: std_logic;

-- signals from other components
signal valid_card, finished_processing_extract, finished_processing_deposit,finished_displaying,finished_updating_extract: std_logic;	
signal balance: std_logic_vector(13 downto 0); 
signal valid_amount, enough_banknotes: std_logic;

--signals to other components
signal reset_pin, reset_accounts, reset_banknotes, extract_sum, deposit_sum, load_card_nr, load_amount: std_logic;
signal start_displaying_banknotes, start_checking_enough_banknotes: std_logic;	 
signal Display_Mode: std_logic_vector(3 downto 0);

--card data
signal card_nr_to_load_14, card_nr_14: std_logic_vector(13 downto 0);  --...to_load value is the one read from the switches
--amount data
signal amount_to_load_binary, amount_binary: std_logic_vector(13 downto 0); -- the non-to_load value is the one saved in the register 

--banknotes signals
signal BANKNOTE_500, BANKNOTE_200, BANKNOTE_100, BANKNOTE_50, BANKNOTE_20, BANKNOTE_10, BANKNOTE_5 : std_logic_vector(9 downto 0);

--display segments(general display+banknotes diaplay) --> segments must be "and"-ed
signal general_seg, banknotes_seg: std_logic_vector(6 downto 0);
signal general_an, banknotes_an: std_logic_vector(3 downto 0); 
signal general_number_to_display: std_logic_vector(13 downto 0); --! must be either the card number, or the balance
signal general_display_enable, banknotes_display_enable: std_logic;

--clk
signal slow_clk, converter_clk: std_logic;	


---------------------------------execution units----------------------------------
component ACCOUNTS is 
	port(CLK: in std_logic;
	RESET: in std_logic;
	CARD_NR: in std_logic_vector(1 downto 0);
	GIVEN_PIN: in std_logic_vector(15 downto 0);
	RESET_PIN, SAVE_MONEY, GET_MONEY: in std_logic;
	NEW_PIN: in std_logic_vector(15 downto 0);
	AMOUNT: in std_logic_vector(9 downto 0);	
	ENOUGH_BANKNOTES: in std_logic;
	VALID_CARD, VALID_AMOUNT: out std_logic;
	BALANCE: out std_logic_vector(13 downto 0));
end component;

component bank_display is	
	port (clk: in std_logic; 
	display_enable: in std_logic;
	mode: in std_logic_vector(3 downto 0);	
	bin_display_number: in std_logic_vector(13 downto 0);
	seg: out std_logic_vector(6 downto 0);
	an: out std_logic_vector(3 downto 0));
end component;			

component  BANKNOTES_UNIT is
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
end component;


component  DISPLAY_BANKNOTES is
	port(ENABLE_DISPLAY_BANKNOTES: in std_logic;
	START_DISPLAYING: in std_logic;
	BANKNOTES_500, BANKNOTES_200, BANKNOTES_100, BANKNOTES_50, BANKNOTES_20, BANKNOTES_10, BANKNOTES_5: in std_logic_vector(9 downto 0);
	clk: in std_logic;	  			
	seg: out std_logic_vector(6 downto 0);
	an: out std_logic_vector(3 downto 0); 
	FINISHED_DISPLAY_BANKNOTES: out std_logic); -- finish displaying the banknotes
end component;		

component Debouncer is
Port (
	btn: in std_logic;
	clk : in std_logic;
	pulse_out : out std_logic);
end component;

component SHIFT_REG_LEFT is   --has load and shift functionality
	generic(NO_BITS: natural);
	port(
		CLK, LOAD, SHIFT: in std_logic; 
		D: in std_logic_vector(NO_BITS-1 downto 0); --for load functionality --> has priority over shift functionality
		SIN: in std_logic; --for shift functionality
		Q: out std_logic_vector(NO_BITS-1 downto 0));
end component; 

component CONVERTER_bcd_to_bin is	 
	port(clk: in std_logic;
	bin_number: out std_logic_vector(13 downto 0);
	bcd_number: in std_logic_vector(15 downto 0));
end component;	 

component clk_div is
	generic(width: INTEGER);
	port(RST: in STD_LOGIC;
	CLK_IN: in STD_LOGIC;
	CLK_OUT: out STD_LOGIC);
end component; 


begin  

----------------------------------------------slow down the clocks--------------------------------------------------------------	
	SLOW_CLOCK: clk_div
		generic map(15)
		port map(RST => '0',CLK_IN => clk, CLK_OUT => slow_clk);  
		
	SLOW_CLOCK_CONVERTERS: clk_div
		generic map(10)
		port map(RST => '0',CLK_IN => clk, CLK_OUT => converter_clk);	
	
-------------------------------------------------define state transitions---------------------------------------------------------
TRANSITIONS: process(current_state,valid_card, finished_processing_deposit,finished_processing_extract,finished_updating_extract,finished_displaying, 
start_btn, next_btn, cancel_btn, back_r_btn, choose_init_btn, choose_reset_pin_btn, choose_display_balance_btn,
choose_extract_sum_btn, choose_deposit_sum_btn, save_btn, back_l_btn, extract_btn, exit_btn, valid_amount, valid_card) --and all the inputs
	 begin
		 case current_state is
-- idle state
			when S_IDLE => 
				if(start_btn='1') then next_state <= S_INIT;
				else next_state <= S_IDLE;
				end if;
				
			when S_INIT => 
				if(next_btn='1') then next_state <= S_INTRODUCE_C_NR;
				else next_state <= S_INIT;
				end if;
-- card validation	
			when S_INTRODUCE_C_NR =>						 
				if(next_btn = '1') then next_state <= S_INTRODUCE_PIN_CODE;
				elsif (cancel_btn = '1') then next_state <= S_INIT;
				else next_state <= S_INTRODUCE_C_NR; 
				end if;	 
				
			when S_INTRODUCE_PIN_CODE => 
				if(next_btn = '1') then
					if(valid_card = '1') then next_state <= S_CHOOSE_OPERATION;
					else next_state <= S_INVALID_CARD;
					end if;
				elsif (cancel_btn = '1') then next_state <= S_INIT;
				else next_state <= S_INTRODUCE_PIN_CODE;
				end if;	 
				
			when S_INVALID_CARD	=> 
				if(back_r_btn = '1') then next_state <= S_INTRODUCE_PIN_CODE;
				elsif(cancel_btn = '1') then next_state <= S_INIT;
				else next_state <= S_INVALID_CARD;
				end if;				
-- choose an operation	
			when S_CHOOSE_OPERATION =>	
			if(choose_init_btn = '1') then next_state <= S_LOG_OUT;  
			elsif(choose_reset_pin_btn = '1') then next_state <= S_RESET_PIN;
			elsif(choose_deposit_sum_btn = '1') then next_state <= S_DEPOSIT_SUM;
			elsif(choose_display_balance_btn = '1') then next_state <= S_DISPLAY_BALANCE;
			elsif(choose_extract_sum_btn = '1') then next_state <= S_EXTRACT_SUM;  
			else next_state <= S_CHOOSE_OPERATION;
			end if;
				
			when S_LOG_OUT => 
			if(exit_btn = '1') then next_state <= S_INIT;
			else next_state <= S_LOG_OUT;
			end if;
-- reset pin
			when S_RESET_PIN => 
			if(save_btn = '1') then	 next_state <= S_SAVED_PIN;
			elsif(back_l_btn = '1') then next_state <= S_CHOOSE_OPERATION;
			else next_state <= S_RESET_PIN;
			end if;
			
			when S_SAVED_PIN => 
			if(back_r_btn = '1') then next_state <= S_CHOOSE_OPERATION;
			else next_state <= S_SAVED_PIN;
			end if;
			
-- deposit sum
			when S_DEPOSIT_SUM =>
			if(save_btn = '1') then next_state <= S_PROCESS_DEPOSITED_AMOUNT;
			elsif(back_l_btn = '1') then next_state <= S_CHOOSE_OPERATION; 
			else next_state <= S_DEPOSIT_SUM;
			end if;
			
			when S_PROCESS_DEPOSITED_AMOUNT =>
			if(finished_processing_deposit = '1') then next_state <= S_SAVED_BANKNOTE;  
			else next_state <= S_PROCESS_DEPOSITED_AMOUNT;
			end if;
			
			when S_SAVED_BANKNOTE =>
			if(next_btn = '1') then next_state <= S_DEPOSIT_SUM; -- introduce another banknote
			elsif(back_l_btn = '1') then next_state <= S_CHOOSE_OPERATION;
			else next_state <= S_SAVED_BANKNOTE;
			end if;
			
-- display balance
			when  S_DISPLAY_BALANCE =>
			if(next_btn = '1') then next_state <= S_CHOOSE_OPERATION;
			else next_state <= S_DISPLAY_BALANCE;
			end if;
			
-- extract sum
			when  S_EXTRACT_SUM =>
			if(extract_btn = '1') then next_state <= S_PROCESS_EXTRACTED_AMOUNT;
			elsif(back_l_btn = '1') then next_state <= S_CHOOSE_OPERATION;
			else next_state <= S_EXTRACT_SUM;
			end if;
			
			when  S_PROCESS_EXTRACTED_AMOUNT =>
			if(finished_processing_extract = '1') then			
				if(valid_amount = '1') then	 next_state <=  S_DISPLAY_BANKNOTES;
				else next_state <= S_INVALID_AMOUNT;
				end if;
			else next_state <= S_PROCESS_EXTRACTED_AMOUNT;
			end if;
			
			when S_INVALID_AMOUNT =>
			if(back_l_btn = '1') then next_state <= S_CHOOSE_OPERATION;
			else next_state <= S_INVALID_AMOUNT;
			end if;
						
			when S_DISPLAY_BANKNOTES =>
			if(finished_displaying = '1') then next_state <= S_FINISHED_EXTRACTION;
			else next_state <= S_DISPLAY_BANKNOTES;
			end if;
			
			when  S_FINISHED_EXTRACTION =>
			if(back_r_btn = '1') then next_state <= S_CHOOSE_OPERATION;
			else next_state <= S_FINISHED_EXTRACTION;
			end if;
			
			when others => next_state <= S_IDLE;
			
		 end case;
	 end process;	 
	 
	                            
-----------------------------------------execute transitions and calculate outputs---------------------------------------------
	 outputs: process(slow_clk)
	 begin
		if(slow_clk'EVENT and slow_clk='1') then 	
			reset_pin <= '0'; reset_accounts <= '0'; reset_banknotes <= '0'; extract_sum <= '0'; deposit_sum <= '0';
			load_card_nr <= '0'; load_amount <= '0'; start_displaying_banknotes <= '0';	start_checking_enough_banknotes <= '0';
		    banknotes_display_enable <= '0'; General_Display_Enable <= '0';
		    Display_Mode <= "0000";
			case current_state is
-- idle state
				when S_IDLE => 	 
					reset_banknotes <= '1';
					general_display_enable <= '1';
					if(start_btn='1') then 
						display_mode <= "1001";	--login
						reset_accounts <= '1';
					else 
						display_mode <= "0111"; --start
					end if;
				
				when S_INIT => 	
					general_display_enable <= '1';
					if(next_btn='1') then 
					   display_mode <= "1100";	--read card
					else 
					   display_mode <= "1001"; --login
					end if;
-- card validation	
				when S_INTRODUCE_C_NR =>	
					general_display_enable <= '1';
					if(next_btn = '1') then 
					   load_card_nr <= '1';
					   display_mode <= "0110";	--read pin
					elsif (cancel_btn = '1') then 
						display_mode <= "1001"; --login
					else 
						display_mode <= "1100"; --read card
					end if;	 
				
				when S_INTRODUCE_PIN_CODE =>  
					general_display_enable <= '1';
					if(next_btn = '1') then
						if(valid_card = '1') then 
							 display_mode <= "0001"; --ok
						else 
							display_mode <= "0010"; --x
						end if;
					elsif (cancel_btn = '1') then 
						display_mode <= "1001"; --login
					else
						display_mode <= "0110";	--read pin
					end if;	 
				
				when S_INVALID_CARD	=> 
					general_display_enable <= '1';
					if(back_r_btn = '1') then display_mode <= "0110"; --read pin
					elsif(cancel_btn = '1') then display_mode <= "1001"; --login
					else display_mode <= "0010"; --x
					end if;				
-- choose an operation	
				when S_CHOOSE_OPERATION =>	
					general_display_enable <= '1';
					if(choose_init_btn = '1') then general_number_to_display <= card_nr_14;   --display number(card)
					elsif(choose_reset_pin_btn = '1') then display_mode <= "0101"; --reset pin
					elsif(choose_deposit_sum_btn = '1') then display_mode <= "0011"; --deposit
					elsif(choose_extract_sum_btn = '1') then 
						display_mode <= "0100"; --extract
						load_amount <= '1';	 
					elsif(choose_display_balance_btn='1') then
						general_number_to_display <= balance;
					else display_mode <= "1000"; --choose operation
					end if;
				
				when S_LOG_OUT =>
					general_display_enable <= '1';
					if(exit_btn = '1') then display_mode <= "1001"; --login
					else general_number_to_display <= card_nr_14; --display number(card)
					end if;
-- reset pin
				when S_RESET_PIN => 
					general_display_enable <= '1';
					if(save_btn = '1') then	 
						reset_pin <= '1';
						display_mode <= "0001"; --ok
					elsif(back_l_btn = '1') then display_mode <= "1000"; --choose operation
					else display_mode <= "0101"; --reset pin
					end if;
			
				when S_SAVED_PIN => 
					general_display_enable <= '1';
					if(back_r_btn = '1') then display_mode <= "1000"; --choose operation
					else display_mode <= "0001";
					end if;
			
-- deposit sum
				when S_DEPOSIT_SUM =>  
					general_display_enable <= '1';
					if(save_btn = '1') then 
						deposit_sum <= '1';
					elsif(back_l_btn = '1') then 
						display_mode <= "1000"; --choose operation
					else 
						load_amount <= '1';
						display_mode <= "0011"; --deposit
					end if;
				
				when S_PROCESS_DEPOSITED_AMOUNT =>
					if(finished_processing_deposit= '1') then 
					   display_mode <= "0001"; --ok  
					   general_display_enable <= '1';
					end if;
				
				when S_SAVED_BANKNOTE =>
					general_display_enable <= '1';
					if(next_btn = '1') then display_mode <= "0011"; --deposit
					elsif(back_l_btn = '1') then display_mode <= "1000"; --choose operation
					else display_mode <= "0001"; --ok
					end if;
			
-- display balance
				when  S_DISPLAY_BALANCE => 
					general_display_enable <= '1';	 
					general_number_to_display <= balance;
					if(next_btn = '1') then display_mode <= "1000"; --choose operation
					end if;
			
-- extract sum
				when  S_EXTRACT_SUM =>	 
					if(extract_btn = '1') then
						start_checking_enough_banknotes <= '1';
					elsif(back_l_btn = '1') then 
					   display_mode <= "1000"; --choose operation
					   general_display_enable <= '1';
					else 
						display_mode <= "0100"; --extract
						general_display_enable <= '1';	
						load_amount <= '1';
					end if;
			
				when  S_PROCESS_EXTRACTED_AMOUNT =>
				if(finished_processing_extract= '1') then	
					if(valid_amount = '1') then	 		
						start_displaying_banknotes <= '1'; 
						banknotes_display_enable <= '1';  
						extract_sum <= '1';
					else 
						general_display_enable <= '1';
						display_mode <= "0010"; --x
					end if;
				end if;
			
				when S_INVALID_AMOUNT =>  
					general_display_enable <= '1';
					if(back_l_btn = '1') then display_mode <= "1000"; --choose operation
					else display_mode <= "0010"; --x
					end if;
						
				when S_DISPLAY_BANKNOTES =>
					if(finished_displaying = '1') then	
						general_display_enable <= '1';
					    display_mode <= "0001"; --ok		
					else banknotes_display_enable <= '1';	  
					end if;
			
				when  S_FINISHED_EXTRACTION => 
					general_display_enable <= '1';
					if(back_r_btn = '1') then display_mode <= "1000"; --choose operation
					else display_mode <= "0001"; --ok
					end if;
			end case;
			current_state <= next_state;
		end if;
	 end process;	


-------------------------------BUTTONS------------------------------------
	--debouncing buttons
	Debounce_MiddleButton: Debouncer
	port map(btn => btn_m, clk => slow_clk, pulse_out => debounced_btn_m);
	
	Debounce_LeftButton: Debouncer
	port map(btn => btn_l, clk => slow_clk, pulse_out => debounced_btn_l);
	
	Debounce_RightButton: Debouncer
	port map(btn => btn_r, clk => slow_clk, pulse_out => debounced_btn_r);
	
	Debounce_BottomButton: Debouncer
	port map(btn => btn_b, clk => slow_clk, pulse_out => debounced_btn_b);
	
	Debounce_UpperButton: Debouncer
	port map(btn => btn_u, clk => slow_clk, pulse_out => debounced_btn_u);  
	
	--button associations  
	start_btn <= debounced_btn_m;
	next_btn <= debounced_btn_r;
	cancel_btn <= debounced_btn_l; 
	back_r_btn <= debounced_btn_r;
	choose_init_btn <= debounced_btn_m;
	choose_reset_pin_btn <= debounced_btn_u;
	choose_display_balance_btn <= debounced_btn_b;
	choose_extract_sum_btn <= debounced_btn_l;
	choose_deposit_sum_btn <= debounced_btn_r;
	save_btn <= debounced_btn_r;
	back_l_btn <= debounced_btn_l;
	extract_btn <= debounced_btn_r;
	exit_btn <= debounced_btn_r;   
	
	
-------------------------------------Accounts------------------------------------	 

	Accounts_management: ACCOUNTS
		port map(CLK => slow_clk,
		RESET => reset_accounts,
		CARD_NR => card_nr_14(1 downto 0),
		GIVEN_PIN => sw(15 downto 0),
		RESET_PIN => reset_pin,  SAVE_MONEY => deposit_sum,  GET_MONEY => extract_sum, 
		NEW_PIN => sw(15 downto 0),
		AMOUNT => amount_binary(9 downto 0),  
		ENOUGH_BANKNOTES => enough_banknotes, 
		VALID_CARD => valid_card, VALID_AMOUNT => valid_amount,
		BALANCE => balance);	
		
---------------------------------Registers for data---------------------------------  
	
-----------Card number-----------
	
	card_nr_to_load_14(13 downto 2) <= "000000000000";
	card_nr_to_load_14(1 downto 0) <= sw(1 downto 0);
	
	Card_Nr_Register: SHIFT_REG_LEFT  --has load and shift functionality assert well
	generic map(NO_BITS => 14) 
	--I will need a 14 bits number for the display. Note that only bits[0-1] contain useful data,
	--all the others must be set to 0
	port map(
		CLK => slow_clk, LOAD => load_card_nr, SHIFT => '0',
		D => card_nr_to_load_14, --for load functionality --> has priority over shift functionality
		SIN => '0', --for shift functionality
		Q => card_nr_14);  
	
-------------Amount------------- 

	--need to transform the bcd number on the switches to a binary number on 14 bits
	CONVERT_AMOUNT_TO_BIN: CONVERTER_bcd_to_bin
		port map(clk => converter_clk,
		bin_number => amount_to_load_binary,
		bcd_number => sw);
		
	--use the binary number in the accounts module
	Amount_Register: SHIFT_REG_LEFT  --has load and shift functionality assert well
	generic map(NO_BITS => 14) 
	port map(
		CLK => slow_clk, LOAD => load_amount, SHIFT => '0',
		D => amount_to_load_binary, --for load functionality --> has priority over shift functionality
		SIN => '0', --for shift functionality
		Q => amount_binary);  
		
		
---------------------------------Display units-----------------------------------	
	
	seg <= general_seg and banknotes_seg;		   
	an <= general_an and banknotes_an; 
	
	GENERAL_DISPLAY: bank_display	
		port map(clk => clk, 
		display_enable => general_display_enable,
		mode => display_mode,
		bin_display_number => general_number_to_display,
		seg => general_seg,
		an => general_an);
	
	------------------Banknotes Display Unit---------------------

	BANKNOTES_DISPLAY_UNIT: DISPLAY_BANKNOTES port map(ENABLE_DISPLAY_BANKNOTES => banknotes_display_enable,
	START_DISPLAYING => start_displaying_banknotes,
	BANKNOTES_500 => BANKNOTE_500, BANKNOTES_200 => BANKNOTE_200, BANKNOTES_100 => BANKNOTE_100, BANKNOTES_50 => BANKNOTE_50, BANKNOTES_20 =>  BANKNOTE_20, BANKNOTES_10 => BANKNOTE_10, BANKNOTES_5 => BANKNOTE_5, 
	clk => clk,
	seg => banknotes_seg,
	an => banknotes_an,
	FINISHED_DISPLAY_BANKNOTES => finished_displaying);
	
---------------------------------- Banknotes Unit----------------------------------------


	COMPUTE_BANKNOTES: BANKNOTES_UNIT port map(
	START_DEPOSIT => deposit_sum,
	START_CHECKING => start_checking_enough_banknotes,
	AMOUNT =>amount_binary(9 downto 0),
	EXTRACT_SUM	=> extract_sum,
    CLK => slow_clk,
	RST => reset_banknotes,
	ENOUGH_BANKNOTES => enough_banknotes,  
	BANKNOTES_500 => BANKNOTE_500, BANKNOTES_200 => BANKNOTE_200, BANKNOTES_100 => BANKNOTE_100, BANKNOTES_50 => BANKNOTE_50, BANKNOTES_20 =>  BANKNOTE_20, BANKNOTES_10 => BANKNOTE_10, BANKNOTES_5 => BANKNOTE_5, 
	FINISHED_DEPOSIT_BANKNOTES => finished_processing_deposit,
	FINISHED_CHECKING_BANKNOTES => finished_processing_extract,
	FINISHED_EXTRACT_BANKNOTES => finished_updating_extract);	 
		
--	led(0) <= extract_sum;
--	led(1) <= start_checking_enough_banknotes;
--	led(2) <=  start_displaying_banknotes;
--	led(12 downto 3) <=BANKNOTE_200; 
--	led(15 downto 13) <= "000";
end Arch_CU;