`include"define.sv"

module write_back(input  logic clk,halt,taken_branch,
                  input  logic [`XLEN-1:0] instruction_in,alu_in, 
                  output logic reg_write_en);
                  
          assign reg_write_en = (instruction_in[6:0] == `STORE ) ? 0 : 1;        
                  
endmodule:write_back

