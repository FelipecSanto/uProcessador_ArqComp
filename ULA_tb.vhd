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

            -- to_unsigned(3, 16) converte 3 para o tipo unsigned com 16 bits

            -- Test case 1: A = 3, B = 2, Op = "00" (Addition)
            A <= to_unsigned(3, 16);
            B <= to_unsigned(2, 16);
            Op <= "00";
            wait for 10 ns;
    
            -- Test case 2: A = 5, B = 3, Op = "01" (Subtraction)
            A <= to_unsigned(5, 16);
            B <= to_unsigned(3, 16);
            Op <= "01";
            wait for 10 ns;
    
            -- Test case 3: A = 6, B = 9, Op = "10" (AND)
            A <= to_unsigned(6, 16);
            B <= to_unsigned(9, 16);
            Op <= "10";
            wait for 10 ns;
    
            -- Test case 4: A = 7, B = 8, Op = "11" (Equality)
            A <= to_unsigned(7, 16);
            B <= to_unsigned(8, 16);
            Op <= "11";
            wait for 10 ns;
    
            -- Test case 5: A = 4, B = 4, Op = "11" (Equality)
            A <= to_unsigned(4, 16);
            B <= to_unsigned(4, 16);
            Op <= "11";
            wait for 10 ns;
    
            -- Stop simulation
            wait;
        end process;
end architecture;