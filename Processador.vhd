library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Processador is
    port(
        clk       : in std_logic;
        rst       : in std_logic;
        wr_en     : in std_logic;
        wr_addr   : in unsigned(2 downto 0); -- Endereço de escrita (3 bits para 6 registradores)
        rd_addr   : in unsigned(2 downto 0); -- Endereço de leitura (3 bits para 6 registradores)
        ula_op    : in unsigned(1 downto 0); -- Operação da ULA
        data_in   : in unsigned(15 downto 0);
        data_out  : out unsigned(15 downto 0)
    );
end entity;

architecture a_Processador of Processador is

    component reg_bank
        port(
            clk             : in std_logic;
            rst             : in std_logic;
            reg_wr_en       : in std_logic;
            selec_reg_wr    : in unsigned(2 downto 0);
            selec_reg_rd    : in unsigned(2 downto 0);
            data_wr         : in unsigned(15 downto 0);
            data_r1         : out unsigned(15 downto 0)
        );
    end component;

    component ULA
        port(
            A : in unsigned(15 downto 0);
            B : in unsigned(15 downto 0);
            Op : in unsigned(1 downto 0);
            Result : out unsigned(15 downto 0);
            Equal : out std_logic;
            Negative : out std_logic;
            Overflow : out std_logic
        );
    end component;

    component reg16bits
        port(
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;

    signal reg_bank_data_out : unsigned(15 downto 0);
    signal ula_result : unsigned(15 downto 0);
    signal equal : std_logic;
    signal negative : std_logic;
    signal overflow : std_logic;
    signal acumulador_out : unsigned(15 downto 0);

begin
    -- Instanciação do banco de registradores
    reg_bank_inst: reg_bank
        port map (
            clk => clk,
            rst => rst,
            reg_wr_en => wr_en,
            selec_reg_wr => wr_addr,
            selec_reg_rd => rd_addr,
            data_wr => data_in,
            data_r1 => reg_bank_data_out
        );

    -- Instanciação da ULA
    ula_inst: ULA
        port map (
            A => acumulador_out,
            B => reg_bank_data_out,
            Op => ula_op,
            Result => ula_result,
            Equal => equal,
            Negative => negative,
            Overflow => overflow
        );

    -- Instanciação do acumulador
    acumulador_inst: reg16bits
        port map (
            clk => clk,
            rst => rst,
            wr_en => '1',
            data_in => ula_result,
            data_out => acumulador_out
        );

    -- Saída de dados
    data_out <= ula_result;

end architecture;