`timescale 1ns / 1ps
`include"define.v"

module write_back(input clk,halt,taken_branch,
                  input[`XLEN-1:0] instruction_in, alu_in,
                  output reg reg_write_en);
                  
   always @(posedge clk)
    begin
        if(halt==1'b0 && taken_branch == 1'b0)
        begin
            reg_write_en   <= 1;
            if(instruction_in[6:0] == `STORE)
                 begin reg_write_en   <= 0; end
            end
    end
endmodule
