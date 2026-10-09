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

//  - Root Mean Square (RMS): the root mean square of the processed signal.
//    When RMS is selected, the square of the processed signal is used to
//    avoid computing the square root. The threshold condition:
//          x(t) > sqrt(sum(x^2)/N)
//    becomes:
//          x^2(t) > sum(x^2)/N

module rms
#(
parameter  [1:0] trunc_shift = 0,	// default = 0	
parameter [5:0] rms_coeff = 10,
parameter [14:0] thr_w = 2**8		// tutto dimensionato per 2^8
)
(
input  clk,rst,en_mult_rms,en_acc_rms,en_d2_rms,
input  [8:0] in_value,

output reg start_compare,
output wire [22-trunc_shift:0]  threshold,		// reg
output reg [17-trunc_shift:0] in_value_sqr_trunc_d2
);

/*
	"trunc_shift" tronca di n-bit il segnale in_value_sqr affinchè le operazioni successive fino
	allo shifting di 14 (compreso) vengano eseguite con un numero minore di bit (minore complessit).
	Per avere una buona accuratezza finale l'intervallo consigliato  [0;3] con 0 che non effettua 
	alcuna approssimazione 
*/

wire [17:0] in_value_sqr;
assign in_value_sqr = in_value * in_value;

reg [25-trunc_shift:0] out_add;
reg [25-trunc_shift:0] out_add_aux;
reg hit_n;
reg [13:0] counter;
reg [17-trunc_shift:0] in_value_sqr_trunc;
reg [17-trunc_shift:0] in_value_sqr_trunc_d1;

always @(posedge clk) begin
	if(rst)
		in_value_sqr_trunc <= 0;
	else if(en_mult_rms)	
		in_value_sqr_trunc <= in_value_sqr[17:trunc_shift];
end

always @(posedge clk) begin     // da verificare se posedge o negedge+
	if(rst)
		out_add <= 0;
	else begin 
		if(hit_n)
		    out_add <= in_value_sqr_trunc;
		else if(en_acc_rms) 
			out_add <= out_add + in_value_sqr_trunc;
	end
end

wire [30:0] out_coeff;
always @(posedge clk) begin
	if (rst) begin
	out_add_aux <= 0;
	start_compare <= 0;
	end
	else 
	// if (en_d2_rms)
		if (hit_n) begin
			out_add_aux <= out_add;
			start_compare <= 1;
		end
end


/*
always @(posedge clk)begin
	if(rst) begin
		threshold <= {23{1'b0}};
		start_compare <= 0;
	end
	else 
	if (hit_n) begin
		threshold <= (out_coeff >> $clog2(thr_w));
		// flag che va ad 1 quando termina la prima threshold window - attiva la comparazione per il detecting degli spike
		start_compare <= 1;
	end
end
*/

assign out_coeff = rms_coeff * out_add_aux;

assign threshold = (out_coeff >> $clog2(thr_w));

always @(posedge clk) begin
    if (rst) begin
        counter <= 0;
        hit_n   <= 0;
    end else begin
        if (en_acc_rms) begin
            if (counter < thr_w - 1) begin
                counter <= counter + 1;
                hit_n   <= 0;
            end else begin
                counter <= 0;
                hit_n   <= 1; // Fine finestra raggiunta
            end
        end else begin
            hit_n <= 0;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        in_value_sqr_trunc_d1 <= 0;
        in_value_sqr_trunc_d2 <= 0;
  end else begin 
    if (en_acc_rms)
      in_value_sqr_trunc_d1 <= in_value_sqr_trunc;
	if (en_d2_rms)
      in_value_sqr_trunc_d2 <= in_value_sqr_trunc_d1;  
  end
end

endmodule
