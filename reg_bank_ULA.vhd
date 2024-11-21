library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_bank_ULA is
    port(
        clk             : in std_logic;
        rst             : in std_logic;
        regs_en         : in std_logic;
        save_in_bank    : in std_logic; -- Escolhe se a saída da ULA deve entrar no acumulador ou salvar no banco
        acumulador_en   : in std_logic;
        wr_addr         : in unsigned(2 downto 0); -- Seleciona o registrador de escrita (3 bits para 6 registradores)
        rd_addr         : in unsigned(2 downto 0); -- Seleciona o registrador de leitura (3 bits para 6 registradores)
        ula_op          : in unsigned(1 downto 0); -- Operação que a ULA faz (00 = Adição, 01 = Subtração, 10 = Negação, 11 = AND)
        flagZero        : out std_logic;
        flagNegative    : out std_logic;
        flagOverflow    : out std_logic;
        data_in         : in unsigned(15 downto 0);
        data_out        : out unsigned(15 downto 0)
    );
end entity;

architecture a_reg_bank_ULA of reg_bank_ULA is

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
            A           : in unsigned(15 downto 0);
            B           : in unsigned(15 downto 0);
            Op          : in unsigned(1 downto 0);
            Result      : out unsigned(15 downto 0);
            Zero        : out std_logic;
            Negative    : out std_logic;
            Overflow    : out std_logic
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

    signal regBank_data_out : unsigned(15 downto 0) := (others => '0');
    signal ula_result : unsigned(15 downto 0) := (others => '0');
    signal acumulador_out : unsigned(15 downto 0) := (others => '0');
    signal data_in_bank : unsigned(15 downto 0) := (others => '0');

begin

    -- Mux para escolher quando registrar o resultado da ULA no banco
    data_in_bank <= ula_result when save_in_bank = '1' else data_in;

    -- Instanciação do banco de registradores
    reg_bank_inst: reg_bank
        port map (
            clk => clk,
            rst => rst,
            reg_wr_en => regs_en,
            selec_reg_wr => wr_addr,
            selec_reg_rd => rd_addr,
            data_wr => data_in_bank,
            data_r1 => regBank_data_out
        );

    -- Instanciação da ULA
    ula_inst: ULA
        port map (
            A => regBank_data_out,
            B => acumulador_out,
            Op => ula_op,
            Result => ula_result,
            Zero => flagZero,
            Negative => flagNegative,
            Overflow => flagOverflow
        );

    -- Instanciação do acumulador
    acumulador_inst: reg16bits
        port map (
            clk => clk,
            rst => rst,
            wr_en => acumulador_en,
            data_in => ula_result,
            data_out => acumulador_out
        );

    -- Saída de dados
    data_out <= ula_result;

end architecture;