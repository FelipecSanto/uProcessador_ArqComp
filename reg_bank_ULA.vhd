library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_bank_ULA is
    port(
        clk                 : in std_logic;
        rst                 : in std_logic;
        regs_en             : in std_logic;
        mov_instruction     : in std_logic;
        acumulador_en       : in std_logic;
        wr_addr             : in unsigned(2 downto 0);  -- Seleciona o registrador de escrita (3 bits para 6 registradores)
        rd_addr             : in unsigned(2 downto 0);  -- Seleciona o registrador de leitura (3 bits para 6 registradores)
        ula_op              : in unsigned(2 downto 0);  -- Operação que a ULA faz (00 = Adição, 01 = Subtração, 10 = Negação, 11 = AND)
        data_in_regbank     : in unsigned(15 downto 0);
        flagZero            : out std_logic;
        flagNegative        : out std_logic;
        flagOverflow        : out std_logic;
        ula_result_o        : out unsigned(15 downto 0);
        regBank_data_out_o  : out unsigned(15 downto 0);
        acumulador_out_o    : out unsigned(15 downto 0)
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
            Op          : in unsigned(2 downto 0);
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

    signal regBank_data_out_s : unsigned(15 downto 0) := (others => '0');
    signal ula_result_s : unsigned(15 downto 0) := (others => '0');
    signal acumulador_out_s : unsigned(15 downto 0) := (others => '0');
    signal data_in_regbank_s : unsigned(15 downto 0) := (others => '0');

begin

    -- Mux para escolher quando registrar o resultado da ULA no banco
    data_in_regbank_s <= regBank_data_out_s when mov_instruction = '1' else data_in_regbank;

    -- Instanciação do banco de registradores
    reg_bank_inst: reg_bank
        port map (
            clk => clk,
            rst => rst,
            reg_wr_en => regs_en,
            selec_reg_wr => wr_addr,
            selec_reg_rd => rd_addr,
            data_wr => data_in_regbank_s,
            data_r1 => regBank_data_out_s
        );

    -- Instanciação da ULA
    ula_inst: ULA
        port map (
            A => acumulador_out_s,
            B => regBank_data_out_s,
            Op => ula_op,
            Result => ula_result_s,
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
            data_in => ula_result_s,
            data_out => acumulador_out_s
        );

    -- Saída de dados
    ula_result_o <= ula_result_s;
    regBank_data_out_o <= regBank_data_out_s;
    acumulador_out_o <= acumulador_out_s;

end architecture;