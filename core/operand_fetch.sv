`include "define.sv"


module operand_fetch( input  logic clk,halt,
                     input  logic [`XLEN-1:0] pc_in,instruction_in,
                     output logic [`XLEN-1:0] instruction_out, pc_out,
                     output logic [`XLEN-1:0] imm_i_type,imm_s_type,imm_b_type,imm_u_type,imm_j_type);                    

      
 always_ff @(posedge clk)
    begin
        if(halt == 1'b0)begin
            instruction_out <= instruction_in;
            pc_out          <= pc_in;        
            imm_i_type <= {{21{instruction_in[31]}}, instruction_in[30:20]};
            imm_s_type <= {{21{instruction_in[31]}}, instruction_in[30:25],instruction_in[11:7]};
            imm_b_type <= {{20{instruction_in[31]}}, instruction_in[7], instruction_in[30:25], instruction_in[11:8],1'b0};
            imm_u_type <= {instruction_in[31:12], 12'b0};
            imm_j_type <= {{12{instruction_in[31]}},instruction_in[19:12],instruction_in[20],instruction_in[30:21],1'b0};
        end
    end
endmodule:operand_fetch
