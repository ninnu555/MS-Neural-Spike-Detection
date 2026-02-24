`timescale 1ns/1ps

module nandNet (
    in_nand, 
    out_nand
);

parameter N = 256;

input [0:N-1] in_nand;
output reg [0:N-2] out_nand;

integer i;

always @(*) begin
	// definizione prima nand che ha solo due ingressi. Una eventuale bubble non pu essere corretta per lei
    out_nand[0] = ~(in_nand[0] & ~in_nand[1]);
	//definizione di tutte le altre nand
    for (i = 1; i < N-1; i = i + 1) begin
        out_nand[i] = ~(in_nand[i-1] & in_nand[i] & ~in_nand[i+1]); // NAND tra i bit adiacenti
    end

end
    
endmodule
