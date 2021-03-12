`include "define.sv"

module halt_control(input logic clk,rst,taken_branch,
                    input logic[`XLEN-1:0]if_id_instr,id_ex_instr,ex_mem_instr,mem_wb_instr,
                    output logic halt_if,halt_id,halt_ex,halt_mem,
                    output logic [4:0] halt);
                        
                    
       always_ff @(posedge clk or negedge rst)
       begin
            if(!rst) begin
                halt <= 5'b00000;end
             else if((ex_mem_instr[6:0] == `LOAD) && ((id_ex_instr[19:15] == ex_mem_instr[11:7]) || (id_ex_instr[24:20] == ex_mem_instr[11:7]))) begin
                halt <= 5'b11100;
             end
             else if(if_id_instr[19:15] == ex_mem_instr[11:7] || if_id_instr[24:20] == ex_mem_instr[11:7])begin
                halt <= 5'b00011;
             end
             else begin
                halt <= 5'b00000;end
            end
endmodule:halt_control
