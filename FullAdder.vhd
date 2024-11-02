library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FullAdder is
    Port (
        A : in std_logic;
        B : in std_logic;
        Cin : in std_logic;
        Sum : out std_logic;
        Cout : out std_logic
    );
end entity;

architecture a_FullAdder of FullAdder is
begin
    Sum <= A xor B xor Cin;
    Cout <= (A and B) or (Cin and (A xor B));
end architecture;