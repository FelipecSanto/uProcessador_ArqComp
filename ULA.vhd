library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    Port (
        -- Entradas e saídas
        A : in unsigned(15 downto 0);
        B : in unsigned(15 downto 0);
        Op : in unsigned(1 downto 0);
        Result : out unsigned(15 downto 0);
        -- Flags
        CarryOut : out STD_LOGIC;
        Equal : out STD_LOGIC;
        Negative : out STD_LOGIC;
        Overflow : out STD_LOGIC
    );
end entity;

architecture a_ULA of ULA is
    -- Operações
    signal soma : unsigned(16 downto 0);
    signal subtracao : unsigned(16 downto 0);
    signal notA : unsigned(15 downto 0);
    signal igualdade : unsigned(15 downto 0);
    -- Resultado
    signal resultadoParcial : unsigned(16 downto 0);

begin

    -- Operações

        soma <= ('0'&A) + ('0'&B);
        subtracao <= ('0'&A) - ('0'&B);
        notA <= not A;
        igualdade <= A;

        resultadoParcial <= soma            when Op="00" else
                            subtracao       when Op="01" else
                            ('0'&notA)      when Op="10" else
                            ('0'&igualdade) when Op="11" else
                            "00000000000000000";

    -- Flags

        Overflow <= '1' when (Op = "00" and A(15) = '1' and B(15) = '1' and resultadoParcial(15) = '0') else
                    '1' when (Op = "00" and A(15) = '0' and B(15) = '0' and resultadoParcial(15) = '1') else
                    '0';
                        
        Negative <= resultadoParcial(15);

        CarryOut <= resultadoParcial(16) when Op = "00" else '0';

        Equal <= '1' when A = B else '0';

    -- Resultado 

        Result <=  resultadoParcial (15 downto 0); 

end architecture;