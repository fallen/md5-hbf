`timescale 1 ns / 1 ns

module top;

reg clk = 0;
wire led;
wire tx_led;
reg reset = 1;

wire tx;


always #31 clk = ~clk;

generator g1 (clk, reset, led, tx_led, tx);

initial begin
	reset = 1;
	#32
	reset = 0;
	#1000000
	$stop;
	$finish;
end

endmodule
