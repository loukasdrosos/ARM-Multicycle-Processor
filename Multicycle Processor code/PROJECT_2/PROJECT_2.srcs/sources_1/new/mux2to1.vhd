library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux2to1 is
    generic (N : integer := 32);
    port (
        SEL     : in std_logic;                        -- Selection Signal
        Input_1 : in std_logic_vector(N - 1 downto 0); -- Input data 1
        Input_2 : in std_logic_vector(N - 1 downto 0); -- Input data 2
        Output  : out std_logic_vector(N - 1 downto 0) -- Output data
    );
end entity mux2to1;

architecture Behavioral of mux2to1 is
begin
    Selection : process (SEL, Input_1, Input_2)
        begin
            case SEL is
                when '0' => Output <= Input_1;
                when '1' => Output <= Input_2;
                when others => Output <= (others => 'X');
             end case;
    end process Selection;
end architecture Behavioral;
