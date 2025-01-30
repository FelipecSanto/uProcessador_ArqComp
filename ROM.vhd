library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
   port( 
      clk      : in std_logic;
      endereco : in unsigned(6 downto 0);
      dado     : out unsigned(18 downto 0) 
   );
end entity;

architecture a_ROM of ROM is
   signal dado_s : unsigned(18 downto 0) := (others => '0');
   type mem is array (0 to 127) of unsigned(18 downto 0);
   constant conteudo_ROM : mem := (
      -- caso endereco => conteudo
      -- bit 18 a 7: depende da instrução (por enquanto ver UC para saber cada uma)
      -- bit 6 a 4: funct
      -- bit 3 a 0: opcode
      0  => B"000010100_011_000_0011",    -- Carrega R3 (o registrador 3) com o valor 20
      1  => B"000100011_100_000_0011",    -- Carrega R4 com 35
      2  => B"000001010_010_000_0011",    -- Carrega R2 com 10
      3  => B"000000000_001_000_0011",    -- Carrega R1 com 0
      4  => B"000000_011_100_000_0110",   -- Salva R3 no endereço 35 (R4)
      5  => B"000000000_000_000_0011",    -- Carrega R0 com 0
      6  => B"000000_011_100_000_0110",   -- Salva R4 no endereço 20 (R3)
      7  => B"000010000_000_000_0011",    -- Carrega R0 com 16
      8  => B"000100_000_000_000_0110",   -- Salva R0 no endereço 4 (cte)
      9  => B"000000_001_100_001_0110",   -- Busca o conteúdo do endereço 35 e põe no registrador R1
      10 => B"000000_010_011_000_0110",   -- Busca o conteúdo do endereço 20 e põe no registrador R2
      11 => B"000000_110_100_000_0100",   -- Copia R4 para A
      12 => B"000000000_010_000_0001",    -- Soma R2 com A e guarda em A
      13 => B"000000_011_110_000_0100",   -- Copia A para R3
      -- abaixo: casos omissos => (zero em todos os bits)
      others => (others=>'0')
   );
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         dado_s <= conteudo_ROM(to_integer(unsigned(endereco)));
      end if;   
   end process;

   dado <= dado_s;
end architecture;