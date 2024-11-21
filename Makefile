# Nome do executável de simulação
TESTBENCH = uProcessador_tb

# Arquivos VHDL
VHDL_FILES = ULA.vhd ULA_tb.vhd reg16bits.vhd reg16bits_tb.vhd reg_bank.vhd reg_bank_tb.vhd ROM.vhd ROM_tb.vhd reg1bit.vhd reg1bit_tb.vhd PC.vhd PC_tb.vhd PC_adder.vhd PC_adder_tb.vhd reg_bank_ULA.vhd reg_bank_ULA_tb.vhd maquina_estados.vhd maquina_estados_tb.vhd un_controle.vhd un_controle_tb.vhd uProcessador.vhd uProcessador_tb.vhd

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
	$(GHDL) -a ROM.vhd
	$(GHDL) -e ROM
	$(GHDL) -a ROM_tb.vhd
	$(GHDL) -e ROM_tb
	$(GHDL) -a reg1bit.vhd
	$(GHDL) -e reg1bit
	$(GHDL) -a reg1bit_tb.vhd
	$(GHDL) -e reg1bit_tb
	$(GHDL) -a PC.vhd
	$(GHDL) -e PC
	$(GHDL) -a PC_tb.vhd
	$(GHDL) -e PC_tb
	$(GHDL) -a PC_adder.vhd
	$(GHDL) -e PC_adder
	$(GHDL) -a PC_adder_tb.vhd
	$(GHDL) -e PC_adder_tb
	$(GHDL) -a reg_bank_ULA.vhd
	$(GHDL) -e reg_bank_ULA
	$(GHDL) -a reg_bank_ULA_tb.vhd
	$(GHDL) -e reg_bank_ULA_tb
	$(GHDL) -a maquina_estados.vhd
	$(GHDL) -e maquina_estados
	$(GHDL) -a maquina_estados_tb.vhd
	$(GHDL) -e maquina_estados_tb
	$(GHDL) -a un_controle.vhd
	$(GHDL) -e un_controle
	$(GHDL) -a un_controle_tb.vhd
	$(GHDL) -e un_controle_tb
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