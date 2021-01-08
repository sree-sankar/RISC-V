`timescale 1ns / 1ps
`include "define.v"


module instr_decode( input clk,halt,
                     input  [`XLEN-1:0] pc_in,instruction_in,
                     output reg [`XLEN-1:0] instruction_out,
                     output reg [`XLEN-1:0]pc_out);                    

 always @(posedge clk)
    begin
    if(halt == 1'b0)begin
        instruction_out <= instruction_in;
        pc_out          <= pc_in;        
        end
        
    else begin
        instruction_out <= 32'b0;end
    end
endmodule
