`timescale 1ns / 1ps
`include"define.v"


module instr_fetch(
                input clk,halt,rst,branch_en,
                input [`XLEN-1:0] branch_addr,
                output reg [`XLEN-1:0]pc,next_pc,
                output reg taken_branch,mem_read_en,reg_read_en
                );
                    
    always @(posedge clk or negedge rst)
    begin
         if(!rst) begin
            pc              <= 0;
            next_pc         <= 1;
            taken_branch    <= 1'b0;
            mem_read_en     <= 1'b1;
            reg_read_en     <= 1'b1;
            end
        else begin

            if(halt == 1'b0 && branch_en == 1'b1 ) begin
               pc           <= branch_addr;
               next_pc      <= branch_addr + 1;
               taken_branch <= 1'b1;end 
               
            else if(halt == 1'b0 && branch_en == 1'b0 )begin
               pc           <= next_pc;
               next_pc      <= next_pc + 1;
               taken_branch <= 1'b0; end  
         end
         
       end      
endmodule