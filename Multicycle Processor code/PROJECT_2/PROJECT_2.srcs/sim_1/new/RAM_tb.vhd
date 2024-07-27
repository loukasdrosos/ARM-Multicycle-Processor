library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DM_RAM_tb is
end entity DM_RAM_tb;

architecture Behavioral of DM_RAM_tb is

    constant N : integer := 5;  -- Address length (bits)
    constant M : integer := 32; -- Data word length (bits)
   
    -- Unit Under Test (UUT) Component
    component DM_RAM
        port (
            CLK        : in std_logic;                        -- Clock signal
            WE         : in std_logic;                        -- Write Enable
            Address    : in std_logic_vector(N - 1 downto 0); -- Input Address
            Data_In    : in std_logic_vector(M - 1 downto 0); -- Input Data
            Data_Out   : out std_logic_vector(M - 1 downto 0) -- Output Data
        );
    end component;

    -- UUT Signals
    signal CLK_tb        : std_logic := '0';
    signal WE_tb         : std_logic;
    signal Address_tb    : std_logic_vector(N - 1 downto 0);
    signal Data_In_tb    : std_logic_vector(M - 1 downto 0);
    signal Data_Out_tb   : std_logic_vector(M - 1 downto 0);

    constant CLK_PERIOD : time := 10 ns;
 
begin

    -- Instantiate the UUT
    uut: DM_RAM
        port map (
            CLK     => CLK_tb,
            WE      => WE_tb,
            Address => Address_tb,
            Data_In => Data_In_tb,
            Data_Out => Data_Out_tb
        );

    -- Clock generation
    clock: process is
         begin
             CLK_tb <= '0'; 
             wait for CLK_PERIOD/2;
             CLK_tb <= '1'; 
             wait for CLK_PERIOD/2;
     end process clock;
        

    -- Stimulus process
    stimulus: process
    begin
        wait for 100 ns;

        -- Initialize signals
        WE_tb <= '0';
        Address_tb <= (others => '0');
        Data_In_tb <= (others => '0');
        wait for 100 ns;

        -- Test case 1: 
        WE_tb <= '1';
        Address_tb <= "00000";
        Data_In_tb <= "00000000000000000000000000000001"; 
        wait for CLK_PERIOD;
        WE_tb <= '0';
        wait for CLK_PERIOD;
        assert (Data_Out_tb = "00000000000000000000000000000001")
            report "Test case 1 failed"
            severity error;

        -- Test case 2: 
        WE_tb <= '1';
        Address_tb <= "00001";
        Data_In_tb <= "00000000000000000000000000000010"; 
        wait for CLK_PERIOD;
        WE_tb <= '0';
        wait for CLK_PERIOD;
        assert (Data_Out_tb = "00000000000000000000000000000010")
            report "Test case 2 failed"
            severity error;

        -- Test case 3: 
        WE_tb <= '0';
        Address_tb <= "00000";
        wait for CLK_PERIOD;
        assert (Data_Out_tb = "00000000000000000000000000000001")
            report "Test case 3 failed"
            severity error;

        -- Test case 4:
        WE_tb <= '1';
        Address_tb <= "00010";
        Data_In_tb <= "00000000000000000000000000000100"; 
        wait for CLK_PERIOD;
        Address_tb <= "00011";
        Data_In_tb <= "00000000000000000000000000001000"; 
        wait for CLK_PERIOD;
        WE_tb <= '0';
        Address_tb <= "00010";
        wait for CLK_PERIOD;
        assert (Data_Out_tb = "00000000000000000000000000000100")
            report "Test case 4 failed"
            severity error;
        Address_tb <= "00011";
        wait for CLK_PERIOD;
        assert (Data_Out_tb = "00000000000000000000000000001000")
            report "Test case 4 failed"
            severity error;

        report "Testbench completed";
        wait;
    end process stimulus;
end architecture Behavioral;

