`timescale 1ns / 1ps
`include "define.v"


module reg_memory(
    input clk,read_en,write_en,
    input [4:0]rs1_addr,rs2_addr,rd_addr,bypass_rd,
    input [`XLEN-1:0]data_in, bypass_res,
    output reg [`XLEN-1:0] rs1,rs2
);
   reg [`XLEN-1:0] reg_bank[0:`XLEN-1];
   
  //Write 
    always @(posedge clk)
        begin
         if(write_en == 1'b1 && rd_addr != 5'b00000) begin
            reg_bank[rd_addr] <= data_in; end
        end
        
  //Read      
    always @(*) begin
        if(read_en==1'b1 && rs1_addr == bypass_rd)begin
          rs1 <= bypass_res;
        end
       else begin
          rs1 <= reg_bank[rs1_addr];
       end
    end
    always @(*) begin
        if(read_en == 1'b1 && rs2_addr == bypass_rd)begin
          rs2 <= bypass_res;
        end
       else begin
          rs2 <= reg_bank[rs2_addr];
       end
    end 

endmodule
