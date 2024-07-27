library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity INC4_Adder is
    generic (N : integer := 32);
    port (
        PC     : in std_logic_vector(N-1 downto 0);  -- Input of adder 
        new_PC : out std_logic_vector(N-1 downto 0)  -- Output of adder
    );
end entity INC4_Adder;

-- Calculates PC + 4 (adress of next instruction)
-- Two Inputs: 
    -- 1. Current adress of PC (32 bits)
    -- 2. "00000000000000000000000000000100" (= 4) in unsigned form 
    
architecture Dataflow of INC4_Adder is
begin
     new_PC <= std_logic_vector(unsigned(PC) + 4);
end architecture Dataflow;
