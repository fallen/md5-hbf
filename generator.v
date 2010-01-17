module generator(input clk, input reset, output led, output tx_led, output tx);

reg	[10:0] a = 11'b0;
reg	we = 0;
wire	[7:0] do;
reg	[7:0] di = 8'b0;
reg	[47:0] j = 48'b0;
reg	[3:0] state = 4'b0;

bram bram1 (clk, we, a, di, do);

reg	[0:127] m_in = 128'd0;
reg	[0:127] m_in_buff = 128'd0;
reg	[0:7]	m_in_w = 8'd0;
reg	m_in_valid = 0;

wire	[0:127] m_out;
wire	m_out_val;
wire	md5_ready;

reg	led_reg = 0;

wire	[7:0] bytetosend;
wire	sent;
reg	send;

pancham md5(
	.clk(clk),
	.reset(reset),
	.msg_in(m_in),
	.msg_in_width(m_in_w),
	.msg_in_valid(m_in_valid),
	.msg_output(m_out),
	.msg_out_valid(m_out_val),
	.ready(md5_ready)
	);
	
usart usart1 (clk, reset, tx_led, bytetosend, send, sent, tx); 


assign led = led_reg;


initial begin
	state = 0;
	$dumpfile("top.vcd");
	$dumpvars(0, top);
end

parameter s1 = 4'd0;
parameter s2 = 4'd1;
parameter s3 = 4'd2;
parameter s4 = 4'd3;
parameter s5 = 4'd4;
parameter s6 = 4'd5;
parameter s7 = 4'd6;
parameter s8 = 4'd7;
parameter s9 = 4'd8;
parameter s10 = 4'd9;
parameter s11 = 4'd10;
parameter found = 4'd11;

always @(posedge clk or posedge reset)
begin
	if (reset)
		begin
			state <= s1;
			led_reg <= 0;
			a <= 11'b0;
			j <= 48'b0;
			m_in_valid <= 0;
			m_in_w <= 8'd64;
			m_in_buff <= 128'd0;
		end
	else
		begin
			case (state)
			s1:	begin
					a <= { 5'b0, j[11:6] };
					state <= s2;
					m_in_valid <= 0;
				end
			s2:	begin
					m_in_buff[64:71] <= do;
					a <= { 5'b0, j[17:12] };
					state <= s3;
				end
			s3:	begin
					m_in_buff[72:79] <= do;
					a <= { 5'b0, j[23:18] };
					state <= s4;
				end
			s4:	begin
					m_in_buff[80:87] <= do;
					a <= { 5'b0, j[29:24] };
					state <= s5;
				end
			s5:	begin
					m_in_buff[88:95] <= do;
					a <= { 5'b0, j[35:30] };
					state <= s6; 
				end
			s6:	begin
					m_in_buff[96:103] <= do;
					a <= { 5'b0, j[41:36] };
					state <= s7;
				end
			s7:	begin
					m_in_buff[104:111] <= do;
					a <= { 5'b0, j[47:42] };
					state <= s8;
				end
			s8:	begin
					m_in_buff[112:119] <= do;
					state <= s9;
				end
			s9:	begin
					m_in_buff[120:127] <= do;
					state <= s10;
					j <= j + 1;
				end
			s10:	begin
					if (m_out_val)
						begin
							$display("md5(%s) = %h", m_in, m_out);
							if (m_out == 128'h82cf9fa647dd1b3fbd9de71bbfb83fb2)
								begin
									state <= found;
									led_reg <= 1;
									$display("MD5 HASH FOUND");
								end
							else
								begin
									state <= s10;
								end
						end
					else
						begin
						if (md5_ready)
							begin
								m_in_w <= 8'd64;
								m_in_valid <= 1;
								m_in <= m_in_buff;
								state <= s1;
								a <= { 5'b0, j[5:0] };
							end
						else
							begin
								state <= s10;
							end
						end
				end
			found:	begin
					state <= found;
				end
			endcase
		end
end

endmodule
