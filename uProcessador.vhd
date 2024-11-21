library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uProcessador is
    port(
        clk         : in std_logic;
        PC_rst      : in std_logic;
        data_out    : out unsigned(18 downto 0);
        estado      : out std_logic
    );
end entity;

architecture a_uProcessador of uProcessador is
    component ROM
        port( 
            clk      : in std_logic;
            endereco : in unsigned(6 downto 0);
            dado     : out unsigned(18 downto 0)
        );
    end component;

    component PC_adder
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
    end component;

    component un_controle
        port(
            clk           : in std_logic;
            instruction   : in unsigned(18 downto 0);
            PC_wr_en      : out std_logic;
            jump_abs      : out std_logic;
            jump_rel      : out std_logic;
            jump_addr     : out unsigned(6 downto 0);
            estado        : out std_logic
        );
    end component;

    signal data_out_PC : unsigned(6 downto 0) := (others => '0');
    signal data_out_ROM : unsigned(18 downto 0) := (others => '0');
    signal PC_wr_en : std_logic := '0';
    signal jump_abs : std_logic := '0';
    signal jump_rel : std_logic := '0';
    signal jump_addr : unsigned(6 downto 0) := (others => '0');

begin

    PC_inst: PC_adder
        port map (
            clk        => clk,
            PC_rst     => PC_rst,
            PC_wr_en   => PC_wr_en,
            jump_abs   => jump_abs,
            jump_rel   => jump_rel,
            jump_addr  => jump_addr,
            data_in    => (others => '0'),
            data_out   => data_out_PC
        );

    ROM_inst: ROM
        port map (
            clk        => clk,
            endereco   => data_out_PC,
            dado       => data_out_ROM
        );

    un_controle_inst: un_controle
        port map (
            clk => clk,
            instruction => data_out_ROM,
            PC_wr_en => PC_wr_en,
            jump_abs => jump_abs,
            jump_rel => jump_rel,
            jump_addr => jump_addr,
            estado => estado
        );

    data_out <= data_out_ROM;
end architecture;