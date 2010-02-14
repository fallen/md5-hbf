module top(output reset_led, input clock, input reset, output led, output led2, output led3, input UART_TXD, output UART_RXD);

reg reset_sync;

always @(posedge clock)
begin
	reset_sync <= reset;
end

generator g1 (clock, reset_sync, led, led3, UART_RXD);

assign led2 = UART_TXD;
assign reset_led = reset_sync;

endmodule
