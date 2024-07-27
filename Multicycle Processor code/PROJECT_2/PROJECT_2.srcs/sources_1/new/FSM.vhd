library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Finite_State_Machine is
    port
    (
        CLK         : in std_logic;                         -- Clock signal
        RESET       : in std_logic;                         -- Reset signal
        op          : in std_logic_vector (1 downto 0);     -- op field of instr(27:26)
        S           : in std_logic;                         -- Instr(20), determines CMP in data-processing instructions and LDR or STR in memory instructions
        L           : in std_logic;                         -- Instr(24), determines the branch instruction (B or BL)
        Rd          : in std_logic_vector (3 downto 0);     -- Destination regiter of the instruction
        NoWrite_in  : in std_logic;                         -- Instruction Decoder output, Separates CMP from other DP instructions
        CondEx_in   : in std_logic;                         -- Conditional Logic output, approves the execution of the instruction when it receives value 1
        IRWrite     : out std_logic;                        -- Write Enable to the Instruction Register
        RegWrite    : out std_logic;                        -- Write Enable to Register File
        MAWrite     : out std_logic;                        -- Write Enable to the Memory Address Register
        MemWrite    : out std_logic;                        -- Write Enable of RAM data memory
        FlagsWrite  : out std_logic;                        -- Enables updating the condition flags (N, Z, C, V) on the status register based on the ALU result
        PCSrc       : out std_logic_vector (1 downto 0);    -- Determines the source of the next PC value
        PCWrite     : out std_logic                         -- Update Enable of the PC
    );
end entity Finite_State_Machine;

architecture Behavioral of Finite_State_Machine is

    type FSM_states is
        (S0,S1,S2a,S2b,S3,S4a,S4b,S4c,S4d,S4e,S4f,S4g,S4h,S4i);
    
    signal current_state, next_state : FSM_states;

    begin

        -- State register
        SYNC: process (CLK)
            begin
                if rising_edge(CLK) then
                    if RESET = '1' then
                        current_state <= S0;
                    else
                        current_state <= next_state;
                    end if;
                end if;
        end process SYNC;
        
        -- Next state logic and output logic
        ASYNC: process (current_state, op, S, L, Rd, NoWrite_in, CondEx_in)
            begin
                --FSM next state and output initialization
                IRWrite <= '0';
                RegWrite <= '0';
                MAWrite <= '0';
                MemWrite <= '0';
                FlagsWrite <= '0';
                PCSrc <= "00";
                PCWrite <= '0';     
                next_state <= S0;   
     
                case current_state is
                    when S0 =>
                        IRWrite <= '1';
                        next_state <= S1;
                    when S1 =>
                        if CondEx_in = '0'                                        -- Not executed                                
                            then next_state <= S4c;  
                        elsif CondEx_in = '1' and op = "01"                       -- LDR or STR                     
                            then next_state <= S2a;
                        elsif CondEx_in = '1' and op = "00" and NoWrite_in = '0'  -- Data Processing (except CMP)
                            then next_state <= S2b;            
                        elsif CondEx_in = '1' and op = "00" and NoWrite_in = '1'  -- CMP
                            then next_state <= S4g;
                        elsif CondEx_in = '1' and op = "10" and L = '0'           -- B
                            then next_state <= S4h;
                        elsif CondEx_in = '1' and op = "10" and L = '1'           -- BL
                            then next_state <= S4i;
                        else next_state <= S0;                                    -- Invalid instruction      
                        end if;
                    when S2a =>
                        MAWrite <= '1';              
                        if S = '1'                        -- LDR
                            then next_state <= S3;
                        elsif S = '0'                     -- STR
                            then next_state <= S4d;
                        else next_state <= current_state; -- Error
                        end if;
                    when S2b =>
                        if S = '0' and unsigned(Rd) /= "1111" 
                            then next_state <= S4a;
                        elsif S = '0' and unsigned(Rd) = "1111"   
                            then next_state <= S4b;
                        elsif S = '1' and unsigned(Rd) /= "1111"  
                            then next_state <= S4e;
                        elsif S = '1' and unsigned(Rd) = "1111"   
                            then next_state <= S4f;
                        else next_state <= current_state; -- Error
                        end if;
                    when S3 =>
                        if unsigned(Rd) /= "1111"   
                            then next_state <= S4a;
                        elsif unsigned(Rd) = "1111"   
                            then next_state <= S4b;
                        else next_state <= current_state; -- Error
                        end if;
                    when S4a =>
                        RegWrite <= '1';
                        PCWrite <= '1';
                        next_state <= S0;
                    when S4b =>
                        PCSrc <= "10";
                        PCWrite <= '1';
                        next_state <= S0;
                    when S4c =>
                        PCWrite <= '1';
                        next_state <= S0;
                    when S4d =>
                        MemWrite <= '1';
                        PCWrite <= '1';
                        next_state <= S0;
                    when S4e =>
                        RegWrite <= '1';
                        FlagsWrite <= '1';
                        PCWrite <= '1';
                        next_state <= S0;
                    when S4f =>
                        FlagsWrite <= '1';
                        PCSrc <= "10";
                        PCWrite <= '1';
                        next_state <= S0;
                    when S4g =>
                        FlagsWrite <= '1';
                        PCWrite <= '1';
                        next_state <= S0;
                    when S4h =>
                        PCSrc <= "11";
                        PCWrite <= '1';
                        next_state <= S0;
                    when S4i =>                       
                        RegWrite <= '1';
                        PCSrc <= "11";
                        PCWrite <= '1';
                        next_state <= S0;
                    when others =>
                        next_state <= S0;
                end case;
        end process ASYNC;

end architecture Behavioral;