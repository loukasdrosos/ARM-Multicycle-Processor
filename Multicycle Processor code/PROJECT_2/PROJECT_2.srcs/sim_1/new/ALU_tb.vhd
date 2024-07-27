library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_tb is
end entity ALU_tb;

architecture Behavioral of ALU_tb is

    constant WIDTH : integer := 32;

    -- Unit Under Test (UUT) Component
    component ALU
        port (
            SrcA       : in  std_logic_vector (WIDTH - 1 downto 0); -- 1st Input of ALU
            SrcB       : in  std_logic_vector (WIDTH - 1 downto 0); -- 2nd Input of ALU
            shamt5     : in  std_logic_vector (4 downto 0);         -- shift amount 
            sh         : in  std_logic_vector (1 downto 0);         -- shift type
            ALUControl : in  std_logic_vector (2 downto 0);         -- 3-bit control signal to select the operation
            ALUResult  : out std_logic_vector (WIDTH - 1 downto 0); -- ALU Output
            N          : out std_logic;                             -- Negative flag
            Z          : out std_logic;                             -- Zero flag
            C          : out std_logic;                             -- Carry flag
            V          : out std_logic                              -- Overflow flag
        );
    end component;

    -- UUT Signals
    signal SrcA_tb       : std_logic_vector(WIDTH - 1 downto 0);
    signal SrcB_tb       : std_logic_vector(WIDTH - 1 downto 0);
    signal shamt5_tb     : std_logic_vector(4 downto 0);
    signal sh_tb         : std_logic_vector(1 downto 0);
    signal ALUControl_tb : std_logic_vector(2 downto 0);
    signal ALUResult_tb  : std_logic_vector(WIDTH - 1 downto 0);
    signal N_tb          : std_logic;
    signal Z_tb          : std_logic;
    signal C_tb          : std_logic;
    signal V_tb          : std_logic;

begin

    -- Instantiate the UUT
    uut: ALU
        port map (
            SrcA       => SrcA_tb,
            SrcB       => SrcB_tb,
            shamt5     => shamt5_tb,
            sh         => sh_tb,
            ALUControl => ALUControl_tb,
            ALUResult  => ALUResult_tb,
            N          => N_tb,
            Z          => Z_tb,
            C          => C_tb,
            V          => V_tb
        );

    -- Stimulus process
    stimulus: process
    begin
        wait for 100 ns;

        -- Initialize inputs
        SrcA_tb <= (others => '0');
        SrcB_tb <= (others => '0');
        shamt5_tb <= (others => '0');
        sh_tb <= (others => '0');
        ALUControl_tb <= (others => '0');
        wait for 100 ns;

        -- Test case 1: ADD positive result
        SrcA_tb <= "00000000000000000000000000000001"; -- 1
        SrcB_tb <= "00000000000000000000000000000001"; -- 1
        ALUControl_tb <= "000"; -- ADD
        wait for 10 ns;
        assert (ALUResult_tb = "00000000000000000000000000000010" and N_tb = '0' and Z_tb = '0' and C_tb = '0' and V_tb = '0')
            report "Test case 1 failed"
            severity error;

        -- Test case 2: ADD overflow
        SrcA_tb <= "01111111111111111111111111111111"; -- 2147483647 (max positive 32-bit int)
        SrcB_tb <= "00000000000000000000000000000001"; -- 1
        ALUControl_tb <= "000"; -- ADD
        wait for 10 ns;
        assert (ALUResult_tb = "10000000000000000000000000000000" and N_tb = '1' and Z_tb = '0' and C_tb = '0' and V_tb = '1')
            report "Test case 2 failed"
            severity error;

        -- Test case 3: SUB negative result
        SrcA_tb <= "00000000000000000000000000000001"; -- 1
        SrcB_tb <= "00000000000000000000000000000010"; -- 2
        ALUControl_tb <= "001"; -- SUB
        wait for 10 ns;
        assert (ALUResult_tb = "11111111111111111111111111111111" and N_tb = '1' and Z_tb = '0' and C_tb = '0' and V_tb = '0')
            report "Test case 3 failed"
            severity error;

        -- Test case 4: SUB underflow
        SrcA_tb <= "10000000000000000000000000000000"; -- -2147483648 (min negative 32-bit int)
        SrcB_tb <= "00000000000000000000000000000001"; -- 1
        ALUControl_tb <= "001"; -- SUB
        wait for 10 ns;
        assert (ALUResult_tb = "01111111111111111111111111111111" and N_tb = '0' and Z_tb = '0' and C_tb = '1' and V_tb = '1')
            report "Test case 4 failed"
            severity error;

        -- Test case 5: AND
        SrcA_tb <= "00000000000000000000000000000001"; -- 1
        SrcB_tb <= "00000000000000000000000000000011"; -- 3
        ALUControl_tb <= "010"; -- AND
        wait for 10 ns;
        assert (ALUResult_tb = "00000000000000000000000000000001" and N_tb = '0' and Z_tb = '0' and C_tb = '0' and V_tb = '0')
            report "Test case 5 failed"
            severity error;

        -- Test case 6: EOR 
        SrcA_tb <= "00000000000000000000000000000001"; -- 1
        SrcB_tb <= "00000000000000000000000000000011"; -- 3
        ALUControl_tb <= "011"; -- EOR
        wait for 10 ns;
        assert (ALUResult_tb = "00000000000000000000000000000010" and N_tb = '0' and Z_tb = '0' and C_tb = '0' and V_tb = '0')
            report "Test case 6 failed"
            severity error;

        -- Test case 7: LSL
        SrcB_tb <= "00000000000000000000000000000001"; -- 1
        shamt5_tb <= "00001"; -- Shift by 1
        sh_tb <= "00"; -- LSL
        ALUControl_tb <= "100"; -- Shift operation
        wait for 10 ns;
        assert (ALUResult_tb = "00000000000000000000000000000010" and N_tb = '0' and Z_tb = '0' and C_tb = '0' and V_tb = '0')
            report "Test case 7 failed"
            severity error;

        -- Test case 8: ASR
        SrcB_tb <= "00000000000000000000000000000010"; -- 2
        shamt5_tb <= "00001"; -- Shift by 1
        sh_tb <= "10"; -- ASR
        ALUControl_tb <= "100"; -- Shift operation
        wait for 10 ns;
        assert (ALUResult_tb = "00000000000000000000000000000001" and N_tb = '0' and Z_tb = '0' and C_tb = '0' and V_tb = '0')
            report "Test case 8 failed"
            severity error;

        -- Test case 9: MOV
        SrcB_tb <= "00000000000000000000000000000001"; -- 1
        ALUControl_tb <= "101"; -- MOV
        wait for 10 ns;
        assert (ALUResult_tb = "00000000000000000000000000000001" and N_tb = '0' and Z_tb = '0' and C_tb = '0' and V_tb = '0')
            report "Test case 9 failed"
            severity error;

        -- Test case 10: MVN
        SrcB_tb <= "11111111111111111111111111111110"; -- -2
        ALUControl_tb <= "110"; -- MVN
        wait for 10 ns;
        assert (ALUResult_tb = "00000000000000000000000000000001" and N_tb = '0' and Z_tb = '0' and C_tb = '0' and V_tb = '0')
            report "Test case 10 failed"
            severity error;

        report "Testbench completed";
        wait; 
    end process stimulus;
end architecture Behavioral;