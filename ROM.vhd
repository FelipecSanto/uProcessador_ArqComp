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
      0  => B"000000000_011_000_0011",    -- A: Carrega R3 (o registrador 3) com o valor 0
      1  => B"000000000_100_000_0011",    -- B: Carrega R4 com 0
      2  => B"000000_110_011_000_0100",   -- C: Copia R3 para A
      3  => B"000000000_100_000_0001",    -- C: Soma R4 com A e guarda em A
      4  => B"000000_100_110_000_0100",   -- C: Copia A para R4
      5  => B"000000001_000_000_0011",    -- D: Carrega R0 com o valor 1
      6  => B"000000_110_011_000_0100",   -- D: Copia R3 para A
      7  => B"000000000_000_000_0001",    -- D: Soma R0 com A e guarda em A
      8  => B"000000_011_110_000_0100",   -- D: Copia A para R3
      9  => B"000011110_110_000_0011",    -- E: Carrega A com 30
      10 => B"000000000_011_000_0101",    -- E: Faz o CMPI R3, A (R3 - A, ou seja, R3 - 30)
      11 => B"00000_1110111_010_1111",    -- E: Faz o jump relativo para C se R3<30 (bmi)
      12 => B"000000_101_100_000_0100",   -- F: Copia R4 para R5
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