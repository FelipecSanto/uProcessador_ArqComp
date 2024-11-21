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
   type mem is array (0 to 127) of unsigned(18 downto 0);
   constant conteudo_ROM : mem := (
      -- caso endereco => conteudo
      0  => "0000000000000000000",
      1  => "0000000000000000001",
      2  => "0000000000000000010",
      3  => "0000000000000000011",
      4  => "0000000000000000100",
      5  => "0000000000000000101",
      6  => "0000000000000000110",
      7  => "0000000000000000111",
      8  => "0000000000000001000",
      9  => "0000000000000001001",
      10 => "0000000000000001010",
      -- abaixo: casos omissos => (zero em todos os bits)
      others => (others=>'0')
   );
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         dado <= conteudo_ROM(to_integer(endereco));
      end if;
   end process;
end architecture;