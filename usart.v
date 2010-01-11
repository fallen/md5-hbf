module usart(input clock, input reset, output tx_led, input bytetosend, input send, output sent, output tx);

	reg [15:0] clk_count = 16'b0;
	reg clk = 0;
	reg [3:0] state = 4'b0;

	parameter clk_divider = 16000000/115200/2; 
	parameter IDLE = 4'b0;
	parameter START_BIT = 4'd1;
	parameter BIT_ONE = 4'd2;
	parameter BIT_TWO = 4'd3;
	parameter BIT_THREE = 4'd4;
	parameter BIT_FOUR = 4'd5;
	parameter BIT_FIVE = 4'd6;
	parameter BIT_SIX = 4'd7;
	parameter BIT_SEVEN = 4'd8;
	parameter BIT_HEIGT = 4'd9;
	parameter STOP_BIT = 4'd10;
	parameter STOP_BIT2 = 4'd11;
	parameter STOP_BIT3 = 4'd12;

	always @(posedge clock)
		begin
			if (clk_count > clk_divider)
				begin
					clk_count <= 0;
					clk = ~clk;
				end
			else
				begin
					clk_count <= clk_count + 1;
				end
		end

		

endmodule
