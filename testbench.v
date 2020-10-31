// No Copyright. Vladislav Aleinik, 2020
`timescale 1 ns / 100 ps
module testbench();

reg clk = 1'b0;
always begin
    #1 clk = ~clk;
end

reg rxd = 1'b0;
always begin
	#50   rxd = ~rxd;
	#10   rxd = ~rxd;
	#100  rxd = ~rxd;
	#10   rxd = ~rxd;
	#50   rxd = ~rxd;
end

top qrng(.CLK(clk), .RXD(rxd));

initial begin
	$display("QRNG Testing Initiated!");
    $dumpvars;
    #10000 $finish;
end

endmodule