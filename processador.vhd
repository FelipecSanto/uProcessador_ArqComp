library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
    port(
        clk             : in std_logic;
        rst             : in std_logic;
        data_out_PC_o   : out unsigned(6 downto 0);
        result_ula_o    : out unsigned(15 downto 0);
        regBank_out     : out unsigned(15 downto 0);
        acumulador_out  : out unsigned(15 downto 0);
        instruction_o   : out unsigned(18 downto 0);
        estado_o        : out unsigned(1 downto 0)
    );
end entity;

architecture a_processador of processador is

    component reg1bit
        port( 
           clk      : in std_logic;
           rst      : in std_logic;
           wr_en    : in std_logic;
           data_in  : in std_logic;
           data_out : out std_logic
        );
     end component;

    component instruction_reg
        port( 
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(18 downto 0);
            data_out : out unsigned(18 downto 0)
        );
    end component;

    component ROM
        port( 
            clk      : in std_logic;
            endereco : in unsigned(6 downto 0);
            dado     : out unsigned(18 downto 0)
        );
    end component;

    component PC_adder
        port( 
            clk         : in std_logic;
            PC_rst      : in std_logic;
            PC_wr_en_i  : in std_logic;
            jump_abs_i  : in std_logic;
            jump_rel_i  : in std_logic;
            jump_addr_i : in unsigned(6 downto 0);
            data_in     : in unsigned(6 downto 0);
            data_out    : out unsigned(6 downto 0)
        );
    end component;

    component UC
        port(
            clk                 : in std_logic;
            rst                 : in std_logic;
            instruction         : in unsigned(18 downto 0);
            flagNegativeFF_in   : in std_logic;
            flagZeroFF_in       : in std_logic;
            flagOverflowFF_in   : in std_logic;
            PC_wr_en_o          : out std_logic;
            jump_abs_o          : out std_logic;
            jump_rel_o          : out std_logic;
            jump_addr_o         : out unsigned(6 downto 0);
            op_ULA              : out unsigned(2 downto 0);
            wr_addr_o           : out unsigned(2 downto 0);
            rd_addr_o           : out unsigned(2 downto 0);
            cte_instruction_o   : out unsigned(15 downto 0);
            regs_en_o           : out std_logic;
            acumulador_en_o     : out std_logic;
            flags_en            : out std_logic;
            mov_en_o            : out std_logic;
            cmpi_en_o           : out std_logic;
            ld_en_o             : out std_logic;
            estado              : out unsigned(1 downto 0)
        );
    end component;

    component reg_bank
        port(
            clk             : in std_logic;
            rst             : in std_logic;
            reg_wr_en       : in std_logic;
            selec_reg_wr    : in unsigned(2 downto 0);
            selec_reg_rd    : in unsigned(2 downto 0);
            data_wr         : in unsigned(15 downto 0);
            data_r1         : out unsigned(15 downto 0)
        );
    end component;

    component ULA
        port(
            A           : in unsigned(15 downto 0);
            B           : in unsigned(15 downto 0);
            Op          : in unsigned(2 downto 0);
            Result      : out unsigned(15 downto 0);
            Zero        : out std_logic;
            Negative    : out std_logic;
            Overflow    : out std_logic
        );
    end component;

    component reg16bits
        port(
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;


    signal ULA_in_A             : unsigned(15 downto 0) := (others => '0');
    signal ULA_in_B             : unsigned(15 downto 0) := (others => '0');

    signal ula_result_s         : unsigned(15 downto 0) := (others => '0');

    signal acumulador_in_s      : unsigned(15 downto 0) := (others => '0');
    signal acumulador_out_s     : unsigned(15 downto 0) := (others => '0');

    -- SINAIS PARA A INSTRUÇÃO

    signal address_instruction  : unsigned(6 downto 0) := (others => '0');      -- ENTRADA DA ROM
    signal instruction_s        : unsigned(18 downto 0) := (others => '0');     -- SAÍDA DA ROM
    signal instruction_reg_s    : unsigned(18 downto 0) := (others => '0');     -- SAÍDA DO REGISTRADOR DE INSTRUÇÃO

    -- SINAIS PARA A INSTRUÇÃO DE JUMP

    signal jump_abs     : std_logic := '0';
    signal jump_rel     : std_logic := '0';
    signal jump_addr    : unsigned(6 downto 0) := (others => '0');

    -- SINAIS ENABLERS

    signal regs_en_s        : std_logic := '0';
    signal acumulador_en_s  : std_logic := '0';
    signal PC_wr_en_s       : std_logic := '0';
    signal op_ULA_s         : unsigned(2 downto 0) := (others => '0');
    signal flags_en_s       : std_logic := '0';
    signal mov_en_s         : std_logic := '0';
    signal cmpi_en_s        : std_logic := '0';
    signal ld_en_s          : std_logic := '0';

    
    -- SINAIS PARA AS FLAGS

    signal flagZero_s_in        : std_logic := '0';
    signal flagZero_s_out       : std_logic := '0';

    signal flagNegative_s_in    : std_logic := '0';
    signal flagNegative_s_out   : std_logic := '0';

    signal flagOverflow_s_in    : std_logic := '0';
    signal flagOverflow_s_out   : std_logic := '0';

    -- SINAIS PARA OS ENDEREÇOS NO BANCO DE REGISTRADORES

    signal wr_addr_s : unsigned(2 downto 0) := (others => '0');
    signal rd_addr_s : unsigned(2 downto 0) := (others => '0');

    -- SINAL PARA A CONSTANTE NA INSTRUÇÃO

    signal data_in_regbank_s    : unsigned(15 downto 0) := (others => '0');
    signal cte_instruction      : unsigned(15 downto 0) := (others => '0');

    -- DADO DO REGISTRADOR LIDO NO BANCO DE REGISTRADORES

    signal regBank_data_out_s   : unsigned(15 downto 0) := (others => '0');

    -- MAQUINA DE ESTADOS

    signal estado_s : unsigned(1 downto 0) := (others => '0');

begin

    ----------------------------------------------------------- FLAGS ----------------------------------------------------------------

    flagZero_reg: reg1bit
        port map (
            clk => clk,
            rst => rst,
            wr_en => flags_en_s,
            data_in => flagZero_s_in,
            data_out => flagZero_s_out
        );

    flagNegative_reg: reg1bit
        port map (
            clk => clk,
            rst => rst,
            wr_en => flags_en_s,
            data_in => flagNegative_s_in,
            data_out => flagNegative_s_out
        );

    flagOverflow_reg: reg1bit
        port map (
            clk => clk,
            rst => rst,
            wr_en => flags_en_s,
            data_in => flagOverflow_s_in,
            data_out => flagOverflow_s_out
        );

    ----------------------------------------------------------- FLAGS ----------------------------------------------------------------


    ------------------------------------------------------------- PC -----------------------------------------------------------------

    PC_inst: PC_adder
        port map (
            clk         => clk,
            PC_rst      => rst,
            PC_wr_en_i  => PC_wr_en_s,
            jump_abs_i  => jump_abs,
            jump_rel_i  => jump_rel,
            jump_addr_i => jump_addr,
            data_in     => (others => '0'),
            data_out    => address_instruction
        );

    ------------------------------------------------------------- PC -----------------------------------------------------------------


    ------------------------------------------------------------ ROM -----------------------------------------------------------------

    ROM_inst: ROM
        port map (
            clk        => clk,
            endereco   => address_instruction,
            dado       => instruction_s
        );

    
    ------------------------------------------------------------ ROM -----------------------------------------------------------------


    ---------------------------------------------------------INSTRUCTION -------------------------------------------------------------
    
    instruction_reg_inst: instruction_reg
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => '1',
            data_in  => instruction_s,
            data_out => instruction_reg_s
        );

    -------------------------------------------------------- INSTRUCTION -------------------------------------------------------------


    ------------------------------------------------------------- UC -----------------------------------------------------------------

    UC_inst: UC
        port map (
            clk                 => clk,
            rst                 => rst,
            instruction         => instruction_reg_s,
            flagNegativeFF_in   => flagNegative_s_out,
            flagZeroFF_in       => flagZero_s_out,
            flagOverflowFF_in   => flagOverflow_s_out,
            PC_wr_en_o          => PC_wr_en_s,
            jump_abs_o          => jump_abs,
            jump_rel_o          => jump_rel,
            jump_addr_o         => jump_addr,
            op_ULA              => op_ULA_s,
            wr_addr_o           => wr_addr_s,
            rd_addr_o           => rd_addr_s,
            cte_instruction_o   => cte_instruction,
            regs_en_o           => regs_en_s,
            acumulador_en_o     => acumulador_en_s,
            flags_en            => flags_en_s,
            mov_en_o            => mov_en_s,
            cmpi_en_o           => cmpi_en_s,
            ld_en_o             => ld_en_s,
            estado              => estado_s
        );

    
    ------------------------------------------------------------- UC -----------------------------------------------------------------


    -- MUX PARA DECIDIR QUAL DADO SERÁ ESCRITO NO BANCO DE REGISTRADORES
    data_in_regbank_s <= regBank_data_out_s when (mov_en_s = '1' and rd_addr_s /= "110") else   -- SE A INSTRUÇÃO FOR MOV E NÃO FOR DO ACUMULADOR PARA OUTRO REGISTRADOR (MOV Rn, Rm)
                         acumulador_out_s   when (mov_en_s = '1' and rd_addr_s = "110") else    -- SE A INSTRUÇÃO FOR MOV E FOR DO ACUMULADOR PARA OUTRO REGISTRADOR (MOV Rn, A)
                         cte_instruction;                                                       -- CONSTANTE NA INSTRUÇÃO


    ---------------------------------------------------------- REG_BANK --------------------------------------------------------------

    reg_bank_inst: reg_bank
        port map (
            clk => clk,
            rst => rst,
            reg_wr_en => regs_en_s,
            selec_reg_wr => wr_addr_s,
            selec_reg_rd => rd_addr_s,
            data_wr => data_in_regbank_s,
            data_r1 => regBank_data_out_s
        );
    
    ---------------------------------------------------------- REG_BANK --------------------------------------------------------------

    
    ULA_in_A <= regBank_data_out_s  when (cmpi_en_s = '1') else acumulador_out_s;
    ULA_in_B <= acumulador_out_s    when (cmpi_en_s = '1') else regBank_data_out_s;

    
    ------------------------------------------------------------- ULA ----------------------------------------------------------------

    ula_inst: ULA
        port map (
            A => ULA_in_A,
            B => ULA_in_B,
            Op => op_ULA_s,
            Result => ula_result_s,
            Zero => flagZero_s_in,
            Negative => flagNegative_s_in,
            Overflow => flagOverflow_s_in
        );

    ------------------------------------------------------------- ULA ----------------------------------------------------------------


    -- MUX PARA DECIDIR QUAL DADO SERÁ ESCRITO NO ACUMULADOR
    acumulador_in_s <= regBank_data_out_s   when (mov_en_s = '1' and wr_addr_s = "110") else    -- SE A INSTRUÇÃO FOR MOV E FOR DO REGISTRADOR PARA O ACUMULADOR (MOV A, Rn)
                       cte_instruction      when (ld_en_s =  '1' and wr_addr_s = "110") else    -- SE A INSTRUÇÃO FOR LD E FOR PARA O ACUMULADOR (LD A, cte)
                       cte_instruction      when (cmpi_en_s = '1') else                         -- SE A INSTRUÇÃO FOR CMPI
                       ula_result_s;                                                            -- RESULTADO DA ULA


    --------------------------------------------------------- ACUMULADOR -------------------------------------------------------------

    acumulador_inst: reg16bits
        port map (
            clk => clk,
            rst => rst,
            wr_en => acumulador_en_s,
            data_in => acumulador_in_s,
            data_out => acumulador_out_s
        );

    --------------------------------------------------------- ACUMULADOR -------------------------------------------------------------

    instruction_o <= instruction_reg_s;
    estado_o <= estado_s;
    acumulador_out <= acumulador_out_s;
    regBank_out <= regBank_data_out_s;
    result_ula_o <= ula_result_s;
    data_out_PC_o <= address_instruction;

end architecture;
