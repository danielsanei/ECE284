// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, A, B, format, acc, clk, reset);

parameter bw = 8;
parameter psum_bw = 16;

input clk;
input acc;
input reset;
input format;

input signed [bw-1:0] A;	// declared with signed
input signed [bw-1:0] B;		// simulator interprets as 2's complement by default

output signed [psum_bw-1:0] out;

reg signed [psum_bw-1:0] psum_q;
reg signed [bw-1:0] a_q;
reg signed [bw-1:0] b_q;

// intermediate wires for sign/magnitude computation
	// use unsigned (sign is in MSB)
reg sign_a, sign_b;		// 1 bit
reg [6:0] mag_a, mag_b;		// 7 bits
reg [13:0] prod_mag;		// 14 bits
reg prod_sign;			// 1 bit
reg signed [15:0] prod_signed;	// 16 bits

assign out = psum_q;	// out automatically updates based on any changes within psum_q

// start of my code
always @(posedge clk) begin
	// reset accumulated sum
	if (reset) begin
		psum_q <= 0; 
	// initialize a_q, b_q registers with A, B values
	end else begin
		a_q <= A;
		b_q <= B;
		// multiply-accumulate sum
		if (acc) begin
			// 2's complement
			if (!format) begin
				psum_q <= psum_q + (a_q * b_q);
			// sign and magnitude
			end else begin
				// extract sign, magnitude values
				sign_a = a_q[bw-1];
				sign_b = b_q[bw-1];
				mag_a = a_q[bw-2:0];
				mag_b = b_q[bw-2:0];
				// perform MAC
				prod_mag = mag_a * mag_b;	// multiply magnitudes (absolute value)
				prod_sign = sign_a ^ sign_b;	// compute final sign
				if (prod_sign) begin		// convert back to 2's complement
					prod_signed = -prod_mag;
				end else begin
					prod_signed = prod_mag;
				end
				psum_q <= psum_q + prod_signed;
			end
		// otherwise, keep previous accumulated sum
		end else begin
			psum_q <= psum_q;
		end
	end
end

endmodule
