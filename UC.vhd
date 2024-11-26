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

    -- OPERAÇÕES DE ULA
                -- OPERAÇÕES ARITMÉTICAS
    op_ULA <=   "000" when (opcode = "0001" and funct = "000") else             -- ADD A, Rn    A = A + Rn
                "001" when (opcode = "0001" and funct = "001") else             -- SUB A, Rn    A = A - Rn
                
                -- OPERAÇÕES LÓGICAS
                "010" when (opcode = "0010" and funct = "000") else             -- NEG A       A = ~A
                "011" when (opcode = "0010" and funct = "001") else             -- AND A, Rn   A = A & Rn
                "100";

    -- ENDEREÇO DO REGISTRADOR A SER LIDO E INSERIDO NO OPERANDO B DA ULA
    rd_addr_o <= instruction(9 downto 7) when (opcode = "0001"              -- OPERAÇÕES ARITMÉTICAS (LENDO Rn)
                                               or opcode = "0010"           -- OPERAÇÕES LÓGICAS (PARA O NEG ESSE VALOR É IRRELEVANTE)
                                               or opcode = "0100") else     -- MOV Rn, Rm   Rn = Rm (LENDO Rm)
                 "111";


    -- HABILITA O ACUMULADOR PARA AS OPERAÇÕES DE ULA (GAMBIARRA PARA ESCREVER NO ACUMULADOR EM CASO DE MOV A, Rn)
    acumulador_en_o <= '1' when (opcode = "0001" or opcode = "0010" or (opcode = "0100" and instruction(12 downto 10) = "110")) else '0';


    -- HABILITA A ESCRITA NO BANCO DE REGISTRADORES
    regs_en_o <= '1' when ((opcode = "0011" and funct = "000")                  -- LD Rn,cte
                            or (opcode = "0100" and funct = "000")) else '0';   -- MOV Rn, Rm


    -- ENDEREÇO DO REGISTRADOR A SER ESCRITO
    wr_addr_o <= instruction(9 downto 7) when (opcode = "0011") else            -- LD Rn,cte    Rn = cte (instruction(9 downto 7) é irrelevante)
                 instruction(12 downto 10) when (opcode = "0100") else          -- MOV Rn, Rm   Rn = Rm
                 (others => '0');
    
    -- CONSTANTE PRESENTE NA INSTRUÇÃO LD A SER ESCRITA NO BANCO DE REGISTRADORES
    data_in_regbank_o <= "0000000" & instruction(18 downto 10) when (opcode = "0011") else 
                         (others => '0');

    -- MOV Rn, Rm    Rn = Rm (QUANDO 1 FAZ A SAIDA DO BANCO DE REGISTRADORES QUE SERÁ Rm SE TORNAR A ENTRADA DO BANCO DE REGISTRADORES)
    mov_instruction_o <= '1' when (opcode = "0100") else '0';

    -- JUMPS
    jump_abs_o <=   '1' when (opcode = "1111" and funct = "000") else '0';  -- Pula para a instrução jump_addr_o
    jump_rel_o <=   '1' when (opcode = "1111" and funct = "001") else '0';  -- Pula jump_addr_o instruções
    jump_addr_o <=  instruction(13 downto 7) when (opcode = "1111") else
                    (others => '0');


    ------------------------------------------- DECODIFICAÇÃO DA INSTRUÇÃO ----------------------------------------------------------
    
    -- ATUALIZAR PC
    PC_wr_en_o <= '1' when estado_s = '10' else '0';

    estado <= estado_s;

end architecture;
 