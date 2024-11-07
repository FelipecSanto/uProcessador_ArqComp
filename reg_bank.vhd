library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_bank is
   port(
      clk           : in std_logic;
      rst           : in std_logic;
      reg_wr_en     : in std_logic;
      selec_reg_wr  : in unsigned(2 downto 0);
      selec_reg_rd  : in unsigned(2 downto 0);
      data_wr       : in unsigned(15 downto 0);
      data_r1       : out unsigned(15 downto 0)
   );
end entity;

architecture a_reg_bank of reg_bank is
    type reg_array is array (0 to 5) of unsigned(15 downto 0);
    signal regs : reg_array := (others => (others => '0'));
    signal reg_wr_en_signals : unsigned(5 downto 0) := (others => '0');

    component reg16bits
        port(
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;

begin

    -- Multiplexador para selecionar o registrador de escrita (se o banco de registradores estiber habilitado para escrita)
    reg_wr_en_signals <= "000001" when (selec_reg_wr = "000" and reg_wr_en = '1') else
                         "000010" when (selec_reg_wr = "001" and reg_wr_en = '1') else
                         "000100" when (selec_reg_wr = "010" and reg_wr_en = '1') else
                         "001000" when (selec_reg_wr = "011" and reg_wr_en = '1') else
                         "010000" when (selec_reg_wr = "100" and reg_wr_en = '1') else
                         "100000" when (selec_reg_wr = "101" and reg_wr_en = '1') else
                         (others => '0');

    -- Instanciação dos registradores
    reg0: reg16bits
        port map (
            clk => clk,
            rst => rst,
            wr_en => reg_wr_en_signals(0),
            data_in => data_wr,
            data_out => regs(0)
        );

    reg1: reg16bits
        port map (
            clk => clk,
            rst => rst,
            wr_en => reg_wr_en_signals(1),
            data_in => data_wr,
            data_out => regs(1)
        );

    reg2: reg16bits
        port map (
            clk => clk,
            rst => rst,
            wr_en => reg_wr_en_signals(2),
            data_in => data_wr,
            data_out => regs(2)
        );

    reg3: reg16bits
        port map (
            clk => clk,
            rst => rst,
            wr_en => reg_wr_en_signals(3),
            data_in => data_wr,
            data_out => regs(3)
        );

    reg4: reg16bits
        port map (
            clk => clk,
            rst => rst,
            wr_en => reg_wr_en_signals(4),
            data_in => data_wr,
            data_out => regs(4)
        );

    reg5: reg16bits
        port map (
            clk => clk,
            rst => rst,
            wr_en => reg_wr_en_signals(5),
            data_in => data_wr,
            data_out => regs(5)
        );

    -- Multiplexador para selecionar o registrador de leitura
    data_r1 <= regs(0) when selec_reg_rd = "000" else
               regs(1) when selec_reg_rd = "001" else
               regs(2) when selec_reg_rd = "010" else
               regs(3) when selec_reg_rd = "011" else
               regs(4) when selec_reg_rd = "100" else
               regs(5) when selec_reg_rd = "101" else
               (others => '0');

end architecture;