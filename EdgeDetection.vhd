library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity EdgeDetection is
    Port (
        clk      : in  STD_LOGIC;
        pixel_in : in  STD_LOGIC_VECTOR(7 downto 0);
        edge_out : out STD_LOGIC_VECTOR(7 downto 0)
    );
end EdgeDetection;

architecture Behavioral of EdgeDetection is
    signal gx, gy : signed(9 downto 0);
    signal magnitude : unsigned(9 downto 0);

    type sobel_array is array (0 to 2, 0 to 2) of integer;
    constant sobel_x : sobel_array := ((-1, 0, 1), (-2, 0, 2), (-1, 0, 1));
    constant sobel_y : sobel_array := ((-1, -2, -1), (0, 0, 0), (1, 2, 1));

begin
    process(clk)
    begin
        if rising_edge(clk) then
            gx <= to_signed(sobel_x(0, 0) * to_integer(unsigned(pixel_in)), 10) +
                  to_signed(sobel_x(0, 1) * to_integer(unsigned(pixel_in)), 10) +
                  to_signed(sobel_x(0, 2) * to_integer(unsigned(pixel_in)), 10);

            gy <= to_signed(sobel_y(0, 0) * to_integer(unsigned(pixel_in)), 10) +
                  to_signed(sobel_y(0, 1) * to_integer(unsigned(pixel_in)), 10) +
                  to_signed(sobel_y(0, 2) * to_integer(unsigned(pixel_in)), 10);

            magnitude <= unsigned(abs(gx)) + unsigned(abs(gy));
            edge_out <= std_logic_vector(magnitude(7 downto 0));
        end if;
    end process;
end Behavioral;
