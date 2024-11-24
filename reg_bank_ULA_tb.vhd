library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_bank_ULA_tb is
end entity;

architecture a_reg_bank_ULA_tb of reg_bank_ULA_tb is
    component reg_bank_ULA
        port(
            clk                 : in std_logic;
            rst                 : in std_logic;
            regs_en             : in std_logic;
            mov_instruction     : in std_logic;
            acumulador_en       : in std_logic;
            wr_addr             : in unsigned(2 downto 0); -- Seleciona o registrador de escrita (3 bits para 6 registradores)
            rd_addr             : in unsigned(2 downto 0); -- Seleciona o registrador de leitura (3 bits para 6 registradores)
            ula_op              : in unsigned(2 downto 0); -- Operação que a ULA faz (00 = Adição, 01 = Subtração, 10 = Negação, 11 = AND)
            data_in_regbank     : in unsigned(15 downto 0);
            flagZero            : out std_logic;
            flagNegative        : out std_logic;
            flagOverflow        : out std_logic;
            ula_result_o        : out unsigned(15 downto 0);
            regBank_data_out_o  : out unsigned(15 downto 0);
            acumulador_out_o    : out unsigned(15 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal regs_en : std_logic := '0';
    signal save_in_bank : std_logic := '0';
    signal acumulador_en : std_logic := '0';
    signal wr_addr : unsigned(2 downto 0) := (others => '0');
    signal rd_addr : unsigned(2 downto 0) := (others => '0');
    signal ula_op : unsigned(2 downto 0) := (others => '0');
    signal Zero : std_logic := '0';
    signal Negative : std_logic := '0';
    signal Overflow : std_logic := '0';
    signal data_in : unsigned(15 downto 0) := (others => '0');
    signal ula_result_s : unsigned(15 downto 0);
    signal regBank_data_out_s : unsigned(15 downto 0);
    signal acumulador_out_s : unsigned(15 downto 0);

    constant clk_period : time := 100 ns;
    signal finished : std_logic := '0';

begin
    uut: reg_bank_ULA
        port map (
            clk => clk,
            rst => rst,
            regs_en => regs_en,
            save_in_bank => save_in_bank,
            acumulador_en => acumulador_en,
            wr_addr => wr_addr,
            rd_addr => rd_addr,
            ula_op => ula_op,
            flagZero => Zero,   
            flagNegative => Negative,
            flagOverflow => Overflow,
            data_in_regbank => data_in,
            ula_result_o => ula_result_s       
            regBank_data_out_o => regBank_data_out_s,
            acumulador_out_o => acumulador_out_s
        );

    -- Geração do clock
    process
    begin
        while finished = '0' loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Processo de reset global
    reset_global : process
    begin
        rst <= '1';
        wait for 2 * clk_period;
        rst <= '0';
        wait;
    end process;

    -- Processo para definir o tempo de simulação
    sim_time_proc : process
    begin
        wait for 1200 ns;
        finished <= '1';
        wait;
    end process sim_time_proc;

    -- Estímulos de teste
    stim_proc: process
    begin
        -- Esperar o reset
        wait for 2 * clk_period;

        -- Escrever 100 no registrador 0
        regs_en <= '1';
        wr_addr <= "000";
        rd_addr <= "000";
        data_in <= to_unsigned(100, 16);
        wait for clk_period;

        -- Escrever 150 no registrador 1
        wr_addr <= "001";
        rd_addr <= "001";
        data_in <= to_unsigned(150, 16);
        wait for clk_period;

        -- Ler do registrador 0 e realizar operação de adição. Resultado: 100 no acumulador
        acumulador_en <= '1';
        regs_en <= '0';
        rd_addr <= "000";
        ula_op <= "000"; -- Operação de adição
        wait for clk_period;

        -- Ler do registrador 1 e realizar operação de subtração. Resultado: registra 50 no acumulador e no registrador 5
        save_in_bank <= '1';
        regs_en <= '1';
        rd_addr <= "001";
        wr_addr <= "101";
        ula_op <= "001"; -- Operação de subtração
        wait for clk_period;

        -- Escrever 2 no registrador 2
        save_in_bank <= '0';
        acumulador_en <= '0';
        regs_en <= '1';
        wr_addr <= "010";
        rd_addr <= "010";
        data_in <= to_unsigned(2, 16);
        wait for clk_period;

        -- Ler do registrador 2 e realizar operação de negação. Resultado: registra -3 no acumulador (ou 65.533), que seria o complemento de 2 de 2
        ula_op <= "010"; -- Operação de negação
        acumulador_en <= '1';
        regs_en <= '0';
        rd_addr <= "010";
        wait for clk_period;

        -- Escrever 11111 no registrador 3
        acumulador_en <= '0';
        regs_en <= '1';
        wr_addr <= "011";
        rd_addr <= "011";
        data_in <= to_unsigned(11111, 16);
        wait for clk_period;

        -- Ler do registrador 3 e realizar operação AND. Resultado: registra 11109 no acumulador
        ula_op <= "011"; -- Operação AND
        acumulador_en <= '1';
        regs_en <= '0';
        rd_addr <= "011";
        wait for clk_period;

        wait;
    end process;
end architecture;