`include "define.sv"

module mem_access(input  logic clk,taken_branch,halt,
                  input  logic [`XLEN-1:0] pc_in,alu_in,instruction_in,rs2,mem_data_in,
                  output logic [`XLEN-1:0] mem_out,mem_addr,instruction_out,
                  output logic mem_write_en);
                       
                 logic [`XLEN-1:0] mem_comb_out;
                 logic mem_comb_write_en ;

    assign mem_write_en = (instruction_in[14:12] == `STORE) ? 1 : 0;

    always_ff @(posedge clk)
     begin
        if(halt == 1'b0 && taken_branch == 1'b0)begin
            instruction_out <= instruction_in;
            mem_out         <= mem_comb_out;
         end
         else begin instruction_out <= 32'bx; 
                    mem_out         <= 32'bx;
         end
      end
             
      always_comb 
        begin
          case(instruction_in[6:0])
             `OP,`OP_IMM,`LUI,`AUIPC  : begin mem_comb_out   <= alu_in; end                            
             `LOAD      : begin           
                             case(instruction_in[14:12])
                               `FN3_LB   : mem_comb_out  <= {{24{1'b0}},mem_data_in[7:0]};
                               `FN3_LH   : mem_comb_out  <= {{16{1'b0}},mem_data_in[15:0]};
                               `FN3_LW   : mem_comb_out  <= mem_data_in;
                               `FN3_LBU  : mem_comb_out  <= $unsigned(mem_data_in[7:0]);
                               `FN3_LHU  : mem_comb_out  <= $unsigned( {{16{1'b0}},mem_data_in[15:0]} );
                             endcase
                          end
             `JAL,`JALR : begin mem_comb_out <= alu_in;end
             default    : begin mem_comb_out <= 32'bx; end  
          endcase
        end
         
endmodule:mem_access
