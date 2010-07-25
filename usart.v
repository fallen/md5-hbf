module usart(input clock, input reset, output tx_led, input [7:0] bytetosend, input send, output sent, output tx, input rx);

	reg	[15:0] fsm_clk_count = 16'b0;
	wire	fsm_clk;
	reg 	[3:0] state = 4'b0;
	reg	tx_reg = 1;

	parameter fsm_clk_freq = 16000000;
	parameter baud_rate = 115200;
	parameter fsm_clk_divider = fsm_clk_freq/baud_rate; 
	parameter IDLE = 4'b0;
	parameter START_BIT = 4'd1;
	parameter BIT_ONE = 4'd2;
	parameter BIT_TWO = 4'd3;
	parameter BIT_THREE = 4'd4;
	parameter BIT_FOUR = 4'd5;
	parameter BIT_FIVE = 4'd6;
	parameter BIT_SIX = 4'd7;
	parameter BIT_SEVEN = 4'd8;
	parameter BIT_EIGHT = 4'd9;
	parameter STOP_BIT = 4'd10;
	parameter STOP_BIT2 = 4'd11;

	assign fsm_clk = (fsm_clk_count == 16'd0);
	assign tx_led = sent;
	assign tx = tx_reg;
	assign sent = (state == IDLE);


	always @(posedge clock)
	begin
		if (reset | send)
			fsm_clk_count <= fsm_clk_divider - 16'b1;
		else 
		begin
			fsm_clk_count <= fsm_clk_count - 16'd1;
			if (fsm_clk)
				fsm_clk_count <= fsm_clk_divider - 16'b1;
		end
		
	end


	always @(posedge clock)
	begin
		if (reset)
		begin
			state <= IDLE;
			tx_reg <= 1'b1;
		end
		else
			if (send & sent)
			begin
				state <= START_BIT;
				tx_reg <= 1'b0;
`ifdef SIMULATION
				$display("sending: %h", bytetosend);
`endif
			end
			else if (fsm_clk & ~sent) 
			begin
				case(state)
				START_BIT:	begin
							tx_reg <= bytetosend[0];
							state <= BIT_ONE;
						end
				BIT_ONE:	begin
							tx_reg <= bytetosend[1];
							state <= BIT_TWO;
						end
				BIT_TWO:	begin
							tx_reg <= bytetosend[2];
							state <= BIT_THREE;
						end
				BIT_THREE:	begin
							tx_reg <= bytetosend[3];
							state <= BIT_FOUR;
						end
				BIT_FOUR:	begin
							tx_reg <= bytetosend[4];
							state <= BIT_FIVE;
						end
				BIT_FIVE:	begin
							tx_reg <= bytetosend[5];
							state <= BIT_SIX;
						end
				BIT_SIX:	begin
							tx_reg <= bytetosend[6];
							state <= BIT_SEVEN;
						end
				BIT_SEVEN:	begin
							tx_reg <= bytetosend[7];
							state <= BIT_EIGHT;
						end
				BIT_EIGHT:	begin
							tx_reg <= 1'b1;
							state <= STOP_BIT;
						end
				STOP_BIT:	begin
							tx_reg <= 1'b1;
							state <= STOP_BIT2;
						end
				STOP_BIT2:	begin
							tx_reg <= 1'b1;
							state <= IDLE;
						end
				endcase
			end
	end

/*	assign recv = (start_bit_received & ~recv_finished);

	always @(negedge rx)
	begin
		if (~recv)
			start_bit_received <= start_bit_received;
	end

	always @(posedge clock)
	begin
		if (reset)
		begin
			state <= IDLE;
		end
		else
			if (recv)
				

	end
*/

endmodule
