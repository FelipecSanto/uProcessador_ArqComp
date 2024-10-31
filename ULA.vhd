library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    Port (
        A : in unsigned(15 downto 0);
        B : in unsigned(15 downto 0);
        Op : in unsigned(1 downto 0);
        Result : out unsigned(15 downto 0);
        CarryOut : out STD_LOGIC;
        Equal : out STD_LOGIC;
        Negative : out STD_LOGIC;
        Overflow : out STD_LOGIC
    );
end entity;

architecture a_ULA of ULA is
    signal soma : unsigned(16 downto 0);
    signal subtracao : unsigned(15 downto 0);

    component Comparator
        Port (
            A : in unsigned(15 downto 0);
            B : in unsigned(15 downto 0);
            Equal : out STD_LOGIC
        );
    end component;

begin

    -- OPERAÇOES

    soma <= A + B;
    subtracao <= A - B;

    -- FLAGS

    Overflow <= '1' when (Op = "00" and A(15) = B(15) and A(15) /= soma(15)) else
                '1' when (Op = "01" and A(15) /= B(15) and A(15) /= subtracao(15)) else
                '0';
                    
    Negative <= subtracao(15);

    CarryOut <= soma(16);

    comp_inst: Comparator
        Port map (
            A => A,
            B => B,
            Equal => Equal
    );


    -- DEFINIÇÃO DE QUAL OPERAÇÃO É REALIZADA

    Result <=   soma(15 downto 0)       when Op="00" else
                subtracao(15 downto 0)  when Op="01" else
                A                       when Op="10" else
                A                       when Op="11" else
                                        "0000000000000000";
    
end architecture;