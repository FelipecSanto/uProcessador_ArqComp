library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
    port(
        clk             : in std_logic;
        rst             : in std_logic;
        data_out_PC_o   : out unsigned(6 downto 0);
        result_ula_o    : out unsigned(15 downto 0);
        regBank_out     : out unsigned(15 downto 0);
        acumulador_out  : out unsigned(15 downto 0);
        instruction_o   : out unsigned(18 downto 0);
        estado_o        : out unsigned(1 downto 0)
    );
end entity;

architecture a_processador of processador is

    component ROM_PC_UC
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
    end component;

    component reg_bank_ULA
        port(
            clk                 : in std_logic;
            rst                 : in std_logic;
            regs_en             : in std_logic;
            mov_instruction     : in std_logic;
            acumulador_en       : in std_logic;
            wr_addr             : in unsigned(2 downto 0);
            rd_addr             : in unsigned(2 downto 0);
            ula_op              : in unsigned(2 downto 0);
            data_in_regbank     : in unsigned(15 downto 0);
            flagZero            : out std_logic;
            flagNegative        : out std_logic;
            flagOverflow        : out std_logic;
            ula_result_o        : out unsigned(15 downto 0);
            regBank_data_out_o  : out unsigned(15 downto 0);
            acumulador_out_o    : out unsigned(15 downto 0)
        );
    end component;

    signal instruction_s : unsigned(18 downto 0) := (others => '0');
    signal regs_en_s : std_logic := '0';
    signal acumulador_en_s : std_logic := '0';
    signal flagZero_s : std_logic := '0';
    signal flagNegative_s : std_logic := '0';
    signal flagOverflow_s : std_logic := '0';
    signal wr_addr_s : unsigned(2 downto 0) := (others => '0');
    signal rd_addr_s : unsigned(2 downto 0) := (others => '0');
    signal ula_op_s : unsigned(2 downto 0) := (others => '0');
    signal data_in_regbank_s : unsigned(15 downto 0) := (others => '0');
    signal mov_instruction_s : std_logic := '0';

begin
    -- Instanciação do ROM_PC_UC
    ROM_PC_UC_inst: ROM_PC_UC
        port map (
            clk => clk,
            PC_rst => rst,
            data_out_PC => data_out_PC_o,
            instruction_reg_o => instruction_s,
            op_ULA_o => ula_op_s,
            wr_addr => wr_addr_s,
            rd_addr => rd_addr_s,
            data_in_regbank => data_in_regbank_s,
            regs_en => regs_en_s,
            acumulador_en => acumulador_en_s,
            mov_instruction_out => mov_instruction_s,
            estado => estado_o
        );

    -- Instanciação do reg_bank_ULA
    reg_bank_ULA_inst: reg_bank_ULA
        port map (
            clk => clk,
            rst => rst,
            regs_en => regs_en_s,                       -- Habilita a escrita no banco de registradores
            mov_instruction => mov_instruction_s,
            acumulador_en => acumulador_en_s,           -- Habilita a escrita no acumulador
            wr_addr => wr_addr_s,                       -- Seleciona o registrador de escrita (3 bits para 6 registradores)
            rd_addr => rd_addr_s,                       -- Seleciona o registrador de leitura (3 bits para 6 registradores)
            ula_op => ula_op_s,                         -- Operação que a ULA faz (00 = Adição, 01 = Subtração, 10 = Negação, 11 = AND)
            data_in_regbank => data_in_regbank_s,       -- Dados de entrada para o banco de registradores
            flagZero => flagZero_s,
            flagNegative => flagNegative_s,
            flagOverflow => flagOverflow_s,
            ula_result_o => result_ula_o,
            regBank_data_out_o => regBank_out,
            acumulador_out_o => acumulador_out
        );

    instruction_o <= instruction_s;

end architecture;