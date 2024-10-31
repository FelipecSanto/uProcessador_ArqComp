library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Comparator is
    Port (
        A : in unsigned(15 downto 0);
        B : in unsigned(15 downto 0);
        Equal : out STD_LOGIC
    );
end entity;

architecture a_Comparator of Comparator is
begin
    Equal <= '1' when A = B else '0';
end architecture;