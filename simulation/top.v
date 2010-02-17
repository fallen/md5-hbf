`timescale 1 ns / 1 ns

module top;

reg clk = 0;
wire led;
wire tx_led;
reg reset = 1;
reg rewind_usart = 0;

wire tx;


always #31 clk = ~clk;
reg reset_sync;

always @(posedge clk)
begin
	reset_sync <= reset;
end

generator g1 (clk, reset_sync, led, tx_led, tx, rewind_usart);

initial begin
	reset = 1;
	#32
	reset = 0;
	#1000000
//	rewind_usart = 1;
//	#63
//	rewind_usart = 0;
//	#717600
	$stop;
	$finish;
end

endmodule
