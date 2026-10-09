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

module threshold_dect
#(
    parameter [1:0] trunc_shift = 0,
    parameter [3:0] n_cycles = 12
)
(
    input clk, rst,
    input start_compare,
    input [17-trunc_shift:0] in_value_sqr_trunc_d2,
    input [22-trunc_shift:0] threshold,
    output reg spike
);

    reg stop;
    reg [3:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            spike <= 0;
            stop <= 0;
            counter <= 0;
        end else begin
            // Logica di Spike
            if (!stop && start_compare && (in_value_sqr_trunc_d2 > threshold)) begin
                spike <= 1;
                stop <= 1;
                counter <= 0;
            end else begin
                spike <= 0;
                // Logica di conteggio per il reset di stop
                if (stop) begin
                    if (counter >= n_cycles - 2) begin
                        stop <= 0;
                        counter <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end
            end
        end
	end
endmodule

/*

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

module threshold_dect
#(
parameter  [1:0] trunc_shift = 0,	// default = 0	
parameter [3:0] n_cycles = 12
)
(
input  clk,rst,
input  start_compare,
input  [17-trunc_shift:0] in_value_sqr,
input  [22-trunc_shift:0] threshold,

output reg spike
);

// per un periodo di stop del rilevamento delle spike di 0.5 ms,
// si ottiene un numero di cicli di clock pari a: 0.5 ms / Tclk = 12
    

reg stop = 0;	// inizializzato a 0 
reg hit_n = 0;
reg [3:0] counter = 0;

// spike = 1 se: input^2 > threshold && fine periodo disabilitazione detector di spike && fine prima threshold windows
always @(*) begin
    if((in_value_sqr > threshold) && (stop == 0) && (start_compare)) begin
        spike = 1;
    end
    else begin
       spike = 0; 
    end
end


always @(posedge clk) begin
	if(spike) stop <= 1;
	if(hit_n) stop <= 0;		// rimosso  rst || 
end

always @(posedge clk) begin
	//hit_n <= 0;
	//counter <= counter;
    if (stop) begin
		counter <= 0;
        hit_n <= 1;
        if (counter < n_cycles - 2) begin
            counter <= counter + 1;
            hit_n <= 0;
        end
    end
	//if (rst) begin
    //    counter <= 0;
    //    hit_n <= 0;
    //end 
end

endmodule

*/
