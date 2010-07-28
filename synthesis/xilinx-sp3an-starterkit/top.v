`define CLOCK_FREQUENCY 50000000

module top(input rewind_usart, output reset_led, input clock, input reset, output led, output led2, output led3, input UART_TXD, output UART_RXD);

reg reset_sync;
reg rewind_usart_sync;

always @(posedge clock)
begin
	reset_sync <= reset;
	rewind_usart_sync <= rewind_usart;
end

generator #(.clock_freq(`CLOCK_FREQUENCY) ) g1 (clock, reset_sync, led, led3, UART_RXD, rewind_usart_sync);

assign led2 = UART_TXD;
assign reset_led = reset_sync;

endmodule
