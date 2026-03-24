// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module mac_tb;

parameter bw = 4;
parameter psum_bw = 16;

reg clk = 0;

//reg [bw-1:0] a;
//reg [bw-1:0] b;
reg  [4*bw-1:0] a;
reg  [4*bw-1:0] b;
reg  [psum_bw-1:0] c;
wire [psum_bw-1:0] out;
reg  [psum_bw-1:0] expected_out = 0;

integer w_file ; // file handler
integer w_scan_file ; // file handler

integer x_file ; // file handler
integer x_scan_file ; // file handler

integer x_dec;
integer w_dec;
integer i; 
integer u;

// registers to temporarily store data values
reg [4*bw-1:0] a_reg;
reg [4*bw-1:0] b_reg;


function [3:0] w_bin;
  input integer  weight ;
  begin

    if (weight>-1)
     w_bin[3] = 0;
    else begin
     w_bin[3] = 1;
     weight = weight + 8;
    end

    if (weight>3) begin
     w_bin[2] = 1;
     weight = weight - 4;
    end
    else 
     w_bin[2] = 0;

    if (weight>1) begin
     w_bin[1] = 1;
     weight = weight - 2;
    end
    else 
     w_bin[1] = 0;

    if (weight>0) 
     w_bin[0] = 1;
    else 
     w_bin[0] = 0;

  end
endfunction


// convert decimal to 4-bit binary representation
function [3:0] x_bin;
	// declare activation value (read from a_data.txt)
	input integer act_val;
	begin
		// n = 3
		begin
			if ( act_val >= 8 ) begin
				x_bin[3] = 1;
				act_val = act_val - 8;
			end else begin
				x_bin[3] = 0;
			end
		end
		// n = 2
		begin
			if ( act_val >= 4 ) begin
				x_bin[2] = 1;
				act_val = act_val - 4;
			end else begin
				x_bin[2] = 0;
			end
		end
		// n = 1
		begin
			if ( act_val >= 2 ) begin
				x_bin[1] = 1;
				act_val = act_val - 2;
			end else begin
				x_bin[1] = 0;
			end
		end
		// n = 0
		begin
			if ( act_val >= 1 ) begin
				x_bin[0] = 1;
				act_val = act_val - 1;
			end else begin
				x_bin[0] = 0;
			end
		end
	end
endfunction


// Below function is for verification
function [psum_bw-1:0] mac_predicted;

	// variables
	input [4*bw-1:0] a;	// store all sets of 4 integers
	input [4*bw-1:0] b;
	input [psum_bw-1:0] c;	// already 16-bit integer
	integer a_int[0:3];	// array of 4 integers
	integer b_int[0:3];
	integer sum;
	integer i;

	begin
		// extract each set of 4 integers
		for (i=0; i<4; i=i+1) begin
			// convert 4-bit binary to integer (unsigned a)
			a_int[i] = 8*a[4*i+3] + 4*a[4*i+2] + 2*a[4*i+1] + 1*a[4*i+0];
			// convert 4-bit binary to integer (signed b)
			if (b[4*i+3] == 1) begin	// check MSB to see if pos or neg number
				b_int[i] = 4*b[4*i+2] + 2*b[4*i+1] + 1*b[4*i+0] - 8;
			end else begin
				b_int[i] = 4*b[4*i+2] + 2*b[4*i+1] + 1*b[4*i+0];
			end
		end

		// perform MAC
		sum = (a_int[0]*b_int[0]) + (a_int[1]*b_int[1]) + (a_int[2]*b_int[2]) + (a_int[3]*b_int[3]);
		mac_predicted = c + sum;
	end

endfunction



mac_wrapper #(.bw(bw), .psum_bw(psum_bw)) mac_wrapper_instance (
	.clk(clk), 
        .a(a), 
        .b(b),
        .c(c),
	.out(out)
);
 

initial begin 

  w_file = $fopen("b_data.txt", "r");  //weight data
  x_file = $fopen("a_data.txt", "r");  //activation

  $dumpfile("mac_tb.vcd");
  $dumpvars(0,mac_tb);
  $dumpvars(1,mac_tb.expected_out);
 
  #1 clk = 1'b0;  
  #1 clk = 1'b1;
  #1 clk = 1'b0;

  $display("-------------------- Computation start --------------------");
  
  
  // load data sequentially, compute MAC in parallel (as data is loaded)
  	// 20 data values for each x,w (5 cycles of nested loops)
  for (i=0; i<5; i=i+1) begin  // Data lenght is 10 in the data files
	  for (u=0; u<4; u=u+1) begin	// each set contains 4 decimal numbers
		w_scan_file = $fscanf(w_file, "%d\n", w_dec);	// read integers from file
		x_scan_file = $fscanf(x_file, "%d\n", x_dec);
		a_reg[4*u +: 4] = x_bin(x_dec);			// convert decimal to binary
		b_reg[4*u +: 4] = w_bin(w_dec);				// order from LSB -> MSB, 4 bits each time
	  end

     #1 clk = 1'b1;
     #1 clk = 1'b0;

     //w_scan_file = $fscanf(w_file, "%d\n", w_dec);
     //x_scan_file = $fscanf(x_file, "%d\n", x_dec);

     //a = x_bin(x_dec); // unsigned number
     //b = w_bin(w_dec); // signed number
     
     a = a_reg;
     b = b_reg;
     c = expected_out;

     expected_out = mac_predicted(a, b, c);

  end



  #1 clk = 1'b1;
  #1 clk = 1'b0;

  $display("-------------------- Computation completed --------------------");

  #10 $finish;


end

endmodule




