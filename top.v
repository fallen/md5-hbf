module top;

reg clk = 0;
wire led = 0;
reg reset = 1;

always #1 clk = ~clk;

generator g1 (clk, reset, led);

initial begin
	reset = 1;
	#10
	reset = 0;
	#50000
	$stop;
	$finish;
end

endmodule
