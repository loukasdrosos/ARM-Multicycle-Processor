library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Instruction_Decoder is
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
end entity Instruction_Decoder;

architecture Behavioral of Instruction_Decoder is
    
    begin

        RegSrc_Selection : process(op, funct)
        begin
            op_case : case op is
                when "00" => -- Data Processong instructions
                    funct_case : case funct(5 downto 1) is
                        when "11010" =>  -- CMP with an immediate value
                            RegSrc <= "XX0";
                        when "01010" =>  -- CMP where both operands are registers
                            RegSrc <= "X00";
                        when others =>
                            case funct(5) is
                                when '0' => -- Data Processing instructions where both operands are registers (except fot LSL and ASR)
                                    case funct(4 downto 1) is
                                        when "1101" => -- LSL, ASR and MOV 
                                            RegSrc <= "00X";
                                        when "1111" => -- MVN 
                                            RegSrc <= "00X";
                                        when others =>
                                            RegSrc <= "000"; -- ADD, SUB, AND, EOR
                                    end case;
                                when '1' => -- Data Processing instructions with an immediate value
                                    case funct(4 downto 1) is
                                        when "1101" => -- MOV 
                                            RegSrc <= "0XX";                                
                                        when "1111" => -- MVN 
                                            RegSrc <= "0XX";
                                        when others =>
                                            RegSrc <= "0X0"; -- ADD, SUB, AND, XOR
                                    end case;
                                when others =>
                                    RegSrc <= (others => '0');
                            end case;
                    end case funct_case;
                when "01" => -- Memory Access instructions
                    case funct(0) is
                        when '1' =>  -- LDR 
                            RegSrc <= "0X0";
                        when '0' =>  -- STR 
                            RegSrc <= "X10";
                        when others =>
                            RegSrc <= (others => '0');
                    end case;
                when "10" => -- Branch instructions
                    case funct(4) is
                        when '0' =>  -- B 
                            RegSrc <= "XX1";
                        when '1' =>  -- BL 
                            RegSrc <= "1X1";
                        when others =>
                            RegSrc <= (others => '0');
                    end case;
                when others =>
                    RegSrc <= (others => '0');
            end case op_case;
        end process RegSrc_Selection;

        ALUSrc_Selection : process (op, funct)
            begin
                op_case : case op is
                    when "00" => 
                        funct_case : case funct(5) is
                            when '1' =>
                                ALUSrc <= '1';  -- Data Processing instructions with an immediate value
                            when '0' =>
                                ALUSrc <= '0';  -- Data Processing instructions where both operands are registers
                            when others =>
                                ALUSrc <= 'X';
                        end case funct_case;
                    when "01" => 
                        ALUSrc <= '1';          -- Memory Access instructions with an immediate offset
                    when "10" => 
                        ALUSrc <= '1';          -- Branch instructions with an immediate value
                    when others =>
                        ALUSrc <= '0';          
                end case op_case;
        end process ALUSrc_Selection;

        ImmSrc_Selection : process (op, funct)
            begin
                op_case : case op is
                    when "00" => 
                        funct_case : case funct(5) is
                            when '1' =>
                                ImmSrc <= '0';  -- Data Processing instructions with an immediate value
                            when '0' =>
                                ImmSrc <= 'X';  -- Data Processing instructions where both operands are registers
                             when others =>
                                ImmSrc <= 'X';
                        end case funct_case;
                    when "01" => 
                        ImmSrc <= '0';          -- Memory Access instructions with an immediate offset
                    when "10" => 
                        ImmSrc <= '1';          -- Branch instructions with an immediate value
                    when others =>
                        ImmSrc <= '0';          
                end case op_case;
        end process ImmSrc_Selection;
        
        ALUControl_Selection : process(op, funct, shamt5, sh)
        begin
            op_case : case op is
                when "00" =>  -- Data Processing instructions
                    funct_case : case funct(4 downto 1) is
                        when "0100" =>  
                            ALUControl <= "000"; -- ADD
                        when "0010" =>  
                            ALUControl <= "001"; -- SUB
                        when "0000" =>
                            ALUControl <= "010"; -- AND
                        when "0001" => 
                            ALUControl <= "011"; -- EOR
                        when "1111" => 
                            ALUControl <= "110"; -- MVN
                        when "1010" => 
                            ALUControl <= "001"; -- CMP
                        when others =>
                            case funct(5 downto 1) is
                                when "01101" =>
                                    case sh is
                                        when "00" =>  
                                            case shamt5 is
                                                when "00000" =>
                                                    ALUControl <= "100"; -- MOV with register
                                                when others =>
                                                    ALUControl <= "100"; -- LSL 
                                            end case;
                                        when "10" =>
                                            ALUControl <= "100"; --ASR
                                        when others =>
                                            ALUControl <= "XXX";      
                                    end case; 
                                when "11101" =>
                                    ALUControl <= "101";  -- MOV with immediate value
                                when others =>
                                    ALUControl <= "XXX";
                            end case;
                    end case funct_case;
                when "01" =>  -- Memory Access instructions
                    case funct(3) is
                        when '1' =>
                            ALUControl <= "000"; -- LDR or STR (M Imm +)
                        when '0' =>
                            ALUControl <= "001"; -- LDR or STR (M Imm -)
                        when others =>
                            ALUControl <= "XXX";
                    end case;
                when "10" =>  -- Branch instructions
                    ALUControl <= "000"; -- B or BL
                when others =>
                    ALUControl <= "XXX";
            end case op_case;
        end process ALUControl_Selection;

        MemtoReg_Selection : process (op, funct)
        begin
            op_case : case op is
                when "00" => -- Data Processing instructions
                    case funct(4 downto 1) is
                        when "1010" => 
                            MemtoReg <= 'X';  -- CMP
                        when others =>
                            MemtoReg <= '0';  -- Other DP instructions 
                    end case;                       
                when "01" => -- Memory Access instructions
                    case funct(0) is
                        when '1' => 
                            MemtoReg <= '1';  -- LDR
                        when '0' =>
                            MemtoReg <= 'X';  -- STR
                        when others =>
                            MemtoReg <= '0';
                    end case;   
                when "10" => -- Branch instructions
                    MemtoReg <= '0'; -- B or BL
                when others =>
                    MemtoReg <= '0';
            end case op_case;
        end process MemtoReg_Selection;

        NoWrite_in_Selection : process (op, funct)
        begin        
            op_case : case op is
                when "00" =>-- Data Processing instructions
                    case funct(4 downto 1) is
                        when "1010" =>  -- CMP instruction
                            NoWrite_in <= '1';  
                        when others =>
                            NoWrite_in <= '0';  -- Other DP instructions 
                    end case;
                when others =>
                    NoWrite_in <= '0';  
            end case op_case;
        end process NoWrite_in_Selection;
        
end architecture Behavioral;