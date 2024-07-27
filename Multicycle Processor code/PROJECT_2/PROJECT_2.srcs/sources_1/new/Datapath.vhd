library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Datapath is
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
end entity Datapath;

architecture Structural of Datapath is

    -- Component Declaration
    component Register_RESET_WE is 
        generic (
            N : integer := 32 -- Parameter for the size of the register
        );
        port ( 
            CLK      : in  std_logic;                      -- Clock signal
            RESET    : in  std_logic;                      -- Reset signal
            WE       : in std_logic;                       -- Write Enable signal
            Data_in  : in  std_logic_vector(N-1 downto 0); -- Input data
            Data_out : out std_logic_vector(N-1 downto 0)  -- Output data
        );
    end component Register_RESET_WE;
    
    component Register_RESET is 
        generic (
            N : integer := 32 -- Parameter for the size of the register
        );
        port (
            CLK      : in  std_logic;                      -- Clock signal
            RESET    : in  std_logic;                      -- Reset signal
            Data_in  : in  std_logic_vector(N-1 downto 0); -- Input data
            Data_out : out std_logic_vector(N-1 downto 0)  -- Output data
        );
    end component Register_RESET;
    
    component INC4_Adder is
    generic (N : integer := 32);
    port (
        PC     : in std_logic_vector(N-1 downto 0);  -- Input of adder 
        new_PC : out std_logic_vector(N-1 downto 0)  -- Output of adder
    );
    end component INC4_Adder;
    
    component mux2to1 is
    generic (N : integer := 32);
    port (
        SEL     : in std_logic;                        -- Selection Signal
        Input_1 : in std_logic_vector(N - 1 downto 0); -- Input data 1
        Input_2 : in std_logic_vector(N - 1 downto 0); -- Input data 2
        Output  : out std_logic_vector(N - 1 downto 0) -- Output data
    );
    end component mux2to1;
    
    component mux3to1 is
    generic (N : integer := 32);
    port (
        SEL     : in std_logic_vector (1 downto 0);    -- Selection Signal
        Input_1 : in std_logic_vector(N - 1 downto 0); -- Input data 1
        Input_2 : in std_logic_vector(N - 1 downto 0); -- Input data 2
        Input_3 : in std_logic_vector(N - 1 downto 0); -- Input data 3
        Output  : out std_logic_vector(N - 1 downto 0) -- Output data
    );
    end component mux3to1;
    
    component Register_File is
    generic (
        N : integer := 4;  -- Adress Size (bits), 2^N registers
        M : integer := 32  -- Word Size (bits)
    );
    port (
        CLK            : in std_logic;                       -- Clock Signal
        Write_Enable_3 : in std_logic;                       -- Signal that enables writting to register 
        Address_1      : in std_logic_vector(N-1 downto 0);  -- Read address 1 
        Address_2      : in std_logic_vector(N-1 downto 0);  -- Read address 2 
        Address_3      : in std_logic_vector(N-1 downto 0);  -- Write address 3 
        Write_Data_3   : in std_logic_vector(M-1 downto 0);  -- Write data to address 3 
        R15            : in std_logic_vector(M-1 downto 0);  -- PC + 8 address
        Read_Data_1    : out std_logic_vector(M-1 downto 0); -- Read data from address 1
        Read_Data_2    : out std_logic_vector(M-1 downto 0)  -- Read data from address 2
    );
    end component Register_File;
    
    component IM_ROM is
    generic (
        N : integer := 6;  -- Adress length (bits)
        M : integer := 32  -- Data word length (bits)
    );
    port (
        Address   : in std_logic_vector(N-1 downto 0);  -- Input Address
        Read_Data : out std_logic_vector(M-1 downto 0)  -- Output data
    );
    end component IM_ROM;
    
    component Extend is
    generic
    (N : integer := 32);
    port (
        Imm     : in std_logic_vector (23 downto 0);  -- Immediate field of the instruction (Instr[23:0])
        ImmSrc  : in std_logic;                       -- Control Signal for different instructions
        ExtImm  : out std_logic_vector (N-1 downto 0) -- 32-bit extension of the immediate field
    );
    end component Extend;
    
    component DM_RAM is
    generic (
      N : integer := 5; -- Adress length (bits)
      M : integer := 32 -- Data word length (bits)
    );
    port (
      CLK        : in std_logic;                        -- Clock signal
      WE         : in std_logic;                        -- Write Enable
      Address    : in std_logic_vector(N - 1 downto 0); -- Input Adress
      Data_In    : in std_logic_vector(M - 1 downto 0); -- Input Data
      Data_Out   : out std_logic_vector(M - 1 downto 0) -- Output Data
    );
    end component DM_RAM;
    
    component ALU is
    generic (WIDTH : integer := 32);
    port (
      SrcA       : in std_logic_vector (WIDTH - 1 downto 0);  -- 1st Input of ALU
      SrcB       : in std_logic_vector (WIDTH - 1 downto 0);  -- 2nd Input of ALU
      shamt5     : in std_logic_vector (4 downto 0);          -- shift amount 
      sh         : in std_logic_vector (1 downto 0);          -- shift type
      ALUControl : in std_logic_vector (2 downto 0);          -- 3-bit control signal to select the operation
      ALUResult  : out std_logic_vector (WIDTH - 1 downto 0); -- ALU Output
      N          : out std_logic;                             -- Negative flag
      Z          : out std_logic;                             -- Zero flag
      C          : out std_logic;                             -- Carry flag
      V          : out std_logic                              -- Overflow flag
    );
    end component ALU;
    
    -- Signal Declaration
    signal next_PC            : std_logic_vector (N-1 downto 0);
    signal new_PC             : std_logic_vector (N-1 downto 0);
    signal ROM_Output         : std_logic_vector (N-1 downto 0); 
    signal IR_Output          : std_logic_vector (N-1 downto 0);
    signal PCPlus4_Output     : std_logic_vector (N-1 downto 0);  
    signal PCPlus4_Reg_Output : std_logic_vector (N-1 downto 0);            
    signal A1                 : std_logic_vector (3 downto 0);
    signal A2                 : std_logic_vector (3 downto 0);
    signal A3                 : std_logic_vector (3 downto 0);
    signal PCPlus8_Output     : std_logic_vector (N-1 downto 0);
    signal WD3_Output         : std_logic_vector (N-1 downto 0);
    signal RD_Mux_Output      : std_logic_vector (N-1 downto 0);
    signal RD1                : std_logic_vector (N-1 downto 0);                     
    signal RD2                : std_logic_vector (N-1 downto 0);    
    signal Extend_Output      : std_logic_vector (N-1 downto 0);                                 
    signal A_Reg_Output       : std_logic_vector (N-1 downto 0);
    signal ALUSrcB_Output     : std_logic_vector (N-1 downto 0);
    signal B_Reg_Output       : std_logic_vector (N-1 downto 0);                      
    signal I_Reg_Output       : std_logic_vector (N-1 downto 0);                      
    signal ALU_Output         : std_logic_vector (N-1 downto 0);
    signal ALU_Flags          : std_logic_vector (3 downto 0);
    signal Status_Reg_Output  : std_logic_vector (3 downto 0);
    signal MA_Reg_Output      : std_logic_vector (4 downto 0);                        
    signal S_Reg_Output       : std_logic_vector (N-1 downto 0);                     
    signal WD_Reg_Output      : std_logic_vector (N-1 downto 0);                      
    signal RAM_Output         : std_logic_vector (N-1 downto 0);
    signal RD_Reg_Output      : std_logic_vector (N-1 downto 0);                      
    
   begin
      -- Component Instantiation
      PC_Register : Register_RESET_WE 
         generic map (N => N)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             WE       => PCWrite,
             Data_in  => next_PC,
             Data_out => new_PC
         );
         
      Instruction_Memory : IM_ROM
        generic map (N => 6 , M => N)
        port map(
            Address   => new_PC(7 downto 2),
            Read_Data => ROM_Output
        );
        
      Instruction_Register : Register_RESET_WE 
         generic map (N => N)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             WE       => IRWrite,
             Data_in  => ROM_Output,
             Data_out => IR_Output
         );   
               
      PCPlus4: INC4_Adder
         generic map (N => N)
         port map (
            PC     => new_PC,
            new_PC => PCPlus4_Output
         );

      PCPlus4_Register : Register_RESET 
         generic map (N => N)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             Data_in  => PCPlus4_Output,
             Data_out => PCPlus4_Reg_Output
         ); 

      PCPlus8: INC4_Adder
         generic map (N => N)
         port map (
            PC     => PCPlus4_Reg_Output,
            new_PC => PCPlus8_Output
         );            

      RegisterFile : Register_File
        generic map(N => 4, M => N)
        port map(
          Address_1      => A1,
          Address_2      => A2,
          Address_3      => A3,
          Write_Data_3   => WD3_Output,
          R15            => PCPlus8_Output,
          CLK            => CLK,
          Write_Enable_3 => RegWrite,
          Read_Data_1    => RD1,
          Read_Data_2    => RD2
        ); 
      
      RA1_mux: mux2to1
        generic map (N => 4) 
        port map (
            SEL     => RegSrc(0),
            Input_1 => IR_Output(19 downto 16),
            Input_2 => "1111",
            Output  => A1
        );         

      RA2_mux: mux2to1
        generic map (N => 4) 
        port map (
            SEL     => RegSrc(1),
            Input_1 => IR_Output(3 downto 0),
            Input_2 => IR_Output(15 downto 12),
            Output  => A2
        );          

      WA_mux: mux2to1
        generic map (N => 4) 
        port map (
            SEL     => RegSrc(2),
            Input_1 => IR_Output(15 downto 12),
            Input_2 => "1110",
            Output  => A3
        );                         

      WD3_mux: mux2to1
        generic map (N => N) 
        port map (
            SEL     => RegSrc(2),
            Input_1 => RD_Mux_Output,
            Input_2 => PCPlus4_Reg_Output,
            Output  => WD3_Output
        );  

    Extend_Unit: Extend
        generic map (N => N)    
        port map (
            Imm     => IR_Output(23 downto 0),
            ImmSrc  => ImmSrc,
            ExtImm  => Extend_Output
        );

      A_Register : Register_RESET 
         generic map (N => N)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             Data_in  => RD1,
             Data_out => A_Reg_Output
         );   

      B_Register : Register_RESET 
         generic map (N => N)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             Data_in  => RD2,
             Data_out => B_Reg_Output
         );   

      I_Register : Register_RESET 
         generic map (N => N)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             Data_in  => Extend_Output,
             Data_out => I_Reg_Output
         );   

      ALUSrcB_mux: mux2to1
        generic map (N => N) 
        port map (
            SEL     => ALUSrc,
            Input_1 => B_Reg_Output,
            Input_2 => I_Reg_Output,
            Output  => ALUSrcB_Output
        ); 

      ALU_Unit: ALU
        generic map (WIDTH => N)
        port map (
            SrcA       => A_Reg_Output,
            SrcB       => ALUSrcB_Output,
            shamt5     => IR_Output(11 downto 7),
            sh         => IR_output(6 downto 5),
            ALUControl => ALUControl,
            ALUResult  => ALU_Output,
            N          => ALU_Flags(3),
            Z          => ALU_Flags(2),
            C          => ALU_Flags(1),
            V          => ALU_Flags(0)
        );
 
      Status_Register : Register_RESET_WE 
         generic map (N => 4)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             WE       => FlagsWrite,
             Data_in  => ALU_Flags,
             Data_out => Status_Reg_Output
         );        

      Memory_Address_Register : Register_RESET_WE 
         generic map (N => 5)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             WE       => MAWrite,
             Data_in  => ALU_Output(6 downto 2),
             Data_out => MA_Reg_Output
         );         

      Write_Data_Register : Register_RESET 
         generic map (N => N)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             Data_in  => B_Reg_Output,
             Data_out => WD_Reg_Output
         );           

      S_Register : Register_RESET 
         generic map (N => N)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             Data_in  => ALU_Output,
             Data_out => S_Reg_Output
         );         

      Data_Memory: DM_RAM
         generic map (N => 5, M => N)
         port map (
             CLK      => CLK,
             WE       => MemWrite,
             Address  => MA_Reg_Output,
             Data_In  => WD_Reg_Output,
             Data_Out => RAM_Output
         );        

      Read_Data_Register : Register_RESET 
         generic map (N => N)
         port map(
             CLK      => CLK,
             RESET    => RESET,
             Data_in  => RAM_Output,
             Data_out => RD_Reg_Output
         );  

      Rd_Source_mux: mux2to1
        generic map (N => N) 
        port map (
            SEL     => MemtoReg,
            Input_1 => S_Reg_Output,
            Input_2 => RD_Reg_Output,
            Output  => RD_Mux_Output
        );          
                   
      PCSource_mux: mux3to1
        generic map (N => N)
        port map (
            SEL     => PCSrc,
            Input_1 => PCPlus4_Output,
            Input_2 => ALU_Output,
            Input_3 => RD_Mux_Output,           
            Output  => next_PC
        );                   
        
        -- Output signals
        flags     <= Status_Reg_Output;
        PC        <= new_PC;             
        instr     <= IR_Output;             
        ALUResult <= ALU_Output;        
        WriteData <= B_Reg_Output;        
        Result    <= RD_Mux_Output;        
                            
end architecture Structural;
