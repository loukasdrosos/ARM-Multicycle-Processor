library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit is
    port
    (
        CLK         : in std_logic;                         -- Clock signal
        RESET       : in std_logic;                         -- Reset signal
        op          : in std_logic_vector (1 downto 0);     -- op field of instr(27:26)   
        funct       : in std_logic_vector (5 downto 0);     -- funct field of instr(25:20)
        shamt5      : in std_logic_vector (4 downto 0);     -- shmat5 field of instr(11:7)
        sh          : in std_logic_vector (1 downto 0);     -- sh field of instr(6:5)
        cond        : in std_logic_vector (3 downto 0);     -- instr(31:28) (Instruction Register Output) 
        flags       : in std_logic_vector (3 downto 0);     -- N, Z, C, V (Status Register Output)
        Rd          : in std_logic_vector (3 downto 0);     -- Destination register of the instruction
        RegSrc      : out std_logic_vector (2 downto 0);    -- Controls multiplexers to select between different sources of data for the registers                 
        ImmSrc      : out std_logic;                        -- Selects Zero extension or Sign extension                                                            
        ALUSrc      : out std_logic;                        -- Selects the source of the second operand for the ALU between a register value and an immediate value
        ALUControl  : out std_logic_vector (2 downto 0);    -- Selects ALU operation                                                                               
        MemtoReg    : out std_logic;                        -- Selects the source of the data written to a register (PC or Register File)                          
        IRWrite     : out std_logic;                        -- Write Enable to the Instruction Register
        RegWrite    : out std_logic;                        -- Write Enable to Register File
        MAWrite     : out std_logic;                        -- Write Enable to the Memory Address Register
        MemWrite    : out std_logic;                        -- Write Enable of RAM data memory
        FlagsWrite  : out std_logic;                        -- Enables updating the condition flags (N, Z, C, V) on the status register based on the ALU result
        PCSrc       : out std_logic_vector (1 downto 0);    -- Determines the source of the next PC value
        PCWrite     : out std_logic                         -- Update Enable of the PC
    );
end entity Control_Unit;

architecture Structural of Control_Unit is

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

    component Conditional_Logic is
        port
        (
            cond        : in std_logic_vector (3 downto 0);    -- instr(31:28) (Instruction Register Output)
            flags       : in std_logic_vector (3 downto 0);    -- N, Z, C, V (Status Register Output)
            CondEx_in   : out std_logic                        -- Conditional Logic output, approves the execution of the instruction when it receives value 1
        );
    end component Conditional_Logic;

    component Finite_State_Machine is
        port
        (
            CLK         : in std_logic;                        -- Clock signal
            RESET       : in std_logic;                        -- Reset signal
            op          : in std_logic_vector (1 downto 0);    -- op field of instr(27:26)
            S           : in std_logic;                        -- Instr(20), determines CMP in data-processing instructions and LDR or STR in memory instructions
            L           : in std_logic;                        -- Instr(24), determines the branch instruction (B or BL)
            Rd          : in std_logic_vector (3 downto 0);    -- Destination regiter of the instruction
            NoWrite_in  : in std_logic;                        -- Instruction Decoder output, Separates CMP from other DP instructions
            CondEx_in   : in std_logic;                        -- Conditional Logic output, approves the execution of the instruction when it receives value 1
            IRWrite     : out std_logic;                       -- Write Enable to the Instruction Register
            RegWrite    : out std_logic;                       -- Write Enable to Register File
            MAWrite     : out std_logic;                       -- Write Enable to the Memory Address Register
            MemWrite    : out std_logic;                       -- Write Enable of RAM data memory
            FlagsWrite  : out std_logic;                       -- Enables updating the condition flags (N, Z, C, V) on the status register based on the ALU result
            PCSrc       : out std_logic_vector (1 downto 0);   -- Determines the source of the next PC value
            PCWrite     : out std_logic                        -- Update Enable of the PC
        );
    end component Finite_State_Machine;
    
    signal NoWrite_in : std_logic;
    signal CondEx_in  : std_logic;

    begin

        InstructionDecoder: Instruction_Decoder    port map
                            (
                                op         => op,
                                funct      => funct,
                                shamt5     => shamt5,
                                sh         => sh,
                                RegSrc     => RegSrc,
                                ImmSrc     => ImmSrc,
                                ALUSrc     => ALUSrc,
                                ALUControl => ALUControl,
                                MemtoReg   => MemtoReg,
                                NoWrite_in => NoWrite_in
                            );

        ConditionalLogic: Conditional_Logic port map
                            (
                                cond => cond,
                                flags => flags,
                                CondEx_in => CondEx_in
                            );
        
        FSM: Finite_State_Machine port map
                            (
                                clk        => CLK,
                                reset      => RESET,
                                op         => op,
                                S          => funct(0),
                                L          => funct(4),
                                Rd         => Rd,
                                NoWrite_in => NoWrite_in,
                                CondEx_in  => CondEx_in,
                                IRWrite    => IRWrite,
                                RegWrite   => RegWrite,
                                MAWrite    => MAWrite,
                                MemWrite   => MemWrite,
                                FlagsWrite => FlagsWrite,
                                PCWrite    => PCWrite,
                                PCSrc      => PCSrc
                            );
        
end architecture Structural;
