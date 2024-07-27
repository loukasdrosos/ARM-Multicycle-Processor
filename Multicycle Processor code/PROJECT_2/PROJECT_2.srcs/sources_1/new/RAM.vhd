library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Data Memory RAM
entity DM_RAM is
  generic (
    N : integer := 5; -- Adress length (bits)
    M : integer := 32 -- Data word length (bits)
  );
  port (
    CLK       : in std_logic;                        -- Clock signal
    WE        : in std_logic;                        -- Write Enable
    Address   : in std_logic_vector(N - 1 downto 0); -- Input Adress
    Data_In   : in std_logic_vector(M - 1 downto 0); -- Input Data
    Data_Out  : out std_logic_vector(M - 1 downto 0) -- Output Data
  );
end entity DM_RAM;

architecture Behavioral of DM_RAM is
    type RAM_array is array (2**N-1 downto 0) of std_logic_vector(M-1 downto 0);
    signal RAM : RAM_array;

    begin
        --Asynchronous reading of data from RAM
        Data_Out <= RAM(to_integer(unsigned(Address)));
        
        -- Synchronous writing of data to RAM
        process (CLK)
            begin
                if rising_edge(CLK) then
                    if WE = '1' then
                        RAM(to_integer(unsigned(Address))) <= Data_In;
                    end if;
                end if;
        end process;
 
end architecture Behavioral;