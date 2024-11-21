library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC_adder is
    port( 
       clk         : in std_logic;
       PC_rst      : in std_logic;
       PC_wr_en    : in std_logic;
       jump_abs    : in std_logic;
       jump_rel    : in std_logic;
       jump_addr   : in unsigned(6 downto 0);
       data_in     : in unsigned(6 downto 0);
       data_out    : out unsigned(6 downto 0)
    );
end entity;

architecture a_PC_adder of PC_adder is
    component PC
        port(
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(6 downto 0);
            data_out : out unsigned(6 downto 0)
        );
    end component;

    signal PC_data_in  : unsigned(6 downto 0);
    signal PC_data_out : unsigned(6 downto 0);

    begin
        PC_inst: PC
        port map(
            clk      => clk,
            rst      => PC_rst,
            wr_en    => PC_wr_en,
            data_in  => PC_data_in,
            data_out => PC_data_out
        );

        PC_data_in <= jump_addr when jump_abs = '1' else
                      PC_data_out + jump_addr when jump_rel = '1' else
                      PC_data_out + "0000001";

        data_out <= PC_data_out;

end architecture;