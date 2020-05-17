---------------------------------------------------------------------------------------------------
--
-- Title       : ACCOUNTS
-- Design      : ATM_accounts
-- Author      : fazakasbori@gmail.com
-- Company     : utcn
--
---------------------------------------------------------------------------------------------------
--
-- File        : accounts.vhd
-- Generated   : Thu Apr  2 11:23:44 2020
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
--{entity {ACCOUNTS} architecture {ARCH_ACCOUNTS}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ACCOUNTS is 
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
end ACCOUNTS;

--}} End of automatically maintained section

architecture ARCH_ACCOUNTS of ACCOUNTS is
	--components used
	component CMP is  
		generic (N: natural);
		port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0);
		EQUAL: out STD_LOGIC;
		GREATER: out STD_LOGIC;
		SMALLER: out STD_LOGIC);
	end component;	
	
	component ADDER_SUBTRACTOR is	
		generic(N : natural);
		port(A, B: in STD_LOGIC_VECTOR(N-1 downto 0); --positive numbers --> stored in unsigned format
		MODE: in STD_LOGIC; --1 is subtract, 1 if add
		RES: out STD_LOGIC_VECTOR(N-1 downto 0));  --positive number --> stored in unsigned format);
	end component;
	
	component RAM is
		generic(DATA_WIDTH : natural;
		ADDR_WIDTH : natural);
		port(ADDRESS: in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);  
		RESET: in STD_LOGIC;
		CS_RAM: in STD_LOGIC;
		WE: in STD_LOGIC;
		READ_DATA: out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
		WRITE_DATA: in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0));
	end component;	
	
	component D_FF is	
		port(D, CLK: in STD_LOGIC;
		Q: out STD_LOGIC);		
	end component; 
	
	component SHIFT_REG_LEFT is 
		generic(NO_BITS: natural);
		port(
			CLK, LOAD, SHIFT: in std_logic; 
			D: in std_logic_vector(NO_BITS-1 downto 0); --for load functionality --> has priority over shift functionality
			SIN: in std_logic; --for shift functionality
			Q: out std_logic_vector(NO_BITS-1 downto 0));
	end component;

	
--signals linked to the PINs	
SIGNAL REAL_PIN : std_logic_vector(15 downto 0); -- the pin stored in the RAM for this account
SIGNAL GREATER_PIN, SMALLER_PIN: std_logic;	 --the relation between the real pin and the given pin(pin given by the user)

--signals linke dto the balances
SIGNAL REAL_BALANCE, NEW_BALANCE, CALCULATED_BALANCE, registered_balance: std_logic_vector(13 downto 0);   
SIGNAL INTERNAL_VALID_AMOUNT: std_logic;
SIGNAL UPDATE_BALANCE, UPDATED_BALANCE: std_logic; --updated_balance has the same waveform as update_balance, but with a one clock cycle delay
SIGNAL EXTENDED_AMOUNT: std_logic_vector(13 downto 0);
SIGNAL SMALLER_AMOUNT, EQUAL_AMOUNT, GREATER_AMOUNT: std_logic;	 

--signals linked to the state
SIGNAL STATE, NEXT_D: std_logic;  
SIGNAL LOAD_REGISTER: std_logic;


	
begin	
	INTERNAL_VALID_AMOUNT <= (SMALLER_AMOUNT or EQUAL_AMOUNT) and ENOUGH_BANKNOTES;
	VALID_AMOUNT <= INTERNAL_VALID_AMOUNT; 
	BALANCE <= REAL_BALANCE;	
	UPDATE_BALANCE <= GET_MONEY or SAVE_MONEY; 	
	--UPDATED_BALANCE <= update_balance;
	
	EXTEND_AMOUNT: process(AMOUNT)
	begin
		for i in 0 to 9 loop
			EXTENDED_AMOUNT(i) <= AMOUNT(i);
		end loop;
		for i in 10 to 13 loop
			EXTENDED_AMOUNT(i) <= '0';
		end loop;
	end process;	
	
	PINS_RAM: RAM
		generic map(DATA_WIDTH => 16, ADDR_WIDTH => 2)
		port map(ADDRESS =>	CARD_NR, RESET => RESET, CS_RAM => '1', WE => RESET_PIN, READ_DATA => REAL_PIN, WRITE_DATA => NEW_PIN);	 
		
	BALANCES_RAM: RAM
	generic map(DATA_WIDTH => 14, ADDR_WIDTH => 2)
	port map(ADDRESS =>	CARD_NR, RESET => RESET, CS_RAM => '1', WE => UPDATED_BALANCE, READ_DATA => REAL_BALANCE, WRITE_DATA => NEW_BALANCE);	
		
	
	CMP1_VALID_CARD : CMP
		generic map(N => 16)
		port map(A => GIVEN_PIN, B => REAL_PIN, EQUAL => VALID_CARD, GREATER => GREATER_PIN, SMALLER => SMALLER_PIN);  	 
		
	CMP1_VALID_AMOUNT : CMP
		generic map(N => 14)
		port map(A => EXTENDED_AMOUNT, B => REAL_BALANCE, EQUAL => EQUAL_AMOUNT, GREATER => GREATER_AMOUNT, SMALLER => SMALLER_AMOUNT);
		
	ARITH_UNIT : ADDER_SUBTRACTOR
		generic map(N => 14)
		port map(A => registered_balance, B => EXTENDED_AMOUNT, MODE => GET_MONEY, RES => CALCULATED_BALANCE); 
		
	NEW_BALANCE_REG: SHIFT_REG_LEFT	--I store the result of an operation(extraction/deposit) in this register, and then I reload the ram memory
		generic map(NO_BITS => 14)
		port map(CLK => clk, LOAD => update_balance, SHIFT => '0',
			D => calculated_balance, --for load functionality --> has priority over shift functionality
			SIN => '0', --for shift functionality
			Q => new_balance);
			
    BALANCE_REG: SHIFT_REG_LEFT	--I store the result of an operation(extraction/deposit) in this register, and then I reload the ram memory
		generic map(NO_BITS => 14)
		port map(CLK => clk, LOAD => '1', SHIFT => '0',
			D => real_balance, --for load functionality --> has priority over shift functionality
			SIN => '0', --for shift functionality
			Q => registered_balance);
			
	STORE_UPDATE_BALANCE: D_FF	
		port map(D => update_balance,  CLK => clk, Q => updated_balance);		
								
end ARCH_ACCOUNTS;
