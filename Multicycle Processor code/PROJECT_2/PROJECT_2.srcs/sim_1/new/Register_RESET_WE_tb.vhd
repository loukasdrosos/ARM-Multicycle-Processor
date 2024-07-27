library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register_RESET_WE_tb is
end Register_RESET_WE_tb; 

architecture Behavioral of Register_RESET_WE_tb is

    constant N : integer := 32;
    
     -- Unit Under Test (UUT) Component
    component Register_RESET_WE is 
    port (
        CLK      : in  std_logic;                      -- Clock signal
        RESET    : in  std_logic;                      -- Reset signal
        WE       : in std_logic;                       -- Write Enable signal
        Data_in  : in  std_logic_vector(N-1 downto 0); -- Input data
        Data_out : out std_logic_vector(N-1 downto 0)  -- Output data
    );
    end component;

    -- UUT Signals
    signal CLK_tb      : std_logic; 
    signal RESET_tb    : std_logic;  
    signal WE_tb       : std_logic; 
    signal Data_in_tb  : std_logic_vector(N-1 downto 0); 
    signal Data_out_tb : std_logic_vector(N-1 downto 0);
        
    constant clk_period : time := 10ns;
                  
    begin

        -- Instantiate the UUT
        uut : Register_RESET_WE
            port map(
                CLK => CLK_tb,
                RESET => RESET_tb,
                WE => WE_tb,
                Data_in => Data_in_tb,
                Data_out => Data_out_tb
            );
            
        clock: process is
            begin
                CLK_tb <= '0'; 
                wait for clk_period/2;
                CLK_tb <= '1'; 
                wait for clk_period/2;
        end process clock;
        
        -- Stimulus process
        stimulus: process is
        begin
            wait for 100 ns;

            RESET_tb <= '1'; -- Reset the register
            wait for clk_period;
            RESET_tb <= '0';
            wait for clk_period;     
            WE_tb <= '1'; -- Write to the register    
            Data_in_tb <= "00000000000000000000000000000001";
            wait for clk_period;
            WE_tb <= '0';
            Data_in_tb <= "10000000000000000000000000000000";
            wait for clk_period;
            WE_tb <= '1'; 
            Data_in_tb <= "00100000000000000111000000000000";
            wait; 
    end process stimulus;
end architecture Behavioral;
            
            
