// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// UART Transmitter
//=============================================================================
// - Transmits generated bits to PC via UART at 250kbps
//=============================================================================
module UartTransmitter #(
	parameter BAUDRATE = 250000
)(
	input clk,

	input [7:0]data,
	input data_ready,

	output reg signal = 1
);

// Circular buffer management:
parameter [7:0]BUFFER_SIZE = 128;
reg [7:0]circular_buffer[127:0];
reg [7:0]head = 0;
reg [7:0]tail = 0;

// Head management:
always @(posedge clk) begin
	if (data_ready && head - tail != BUFFER_SIZE) begin
		circular_buffer[head] <= data;
		head <= head + 1;
	end
end

// Uart transmitter state:
reg [7:0]cur_byte;
reg [3:0]cur_bit = 4'hA;


// Uart timings:
parameter CLK_PER_BIT = 48000000/BAUDRATE;

reg [15:0]counter = 0;
always @(posedge clk) begin
	if (counter == CLK_PER_BIT) begin
		counter <= 0;
	end else begin
		counter <= counter + 1;
	end
end

wire uart_tick = (counter == 0);

// Tranmission
always @(posedge clk) begin
	if (uart_tick && cur_bit != 4'hA) begin
		cur_bit <= cur_bit + 1;

		// Start bit: 
		if (cur_bit == 0) begin
			cur_byte <= circular_buffer[tail];
			tail <= tail + 1;

			signal <= 0;
		end

		// Data bits:
		if (1 <= cur_bit && cur_bit <= 8) begin
			signal <= cur_byte[cur_bit - 1];
		end

		// Stop bit:
		if (cur_bit == 9) begin
			signal <= 1;
		end
	end
	else if (cur_bit == 4'hA && head != tail) begin
		cur_bit <= 0;
	end
end

endmodule
