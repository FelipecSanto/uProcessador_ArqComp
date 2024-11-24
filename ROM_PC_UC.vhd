library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM_PC_UC is
    port(
        clk                 : in std_logic;
        PC_rst              : in std_logic;
        data_out_PC         : out unsigned(6 downto 0);
        instruction_reg_o   : out unsigned(18 downto 0);
        op_ULA_o            : out unsigned(2 downto 0);
        wr_addr             : out unsigned(2 downto 0);
        rd_addr             : out unsigned(2 downto 0);
        data_in_regbank     : out unsigned(15 downto 0);
        regs_en             : out std_logic;
        acumulador_en       : out std_logic;
        mov_instruction_out : out std_logic;
        estado              : out unsigned(1 downto 0)
    );
end entity;

architecture a_ROM_PC_UC of ROM_PC_UC is
    component instruction_reg is
        port( 
           clk      : in std_logic;
           rst      : in std_logic;
           wr_en    : in std_logic;
           data_in  : in unsigned(18 downto 0);
           data_out : out unsigned(18 downto 0)
        );
     end component;

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
            PC_wr_en_i  : in std_logic;
            jump_abs_i  : in std_logic;
            jump_rel_i  : in std_logic;
            jump_addr_i : in unsigned(6 downto 0);
            data_in     : in unsigned(6 downto 0);
            data_out    : out unsigned(6 downto 0)
        );
    end component;

    component UC
        port(
            clk                 : in std_logic;
            instruction         : in unsigned(18 downto 0);
            PC_wr_en_o          : out std_logic;
            jump_abs_o          : out std_logic;
            jump_rel_o          : out std_logic;
            jump_addr_o         : out unsigned(6 downto 0);
            op_ULA              : out unsigned(2 downto 0);
            wr_addr_o           : out unsigned(2 downto 0);
            rd_addr_o           : out unsigned(2 downto 0);
            data_in_regbank_o   : out unsigned(15 downto 0);
            regs_en_o           : out std_logic;
            acumulador_en_o     : out std_logic;
            mov_instruction_o   : out std_logic;
            estado              : out unsigned(1 downto 0)
        );
    end component;

    signal address_instruction : unsigned(6 downto 0) := (others => '0');
    signal instruction_s : unsigned(18 downto 0) := (others => '0');
    signal instruction_reg_s : unsigned(18 downto 0) := (others => '0');
    signal PC_wr_en_s : std_logic := '0';
    signal jump_abs : std_logic := '0';
    signal jump_rel : std_logic := '0';
    signal jump_addr : unsigned(6 downto 0) := (others => '0');
    signal op_ULA_s : unsigned(2 downto 0) := (others => '0');

begin

    PC_inst: PC_adder
        port map (
            clk         => clk,
            PC_rst      => PC_rst,
            PC_wr_en_i  => PC_wr_en_s,
            jump_abs_i  => jump_abs,
            jump_rel_i  => jump_rel,
            jump_addr_i => jump_addr,
            data_in     => (others => '0'),
            data_out    => address_instruction
        );

    ROM_inst: ROM
        port map (
            clk        => clk,
            endereco   => address_instruction,
            dado       => instruction_s
        );

    instruction_reg_inst: instruction_reg
        port map (
            clk      => clk,
            rst      => '0',
            wr_en    => '1',
            data_in  => instruction_s,
            data_out => instruction_reg_s
        );

    UC_inst: UC
        port map (
            clk                 => clk,
            instruction         => instruction_reg_s,
            PC_wr_en_o          => PC_wr_en_s,
            jump_abs_o          => jump_abs,
            jump_rel_o          => jump_rel,
            jump_addr_o         => jump_addr,
            op_ULA              => op_ULA_s,
            wr_addr_o           => wr_addr,
            rd_addr_o           => rd_addr,
            data_in_regbank_o   => data_in_regbank,
            regs_en_o           => regs_en,
            acumulador_en_o     => acumulador_en,
            mov_instruction_o   => mov_instruction_out,
            estado              => estado
        );

        instruction_reg_o <= instruction_reg_s; -- Para visualização
end architecture;