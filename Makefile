# Nome do executável de simulação
TESTBENCH = ULA_tb

# Arquivos VHDL
VHDL_FILES = ULA.vhd ULA_tb.vhd

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

# Regra para executar a simulação e gerar o arquivo GHW
run: $(TESTBENCH)
	$(GHDL) -r ULA_tb --wave=$(GHW_FILE)
	$(GTKWAVE) $(GHW_FILE)

# Regra para limpar os arquivos gerados
clean:
	@if [ -f work-obj*.cf ]; then rm -f work-obj*.cf; fi
	@if [ -f $(GHW_FILE) ]; then rm -f $(GHW_FILE); fi

.PHONY: all run clean
