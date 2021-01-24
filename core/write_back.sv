`timescale 1ns / 1ps
`include"define.sv"

module write_back(input  logic clk,halt,taken_branch,
                  input  logic [`XLEN-1:0] instruction_in, alu_in,
                  output logic reg_write_en);
                  
   always_ff @(posedge clk)
    begin
        if(halt==1'b0 && taken_branch == 1'b0)
        begin
            reg_write_en   <= 1;
            if(instruction_in[6:0] == `STORE)
                 begin reg_write_en   <= 0; end
            end
    end
endmodule:write_back
