`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Unica
// Engineer: Gianluca Leone
// 
// Create Date: 28.09.2022
// Design Name: folded
// Module Name: dp
//
//////////////////////////////////////////////////////////////////////////////////

module abs(
input  signed [9:0] in_abs,
input clk, rst, en_abs,
output reg [8:0] out_abs
);

// se il MSB dell'input  alto il valore  negativo -> l'uscita assume il corrispettivo valore positivo
// assign abs_value = in_value[6] == 1 ? -in_value : in_value;

always @(posedge clk)
	begin
		if (rst) out_abs <= 0;
		else 
		if (en_abs) begin
			if(in_abs[9]) out_abs <= -in_abs;
			else out_abs <= in_abs;
		end
	end

endmodule
