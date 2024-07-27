library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.ENV.ALL;

entity Control_Unit_tb is
end Control_Unit_tb;

architecture Behavioral of Control_Unit_tb is
    
    -- Unit Under Test (UUT) Component
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
    end component Control_Unit;
    
    -- UUT Signals
    signal CLK_tb          : std_logic;
    signal RESET_tb        : std_logic;
    signal instr_tb        : std_logic_vector (31 downto 0);
    signal flags_tb        : std_logic_vector (3 downto 0);
    signal RegSrc_tb       : std_logic_vector (2 downto 0);
    signal ImmSrc_tb       : std_logic;
    signal ALUSrc_tb       : std_logic;
    signal ALUControl_tb   : std_logic_vector (2 downto 0);
    signal MemtoReg_tb     : std_logic;
    signal RegWrite_tb     : std_logic;
    signal MemWrite_tb     : std_logic;
    signal FlagsWrite_tb   : std_logic;
    signal PCWrite_tb      : std_logic;
    signal PCSrc_tb        : std_logic_vector (1 downto 0);
    signal IRWrite_tb      : std_logic;
    signal MAWrite_tb      : std_logic;
    
    constant clk_period : time := 10ns;

    begin

        -- Instantiate the UUT
        uut: Control_Unit  port map
                        (
                            CLK        => CLK_tb,
                            RESET      => RESET_tb,
                            cond       => instr_tb(31 downto 28),
                            op         => instr_tb(27 downto 26),
                            funct      => instr_tb(25 downto 20),
                            Rd         => instr_tb(15 downto 12),
                            shamt5     => instr_tb(11 downto 7),
                            sh         => instr_tb(6 downto 5),
                            flags      => flags_tb,
                            RegSrc     => RegSrc_tb,
                            ImmSrc     => ImmSrc_tb,
                            ALUSrc     => ALUSrc_tb,
                            ALUControl => ALUControl_tb,
                            MemtoReg   => MemtoReg_tb,
                            RegWrite   => RegWrite_tb,
                            MemWrite   => MemWrite_tb,
                            FlagsWrite => FlagsWrite_tb,
                            PCWrite    => PCWrite_tb,
                            PCSrc      => PCSrc_tb,
                            IRWrite    => IRWrite_tb,
                            MAWrite    => MAWrite_tb
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
        stimulus: process is
            begin
            
                RESET_tb <= '1';
                wait for 100ns;
                RESET_tb <= '0';
                flags_tb <= "0000";
                instr_tb <= X"E3A00000";                   -- MOV R0, #0 
                wait for clk_period*2;
                instr_tb <= X"E3A01005";                   -- MOV R1, #5
                wait for clk_period*2;
                instr_tb <= X"E3A0200C";                   -- MOV R2, #12
                wait for clk_period*2;
                instr_tb <= X"E3A0300F";                   -- MOV R3, #15
                wait for clk_period*2;
                instr_tb <= X"E3A0400F";                   -- MOV R4, #15
                wait for clk_period*2;
                instr_tb <= X"E3A05001";                   -- MOV R5, #1
                wait for clk_period*2;
                instr_tb <= X"E0806001";                   -- ADD R6, R0, R1
                wait for clk_period*2;
                instr_tb <= X"E2427009";                   -- SUB R7, R2, #9
                wait for clk_period*2;      
                instr_tb <= X"E0068007";                   -- AND R8, R6, R7
                wait for clk_period*2;
                instr_tb <= X"E0888007";                   -- ADD R8, R8, R7
                wait for clk_period*2;
                instr_tb <= X"E3580004";                   -- CMP R8, #4
                wait for clk_period*2;
                instr_tb <= X"E0279008";                   -- EOR R9, R7, R8
                wait for clk_period*2;
                instr_tb <= X"E3A0A00F";                   -- MOV R10, #15
                wait for clk_period*2;
                instr_tb <= X"E1E0B00A";                   -- MVN R11, R10
                wait for clk_period*2;
                instr_tb <= X"E1A0C08B";                   -- LSL R12, R11, #1
                wait for clk_period*2;                          
                instr_tb <= X"E1A0D24C";                   -- ASR R13, R12, #4
                wait for clk_period*2;
                instr_tb <= X"E058E006";                   -- SUBS R14, R8, R6
                wait for clk_period*2;
                instr_tb <= X"0A00000A";                   -- BEQ end
                wait for clk_period*2;
                instr_tb <= X"E052E008";                   -- SUBS R14, R2, R8
                wait for clk_period*2;
                instr_tb <= X"AA000000";                   -- BGE end
                wait for clk_period*2;
                instr_tb <= X"E2808000";                   -- ADD R8, R0, #0
                wait for clk_period*2; 
                instr_tb <= X"E0578001";                   -- SUBS R8, R7, R1
                wait for clk_period*2;
                instr_tb <= X"B2887001";                   -- ADDLT R7, R8, #1
                wait for clk_period*2;
                instr_tb <= X"E0477001";                   -- SUB R7, R7, R1 
                wait for clk_period*2;
                instr_tb <= X"E5827054";                   -- STR R7, [R2, #84]
                wait for clk_period*2;
                instr_tb <= X"E5901060";                   -- LDR R1, [R0, #96]
                wait for clk_period*2;
                instr_tb <= X"E08FF000";                   -- ADD R15, R15, R0
                wait for clk_period*2;
                instr_tb <= X"E280200E";                   -- ADD R2, R0, #14
                wait for clk_period*2; 
                instr_tb <= X"E291100D";                   -- ADD R1, R1, #13
                wait for clk_period*2;
                instr_tb <= X"75801064";                   -- STRVC R1, [R0, #100]
                wait for clk_period*2;
                instr_tb <= X"EBFFFFE0";                   -- BL main
                wait for clk_period*2;
                stop;
        end process stimulus;
end architecture Behavioral;
