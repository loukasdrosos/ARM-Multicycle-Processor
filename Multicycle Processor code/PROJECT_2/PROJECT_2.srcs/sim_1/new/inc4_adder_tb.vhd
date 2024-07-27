library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity INC4_Adder_tb is
end entity INC4_Adder_tb;

architecture Behavioral of INC4_Adder_tb is

  constant N : integer := 32;

    -- Unit Under Test (UUT) Component
    component INC4_Adder
        port (
            PC     : in std_logic_vector(N-1 downto 0);  -- Input of adder 
            new_PC : out std_logic_vector(N-1 downto 0)  -- Output of adder
        );
    end component;

    -- UUT Signals
    signal PC_tb     : std_logic_vector(N-1 downto 0); -- Internal Input to UUT
    signal new_PC_tb : std_logic_vector(N-1 downto 0); -- Internal Output to UUT
    
    -- Clock period definitions
    constant clk_period : time := 10ns;
begin
    -- Instantiate the UUT
    uut: INC4_Adder
        port map (
            PC => PC_tb,
            new_PC => new_PC_tb
        );

    -- Stimulus process
    stimulus: process
    begin
        wait for 100 ns;

        -- Test case 1: Initial value
        PC_tb <= (others => '0');
        wait for 10 ns;
        assert (new_PC_tb = "00000000000000000000000000000100")
            report "Test case 1 failed: Expected 00000000000000000000000000000100"
            severity error;

        -- Test case 2: PC = 4
        PC_tb <= "00000000000000000000000000000100";
        wait for 10 ns;
        assert (new_PC_tb = "00000000000000000000000000001000")
            report "Test case 2 failed: Expected 00000000000000000000000000001000"
            severity error;

        -- Test case 3: PC = 10
        PC_tb <= "00000000000000000000000000001010";
        wait for 10 ns;
        assert (new_PC_tb = "00000000000000000000000000001110")
            report "Test case 3 failed: Expected 00000000000000000000000000001110"
            severity error;

        -- Test case 4: PC = FFFFFFFC
        PC_tb <= "11111111111111111111111111111100";
        wait for 10 ns;
        assert (new_PC_tb = "00000000000000000000000000000000")
            report "Test case 4 failed: Expected 00000000000000000000000000000000"
            severity error;
            
        report "Testbench completed";

        wait; 
    end process stimulus;
end architecture Behavioral;

