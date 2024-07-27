library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Instruction Memory ROM
entity IM_ROM_tb is
end entity IM_ROM_tb;

architecture Behavioral of IM_ROM_tb is

  constant N : integer := 6;  -- Adress length (bits)
  constant M : integer := 32; -- Data word length (bits)
  
  -- Unit Under Test (UUT) Component
  component IM_ROM
    port (
      Address   : in std_logic_vector(N - 1 downto 0); -- Input Address
      Read_Data : out std_logic_vector(M - 1 downto 0) -- Data word length (bits)
    );
  end component IM_ROM;
  
  -- UUT Signals
  signal Address_tb   : std_logic_vector(N - 1 downto 0);
  signal Read_Data_tb : std_logic_vector(M - 1 downto 0);
  
begin

    -- Instantiate the UUT
    uut : IM_ROM
        port map(
            Address => Address_tb,
            Read_Data => Read_Data_tb
        );
        
        -- Stimulus process
        stimulus: process is
        begin
            wait for 100 ns;
            Address_tb <= std_logic_vector(to_unsigned(0, N));
            wait for 10ns;
            Address_tb <= std_logic_vector(to_unsigned(1, N));
            wait for 10ns;
            Address_tb <= std_logic_vector(to_unsigned(2, N));
            wait for 10ns;
            Address_tb <= std_logic_vector(to_unsigned(5, N));
            wait for 10ns;            
            Address_tb <= std_logic_vector(to_unsigned(8, N));
            wait for 10ns;
            Address_tb <= std_logic_vector(to_unsigned(10, N));
            wait for 10ns;            
            Address_tb <= std_logic_vector(to_unsigned(13, N));
            wait for 10ns;
            Address_tb <= std_logic_vector(to_unsigned(16, N));
            wait for 10ns;
            Address_tb <= std_logic_vector(to_unsigned(24, N));
            wait for 10ns;            
            Address_tb <= std_logic_vector(to_unsigned(32, N));
            wait for 10ns;
            Address_tb <= std_logic_vector(to_unsigned(64, N));
            wait for 10ns;
            wait; 
    end process stimulus;
end architecture Behavioral;