library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uProcessador_tb is
end entity;

architecture a_uProcessador_tb of uProcessador_tb is
    component uProcessador
        port(
            clk                 : in std_logic;
            PC_rst              : in std_logic;
            data_out_PC         : out unsigned(6 downto 0);
            instruction_reg_o   : out unsigned(18 downto 0);
            op_ULA_o            : out unsigned(2 downto 0);
            estado              : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal PC_rst : std_logic := '0';
    signal data_out_PC_s : unsigned(6 downto 0) := (others => '0');
    signal data_out : unsigned(18 downto 0) := (others => '0');
    signal estado : std_logic := '0';

    constant clk_period : time := 100 ns;
    signal finished : std_logic := '0';

begin
    uut: uProcessador
        port map (
            clk => clk,
            PC_rst => PC_rst,
            data_out_PC => data_out_PC_s,
            instruction_reg_o => data_out,
            op_ULA_o => open,
            estado => estado
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

    -- Processo para definir o tempo de simulação
    sim_time_proc : process
    begin
        wait for 1650 ns;
        finished <= '1';
        wait;
    end process sim_time_proc;

    -- Estímulos de teste
    stim_proc: process
    begin
        
        wait for clk_period*3;
 
        wait;
    end process;
end architecture;