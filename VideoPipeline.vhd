library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VideoPipeline is
    Port (
        clk       : in  STD_LOGIC;
        R1, G1, B1 : in  STD_LOGIC_VECTOR(7 downto 0);
        R2, G2, B2 : in  STD_LOGIC_VECTOR(7 downto 0);
        processed1 : out STD_LOGIC_VECTOR(7 downto 0);
        processed2 : out STD_LOGIC_VECTOR(7 downto 0)
    );
end VideoPipeline;

architecture Behavioral of VideoPipeline is
    signal gray_pixel1, gray_pixel2 : std_logic_vector(7 downto 0);
    signal edge_pixel1, edge_pixel2 : std_logic_vector(7 downto 0);

    component Grayscale
        Port (
            clk    : in  STD_LOGIC;
            R, G, B: in  STD_LOGIC_VECTOR(7 downto 0);
            Gray   : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component EdgeDetection
        Port (
            clk      : in  STD_LOGIC;
            pixel_in : in  STD_LOGIC_VECTOR(7 downto 0);
            edge_out : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

begin
    -- Parallel Grayscale modules
    grayscale1: Grayscale
        Port map (
            clk => clk,
            R   => R1,
            G   => G1,
            B   => B1,
            Gray => gray_pixel1
        );

    grayscale2: Grayscale
        Port map (
            clk => clk,
            R   => R2,
            G   => G2,
            B   => B2,
            Gray => gray_pixel2
        );

    -- Parallel Edge Detection modules
    edge1: EdgeDetection
        Port map (
            clk      => clk,
            pixel_in => gray_pixel1,
            edge_out => edge_pixel1
        );

    edge2: EdgeDetection
        Port map (
            clk      => clk,
            pixel_in => gray_pixel2,
            edge_out => edge_pixel2
        );

    processed1 <= edge_pixel1;
    processed2 <= edge_pixel2;
end Behavioral;
