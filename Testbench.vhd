library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.ALL;

entity Testbench is
end Testbench;

architecture Behavioral of Testbench is
    signal clk       : std_logic := '0';
    signal R1, G1, B1 : std_logic_vector(7 downto 0);
    signal R2, G2, B2 : std_logic_vector(7 downto 0);
    signal processed1 : std_logic_vector(7 downto 0);
    signal processed2 : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;

    file video_file : text open read_mode is "C:/Users/Javad/Desktop/video_frames.txt";
    file output_file : text open write_mode is "C:/Users/Javad/Desktop/processed_video_frames.txt";

    component VideoPipeline
        Port (
            clk       : in  STD_LOGIC;
            R1, G1, B1 : in  STD_LOGIC_VECTOR(7 downto 0);
            R2, G2, B2 : in  STD_LOGIC_VECTOR(7 downto 0);
            processed1 : out STD_LOGIC_VECTOR(7 downto 0);
            processed2 : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    function hex_to_integer(hex_str : string) return integer is
        variable result : integer := 0;
        variable value  : integer;
    begin
        for i in hex_str'range loop
            if hex_str(i) >= '0' and hex_str(i) <= '9' then
                value := character'pos(hex_str(i)) - character'pos('0');
            elsif hex_str(i) >= 'A' and hex_str(i) <= 'F' then
                value := character'pos(hex_str(i)) - character'pos('A') + 10;
            else
                value := 0; -- Handle invalid characters
            end if;
            result := result * 16 + value;
        end loop;
        return result;
    end hex_to_integer;

    function integer_to_hex(value : integer; width : integer) return string is
        variable result : string(1 to width);
        variable temp   : integer := value;
        variable digit  : integer;
    begin
        for i in width downto 1 loop
            digit := temp mod 16;
            if digit < 10 then
                result(i) := character'val(character'pos('0') + digit);
            else
                result(i) := character'val(character'pos('A') + digit - 10);
            end if;
            temp := temp / 16;
        end loop;
        return result;
    end integer_to_hex;

begin
    uut: VideoPipeline
        Port map (
            clk       => clk,
            R1        => R1,
            G1        => G1,
            B1        => B1,
            R2        => R2,
            G2        => G2,
            B2        => B2,
            processed1 => processed1,
            processed2 => processed2
        );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    process
        variable line_content : line;
        variable pixel_data1, pixel_data2 : std_logic_vector(23 downto 0);
        variable pixel_value1, pixel_value2 : string(1 to 6);
        variable output_line : line;
        variable frame_count : integer := 0;
        variable hex_value1, hex_value2 : integer;
        variable pixel_in_line : integer := 0;
        variable is_end_of_file : boolean := false;
    begin
        while not is_end_of_file loop
            -- Check if end of file is reached
            if endfile(video_file) then
                is_end_of_file := true;
                wait;
            end if;

            -- Read a line from the file
            readline(video_file, line_content);

            -- Skip empty lines
            if line_content'length = 0 then 
                write(output_line, string'(""));
                writeline(output_file, output_line);

            -- Check for a new frame
            elsif line_content'length > 0 and (line_content(1 to 7) = "# Frame" or line_content(1) = '#') then
                -- Process new frame
                if pixel_in_line > 0 then
                    writeline(output_file, output_line);
                end if;

                -- Log frame start
                write(output_line, "# Frame " & string'(integer'image(frame_count)));
                writeline(output_file, output_line);

                -- Reset counters
                frame_count := frame_count + 1;
                pixel_in_line := 0;
            else
                -- Process pixel data
                for i in 1 to line_content'length / 12 loop
                    -- Extract and convert hex value
                    pixel_value1 := line_content((i-1)*6+1 to i*6);
                    pixel_value2 := line_content((i)*6+1 to (i+1)*6);
                    hex_value1 := hex_to_integer(pixel_value1);
                    hex_value2 := hex_to_integer(pixel_value2);
                    pixel_data1 := std_logic_vector(to_unsigned(hex_value1, 24));
                    pixel_data2 := std_logic_vector(to_unsigned(hex_value2, 24));

                    -- Assign pixel data to signals
                    R1 <= pixel_data1(23 downto 16);
                    G1 <= pixel_data1(15 downto 8);
                    B1 <= pixel_data1(7 downto 0);
                    R2 <= pixel_data2(23 downto 16);
                    G2 <= pixel_data2(15 downto 8);
                    B2 <= pixel_data2(7 downto 0);

                    -- Write processed data to the output file
                    write(output_line, integer_to_hex(to_integer(unsigned(processed1)), 6));
                    write(output_line, string'(" "));
                    write(output_line, integer_to_hex(to_integer(unsigned(processed2)), 6));
                    
                    pixel_in_line := pixel_in_line + 2;

                    if pixel_in_line = 10 then
                        writeline(output_file, output_line);
                        pixel_in_line := 0;
                    else
                        write(output_line, string'(" "));
                    end if;

                    wait for clk_period;
                end loop;
            end if;
        end loop;
    end process;

end Behavioral;