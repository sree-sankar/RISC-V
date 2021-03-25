`include "define.sv"

module instr_execute(
    input  logic clk,rst,halt,taken_branch,
    input  logic [`XLEN-1:0] pc_in,instruction_in,
    input  logic signed[`XLEN-1:0] rs1,rs2,
    input  logic [`XLEN-1:0] imm_i_type,imm_s_type,imm_b_type,imm_j_type,imm_u_type,
    output logic branch_en,
    output logic [`XLEN-1:0] alu_out,mem_data_out,
    output logic [`XLEN-1:0] instruction_out,rs2_out,branch_addr
    );
    
    logic [`XLEN-1 : 0] alu_comb_out,mem_comb_data_out,branch_comb_addr;
    logic branch_comb_en;
    
    //Branch Enable
    assign branch_en = branch_comb_en;
    
    always_ff @(posedge clk or negedge rst)
    begin
        if(!rst)begin
            branch_addr     <= 0;
        end 
        else begin 
            if(halt == 1'b0 && taken_branch == 1'b0)begin
                instruction_out <= instruction_in;
                rs2_out         <= rs2;
                alu_out         <= alu_comb_out;
                mem_data_out    <= mem_comb_data_out;
                branch_addr     <= branch_comb_addr;
                end
            else begin 
                instruction_out <= 32'bx;
                alu_out         <= 32'bx;end    
        end
   end     
        
        //ALU
        always_comb begin
            case(instruction_in[6:0])
//---------------------OP------------------------------//
            `OP:begin
                case(instruction_in[14:12])
                   `FN3_ADD_SUB  : alu_comb_out  <= (instruction_in[31:25] == `FN7_F1) ?  (rs1 + rs2) :
                                                    (instruction_in[31:25] == `FN7_F2) ?  (rs1 - rs2) : 32'bx;
                   `FN3_SLL      : alu_comb_out  <= rs1 << rs2[4:0];
                   `FN3_SLT      : alu_comb_out  <= rs1 < rs2;
                   `FN3_SLTU     : alu_comb_out  <= $unsigned(rs1) < $unsigned(rs2);
                   `FN3_XOR      : alu_comb_out  <= rs1 ^ rs2;
                   `FN3_SRL_SRA  : alu_comb_out  <= (instruction_in[31:25] == `FN7_F1) ?  rs1 >> rs2[4:0]  :
                                                    (instruction_in[31:25] == `FN7_F2) ?  rs1 >>> rs2[4:0] : 32'bx;
                   `FN3_OR       : alu_comb_out  <= rs1 | rs2;
                   `FN3_AND      : alu_comb_out  <= rs1 & rs2;
                endcase
               end
//------------------------------------OP_IMM----------------------------------------//
            `OP_IMM:begin
                case(instruction_in[14:12])   
                        `FN3_ADDI  : alu_comb_out  <= rs1 + imm_i_type;
                        `FN3_SLTI  : alu_comb_out  <= rs1 < imm_i_type;  
                        `FN3_SLTIU : alu_comb_out  <= $unsigned(rs1) < $unsigned(imm_i_type);
                        `FN3_XORI  : alu_comb_out  <= rs1 ^ imm_i_type;
                        `FN3_ORI   : alu_comb_out  <= rs1 | imm_i_type;
                        `FN3_ANDI  : alu_comb_out  <= rs1 & imm_i_type;
                        `FN3_SLLI  : alu_comb_out  <= rs1 << instruction_in[24:20];
                        `FN3_SRLI  : alu_comb_out  <= rs1 >> instruction_in[24:20];
                        `FN3_SRAI  : alu_comb_out  <= rs1 >>> rs2[4:0];
                   endcase
                end  
//------------------------------------BRANCH----------------------------------------//
            `BRANCH : begin
                case(instruction_in[14:12])   
                        `FN3_BEQ  :  {branch_comb_en, branch_comb_addr}  <= (rs1 == rs2) ?  {1'b1, pc_in + imm_b_type} : 0; 
                        `FN3_BNE  :  {branch_comb_en, branch_comb_addr}  <= (rs1 != rs2) ?  {1'b1, pc_in + imm_b_type} : 0; 
                        `FN3_BLT  :  {branch_comb_en, branch_comb_addr}  <= (rs1 < rs2)  ?  {1'b1, pc_in + imm_b_type} : 0; 
                        `FN3_BGE  :  {branch_comb_en, branch_comb_addr}  <= (rs1 > rs2)  ?  {1'b1, pc_in + imm_b_type} : 0; 
                        `FN3_BLTU :  {branch_comb_en, branch_comb_addr}  <= ($unsigned(rs1) < $unsigned(rs2)) ? {1'b1, pc_in + imm_b_type} : 0; 
                        `FN3_BGEU :  {branch_comb_en, branch_comb_addr}  <= ($unsigned(rs1) > $unsigned(rs2)) ? {1'b1, pc_in + imm_b_type} : 0; 
                   endcase
                end                        
//---------------------LUI------------------------------//
            `LUI   :  begin alu_comb_out <=  imm_u_type; end 
//---------------------ALUI------------------------------//
            `AUIPC :  begin alu_comb_out <=  pc_in + imm_u_type; end
//---------------------JAL------------------------------//
            `JAL   : begin
                       branch_comb_en <= 1'b1;
                       alu_comb_out     <= pc_in + 1;
                       branch_addr      <= pc_in +{{12{instruction_in[31]}},instruction_in[31:12]};
                     end
//---------------------JALR------------------------------//
            `JALR  :  begin
                       branch_comb_en <= 1'b1;
                       alu_comb_out     <= pc_in + 1;
                       branch_comb_addr <= (rs1 +{{20{instruction_in[31]}},instruction_in[31:21], 1'b0});
                     end
//---------------------LOAD------------------------------//
            `LOAD  :  begin alu_comb_out <= rs1 + imm_i_type; end   
//---------------------STORE------------------------------//
            `STORE :  begin 
                      alu_comb_out <=  rs1 + imm_s_type ;
                      case(instruction_in[14:12])  
                          `FN3_SB  : mem_comb_data_out  <= {{24{1'b0}},rs2[7:0]};
                          `FN3_SH  : mem_comb_data_out  <= {{16{1'b0}},rs2[15:0]};
                          `FN3_SW  : mem_comb_data_out  <= rs2;
                          `FN3_SBU : mem_comb_data_out  <= $unsigned(rs2[7:0]);
                          `FN3_SHU : mem_comb_data_out  <= $unsigned( {{16{1'b0}},rs2[15:0]} );
                      endcase end 
           default : begin  alu_comb_out       <= 32'bx;
                            branch_comb_en     <= 1'b0;
                            mem_comb_data_out  <= 32'bx;
                            branch_comb_addr   <= 32'bx;
                      end          
         endcase 
   end
    
      
        
endmodule:instr_execute
