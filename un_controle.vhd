library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity un_controle is 
    port(
        clk: in std_logic;
        instruction: in unsigned(18 downto 0);
        -- PC adder:
        PC_wr_en      : out std_logic;
        jump_abs      : out std_logic;
        jump_rel      : out std_logic;
        jump_addr     : out unsigned(6 downto 0);
        -- maquina_estados
        estado       : out std_logic
    );
end entity;

architecture a_un_controle of un_controle is

    component maquina_estados
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            estado  : out std_logic
        );
    end component;

    signal opcode    : unsigned(3 downto 0);
    signal rst_s     : std_logic := '0';
    signal estado_s : std_logic := '0';
begin

    maq_estados: maquina_estados
        port map (
            clk => clk,
            rst => rst_s,
            estado => estado_s
        );
    
    opcode <= instruction(3 downto 0);
    
    -- JUMPS
    jump_abs <= '1' when opcode="1111" else '0';
    jump_addr <= instruction(10 downto 4);

    -- ATUALIZAR PC
    PC_wr_en <= '1' when estado_s = '1' else '0';

    estado <= estado_s;

end architecture;
 