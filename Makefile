# Nome do executável de simulação
TESTBENCH = ULA_tb

# Arquivos VHDL
VHDL_FILES = FullAdder.vhd Somador.vhd Comparator.vhd ULA.vhd ULA_tb.vhd

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
	$(GHDL) -a $(GHDL_FLAGS) FullAdder.vhd
	$(GHDL) -e $(GHDL_FLAGS) FullAdder
	$(GHDL) -a $(GHDL_FLAGS) Somador.vhd
	$(GHDL) -e $(GHDL_FLAGS) Somador
	$(GHDL) -a $(GHDL_FLAGS) Comparator.vhd
	$(GHDL) -e $(GHDL_FLAGS) Comparator
	$(GHDL) -a $(GHDL_FLAGS) ULA.vhd
	$(GHDL) -e $(GHDL_FLAGS) ULA
	$(GHDL) -a $(GHDL_FLAGS) ULA_tb.vhd
	$(GHDL) -e $(GHDL_FLAGS) ULA_tb

# Regra para executar a simulação e gerar o arquivo VCD
run: $(TESTBENCH)
	$(GHDL) -r $(GHDL_FLAGS) ULA_tb --wave=$(GHW_FILE)
	$(GTKWAVE) $(GHW_FILE)

# Regra para limpar os arquivos gerados
clean:
	if exist work-obj08.cf del work-obj08.cf
	if exist $(GHW_FILE) del $(GHW_FILE)

.PHONY: all run clean