`timescale 1ns / 1ps
`include "define.v"

module halt_control(input clk,rst,taken_branch,
                    input[`XLEN-1:0]mem_wb_instr,id_ex_instr,
                    output halt_if,halt_id,halt_ex,halt_mem,
                    output reg [4:0] halt);
                    
                    
                    
       always @(posedge clk or negedge rst)
       begin
            if(!rst) begin
                halt <= 5'b00000;end
             else if((mem_wb_instr[6:0] == `LOAD) && ((id_ex_instr[19:15] == mem_wb_instr[11:7]) || (id_ex_instr[24:20] == mem_wb_instr[11:7]))) begin
                halt <= 5'b11100;
             end
             else begin
                halt <= 5'b00000;end
            end
endmodule
