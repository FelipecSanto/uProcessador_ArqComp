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
    signal soma : unsigned(15 downto 0);
    signal subtracao : unsigned(15 downto 0);
    signal carryOut_soma : STD_LOGIC;
    signal eq : STD_LOGIC;

    component Comparator
        Port (
            A : in unsigned(15 downto 0);
            B : in unsigned(15 downto 0);
            Equal : out STD_LOGIC
        );
    end component;

    component Somador
        Port (
            A : in unsigned(15 downto 0);
            B : in unsigned(15 downto 0);
            Sum : out unsigned(15 downto 0);
            Cout : out STD_LOGIC
        );
    end component;

begin

    -- OPERAÇOES

        soma_inst: Somador
            Port map (
                A => A,
                B => B,
                Sum => soma,
                Cout => carryOut_soma
            );

        subtracao <= A - B;

    -- FLAGS

        Overflow <= '1' when (Op = "00" and A(15) = B(15) and A(15) /= soma(15)) else
                    '1' when (Op = "01" and A(15) /= B(15) and A(15) /= subtracao(15)) else
                    '0';
                        
        -- Será que considera quando dá overflow e fica negativo aqui?
        -- Será que a gente considera negativo quando nega o A?
        
        Negative <= subtracao(15) when Op="01" else '0';

        CarryOut <= carryOut_soma when Op="00" else '0';

        comp_inst: Comparator
            Port map (
                A => A,
                B => B,
                Equal => eq
            );


    -- DEFINIÇÃO DE QUAL OPERAÇÃO É REALIZADA

        Result <=   soma(15 downto 0)       when Op="00" else
                    subtracao(15 downto 0)  when Op="01" else
                    not A                   when Op="10" else
                                            "0000000000000000";

        Equal <= eq when Op = "11" else '0';
    
end architecture;