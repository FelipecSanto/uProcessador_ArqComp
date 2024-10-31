# Nome do executável de simulação
SIM_EXEC = ULA_tb

# Arquivos VHDL
VHDL_FILES = Comparator.vhd ULA.vhd ULA_tb.vhd

# Arquivo de dump de simulação
VCD_FILE = $(SIM_EXEC).vcd

# Comando GHDL
GHDL = ghdl

# Comando GTKWave
GTKWAVE = gtkwave

# Flags de compilação
GHDL_FLAGS = --std=08

# Regra padrão
all: $(SIM_EXEC)

# Regra para compilar e elaborar
$(SIM_EXEC): $(VHDL_FILES)
	$(GHDL) -a $(GHDL_FLAGS) Comparator.vhd
	$(GHDL) -a $(GHDL_FLAGS) ULA.vhd
	$(GHDL) -a $(GHDL_FLAGS) ULA_tb.vhd
	$(GHDL) -e $(GHDL_FLAGS) ULA_tb

# Regra para executar a simulação e gerar o arquivo VCD
run: $(SIM_EXEC)
	$(GHDL) -r $(GHDL_FLAGS) ULA_tb --vcd=$(VCD_FILE)
	$(GTKWAVE) $(VCD_FILE)

# Regra para limpar os arquivos gerados
clean:
	rm -f $(SIM_EXEC) $(SIM_EXEC).o work-obj93.cf $(VCD_FILE)

.PHONY: all run clean