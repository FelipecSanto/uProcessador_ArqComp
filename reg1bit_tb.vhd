library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg1bit_tb is
end entity;

architecture a_reg1bit of reg1bit_tb is
    component reg1bit
        port(
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in std_logic;
            data_out : out std_logic
        );
    end component;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal wr_en    : std_logic := '0';
    signal data_in  : std_logic := '0';
    signal data_out : std_logic := '0';

    constant clk_period : time := 100 ns;
    signal finished : std_logic := '0';

begin
    -- Instanciação da UUT (Unit Under Test)
    uut: reg1bit
        port map (
            clk => clk,
            rst => rst,
            wr_en => wr_en,
            data_in => data_in,
            data_out => data_out
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

    reset_global : process
    begin
        rst <= '1';
        wait for 2 * clk_period;
        rst <= '0';
        wait;
    end process;

    sim_time_proc : process
    begin
        wait for 1 us;
        finished <= '1';
        wait;
    end process sim_time_proc;

    -- Estímulos de teste
    stim_proc: process
    begin
        -- Esperar o reset
        wait for 2 * clk_period;

        -- Escrever no registrador
        wr_en <= '1';
        data_in <= '1';
        wait for clk_period;

        -- Desabilitar escrita
        wr_en <= '0';
        wait for clk_period;

        -- Escrever novo valor no registrador
        wr_en <= '1';
        data_in <= '0';
        wait for clk_period;

        -- Desabilitar escrita
        wr_en <= '0';
        wait for clk_period;

        wait;
    end process;
end architecture;