library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UC is 
    port(
        clk                 : in std_logic;
        instruction         : in unsigned(18 downto 0);
        -- PC adder:
        PC_wr_en_o          : out std_logic;
        jump_abs_o          : out std_logic;
        jump_rel_o          : out std_logic;
        jump_addr_o         : out unsigned(6 downto 0);
        -- ULA:
        op_ULA              : out unsigned(2 downto 0);
        -- reg_bank:
        wr_addr_o           : out unsigned(2 downto 0);
        rd_addr_o           : out unsigned(2 downto 0);
        data_in_regbank_o   : out unsigned(15 downto 0);
        regs_en_o           : out std_logic;
        acumulador_en_o     : out std_logic;
        mov_instruction_o   : out std_logic;
        -- maquina_estados
        estado              : out unsigned(1 downto 0)
    );
end entity;

architecture a_UC of UC is

    component maquina_estados
        port( 
            clk    : in std_logic;
            rst    : in std_logic;
            estado : out unsigned(1 downto 0)
        );
     end component;

    signal opcode   : unsigned(3 downto 0) := (others => '0');
    signal funct    : unsigned(2 downto 0) := (others => '0');
    signal rst_s    : std_logic := '0';
    signal estado_s : unsigned(1 downto 0) := (others => '0');
begin

    maq_estados: maquina_estados
        port map (
            clk => clk,
            rst => rst_s,
            estado => estado_s
        );
    
    ------------------------------------------- DECODIFICAÇÃO DA INSTRUÇÃO ----------------------------------------------------------

    funct <= instruction(6 downto 4);
    opcode <= instruction(3 downto 0);


    -- OPERAÇÕES ARITMÉTICAS
    op_ULA <=   "000" when (opcode = "0000" and funct = "000") else             -- ADD A, R0    A = A + R0
                "001" when (opcode = "0000" and funct = "001") else             -- SUB A, R0    A = A - R0
                "100";
    rd_addr_o <= instruction(9 downto 7) when (opcode = "0000") else
                 (others => '0');

    
    -- OPERAÇÕES LÓGICAS
    op_ULA <=   "010" when (opcode = "0001" and funct = "000") else             -- NEG A       A = ~A
                "011" when (opcode = "0001" and funct = "001") else             -- AND A, R0   A = A & R0
                "100";
    rd_addr_o <= instruction(9 downto 7) when (opcode = "0001") else
                 (others => '0');

    acumulador_en_o <= '1' when (opcode = "0001" or opcode = "0000") else '0';  -- Habilita o acumulador para operações da ULA


    -- LD R0,cte    R0 = cte
    regs_en_o <= '1' when (opcode = "0010" and funct = "000") else '0';     -- Habilita a escrita no banco de registradores
    wr_addr_o <= instruction(9 downto 7) when (opcode = "0010") else        -- Escreve no registrador com endereco wr_addr_o
                 (others => '0');
    
    data_in_regbank_o <= "0000000" & instruction(18 downto 10) when (opcode = "0010") -- Constante a ser escrita no registrador wr_addr_o
                        else (others => '0');

    -- MOV R0, R1    R0 = R1 
    regs_en_o <= '1' when (opcode = "0011" and funct = "000") else '0';     -- Habilita a escrita no banco de registradores
    wr_addr_o <= instruction(12 downto 10) when (opcode = "0011") else      -- Escreve no registrador com endereco wr_addr_o (R0)
                 (others => '0');
    rd_addr_o <= instruction(9 downto 7) when (opcode = "0011") else        -- Leitura do registrador com endereco rd_addr_o (R1)
                 (others => '0');
    mov_instruction_o <= '1' when (opcode = "0011") else '0';               --

    -- JUMPS
    jump_abs_o <=   '1' when (opcode = "1111" and funct = "000") else '0';  -- Pula para a instrução jump_addr_o
    jump_rel_o <=   '1' when (opcode = "1111" and funct = "001") else '0';  -- Pula jump_addr_o instruções
    jump_addr_o <=  instruction(13 downto 7) when (opcode = "1111") else
                    (others => '0');

    
    
    -- ATUALIZAR PC
    PC_wr_en_o <= '1' when estado_s = '01' else '0';

    estado <= estado_s;

end architecture;
 