// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// Qunatum Random Number Generator
//=============================================================================
// - Analyses a voltage stream coming from Photoelectron Amplifier
// - Generates a stream of (hopefully) random bits
// - Trasfers them to end user via UART
//=============================================================================
module top(
	input CLK,

	// Input from Photoelecton Amplifier
	input RXD,

	// UART-output to PC
	output TXD,    

	// 7-SEGMENT INDICATOR
	output DS_EN1, DS_EN2, DS_EN3, DS_EN4,
	output DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G
);

//======================//
// Random Bit Generator //
//======================//

wire gen_random_bit;
wire gen_random_bit_ready;

RandomBitGenerator #(
	.DEC_LEVEL(10),
	.INC_LEVEL(30),
	.MAX_LEVEL(40)
) random_bit_generator(
	.clk             (CLK),
	.signal          (RXD),
	.random_bit      (gen_random_bit),
	.random_bit_ready(gen_random_bit_ready)
);

//================//
// Hex Controller //
//================//

reg [15:0]data_to_hex = 0;

always @(posedge CLK) begin
	if (gen_random_bit_ready)
		data_to_hex <= data_to_hex + 1;
end

// 7-SEG Anodes Output:
wire [3:0]anodes;
assign {DS_EN1, DS_EN2, DS_EN3, DS_EN4} = ~anodes;

// 7-SEG Segments Output:
wire [6:0]segments;
assign {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = segments;

HexDisplay hex_display(
	.clk     (CLK),
	.data    (data_to_hex),
	.anodes  (anodes),
	.segments(segments)
);

//==================//
// UART Transmitter //
//==================//

// Bit-to-byte buffer:
reg [3:0]cur_bit = 0;
reg [7:0]byte_to_uart = 0;
reg byte_to_uart_ready = 0;

always @(posedge CLK) begin
	if (gen_random_bit_ready) begin
		byte_to_uart[cur_bit] <= gen_random_bit;
		cur_bit <= cur_bit + 1;
	end

	if (gen_random_bit_ready && cur_bit == 7) begin
		byte_to_uart_ready <= 1;
	end else begin
		byte_to_uart_ready <= 0;
	end
end

// Uart transmitter:
UartTransmitter #(
	.BAUDRATE(240000)
) uart_tx(
	.clk(CLK),

	.data      (byte_to_uart),
	.data_ready(byte_to_uart_ready),

	.signal(TXD)
);

endmodule	
