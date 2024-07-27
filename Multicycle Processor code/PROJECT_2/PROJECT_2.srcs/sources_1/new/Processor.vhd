library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Processor is
    generic (N : integer := 32);
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
end Processor;

architecture Structural of Processor is

    component Datapath is
        generic (N : integer := 32); -- word size(bits)
        port
        (
            CLK         : in std_logic;                         -- Clock signal
            RESET       : in std_logic;                         -- Reset signal
            RegSrc      : in std_logic_vector (2 downto 0);     -- Controls multiplexers to select between different sources of data for the registers
            ALUSrc      : in std_logic;                         -- Selects the source of the second operand for the ALU between a register value and an immediate value
            MemtoReg    : in std_logic;                         -- Selects the source of the data written to a register (PC or Register File)
            ALUControl  : in std_logic_vector (2 downto 0);     -- Selects ALU operation
            ImmSrc      : in std_logic;                         -- Selects Zero extension or Sign extension 
            IRWrite     : in std_logic;                         -- Write Enable to the Instruction Register
            RegWrite    : in std_logic;                         -- Write Enable to Register File
            MAWrite     : in std_logic;                         -- Write Enable to the Memory Address Register     
            MemWrite    : in std_logic;                         -- Write Enable of RAM data memory
            FlagsWrite  : in std_logic;                         -- Enables updating the condition flags (N, Z, C, V) on the status register based on the ALU result
            PCSrc       : in std_logic_vector (1 downto 0);     -- Determines the source of the next PC value
            PCWrite     : in std_logic;                         -- Update Enable of the PC
            flags       : out std_logic_vector (3 downto 0);    -- Condition flags (N, Z, C, V) that indicate the result of the last ALU operation
            PC          : out std_logic_vector (N-1 downto 0);  -- Program counter which holds the address of the next instruction to be executed
            instr       : out std_logic_vector (N-1 downto 0);  -- The output of the Instruction memory which holds the current instruction
            ALUResult   : out std_logic_vector (N-1 downto 0);  -- The result of the ALU operation
            WriteData   : out std_logic_vector (N-1 downto 0);  -- Output data to be written back to RAM
            Result      : out std_logic_vector (N-1 downto 0)   -- Output data to be written back to the Register File 
        );
    end component Datapath;

    component Control_Unit is
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
            Rd          : in std_logic_vector (3 downto 0);     -- Destination regiter of the instruction
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
    end component Control_Unit;
    
    signal PC_DP           : std_logic_vector (31 downto 0); 
    signal flags_DP        : std_logic_vector (3 downto 0);
    signal instr_DP        : std_logic_vector (31 downto 0);  
    signal RegSrc_CU       : std_logic_vector (2 downto 0);   
    signal ImmSrc_CU       : std_logic;   
    signal ALUSrc_CU       : std_logic; 
    signal ALUControl_CU   : std_logic_vector (2 downto 0);                        
    signal MemtoReg_CU     : std_logic;  
    signal IRWrite_CU      : std_logic;   
    signal RegWrite_CU     : std_logic;    
    signal MAWrite_CU      : std_logic;                                         
    signal MemWrite_CU     : std_logic;                         
    signal FlagsWrite_CU   : std_logic;                         
    signal PCSrc_CU        : std_logic_vector (1 downto 0);
    signal PCWrite_CU      : std_logic;

    begin

        Datapath_component: Datapath   generic map  (N => 32)
                                        port map
                                        (
                                            CLK        => CLK,
                                            RESET      => RESET,
                                            RegSrc     => RegSrc_CU,
                                            ALUSrc     => ALUSrc_CU,
                                            MemtoReg   => MemtoReg_CU,
                                            ALUControl => ALUControl_CU,
                                            ImmSrc     => ImmSrc_CU,
                                            MemWrite   => MemWrite_CU,
                                            FlagsWrite => FlagsWrite_CU,
                                            RegWrite   => RegWrite_CU,
                                            PCSrc      => PCSrc_CU,
                                            PCWrite    => PCWrite_CU,
                                            IRWrite    => IRWrite_CU,
                                            MAWrite    => MAWrite_CU,
                                            flags      => flags_DP,
                                            instr      => instr_DP,
                                            PC         => PC_DP,
                                            ALUResult  => ALUResult,
                                            WriteData  => WriteData,
                                            Result     => Result
                                        );

        ControlUnit_component: Control_Unit port map
                                        (
                                            CLK        => CLK,
                                            RESET      => RESET,
                                            cond       => instr_DP(31 downto 28),     
                                            op         => instr_DP(27 downto 26),     
                                            funct      => instr_DP(25 downto 20),     
                                            Rd         => instr_DP(15 downto 12),     
                                            shamt5     => instr_DP(11 downto 7),      
                                            sh         => instr_DP(6 downto 5),       
                                            flags      => flags_DP,
                                            RegSrc     => RegSrc_CU,
                                            ImmSrc     => ImmSrc_CU,
                                            ALUSrc     => ALUSrc_CU,
                                            ALUControl => ALUControl_CU,
                                            MemtoReg   => MemtoReg_CU,
                                            RegWrite   => RegWrite_CU,
                                            MemWrite   => MemWrite_CU,
                                            FlagsWrite => FlagsWrite_CU,
                                            PCWrite    => PCWrite_CU,
                                            PCSrc      => PCSrc_CU,
                                            IRWrite    => IRWrite_CU,
                                            MAWrite    => MAWrite_CU
                                        );
                                        
        -- Output signals
        PC    <= PC_DP(5 downto 0);
        instr <= instr_DP;

end Structural;
