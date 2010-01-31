module top(input clock, input reset, output led, output led2, output led3, input UART_TXD, output UART_RXD);

generator g1 (clock, reset, led, led3, UART_RXD);

assign led2 = UART_TXD;

endmodule
