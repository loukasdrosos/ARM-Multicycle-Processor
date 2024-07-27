library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Instruction Memory ROM
entity IM_ROM is
    generic (
        N : integer := 6;  -- Adress length (bits)
        M : integer := 32  -- Data word length (bits)
    );
    port (
        Address   : in std_logic_vector(N-1 downto 0);  -- Input Address
        Read_Data : out std_logic_vector(M-1 downto 0)  -- Output data
    );
end entity IM_ROM;

architecture Behavioral of IM_ROM is
    type ROM_array is array (0 to 2**N-1) of std_logic_vector (M-1 downto 0); 
       

        constant ROM : ROM_array := ( -- 64 words
        X"E3A00000", X"E3A01005", X"E3A0200C", X"E3A0300F",
        X"E3A0400F", X"E3A05001", X"E0806001", X"E2427009",
        X"E0068007", X"E0888007", X"E3580004", X"E0279008",
        X"E3A0A00F", X"E1E0B00A", X"E1A0C08B", X"E1A0D24C",
        X"E058E006", X"0A00000A", X"E052E008", X"AA000000",
        X"E2808000", X"E0578001", X"B2887001", X"E0477001",
        X"E5827054", X"E5901060", X"E08FF000", X"E280200E",
        X"E291100D", X"75801064", X"EBFFFFE0", X"00000000",
        X"00000000", X"00000000", X"00000000", X"00000000",
        X"00000000", X"00000000", X"00000000", X"00000000",
        X"00000000", X"00000000", X"00000000", X"00000000",
        X"00000000", X"00000000", X"00000000", X"00000000",
        X"00000000", X"00000000", X"00000000", X"00000000",
        X"00000000", X"00000000", X"00000000", X"00000000",
        X"00000000", X"00000000", X"00000000", X"00000000",
        X"00000000", X"00000000", X"00000000", X"00000000"  );


    begin
        Read_Data <= ROM (to_integer(unsigned(Address)));
end architecture Behavioral;