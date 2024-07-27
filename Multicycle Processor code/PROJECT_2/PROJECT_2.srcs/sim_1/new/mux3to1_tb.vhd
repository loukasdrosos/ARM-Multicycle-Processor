library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux3to1_tb is
end entity mux3to1_tb;

architecture Behavioral of mux3to1_tb is

    constant N : integer := 32;

    -- Unit Under Test (UUT) Component
    component mux3to1
        port (
          SEL     : in std_logic_vector(1 downto 0);     -- Selection Signal
          Input_1 : in std_logic_vector(N - 1 downto 0); -- Input data 1
          Input_2 : in std_logic_vector(N - 1 downto 0); -- Input data 2
          Input_3 : in std_logic_vector(N - 1 downto 0); -- Input data 3
          Output  : out std_logic_vector(N - 1 downto 0) -- Output data
        );
    end component;

    -- UUT Signals
    signal SEL_tb     : std_logic_vector(1 downto 0);
    signal Input_1_tb : std_logic_vector(N - 1 downto 0);
    signal Input_2_tb : std_logic_vector(N - 1 downto 0);
    signal Input_3_tb : std_logic_vector(N - 1 downto 0);
    signal Output_tb  : std_logic_vector(N - 1 downto 0);

begin

    -- Instantiate the UUT
    uut: mux3to1
        port map (
            SEL => SEL_tb,
            Input_1 => Input_1_tb,
            Input_2 => Input_2_tb,
            Input_3 => Input_3_tb,           
            Output => Output_tb
        );

    -- Stimulus process
    stimulus: process
    begin
    wait for 100 ns;
    
        -- Test case 1: Expected Output: Input1
        SEL_tb <= "00";
        Input_1_tb <= "00000000000000000000000000000001";
        Input_2_tb <= "00000000000000000000000000000000";
        Input_3_tb <= "10000000000000000000000000000000";        
        wait for 10 ns;
        assert (Output_tb = "00000000000000000000000000000001")
            report "Test case 1 failed"
            severity error;

        -- Test case 2: Expected Output: Input2
        SEL_tb <= "11";
        wait for 10 ns;
        assert (Output_tb = "00000000000000000000000000000000")
            report "Test case 2 failed"
            severity error;

        -- Test case 3: Expected Output: Input3
        SEL_tb <= "10";
        wait for 10 ns;
        assert (Output_tb = "10000000000000000000000000000000")
            report "Test case 3 failed"
            severity error;

        report "Testbench completed";

        wait; 
    end process stimulus;
end architecture Behavioral;

