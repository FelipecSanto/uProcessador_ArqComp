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
      0  => B"000000010_001_000_0011",    -- 0:  Carrega R1 (o registrador 1) com o valor 2
      1  => B"001011110_010_000_0011",    -- 1:  Carrega R2 com 94
      2  => B"000000_001_010_000_0110",   -- 2:  Salva R1 (2) no endereço R2 (94) 
      3  => B"000000001_110_000_0011",    -- 3:  Carrega A com 1                          |
      4  => B"000000000_010_000_0001",    -- 4:  Soma A com R2 e guarda em A (A = A + R2) | R2 ++
      5  => B"000000_010_110_000_0100",   -- 5:  Copia A para R2                          |
      6  => B"000000001_110_000_0011",    -- 6:  Carrega A com 1                             |
      7  => B"000000000_001_000_0001",    -- 7:  Soma A com R1 e guarda em A (A = A + R1)    |  R1++
      8  => B"000000_001_110_000_0100",   -- 8:  Copia A para R1                             |
      9  => B"000100000_110_000_0011",    -- 9:  Carrega A com 32                                           |
      10 => B"000000000_001_000_0101",    -- 10: Compara o valor de A com R1                                |  Condição loop
      11 => B"00000_1110111_001_1111",    -- 11: Salto condicional se menor igual (BLE) para o endereço -9  |
      -- Inicialização de variáveis para o próximo loop
      12 => B"000000010_000_000_0011",    -- 12: Carrega R0 com 2
      13 => B"000000001_001_000_0011",    -- 13: Carrega R1 com 1
      14 => B"001100000_010_000_0011",    -- 14: Carrega R2 com 96
      15 => B"111111111_011_000_0011",    -- 15: Carrega R3 com -1
      16 => B"001011110_100_000_0011",    -- 16: Carrega R4 com 94
      -- Loop interno 1 - para retirar os números não primos
      17 => B"000000_011_010_000_0110",   -- 17: Salva R3 no endereço R2               
      18 => B"000000_110_010_000_0100",   -- 18: Copia R2 para A                             |
      19 => B"000000000_000_000_0001",    -- 19: Soma A com R0 e guarda em A (A = A + R0)    |  R2 += R0
      20 => B"000000_010_110_000_0100",   -- 20: Copia A para R2                             |
      21 => B"001111110_110_000_0011",    -- 21: Carrega A com 126                                          |
      22 => B"000000000_010_000_0101",    -- 22: Compara o valor de A com R2                                |  Condição loop interno 1
      23 => B"00000_1110111_001_1111",    -- 23: Salto condicional se menor igual (BLE) para o endereço -9  |
      -- loop interno 2 - para procurar o próximo número primo que será usado como nova incrementação
      24 => B"000000001_110_000_0011",    -- 24: Carrega A com 1                             |
      25 => B"000000000_100_000_0001",    -- 25: Soma A com R4 e guarda em A (A = A + R4)    | R4++
      26 => B"000000_100_110_000_0100",   -- 26: Copia A para R4                             |
      27 => B"000000_101_100_001_0110",   -- 27: Busca o conteúdo do endereço (R4) e insere no registrador R5 
      28 => B"000000000_110_000_0011",    -- 28: Carrega A com 0                                         |
      29 => B"000000000_101_000_0101",    -- 29: Compara o valor de A com R5                             |  Condição loop interno 2
      30 => B"00000_1111010_010_1111",    -- 30: Salto condicional se negativo (BMI) para o endereço -6  | 
      31 => B"000000_000_101_000_0100",   -- 31: Copia R5 para R0                                        
      32 => B"000000_110_100_000_0100",   -- 32: Copia R4 para A                             |
      33 => B"000000000_000_000_0001",    -- 33: Soma A com R0 e guarda em A (A = A + R0)    |  Novo início do loop interno 1
      34 => B"000000_010_110_000_0100",   -- 34: Copia A para R2   
      35 => B"000000011_110_000_0011",    -- 35: Carrega A com 3                                            |
      36 => B"000000000_001_000_0101",    -- 36: Compara o valor de A com R1                                |  Condição loop externo
      37 => B"00000_1101100_001_1111",    -- 37: Salto condicional se menor igual (BLE) para o endereço -20 | 
      -- Inicialização de variáveis para o próximo loop  
      38 => B"000000000_001_000_0011",    -- 38: Carrega R1 com 0
      39 => B"001011110_100_000_0011",    -- 39: Carrega R4 com 94   
      -- Loop para passar todos os primos até 31 pras posições iniciais da RAM em ordem crescente um atrás do outro 
      40 => B"000000_000_100_001_0110",   -- 40: Busca o conteúdo do endereço (R4) e insere no registrador R0      
      41 => B"000000001_110_000_0011",    -- 41: Carrega A com 1                             |
      42 => B"000000000_100_000_0001",    -- 42: Soma A com R4 e guarda em A (A = A + R4)    | R4++
      43 => B"000000_100_110_000_0100",   -- 43: Copia A para R4                             |     
      44 => B"000000000_110_000_0011",    -- 44: Carrega A com 0                                         |
      45 => B"000000000_000_000_0101",    -- 45: Compara o valor de A com R0                             | if (R0 >= 0)
      46 => B"00000_1111010_010_1111",    -- 46: Salto condicional se negativo (BMI) para o endereço -6  |
      -- {
      47 => B"000000_000_001_000_0110",   -- 47: Salva R0 no endereço R1 
      48 => B"000000001_110_000_0011",    -- 48:  Carrega A com 1                             |
      49 => B"000000000_001_000_0001",    -- 49:  Soma A com R1 e guarda em A (A = A + R1)    |  R1++
      50 => B"000000_001_110_000_0100",   -- 50:  Copia A para R1                             |
      -- }
      51 => B"000011110_110_000_0011",    -- 51: Carrega A com 30                                            |
      52 => B"000000000_000_000_0101",    -- 52: Compara o valor de A com R0                                 |  Condição loop interno 2
      53 => B"00000_1110011_001_1111",    -- 53: Salto condicional se menor igual (BLE) para o endereço -13  |                             
      -- Inicialização de variáveis para o próximo loop 
      54 => B"000000000_001_000_0011",    -- 54: Carrega R1 com 0
      55 => B"001011110_100_000_0011",    -- 55: Carrega R4 com 94
      -- Loop para passar os números primos para a posição 94 em diante da RAM
      56 => B"000000_010_001_001_0110",   -- 56: Busca o conteúdo do endereço R1 e insere no registrador R2  
      57 => B"000000_010_100_000_0110",   -- 57: Salva R2 no endereço R4 
      58 => B"000000001_110_000_0011",    -- 58:  Carrega A com 1                             |
      59 => B"000000000_001_000_0001",    -- 59:  Soma A com R1 e guarda em A (A = A + R1)    |  R1++
      60 => B"000000_001_110_000_0100",   -- 60:  Copia A para R1                             |
      61 => B"000000001_110_000_0011",    -- 61: Carrega A com 1                             |
      62 => B"000000000_100_000_0001",    -- 62: Soma A com R4 e guarda em A (A = A + R4)    | R4++
      63 => B"000000_100_110_000_0100",   -- 63: Copia A para R4                             |                  
      64 => B"000011110_110_000_0011",    -- 64: Carrega A com 30                                            |
      65 => B"000000000_010_000_0101",    -- 65: Compara o valor de A com R2                                 |  Condição loop 
      66 => B"00000_1110110_001_1111",    -- 66: Salto condicional se menor igual (BLE) para o endereço -10  |  
      -- Inicialização de variáveis para o próximo loop
      67 => B"001011110_001_000_0011",    -- 67: Carrega R1 com 94
      -- Loop para mostrar a sequência de números primos
      68 => B"000000_000_001_001_0110",   -- 68: Busca o conteúdo do endereço R1 e insere no registrador R0
      69 => B"000000001_110_000_0011",    -- 69:  Carrega A com 1                             |
      70 => B"000000000_001_000_0001",    -- 70:  Soma A com R1 e guarda em A (A = A + R1)    |  R1++
      71 => B"000000_001_110_000_0100",   -- 71:  Copia A para R1                             | 
      72 => B"000011110_110_000_0011",    -- 72: Carrega A com 30                                            |
      73 => B"000000000_010_000_0101",    -- 73: Compara o valor de A com R2                                 |  Condição loop 
      74 => B"00000_1111010_001_1111",    -- 74: Salto condicional se menor igual (BLE) para o endereço -6  |  
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