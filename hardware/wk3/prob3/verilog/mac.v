// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;

// extend to support 4 parallel dot product operations
input signed [4*bw-1:0] b;		// 4-bit signed weight (weights can be negative)
input        [4*bw-1:0] a;		// 4-bit unsigned activation (non-negative)
input        [psum_bw-1:0] c;		// 16-bit partial (cumulative) input sum
output reg   [psum_bw-1:0] out;		// 16-bit partial (cumulative) output sum

// extract each of the 4 pairs
wire [bw-1:0] a0 = a[3:0];
wire [bw-1:0] a1 = a[7:4];
wire [bw-1:0] a2 = a[11:8];
wire [bw-1:0] a3 = a[15:12];

wire signed [bw-1:0] b0 = b[3:0];
wire signed [bw-1:0] b1 = b[7:4];
wire signed [bw-1:0] b2 = b[11:8];
wire signed [bw-1:0] b3 = b[15:12];

// multiply signed weight x unsigned activation in 4x parallel
wire signed [psum_bw-1:0] mult_result;			// avoid treating MSB as sign bit
assign mult_result = (b0 * $signed({1'b0, a0})) +	// concatenate leading 0, then cast a to 
			(b1 * $signed({1'b0, a1})) +		// then cast a to signed
			(b2 * $signed({1'b0, a2})) +
			(b3 * $signed({1'b0, a3}));

// accumulate
always @(*) begin
	out = c + mult_result;
end

endmodule
