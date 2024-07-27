library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Extend_tb is
end entity Extend_tb;

architecture Behavioral of Extend_tb is

    constant N : integer := 32;

    -- Unit Under Test (UUT) Component
    component Extend
        port (
            Imm     : in  std_logic_vector (23 downto 0); -- Immediate field of the instruction (Instr[23:0])
            ImmSrc  : in  std_logic;                      -- Control Signal for different instructions
            ExtImm  : out std_logic_vector (N-1 downto 0) -- 32-bit extension of the immediate field
        );
    end component;

    -- UUT Signals
    signal Imm_tb    : std_logic_vector(23 downto 0);
    signal ImmSrc_tb : std_logic;
    signal ExtImm_tb : std_logic_vector(N-1 downto 0);

begin

    -- Instantiate the UUT
    uut: Extend
        port map (
            Imm     => Imm_tb,
            ImmSrc  => ImmSrc_tb,
            ExtImm  => ExtImm_tb
        );

    -- Stimulus process
    stimulus: process
    begin
        wait for 100 ns;
    
        -- Test case 1: Zero Extension
        Imm_tb <= "000000000000111111111111"; 
        ImmSrc_tb <= '0';
        wait for 10 ns;
        assert (ExtImm_tb = "00000000000000000000111111111111")
            report "Test case 1 failed"
            severity error;

        -- Test case 2: Sign Extension and multiply by 4 (left shift by 2 bits)
        Imm_tb <= "000000000000111111111111";  
        ImmSrc_tb <= '1';
        wait for 10 ns;
        assert (ExtImm_tb = std_logic_vector(resize(signed(Imm_tb) * 4, N)))
            report "Test case 2 failed"
            severity error;

        report "Testbench completed";
        wait; 
    end process stimulus;
end architecture Behavioral;
