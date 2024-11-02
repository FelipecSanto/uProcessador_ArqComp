library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Somador is
    Port (
        A : in unsigned(15 downto 0);
        B : in unsigned(15 downto 0);
        Sum : out unsigned(15 downto 0);
        Cout : out STD_LOGIC
    );
end entity;

architecture a_Somador of Somador is
    signal Carry : unsigned(15 downto 0);

    component FullAdder
        Port (
            A : in std_logic;
            B : in std_logic;
            Cin : in std_logic;
            Sum : out std_logic;
            Cout : out std_logic
        );
    end component;

begin
    
    FA0: FullAdder Port map (A => A(0), B => B(0), Cin => '0', Sum => Sum(0), Cout => Carry(0));
    FA1: FullAdder Port map (A => A(1), B => B(1), Cin => Carry(0), Sum => Sum(1), Cout => Carry(1));
    FA2: FullAdder Port map (A => A(2), B => B(2), Cin => Carry(1), Sum => Sum(2), Cout => Carry(2));
    FA3: FullAdder Port map (A => A(3), B => B(3), Cin => Carry(2), Sum => Sum(3), Cout => Carry(3));
    FA4: FullAdder Port map (A => A(4), B => B(4), Cin => Carry(3), Sum => Sum(4), Cout => Carry(4));
    FA5: FullAdder Port map (A => A(5), B => B(5), Cin => Carry(4), Sum => Sum(5), Cout => Carry(5));
    FA6: FullAdder Port map (A => A(6), B => B(6), Cin => Carry(5), Sum => Sum(6), Cout => Carry(6));
    FA7: FullAdder Port map (A => A(7), B => B(7), Cin => Carry(6), Sum => Sum(7), Cout => Carry(7));
    FA8: FullAdder Port map (A => A(8), B => B(8), Cin => Carry(7), Sum => Sum(8), Cout => Carry(8));
    FA9: FullAdder Port map (A => A(9), B => B(9), Cin => Carry(8), Sum => Sum(9), Cout => Carry(9));
    FA10: FullAdder Port map (A => A(10), B => B(10), Cin => Carry(9), Sum => Sum(10), Cout => Carry(10));
    FA11: FullAdder Port map (A => A(11), B => B(11), Cin => Carry(10), Sum => Sum(11), Cout => Carry(11));
    FA12: FullAdder Port map (A => A(12), B => B(12), Cin => Carry(11), Sum => Sum(12), Cout => Carry(12));
    FA13: FullAdder Port map (A => A(13), B => B(13), Cin => Carry(12), Sum => Sum(13), Cout => Carry(13));
    FA14: FullAdder Port map (A => A(14), B => B(14), Cin => Carry(13), Sum => Sum(14), Cout => Carry(14));
    FA15: FullAdder Port map (A => A(15), B => B(15), Cin => Carry(14), Sum => Sum(15), Cout => Cout);

end architecture;