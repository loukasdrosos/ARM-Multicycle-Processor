library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Conditional_Logic is
    port
    (
        cond        : in std_logic_vector (3 downto 0); -- instr(31:28) (Instruction Register Output)
        flags       : in std_logic_vector (3 downto 0); -- N, Z, C, V (Status Register Output)
        CondEx_in   : out std_logic                     -- Conditional Logic output, approves the execution of the instruction when it receives value 1
    );
end entity Conditional_Logic;

architecture behavioral of Conditional_Logic is
begin
  process (cond, flags)
  begin
    case cond is
      when "0000" => -- EQ
        CondEx_in <= flags(2);
      when "0001" => -- NE
        CondEx_in <= not flags(2);
      when "0010" => -- CS/HS
        CondEx_in <= flags(1);
      when "0011" => -- CC/LO
        CondEx_in <= not flags(1);
      when "0100" => -- MI
        CondEx_in <= flags(3);
      when "0101" => -- PL
        CondEx_in <= not flags(3);
      when "0110" => -- VS
        CondEx_in <= flags(0);
      when "0111" => -- VC
        CondEx_in <= not flags(0);
      when "1000" => -- HI
        CondEx_in <= (not flags(2)) and flags(1);
      when "1001" => -- LS
        CondEx_in <= flags(2) or (not flags(1));
      when "1010" => -- GE
        CondEx_in <= not (flags(3) xor flags(0));
      when "1011" => -- LT
        CondEx_in <= flags(3) xor flags(0);
      when "1100" => -- GT
        CondEx_in <= (not flags(2)) and (not (flags(3) xor flags(0)));
      when "1101" => -- LE
        CondEx_in <= flags(2) or (flags(3) xor flags(0));
      when "1110" => -- AL (or none)
        CondEx_in <= '1';
      when "1111" => -- none
        CondEx_in <= '1';
      when others =>
        CondEx_in <= '0';
    end case;
  end process;
end architecture behavioral;