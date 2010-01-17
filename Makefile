all: design

design: simulation/top.v generator.v bram.v pancham.v pancham_round.v pancham.h usart.v
	iverilog -o design simulation/top.v generator.v bram.v pancham.v pancham_round.v usart.v ; vvp design

wave: design
	gtkwave test.vcd
