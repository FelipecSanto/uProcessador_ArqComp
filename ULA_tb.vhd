library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA_tb is
end entity;

architecture a_ULA_tb of ULA_tb is
    
    component ULA is
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
    end component;

    signal A : unsigned(15 downto 0) := (others => '0');
    signal B : unsigned(15 downto 0) := (others => '0');
    signal Op : unsigned(1 downto 0) := (others => '0');
    signal Result : unsigned(15 downto 0);
    signal CarryOut : STD_LOGIC;
    signal Equal : STD_LOGIC;
    signal Negative : STD_LOGIC;
    signal Overflow : STD_LOGIC;

begin

    uut: ULA
        Port map (
            A => A,
            B => B,
            Op => Op,
            Result => Result,
            CarryOut => CarryOut,
            Equal => Equal,
            Negative => Negative,
            Overflow => Overflow
        );

        stim_proc: process
        begin

            -- Test case 1: A = 3, B = 2, Op = "00" (adição) - Resultado esperado: 5
                A <= to_unsigned(3, 16);
                B <= to_unsigned(2, 16);
                Op <= "00";
                wait for 10 ns;

            -- Test case 2: A = 2^16 - 1, B = 1, Op = "00" (adição) - Resultado esperado: Overflow
                A <= to_unsigned(2**15 - 1, 16);
                B <= to_unsigned(1, 16);
                Op <= "00";
                wait for 10 ns;

            -- Test case 3: A = 2^16 - 1, B = 1, Op = "00" (adição) - Resultado esperado: carry
                A <= to_unsigned(2**16 - 1, 16);
                B <= to_unsigned(1, 16);
                Op <= "00";
                wait for 10 ns;
    
            -- Test case 4: A = 5, B = 3, Op = "01" (subtração) - Resultado esperado: 2
                A <= to_unsigned(5, 16);
                B <= to_unsigned(3, 16);
                Op <= "01";
                wait for 10 ns;

            -- Test case 5: A = -8, B = 9, Op = "01" (subtração) - Resultado esperado: -17
                A <= to_unsigned(8, 16);
                B <= to_unsigned(9, 16);
                Op <= "01";
                wait for 10 ns;
    
            -- Test case 6: A = 6, B = X, Op = "10" (not)
            A <= to_unsigned(6, 16);
            B <= (others => '0');
            Op <= "10";
            wait for 10 ns;
    
            -- Test case 7: A = 7, B = 8, Op = "11" (iguandaldade)
            A <= to_unsigned(7, 16);
            B <= to_unsigned(8, 16);
            Op <= "11";
            wait for 10 ns;
    
            -- Test case 8: A = 2^15, B = 2^15, Op = "11" (iguandaldade)
            A <= to_unsigned(2**15, 16);
            B <= to_unsigned(2**15, 16);
            Op <= "11";
            wait for 10 ns;
    
            -- Stop simulation
            wait;
        end process;
end architecture;