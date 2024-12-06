library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UC is 
    port(
        clk                 : in std_logic;
        rst                 : in std_logic;
        instruction         : in unsigned(18 downto 0);
        flagNegativeFF_in   : in std_logic;
        flagZeroFF_in       : in std_logic;
        flagOverflowFF_in   : in std_logic;
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
        cte_instruction_o   : out unsigned(15 downto 0);
        regs_en_o           : out std_logic;
        acumulador_en_o     : out std_logic;
        flags_en            : out std_logic;
        -- MOV:
        mov_en_o            : out std_logic;
        -- CMPI:
        cmpi_en_o           : out std_logic;
        -- LD:
        ld_en_o             : out std_logic;
        -- maquina_estados:
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

    signal opcode       : unsigned(3 downto 0) := (others => '0');
    signal funct        : unsigned(2 downto 0) := (others => '0');
    signal estado_s     : unsigned(1 downto 0) := (others => '0');
    signal exten_sinal  : unsigned(6 downto 0) := (others => '0');
    signal is_for_acumulator   : boolean := false;
    signal execute          : boolean := false;
    signal eh_ld            : boolean := false;
    signal eh_mov           : boolean := false;
    signal ble : std_logic := '0';
    signal bmi : std_logic := '0';

begin

    maq_estados: maquina_estados
        port map (
            clk => clk,
            rst => rst,
            estado => estado_s
        );

        execute <= (estado_s = "10");
    
    ------------------------------------------- DECODIFICAÇÃO DA INSTRUÇÃO ----------------------------------------------------------
    

    funct <= instruction(6 downto 4);
    opcode <= instruction(3 downto 0);


    -- OPERAÇÕES DE ULA
                -- OPERAÇÕES ARITMÉTICAS
    op_ULA <=   "000" when (opcode = "0001" and funct = "000") else         -- ADD A, Rn    A = A + Rn
                "001" when (opcode = "0001" and funct = "001") else         -- SUB A, Rn    A = A - Rn
                "001" when (opcode = "0101" and funct = "000") else         -- CMPI Rn, cte
                
                -- OPERAÇÕES LÓGICAS
                "010" when (opcode = "0010" and funct = "000") else         -- NEG A       A = ~A
                "011" when (opcode = "0010" and funct = "001") else "100";  -- AND A, Rn   A = A & Rn

    -- ENABLE PARA SABER SE É UMA OPERAÇÃO QUE PODE ALTERAR AS FLAGS
    flags_en <= '1' when (opcode = "0001" and funct = "000" and execute) else       -- ADD A, Rn
                '1' when (opcode = "0001" and funct = "001" and execute) else       -- SUB A, Rn
                '1' when (opcode = "0010" and funct = "000" and execute) else       -- NEG A
                '1' when (opcode = "0010" and funct = "001" and execute) else       -- AND A, Rn
                '1' when (opcode = "0101" and funct = "000" and execute) else '0';  -- CMPI Rn, cte
    
    
     -- ENABLE PARA SABER SE É CMPI
     cmpi_en_o  <= '1' when (opcode = "0101" and funct = "000") else '0';


     -- ENABLE PARA SABER SE É LD
     ld_en_o    <= '1' when (opcode = "0011" and funct = "000") else '0';
     eh_ld <= (opcode = "0011" and funct = "000");


    is_for_acumulator <= true when (instruction(12 downto 10) = "110" and eh_mov) else  -- MOV A, Rm
                         true when (instruction(9 downto 7) = "110" and eh_ld) else     -- LD A, cte
                         false;

    -- HABILITA O ACUMULADOR PARA AS OPERAÇÕES DE ULA e LD
    acumulador_en_o <= '1' when (opcode = "0001" and funct = "000" and execute) else        -- ADD A, Rn
                       '1' when (opcode = "0001" and funct = "001" and execute) else        -- SUB A, Rn
                       '1' when (opcode = "0010" and funct = "000" and execute) else        -- NEG A
                       '1' when (opcode = "0010" and funct = "001" and execute) else        -- AND A, Rn
                       '1' when (opcode = "0011" and funct = "000" and execute and is_for_acumulator) else -- LD A, cte  A = cte
                       '1' when (opcode = "0100" and funct = "000" and execute and is_for_acumulator) else -- MOV A, Rm  A = Rm
                       '0';


    -- HABILITA A ESCRITA NO BANCO DE REGISTRADORES
    regs_en_o <= '1' when (opcode = "0011" and funct = "000") else          -- LD Rn, cte   Rn = cte
                 '1' when (opcode = "0100" and funct = "000") else '0';     -- MOV Rn, Rm
    

    -- ENDEREÇO DO REGISTRADOR A SER ESCRITO
    wr_addr_o <= instruction(9 downto 7)    when (opcode = "0011" and funct = "000") else   -- LD Rn, cte  (LENDO O ENDEÇO DO Rn)
                 instruction(12 downto 10)  when (opcode = "0100" and funct = "000") else   -- MOV Rn, Rm  (LENDO O ENDEÇO DO Rn)
                 (others => '0');

    
    -- ENDEREÇO DO REGISTRADOR A SER LIDO E INSERIDO NO OPERANDO B DA ULA
    rd_addr_o <= instruction(9 downto 7) when (opcode = "0001" and funct = "000") else          -- ADD A, Rn    A = A + Rn (LENDO Rn)
                 instruction(9 downto 7) when (opcode = "0001" and funct = "001") else          -- SUB A, Rn    A = A - Rn (LENDO Rn)
                 instruction(9 downto 7) when (opcode = "0010" and funct = "001") else          -- AND A, Rn    A = A & Rn (LENDO Rn)
                 instruction(9 downto 7) when (opcode = "0100" and funct = "000") else          -- MOV Rn, Rm   Rn = Rm    (LENDO Rm)
                 instruction(9 downto 7) when (opcode = "0101" and funct = "000") else "111";   -- CMPI Rn, cte (LENDO Rn)

    
    -- EXTENSÃO DE SINAL DA CONSTANTE PARA OPERAÇÕES DE LD
    exten_sinal <= "1111111" when instruction(18) = '1' else (others => '0');

    cte_instruction_o <= exten_sinal & instruction(18 downto 10) when (opcode = "0011" and funct = "000") else  -- LD Rn, cte (LENDO A CONSTANTE)
                         (others => '0');


    -- MOV Rn, Rm    Rn = Rm (QUANDO 1 FAZ A SAIDA DO BANCO DE REGISTRADORES QUE SERÁ Rm SE TORNAR A ENTRADA DO BANCO DE REGISTRADORES)
    mov_en_o <= '1' when (opcode = "0100" and funct = "000") else '0';
    eh_mov <= (opcode = "0100" and funct = "000");

    -- JUMPS
    jump_abs_o <=   '1' when (opcode = "1111" and funct = "000") else '0';          -- Pula para a instrução jump_addr_o
    jump_rel_o <=   '1' when (opcode = "1111" and funct = "001" and ble = '1') else       -- Pula jump_addr_o instruções (SE Rn <= cte)
                    '1' when (opcode = "1111" and funct = "010" and bmi = '1') else '0';  -- Pula jump_addr_o instruções (SE Rn < cte)

    jump_addr_o <=  instruction(13 downto 7) when (opcode = "1111") else (others => '0');

    -- BRANCHES
    ble <= '1' when (flagZeroFF_in = '1' or flagNegativeFF_in /= flagOverflowFF_in) else '0';
    bmi <= '1' when (flagNegativeFF_in = '1') else '0';

    ------------------------------------------- DECODIFICAÇÃO DA INSTRUÇÃO ----------------------------------------------------------
    


    -- ATUALIZAR PC
    PC_wr_en_o <= '1' when estado_s = "10" else '0';

    estado <= estado_s;

end architecture;
 