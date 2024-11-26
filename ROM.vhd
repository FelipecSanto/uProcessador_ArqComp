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
      0  => B"000000101_011_000_0011",    -- A: Carrega R3 (o registrador 3) com o valor 5
      1  => B"000001000_100_000_0011",    -- B: Carrega R4 com o valor 8
      2  => B"000000_110_011_000_0100",   -- C: Copia R3 para A
      3  => B"000000000_100_000_0001",    -- C: Soma R4 com A e guarda em A
      4  => B"000000_101_110_000_0100",   -- C: Copia A para R5
      5  => B"000000001_001_000_0011",    -- D: Carrega R1 com o valor 1
      6  => B"000000000_001_001_0001",    -- D: Subtrai R1 de A e guarda em A
      7  => B"000000_101_110_000_0100",   -- D: Copia A para R5
      8  => B"00000_0010100_000_1111",    -- E: Salta para o endereço 20
      9  => B"000000000_101_000_0011",    -- F: Carrega R5 com o valor 0 (nunca será executada)
      10 => B"000000000_000_000_0000",    -- F: NOP
      11 => B"000000000_000_000_0000",    -- F: NOP
      12 => B"000000000_000_000_0000",    -- F: NOP
      13 => B"000000000_000_000_0000",    -- F: NOP
      14 => B"000000000_000_000_0000",    -- F: NOP
      15 => B"000000000_000_000_0000",    -- F: NOP
      16 => B"000000000_000_000_0000",    -- F: NOP
      17 => B"000000000_000_000_0000",    -- F: NOP
      18 => B"000000000_000_000_0000",    -- F: NOP
      19 => B"000000000_000_000_0000",    -- F: NOP
      20 => B"000000_011_101_000_0100",   -- G: Copia R5 para R3
      21 => B"00000_0000010_000_1111",    -- H: Salta para o passo C
      22 => B"000000000_011_000_0011",    -- I: Carrega R3 com o valor 0 (nunca será executada)
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