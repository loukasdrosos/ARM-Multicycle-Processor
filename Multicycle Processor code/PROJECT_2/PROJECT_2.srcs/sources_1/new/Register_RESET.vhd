library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register_RESET is  -- 32-bit non-architectural register with ONLY RESET signal
    generic (
        N : integer := 32 -- Parameter for the size of the register
    );
    port (
        CLK      : in  std_logic;                      -- Clock signal
        RESET    : in  std_logic;                      -- Reset signal
        Data_in  : in  std_logic_vector(N-1 downto 0); -- Input data
        Data_out : out std_logic_vector(N-1 downto 0)  -- Output data
    );
end entity Register_RESET;

architecture Behavioral of Register_RESET is
begin
    -- Process to handle clock and reset
    process (CLK)
    begin
    if rising_edge(CLK) then
        if (RESET = '1') then
            Data_out <= (others => '0');  -- Reset the register to 0
        else
            Data_out <= Data_in;          -- Load data into the register
        end if;
    end if;
   end process;
end architecture Behavioral;