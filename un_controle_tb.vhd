library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity un_controle_tb is
end entity;

architecture a_un_controle_tb of un_controle_tb is
    component un_controle
        port (
            clk           : in std_logic;
            instruction   : in unsigned(18 downto 0);
            PC_wr_en      : out std_logic;
            jump_abs      : out std_logic;
            jump_rel      : out std_logic;
            jump_addr     : out unsigned(6 downto 0);
            estado       : out std_logic
        );
    end component;

    signal clk           : std_logic := '0';
    signal instruction   : unsigned(18 downto 0) := (others => '0');
    signal PC_wr_en      : std_logic := '0';
    signal jump_abs      : std_logic := '0';
    signal jump_rel      : std_logic := '0';
    signal jump_addr     : unsigned(6 downto 0) := (others => '0');
    signal estado       : std_logic := '0';

    constant clk_period : time := 100 ns;
    signal finished : std_logic := '0';

begin

    uut: un_controle
        port map(
            clk => clk,
            instruction => instruction,
            PC_wr_en => PC_wr_en,
            jump_abs => jump_abs,
            jump_rel => jump_rel,
            jump_addr => jump_addr,
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
        wait for 1200 ns;
        finished <= '1';
        wait;
    end process sim_time_proc;

    -- Estímulos de teste
    stim_proc: process
    begin
        
        wait for clk_period*2;
        instruction <= b"00000010_0000011_1111"; -- jump absolute 
        wait for clk_period*2;
        instruction <= b"00000010_0000111_1111"; -- jump absolute

        wait;
    end process;
end architecture;