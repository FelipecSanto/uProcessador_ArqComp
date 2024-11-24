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
      0  => B"000000000000_000_0000",  -- pula 1 instrução (indo para a instrução 1) -- instrução sem jump
      1  => B"000000000000_010_1110",  -- pula 2 instruções (indo para a instrução 3) -- instrução com jump relativo
      2  => B"000000000000_110_1111",  -- vai para a instrução 6 -- instrução com jump absoluto
      3  => B"000000000000_000_0011",  -- pula 1 instruções (indo para a instrução 4) -- instrução sem jump
      4  => B"000000000000_000_0100",  -- pula 1 instruções (indo para a instrução 5) -- instrução sem jump
      5  => B"000000000000_010_1111",  -- vai para a instrução 2 -- instrução com jump absoluto
      6  => B"000000000000_000_1111",  -- vai para a instrução 0 -- instrução com jump absoluto
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