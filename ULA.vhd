library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    Port (
        A           : in unsigned(15 downto 0);
        B           : in unsigned(15 downto 0);
        Op          : in unsigned(1 downto 0);
        Result      : out unsigned(15 downto 0);
        -- Flags
        Equal       : out std_logic;
        Negative    : out std_logic;
        Overflow    : out std_logic
    );
end entity;

architecture a_ULA of ULA is
    -- Operações
    signal soma : unsigned(16 downto 0) := (others => '0');
    signal subtracao : unsigned(16 downto 0) := (others => '0');
    signal notA : unsigned(15 downto 0) := (others => '0');
    signal A_and_B : unsigned (16 downto 0) := (others => '0');
    -- Resultado
    signal resultadoParcial : unsigned(16 downto 0) := (others => '0');
    -- Flags
    signal V : std_logic := '0';       -- Overflow

begin

    -- OPERAÇÕES

        soma        <=  ('0' & A) + ('0' & B);      -- SOMA
        subtracao   <=  ('0' & A) - ('0' & B);      -- SUBTRAÇÃO
        notA        <=  not A;                      -- NEGAÇÃO DE A
        A_and_B     <=  ('0' & A) and ('0' & B);    -- AND
        
        -- MULTIPLEXADOR 2x4 PARA ESCOLHA DA OPERAÇÃO
        
        resultadoParcial <= soma            when Op="00" else
                            subtracao       when Op="01" else
                            ('0' & notA)    when Op="10" else
                            A_and_B         when Op="11" else
                            "00000000000000000";
        
        -- FLAGS           

        V <= '1' when (Op = "00" and A(15) = B(15) and resultadoParcial(15) /= A(15)) else
             '1' when (Op = "01" and A(15) /= B(15) and resultadoParcial(15) /= A(15)) else
             '0';
                        
        Negative <= resultadoParcial(15) when V = '0' else '0';

        Overflow <= V;

        Equal <= '1' when A = B else '0';

    -- RESULTADO

        Result <=  resultadoParcial (15 downto 0); 

end architecture;