# Nome do executável de simulação
TESTBENCH = uProcessador_tb

# Arquivos VHDL
VHDL_FILES = ULA.vhd ULA_tb.vhd reg16bits.vhd reg16bits_tb.vhd reg_bank.vhd reg_bank_tb.vhd uProcessador.vhd uProcessador_tb.vhd

# Arquivo de dump de simulação
GHW_FILE = $(TESTBENCH).ghw

# Comando GHDL
GHDL = ghdl

# Comando GTKWave
GTKWAVE = gtkwave

# Flags de compilação
GHDL_FLAGS = --std=08

# Regra padrão
all: $(TESTBENCH)

# Regra para compilar e elaborar
$(TESTBENCH): $(VHDL_FILES)
	$(GHDL) -a ULA.vhd
	$(GHDL) -e ULA
	$(GHDL) -a ULA_tb.vhd
	$(GHDL) -e ULA_tb
	$(GHDL) -a reg16bits.vhd
	$(GHDL) -e reg16bits
	$(GHDL) -a reg16bits_tb.vhd
	$(GHDL) -e reg16bits_tb
	$(GHDL) -a reg_bank.vhd
	$(GHDL) -e reg_bank
	$(GHDL) -a reg_bank_tb.vhd
	$(GHDL) -e reg_bank_tb
	$(GHDL) -a uProcessador.vhd
	$(GHDL) -e uProcessador
	$(GHDL) -a uProcessador_tb.vhd
	$(GHDL) -e uProcessador_tb


# Regra para executar a simulação e gerar o arquivo GHW
run: $(TESTBENCH)
	$(GHDL) -r $(TESTBENCH) --wave=$(GHW_FILE)
	$(GTKWAVE) $(GHW_FILE)

# Regra para limpar os arquivos gerados
clean:
	@if [ -f work-obj*.cf ]; then rm -f work-obj*.cf; fi
	@if [ -f $(GHW_FILE) ]; then rm -f *.ghw; fi

.PHONY: all run clean