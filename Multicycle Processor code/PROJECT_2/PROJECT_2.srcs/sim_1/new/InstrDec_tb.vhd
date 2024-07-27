library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Instruction_Decoder_tb is
end entity Instruction_Decoder_tb;

architecture Behavioral of Instruction_Decoder_tb is

    -- Unit Under Test (UUT) Component
    component Instruction_Decoder is
        port
        (
        op          : in std_logic_vector (1 downto 0);    -- op field of instr(27:26)
        funct       : in std_logic_vector (5 downto 0);    -- funct field of instr(25:20)
        shamt5      : in std_logic_vector (4 downto 0);    -- shmat5 field of instr(11:7)
        sh          : in std_logic_vector (1 downto 0);    -- sh field of instr(6:5)
        RegSrc      : out std_logic_vector (2 downto 0);   -- Controls multiplexers to select between different sources of data for the registers
        ImmSrc      : out std_logic;                       -- Selects Zero extension or Sign extension
        ALUSrc      : out std_logic;                       -- Selects the source of the second operand for the ALU between a register value and an immediate value
        ALUControl  : out std_logic_vector (2 downto 0);   -- Selects ALU operation
        MemtoReg    : out std_logic;                       -- Selects the source of the data written to a register (PC or Register File)
        NoWrite_in  : out std_logic                        -- Separates CMP from other DP instructions
        );
    end component Instruction_Decoder;

    -- UUT Signals
    signal op_tb         : std_logic_vector(1 downto 0);
    signal funct_tb      : std_logic_vector(5 downto 0);
    signal shamt5_tb     : std_logic_vector(4 downto 0);
    signal sh_tb         : std_logic_vector(1 downto 0);
    signal RegSrc_tb     : std_logic_vector(2 downto 0);
    signal ImmSrc_tb     : std_logic;
    signal ALUSrc_tb     : std_logic;
    signal ALUControl_tb : std_logic_vector(2 downto 0);
    signal MemtoReg_tb   : std_logic;
    signal NoWrite_in_tb : std_logic;

begin

    -- Instantiate the DUT
    uut: Instruction_Decoder
        port map (
            op          => op_tb,
            funct       => funct_tb,
            shamt5      => shamt5_tb,
            sh          => sh_tb,
            RegSrc      => RegSrc_tb,
            ImmSrc      => ImmSrc_tb,
            ALUSrc      => ALUSrc_tb,
            ALUControl  => ALUControl_tb,
            MemtoReg    => MemtoReg_tb,
            NoWrite_in  => NoWrite_in_tb
        );

    -- Stimulus process
    stimulus: process
    begin
        wait for 100 ns;

        -- Initialize signals
        op_tb <= "00";
        funct_tb <= (others => '0');
        shamt5_tb <= (others => '0');
        sh_tb <= (others => '0');
        wait for 100 ns;
        
         -- ADD Imm
        op_tb <= "00";
        funct_tb <= "101000";  
        wait for 10 ns;
        assert (RegSrc_tb = "0X0" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "000" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test ADD Imm Failed" severity error;
            
        -- ADD Reg
        op_tb <= "00";
        funct_tb <= "001000";  
        wait for 10 ns;
        assert (RegSrc_tb = "000" and ALUSrc_tb = '0' and ALUControl_tb = "000" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test ADD Reg Failed" severity error;

        -- SUB Imm
        op_tb <= "00";
        funct_tb <= "100101";  
        wait for 10 ns;
        assert (RegSrc_tb = "0X0" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "001" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test SUB Imm Failed" severity error;

        -- SUB Reg
        op_tb <= "00";
        funct_tb <= "000101";  
        wait for 10 ns;
        assert (RegSrc_tb = "000" and ALUSrc_tb = '0' and ALUControl_tb = "001" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test SUB Reg Failed" severity error;
            
        -- CMP Imm
        op_tb <= "00";
        funct_tb <= "110101";  
        wait for 10 ns;
        assert (RegSrc_tb = "XX0" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "001" and NoWrite_in_tb = '1')
            report "Test CMP Imm Failed" severity error;

        -- CMP Reg
        op_tb <= "00";
        funct_tb <= "010101";  
        wait for 10 ns;
        assert (RegSrc_tb = "X00" and ALUSrc_tb = '0' and ALUControl_tb = "001" and NoWrite_in_tb = '1')
            report "Test CMP Reg Failed" severity error;            
            
        -- AND Imm
        op_tb <= "00";
        funct_tb <= "100000";  
        wait for 10 ns;
        assert (RegSrc_tb = "0X0" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "010" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test AND Imm Failed" severity error;

        -- AND Reg
        op_tb <= "00";
        funct_tb <= "000000";  
        wait for 10 ns;
        assert (RegSrc_tb = "000" and ALUSrc_tb = '0' and ALUControl_tb = "010" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test AND Reg Failed" severity error;        
                
        -- EOR Imm
        op_tb <= "00";
        funct_tb <= "100011";  
        wait for 10 ns;
        assert (RegSrc_tb = "0X0" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "011" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test EOR Imm Failed" severity error;

        -- EOR Reg
        op_tb <= "00";
        funct_tb <= "000010";  
        wait for 10 ns;
        assert (RegSrc_tb = "000" and ALUSrc_tb = '0' and ALUControl_tb = "011" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test EOR Reg Failed" severity error;   

        -- MVN Imm
        op_tb <= "00";
        funct_tb <= "111111";  
        wait for 10 ns;
        assert (RegSrc_tb = "0XX" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "110" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test MVN Imm Failed" severity error;

        -- MVN Reg
        op_tb <= "00";
        funct_tb <= "011110";  
        wait for 10 ns;
        assert (RegSrc_tb = "00X" and ALUSrc_tb = '0' and ALUControl_tb = "110" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test MVN Reg Failed" severity error;  
            
        -- MOV Imm
        op_tb <= "00";
        funct_tb <= "111011";  
        wait for 10 ns;
        assert (RegSrc_tb = "0XX" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "101" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test MOV Imm Failed" severity error;
            
        -- MOV Reg
        op_tb <= "00";
        funct_tb <= "011011";  
        shamt5_tb <= "00000";
        sh_tb <= "00";
        wait for 10 ns;
        assert (RegSrc_tb = "00X" and ALUSrc_tb = '0' and ALUControl_tb = "100" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test MOV Reg Failed" severity error;

        -- LSL Imm
        op_tb <= "00";
        funct_tb <= "011011";  
        shamt5_tb <= "00001";
        sh_tb <= "00";
        wait for 10 ns;
        assert (RegSrc_tb = "00X" and ALUSrc_tb = '0' and ALUControl_tb = "100" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test LSL Imm Failed" severity error;
            
        -- ASR Imm
        op_tb <= "00";
        funct_tb <= "011011";  
        shamt5_tb <= "00001";
        sh_tb <= "10";
        wait for 10 ns;
        assert (RegSrc_tb = "00X" and ALUSrc_tb = '0' and ALUControl_tb = "100" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test ASR Imm Failed" severity error;

        -- LDR Imm +
        op_tb <= "01";
        funct_tb <= "101011";  
        wait for 10 ns;
        assert (RegSrc_tb = "0X0" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "000" and MemtoReg_tb = '1' and NoWrite_in_tb = '0')
            report "Test LDR Imm + Failed" severity error;
            
        -- LDR Imm -
        op_tb <= "01";
        funct_tb <= "100011";  
        wait for 10 ns;
        assert (RegSrc_tb = "0X0" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "001" and MemtoReg_tb = '1' and NoWrite_in_tb = '0')
            report "Test LDR Imm - Failed" severity error;           
             
        -- STR Imm +
        op_tb <= "01";
        funct_tb <= "101010";  
        wait for 10 ns;
        assert (RegSrc_tb = "X10" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "000" and NoWrite_in_tb = '0')
            report "Test STR Imm + Failed" severity error;
            
        -- STR Imm -
        op_tb <= "01";
        funct_tb <= "100010";  
        wait for 10 ns;
        assert (RegSrc_tb = "X10" and ALUSrc_tb = '1' and ImmSrc_tb = '0' and ALUControl_tb = "001" and NoWrite_in_tb = '0')
            report "Test STR Imm - Failed" severity error;    

        -- B
        op_tb <= "10";
        funct_tb <= "000000";  
        wait for 10 ns;
        assert (RegSrc_tb = "XX1" and ALUSrc_tb = '1' and ImmSrc_tb = '1' and ALUControl_tb = "000" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test B Failed" severity error;

        -- BL
        op_tb <= "10";
        funct_tb <= "010000";  
        wait for 10 ns;
        assert (RegSrc_tb = "1X1" and ALUSrc_tb = '1' and ImmSrc_tb = '1' and ALUControl_tb = "000" and MemtoReg_tb = '0' and NoWrite_in_tb = '0')
            report "Test BL Failed" severity error;

        report "Testbench completed";
        wait;
    end process stimulus;
end architecture Behavioral;
