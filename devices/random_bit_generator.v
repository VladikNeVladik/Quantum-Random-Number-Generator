// No Copyright. Vladislav Aleinik, 2020
//=============================================================================
// Random Bit Generator
//=============================================================================
// - Counts time between incoming impulses
// - Compares two times and generates a random bit
// - Discards the pair if times are equal
//=============================================================================
module RandomBitGenerator #(
	parameter [15:0]DEC_LEVEL = 1,
	parameter [15:0]INC_LEVEL = 3,
	parameter [15:0]MAX_LEVEL = 4
)(
	input clk,

	input signal,

	output reg random_bit       = 0,
	output reg random_bit_ready = 0
);

// Signal debouncer:
reg [15:0]debouncer       = 0;
reg debounced_signal      = 0;
reg debounced_signal_prev = 0;
always @(posedge clk) begin
	if (signal) begin
		if (debouncer < MAX_LEVEL)
			debouncer <= debouncer + 1;
	end else begin
		if (0 < debouncer)
			debouncer <= debouncer - 1;
	end

	if (debouncer == INC_LEVEL)
		debounced_signal <= 1;
	else if (debouncer == DEC_LEVEL)
		debounced_signal <= 0;

	debounced_signal_prev <= debounced_signal;
end

// Clock management:
reg [31:0]timers[1:0];
reg cur_timer = 0;

always @(posedge clk) begin
	// Falling edge:
	if (debounced_signal_prev == 1 && debounced_signal == 0) begin
		timers[cur_timer] <= 0;
	end

	// Low level:
	else if (debounced_signal_prev == 0 && debounced_signal == 0) begin
		if (timers[cur_timer] != 32'hFFFFFFFF)
			timers[cur_timer] <= timers[cur_timer] + 1;
	end

	// Rising edge:
	else if (debounced_signal_prev == 0 && debounced_signal == 1) begin
		cur_timer <= cur_timer + 1;
	end
end

// Random bit generation:
always @(posedge clk) begin
	// Rising edge:
	if (debounced_signal_prev == 0 && debounced_signal == 1 && cur_timer == 1) begin
		random_bit       <= timers[0] <= timers[1];
		random_bit_ready <= timers[0] != timers[1];
	end
	else begin
		random_bit_ready <= 0;
	end
end

endmodule