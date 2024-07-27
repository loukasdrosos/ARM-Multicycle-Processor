library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
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
end entity ALU;

architecture Behavioral of ALU is
    
    begin
     
     Operations : process (SrcA, SrcB, shamt5, sh, ALUControl)
      
      variable temp_A       : signed(WIDTH+1 downto 0);
      variable temp_B       : signed(WIDTH+1 downto 0);
      variable temp_Result  : signed(WIDTH+1 downto 0);
      variable temp_and_xor : std_logic_vector(WIDTH - 1 downto 0);

      begin
        -- Default assignments to avoid latches        
        temp_A := (others => '0');
        temp_B := (others => '0');
        temp_Result := (others => '0');
        temp_and_xor := (others => '0');
        ALUResult <= (others => '0');
        N <= '0';
        Z <= '0'; 
        C <= '0';
        V <= '0';
    
        case ALUControl is
    
          when "000" => -- ADD(S)
            temp_A := signed('0' & SrcA(WIDTH - 1) & SrcA);
            temp_B := signed('0' & SrcB(WIDTH - 1) & SrcB);
            temp_Result := temp_A + temp_B;
            ALUResult <= std_logic_vector (temp_Result(WIDTH - 1 downto 0));
            V <= std_logic(temp_Result(WIDTH) xor temp_Result(WIDTH - 1));
            C <= std_logic(temp_Result(WIDTH + 1));
            if (temp_Result(WIDTH - 1 downto 0) = 0) then
              Z <= '1';
            else
              Z <= '0';
            end if;
            if (temp_Result(WIDTH - 1) = '1') then
              N <= '1';
            else
              N <= '0';
            end if;
            
          when "001" => -- SUB(S)    
            temp_A := signed('0' & SrcA(WIDTH - 1) & SrcA);
            temp_B := signed('0' & not SrcB(WIDTH - 1) & not SrcB) + 1;
            temp_Result := temp_A + temp_B;
            ALUResult <= std_logic_vector (temp_Result(WIDTH - 1 downto 0));
            V <= std_logic(temp_Result(WIDTH) xor temp_Result(WIDTH - 1));
            C <= std_logic(temp_Result(WIDTH + 1));
            if (temp_Result(WIDTH - 1 downto 0) = 0) then
              Z <= '1';
            else
              Z <= '0';
            end if;
            if (temp_Result(WIDTH - 1) = '1') then
              N <= '1';
            else
              N <= '0';
            end if;
            
          when "010" => -- AND(S)
            temp_and_xor := SrcA and SrcB;
            ALUResult <= SrcA and SrcB;
            V <= '0';
            C <= '0';
            if (signed(temp_and_xor) = 0) then
              Z <= '1';
            else
              Z <= '0';
            end if;
            if (temp_and_xor(WIDTH - 1) = '1') then
              N <= '1';
            else
              N <= '0';
            end if;
    
          when "011" => -- EOR(S) 
            temp_and_xor := SrcA xor SrcB;
            ALUResult <= SrcA xor SrcB;
            V <= '0';
            C <= '0';
            if (signed(temp_and_xor) = 0) then
              Z <= '1';
            else
              Z <= '0';
            end if;
            if (temp_and_xor(WIDTH - 1) = '1') then
              N <= '1';
            else
              N <= '0';
            end if;
            
          when "100" =>  -- LSL or ASR (or MOV for specific criteria)
            shift_type : case sh is
               when "00" => -- sh = 00 --> LSL(or MOV)
                   Specific_case : case shamt5 is
                        when "00000" => -- MOV(S=0) 
                            ALUResult <= SrcB;
                        when others => -- LSL(S=0)
                            ALUResult <= std_logic_vector(shift_left(unsigned(SrcB), to_integer(unsigned(shamt5))));
                   end case Specific_case;
               when "10" => -- sh = 10 --> ASR(S=0)
                   ALUResult <= std_logic_vector(shift_right(signed(SrcB), to_integer(unsigned(shamt5))));
               when others =>
                   ALUResult <= (others => '0');
            end case shift_type;
            
          when "101" =>  -- MOV(S=0)
            ALUResult <= SrcB;
     
          when "110" => -- MVN(S=0) (NOT)
            ALUResult <= not SrcB;
    
          when others => -- Unexpected inputs
            ALUResult <= (others => '0');
            
        end case; 
        
      end process Operations; 
end architecture Behavioral;
