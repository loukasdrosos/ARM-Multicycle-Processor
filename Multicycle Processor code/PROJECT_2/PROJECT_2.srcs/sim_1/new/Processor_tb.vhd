library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity Processor_tb is
end entity Processor_tb;

architecture Behavioral of Processor_tb is
    
    constant N : integer := 32;  

    -- Unit Under Test (UUT) Component
    component Processor is
        port
        (
            CLK         : in std_logic;                             -- Clock signal 
            RESET       : in std_logic;                             -- Reset signal 
            PC          : out std_logic_vector (5 downto 0);        -- PC register output
            instr       : out std_logic_vector (N-1 downto 0);      -- The output of the Instruction memory which holds the current instruction
            ALUResult   : out std_logic_vector (N-1 downto 0);      -- The result of the ALU operation
            WriteData   : out std_logic_vector (N-1 downto 0);      -- Output data to be written back to RAM
            Result      : out std_logic_vector (N-1 downto 0)       -- Output data to be written back to the Register File 
        );
    end component Processor;

    -- UUT Signals
    signal CLK_tb         : std_logic;
    signal RESET_tb       : std_logic;
    signal PC_tb          : std_logic_vector (5 downto 0);
    signal instr_tb       : std_logic_vector (N-1 downto 0);
    signal ALUResult_tb   : std_logic_vector (N-1 downto 0);
    signal WriteData_tb   : std_logic_vector (N-1 downto 0);
    signal Result_tb      : std_logic_vector (N-1 downto 0);

    constant clk_period : time := 10ns;

    begin
    
        -- Instantiate the UUT
        uut: Processor  
            port map
            (
                CLK       => CLK_tb,
                RESET     => RESET_tb, 
                PC        => PC_tb,
                instr     => instr_tb,
                ALUResult => ALUResult_tb,
                WriteData => WriteData_tb,
                Result    => Result_tb
            );

        -- Clock process
        clock: process is
            begin
                CLK_tb <= '1';
                wait for clk_period/2;
                CLK_tb <= '0';
                wait for clk_period/2;
        end process clock;

        -- Stimulus Process
        stimulus : process
        begin
          RESET_tb <= '1';
          wait for 100 ns;
          RESET_tb <= '0';
          wait;
        end process stimulus;
        
end architecture Behavioral;