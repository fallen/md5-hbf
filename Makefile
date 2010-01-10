all: design

design: top.v generator.v bram.v pancham.v pancham_round.v pancham.h
	iverilog -o design top.v generator.v bram.v pancham.v pancham_round.v ; vvp design

wave: design
	gtkwave test.vcd
