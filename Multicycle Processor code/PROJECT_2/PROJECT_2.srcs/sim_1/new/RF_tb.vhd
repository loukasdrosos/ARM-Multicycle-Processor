library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File_tb is
end entity Register_File_tb;

architecture Behavioral of Register_File_tb is

  constant N : integer := 4;  -- Adress Size (bits), 2^N registers
  constant M : integer := 32; -- Word Size (bits)
  
  -- Unit Under Test (UUT) Component
  component Register_File
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
  
  -- UUT Signals
  signal CLK_tb            : std_logic;
  signal Write_Enable_3_tb : std_logic; 
  signal Address_1_tb      : std_logic_vector(N-1 downto 0); 
  signal Address_2_tb      : std_logic_vector(N-1 downto 0); 
  signal Address_3_tb      : std_logic_vector(N-1 downto 0);  
  signal Write_Data_3_tb   : std_logic_vector(M-1 downto 0); 
  signal R15_tb            : std_logic_vector(M-1 downto 0);  
  signal Read_Data_1_tb    : std_logic_vector(M-1 downto 0); 
  signal Read_Data_2_tb    : std_logic_vector(M-1 downto 0);
  
  constant clk_period : time := 10 ns;
        
begin

 -- Instantiate the UUT
  utt : Register_File
  port map(
    Address_1    => Address_1_tb,
    Address_2    => Address_2_tb,
    Address_3    => Address_3_tb,
    Write_Data_3 => Write_Data_3_tb,
    R15          => R15_tb,
    CLK          => CLK_tb,
    Write_Enable_3 => Write_Enable_3_tb,
    Read_Data_1  => Read_Data_1_tb,
    Read_Data_2  => Read_Data_2_tb
  );
  
  -- Clock process
    clock: process is
       begin
          CLK_tb <= '0'; 
          wait for clk_period/2;
          CLK_tb <= '1'; 
          wait for clk_period/2;
    end process clock;
    
  -- Stimulus process
  stimulus : process is
  begin
    wait for 100 ns;
    
    -- Initialize signals
    Write_Enable_3_tb <= '0';
    Address_1_tb <= (others => '0');
    Address_2_tb <= (others => '0');
    Address_3_tb <= (others => '0');
    Write_Data_3_tb <= (others => '0');
    R15_tb <= (others => '0');
    wait for 100 ns;

    -- Write to register 0
    Write_Enable_3_tb <= '1';
    Address_3_tb <= "0000";  -- Register 0
    Write_Data_3_tb <= "00000000000000000000000000000001";
    wait for clk_period;

    -- Write to register 1
    Address_3_tb <= "0001";  -- Register 1
    Write_Data_3_tb <= "11110000000000000000000000000000";
    wait for clk_period;

    -- Write to register 15 (R15 should not change)
    Address_3_tb <= "1111";  -- Register 15
    Write_Data_3_tb <= "00000000000000000000000000000000";
    wait for clk_period;

    -- Disable write enable
    Write_Enable_3_tb <= '0';
    wait for clk_period;

    -- Read from register 0
    Address_1_tb <= "0000";
    wait for clk_period;
    assert Read_Data_1_tb = "00000000000000000000000000000001"
        report "Test failed for register 0" severity error;
        
    -- Read from register 15 for address 1
    -- PC = 4
    R15_tb <= std_logic_vector(unsigned(R15_tb) + 4);
    Address_1_tb <= "1111";
    wait for clk_period;
    assert Read_Data_1_tb = "00000000000000000000000000000100"
        report "Test failed for register 15" severity error;

    -- Read from register 1
    Address_2_tb <= "0001";
    wait for clk_period;
    assert Read_Data_2_tb = "11110000000000000000000000000000"
        report "Test failed for register 1" severity error;

    -- Read from register 15 for address 2
    -- PC = 8
    R15_tb <= std_logic_vector(unsigned(R15_tb) + 4);
    Address_2_tb <= "1111";
    wait for clk_period;
    assert Read_Data_1_tb = "00000000000000000000000000001000"
        report "Test failed for register 15" severity error;

    -- End of the testbench
    report "Testbench completed successfully";
    wait;
  end process stimulus;
end architecture Behavioral;