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
      -- Caso endereco => conteudo
      -- Bits 18 a 7: depende da instrução (consultar planilha para maiores detalhes)
      -- Bits 6 a 4: funct
      -- Bits 3 a 0: opcode
      0  => B"000010100_011_000_0011",    -- 0:  Carrega R3 (o registrador 3) com o valor 20
      1  => B"000100011_100_000_0011",    -- 1:  Carrega R4 com 35
      2  => B"000001010_010_000_0011",    -- 2:  Carrega R2 com 10
      3  => B"001001101_001_000_0011",    -- 3:  Carrega R1 com 77
      4  => B"000000_011_100_000_0110",   -- 4:  Salva R3 (20) no endereço 35 (R4)
      5  => B"000000000_000_000_0011",    -- 5:  Carrega R0 com 0
      6  => B"000000_100_011_000_0110",   -- 6:  Salva R4 (35) no endereço 20 (R3)
      7  => B"000010000_101_000_0011",    -- 7:  Carrega R5 com 16
      8  => B"000100_101_000_000_0110",   -- 8:  Salva R5 (16) no endereço 4 (cte + R0) (cte = 4)
      9  => B"000000_001_100_001_0110",   -- 9:  Busca o conteúdo do endereço 35 (R4) e insere no registrador R1 (R1 = 20)
      10 => B"000000_010_011_001_0110",   -- 10: Busca o conteúdo do endereço 20 (R3) e insere no registrador R2 (R2 = 35)
      11 => B"000000_110_100_000_0100",   -- 11: Copia R4 (35) para A
      12 => B"000000000_010_000_0001",    -- 12: Soma R2 com A e guarda em A (A = A + R2) (A = 35 + 35)
      13 => B"000000_011_110_000_0100",   -- 13: Copia A (70) para R3
      14 => B"000000_110_101_000_0100",   -- 14: Copia R5 (16) para A
      15 => B"000000000_001_001_0001",    -- 15: Subtrai R1 de A e guarda em A (A = A - R1) (A = 16 - 20)
      16 => B"000000_110_101_000_0110",   -- 16: Salva A (-4) no endereço 16 (R5)
      17 => B"000000_000_001_001_0110",   -- 17: Busca o conteúdo do endereço 20 (R1) e insere no registrador R0 (R0 = 35)
      18 => B"000000000_000_000_0001",    -- 18: Soma A com R0 e guarda em A (A = A + R0) (A = -4 + 35)
      19 => B"001001101_100_000_0011",    -- 19: Carrega R4 com 77
      20 => B"000000_100_110_000_0110",   -- 20: Salva R4 (77) no endereço 31 (A)
      21 => B"000000_001_101_001_0110",   -- 21: Busca o conteúdo do endereço 16 (R5) e insere no registrador R1 (R1 = -4)
      22 => B"000000_010_110_001_0110",   -- 22: Busca o conteúdo do endereço 31 (A) e insere no registrador R2 (R2 = 77)
      23 => B"000000000_010_001_0001",    -- 23: Subtrai R2 de A e guarda em A (A = A - R2) (A = 31 - 77)
      24 => B"000000_010_110_000_0100",   -- 24: Copia A (-46) para R2
      25 => B"000000000_011_000_0001",    -- 25: Soma A com R3 e guarda em A (A = A + R3) (A = -46 + 70)
      26 => B"000000_010_100_000_0110",   -- 26: Salva R2 (-46) no endereço 77 (R4)
      27 => B"000000_011_100_001_0110",   -- 27: Busca o conteúdo do endereço 77 (R4) e insere no registrador R3 (R3 = -46)
      28 => B"000000000_010_000_0001",    -- 28: Soma A com R2 e guarda em A (A = A + R2) (A = 24 + (-46))
      29 => B"000000_010_110_000_0100",   -- 29: Copia A (-22) para R2
      30 => B"000000000_000_000_0001",    -- 30: Soma A com R0 e guarda em A (A = A + R0) (A = -22 + 35)
      31 => B"000000_010_100_000_0110",   -- 31: Salva R2 (-22) no endereço 77 (R4)
      32 => B"000000_110_000_001_0110",   -- 32: Busca o conteúdo do endereço 35 (R0) e insere em A (A = 20)
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