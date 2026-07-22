library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Grayscale is
    Port (
        clk    : in  STD_LOGIC;
        R, G, B: in  STD_LOGIC_VECTOR(7 downto 0);
        Gray   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Grayscale;

architecture Behavioral of Grayscale is
begin
    process(clk)
        variable temp: unsigned(15 downto 0);
    begin
        if rising_edge(clk) then
            temp := (unsigned(R) * 299 + unsigned(G) * 587 + unsigned(B) * 114) / 1000;
            Gray <= std_logic_vector(temp(7 downto 0));
        end if;
    end process;
end Behavioral;
