`timescale 1ns / 1ps
`include "define.v"

module main_memory(input clk,read_en,write_en,
            input [`XLEN-1:0]pc_in,data_in,addr_in,
            output reg [`XLEN-1:0] instruction_out, data_out);
            
            reg [`XLEN-1:0]mem_bank[0:`ADDR_LEN-1];

            always @(*)begin
              if(read_en )begin 
                  instruction_out <= mem_bank[pc_in];
                  data_out        <= mem_bank[addr_in];end
            end

            always @(posedge clk)
            begin
                if(write_en)begin 
                    mem_bank[addr_in]     <= data_in;
                end
            end
            
endmodule
