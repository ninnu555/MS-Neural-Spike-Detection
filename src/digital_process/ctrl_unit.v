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

module ctrl_unit(
input clk, rst, en,

output reg ready, en_shift, en_add_mad, en_abs, en_mult_rms, en_acc_rms, en_d2_rms
);

// control unit - signals propagation
always @(posedge clk) begin
	ready <= ~rst;
	if (rst) begin
		en_shift 	<= 0;
		en_add_mad 	<= 0;
		en_abs 		<= 0;
		en_mult_rms <= 0;
		en_acc_rms 	<= 0;
		en_d2_rms   <= 0;
	end
	else
	begin
	// en_shift <= en;
    // n_mult_mad <= en_shift;
	// en_add_mad 	<= en_mult_mad;
		en_shift 	<= en;
		en_add_mad 	<= en_shift;
		en_abs		<= en_add_mad;
		en_mult_rms <= en_abs;
		en_acc_rms 	<= en_mult_rms;
		en_d2_rms   <= en_acc_rms;
	end
end
        
endmodule
