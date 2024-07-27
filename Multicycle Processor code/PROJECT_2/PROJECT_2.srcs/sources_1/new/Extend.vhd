library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Performs 32-bit Extension for various types of instructions
entity Extend is
    generic
    (N : integer := 32);
    port (
        Imm     : in std_logic_vector (23 downto 0);  -- Immediate field of the instruction (Instr[23:0])
        ImmSrc  : in std_logic;                       -- Control Signal for different instructions
        ExtImm  : out std_logic_vector (N-1 downto 0) -- 32-bit extension of the immediate field
    );
end entity Extend;

architecture Behavioral of Extend is
begin
 Extension : process (Imm, ImmSrc)
  begin
    case ImmSrc is
        -- Zero Extension from 12-bit to 32-bit
      when '0' => ExtImm <= std_logic_vector(resize(unsigned(Imm(11 downto 0)), N));
        -- Sign Extension from 26-bit to 32-bit
      when '1' => ExtImm <= std_logic_vector(resize(signed(Imm) * 4, N));
        --  Unexpected inputs
      when others => ExtImm <= (others => 'X');
    end case;
  end process Extension;
end architecture Behavioral;



