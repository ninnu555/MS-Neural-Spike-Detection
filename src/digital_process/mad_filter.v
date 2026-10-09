`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Unica
// Engineer: Fabio Piras & Matteo Matta
// 
// Create Date: 28.09.2022
// Design Name: folded
// Module Name: dp
//
//////////////////////////////////////////////////////////////////////////////////

module mad_filter(
input clk, rst,
input en,
input en_add_mad,
// input signed [2:0] b0, b1, b2,
input signed [7:0] x,

output reg signed [9:0] out_mad
);

reg signed [7:0] x_shift [2:0];

// shifter
integer i;
always @(posedge clk) begin
    if(rst) begin
        for(i=0;i<3;i=i+1)    
            x_shift[i] <= 0;
	end 
	else if(en) begin
		x_shift[0] <= x;
		for(i=1;i<3;i=i+1) begin
			x_shift[i] <= x_shift[i-1];
			// simmetrizzato intervallo input da [-128;127] a [-127;127] per risparmiare 1 bit in mul_1_out e mul_2_out
			if (x_shift[i-1] == -128) 
				x_shift[i] <= -127;
		end
	end
end

/*
	mul_0_out, mul_1_out e mul_2_out sono dimensionati in base al caso peggiore incontrato in simulazione:
	mul_0_out = 127 * 2 = 254 -> rappresentabile in 8 bit + 1 bit di segno -> 9 bit necessari
	mul_1_out = -127 * -1 = 127 -> rappresentabile in 7 bit + 1 bit di segno -> 8 bit necessari
	mul_2_out = -127 * -1 = 127 -> rappresentabile in 7 bit + 1 bit di segno -> 8 bit necessari
*/ 
reg signed [8:0] mul_0_out;
reg signed [7:0] mul_1_out;		// valore originale = 9 bit -> cambiato in seguito all'approssimazione -128 = -127
reg signed [7:0] mul_2_out;		// valore originale = 9 bit

always @(*) 
	// if (en_mult_mad) 
	begin
        mul_0_out <= x_shift[0] << 1; // b0
        mul_1_out <= -x_shift[1]; // b1
        mul_2_out <= -x_shift[2]; // b2
    end

// accumulator
always @(posedge clk)
	if(rst) 
		out_mad <= 0;
	else if(en_add_mad)
		out_mad <= mul_0_out + mul_1_out + mul_2_out;  
        
endmodule
