library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File is
    generic (
        N : integer := 4;  -- Adress Size (bits), 2^N registers
        M : integer := 32  -- Word Size (bits)
    );
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
end entity Register_File;

architecture Behavioral of Register_File is
    type reg_file_array is array (0 to 2**N-1) of std_logic_vector(M-1 downto 0);
    signal reg_file : reg_file_array;
    
begin
-- Synchronous Writing of Register File 
    RF_Write : process(CLK)
    begin
        if rising_edge(CLK) then
            if Write_Enable_3 = '1' then
                if Address_3 /= "1111" then  -- Cannot write on R15 ("1111")
                    reg_file(to_integer(unsigned(Address_3))) <= Write_Data_3;
                end if;
            end if;
        end if;
    end process RF_Write;
    
-- Asynchronous Reading of Register File
  -- Read data from Register 1
  RF_Read_1 : process (Address_1, R15)
  begin
    case Address_1 is
      when "1111" =>
        Read_Data_1 <= R15; -- PC + 8
      when others =>
        Read_Data_1 <= reg_file (to_integer(unsigned(Address_1)));
    end case;
  end process RF_Read_1;
  
 -- Read data from Register 2
  RF_Read_2 : process (Address_2, R15)
  begin
    case Address_2 is
      when "1111" =>
        Read_Data_2 <= R15; -- PC + 8
      when others =>
        Read_Data_2 <= reg_file (to_integer(unsigned(Address_2)));
    end case;
  end process RF_Read_2;

end architecture Behavioral;

