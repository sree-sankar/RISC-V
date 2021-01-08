`timescale 1ns / 1ps
`include "define.v"

module mem_access(input clk,taken_branch,halt,
                  input [`XLEN-1:0] pc_in,alu_in,instruction_in,rs2,mem_data_in,
                  output reg [`XLEN-1:0] mem_out,mem_addr,instruction_out,
                  output reg mem_write_en);
                       

    always @(posedge clk)
    begin
        if(halt == 1'b0 && taken_branch == 1'b0)begin
            instruction_out <= instruction_in;
            mem_out <= 32'bx;
            mem_write_en   <= 1'b1; 
            case(instruction_in[6:0])
                `OP,`OP_IMM,`LUI,`AUIPC  : begin mem_write_en   <= 1'b0; 
                                                 mem_out        <= alu_in;
                                                 mem_write_en   <= 1'b0;   end                            
                `LOAD       : begin       
                               mem_write_en   <= 1'b0;           
                               case(instruction_in[14:12])
                               `FN3_LB   : mem_out  <= {{24{1'b0}},mem_data_in[7:0]};
                               `FN3_LH   : mem_out  <= {{16{1'b0}},mem_data_in[15:0]};
                               `FN3_LW   : mem_out  <= mem_data_in;
                               `FN3_LBU  : mem_out  <= $unsigned(mem_data_in[7:0]);
                               `FN3_LHU  : mem_out  <= $unsigned( {{16{1'b0}},mem_data_in[15:0]} );
                               endcase
                              end
                `STORE     : begin mem_write_en   <= 1'b1;
                                   instruction_out <= 0;   end
                `JAL,`JALR : begin 
                                   mem_out  <= alu_in + 1; end
                endcase
            end
            else begin instruction_out <= 32'b0; 
                       mem_out         <= 32'b0;
                       mem_write_en    <= 1'b0; 

                 end
        end
endmodule
