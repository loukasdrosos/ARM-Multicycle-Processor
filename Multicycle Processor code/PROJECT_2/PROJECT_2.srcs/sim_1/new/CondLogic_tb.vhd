library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Conditional_Logic_tb is
end entity Conditional_Logic_tb;

architecture Behavioral of Conditional_Logic_tb is

    -- Unit Under Test (UUT) Component
    component Conditional_Logic is
        port
        (
            cond        : in std_logic_vector (3 downto 0); -- instr(31:28) (Instruction Register Output)
            flags       : in std_logic_vector (3 downto 0); -- N, Z, C, V (Status Register Output)
            CondEx_in   : out std_logic                     -- Conditional Logic output, approves the execution of the instruction when it receives value 1
        );
    end component Conditional_Logic;

    -- UUT Signals
    signal cond_tb        : std_logic_vector(3 downto 0);
    signal flags_tb       : std_logic_vector(3 downto 0);
    signal CondEx_in_tb   : std_logic;

begin

    -- Instantiate the DUT
    uut: Conditional_Logic
        port map (
            cond        => cond_tb,
            flags       => flags_tb,
            CondEx_in   => CondEx_in_tb
        );

    -- Stimulus process
    stimulus: process
    begin
        wait for 100 ns;

        -- EQ 
        cond_tb <= "0000";
        flags_tb <= "0100"; -- N=0, Z=1, C=0, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case EQ failed" severity error;
        
        -- NE 
        cond_tb <= "0001";
        flags_tb <= "0000"; -- N=0, Z=0, C=0, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case NE failed" severity error;
        
        -- CS/HS 
        cond_tb <= "0010";
        flags_tb <= "0110"; -- N=0, Z=1, C=1, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case CS/HS failed" severity error;
        
        -- CC/LO 
        cond_tb <= "0011";
        flags_tb <= "0001"; -- N=0, Z=0, C=0, V=1
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case CC/LO failed" severity error;
        
        -- MI 
        cond_tb <= "0100";
        flags_tb <= "1110"; -- N=1, Z=1, C=1, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case MI failed" severity error;
        
        -- PL 
        cond_tb <= "0101";
        flags_tb <= "0110"; -- N=0, Z=1, C=1, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case PL failed" severity error;
        
        -- VS 
        cond_tb <= "0110";
        flags_tb <= "1111"; -- N=1, Z=1, C=1, V=1
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case VS failed" severity error;
        
        -- VC 
        cond_tb <= "0111";
        flags_tb <= "1110"; -- N=1, Z=1, C=1, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case VC failed" severity error;
        
        -- HI 
        cond_tb <= "1000";
        flags_tb <= "0010"; -- N=0, Z=0, C=1, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case HI failed" severity error;
        
        -- LS
        cond_tb <= "1001";
        flags_tb <= "0000"; -- N=0, Z=0, C=0, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case LS failed" severity error;
        
        -- GE 
        cond_tb <= "1010";
        flags_tb <= "0000"; -- N=0, Z=0, C=0, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case GE failed" severity error;
        
        -- LT 
        cond_tb <= "1011";
        flags_tb <= "1000"; -- N=1, Z=0, C=0, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case LT failed" severity error;
        
        -- GT 
        cond_tb <= "1100";
        flags_tb <= "1011"; -- N=1, Z=0, C=1, V=1
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case GT failed" severity error;
        
        -- LE 
        cond_tb <= "1101";
        flags_tb <= "1000"; -- N=1, Z=0, C=0, V=0
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case LE failed" severity error;
        
        -- AL
        cond_tb <= "1110";
        flags_tb <= "0101"; -- N=0, Z=1, C=0, V=1
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case AL failed" severity error;
        
        -- none
        cond_tb <= "1111";
        flags_tb <= "0101"; -- N=0, Z=1, C=0, V=1
        wait for 10 ns;
        assert (CondEx_in_tb = '1') report "Test Case none failed" severity error;
        
        report "Testbench completed";
        wait;
    end process stimulus;
end architecture Behavioral;
