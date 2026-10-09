`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Unica
// Engineer: Fabio Piras & Matteo Matta
// 
// Create Date: 28.09.2022
// Design Name: folded
// Module Name: top
//
//////////////////////////////////////////////////////////////////////////////////
module top#(
    // 1. Dichiarazione dei parametri nel TOP con i loro valori di default
    parameter [1:0] trunc_shift = 0,
    parameter [5:0] rms_coeff   = 10,	// set 15 if trunc=2, 10 otherwise
	parameter [14:0] thr_w = 2**8,
	parameter [3:0] n_cycles = 12
)(
    input clk, rst,
    input en,
    input signed [7:0] x,
    // input signed [2:0] b0, b1, b2,

	output ready,
	output en_acc_rms,
	output spike,
    output [22-trunc_shift:0] threshold,
	output en_shift
);

wire en_shift, en_add_mad, en_abs, en_mult_rms, en_acc_rms, en_d2_rms;
wire [8:0] out_abs;
wire [9:0] out_mad;
wire [17:0] in_value_sqr_trunc_d2;

ctrl_unit ctrl_unit_module(clk, rst, en, ready, en_shift, en_add_mad, en_abs, en_mult_rms, en_acc_rms, en_d2_rms);
mad_filter mad_module(clk, rst, en_shift, en_add_mad, x, out_mad);
abs abs_module(out_mad, clk, rst, en_abs, out_abs);
rms #(trunc_shift, rms_coeff, thr_w) rms_module(clk, rst, en_mult_rms, en_acc_rms, en_d2_rms, out_abs, start_compare, threshold, in_value_sqr_trunc_d2);
threshold_dect #(trunc_shift, n_cycles) thr_dect_module(clk, rst, start_compare, in_value_sqr_trunc_d2, threshold, spike);

endmodule
