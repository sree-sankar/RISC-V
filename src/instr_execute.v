`timescale 1ns / 1ps
`include "define.v"

module instr_execute(
    input clk,rst,halt,taken_branch,
    input [`XLEN-1:0] pc_in,instruction_in,
    input [`XLEN-1:0] rs1,rs2,
    output reg branch_en,
    output reg [`XLEN-1:0] alu_out,mem_data_out,
    output reg [`XLEN-1:0] instruction_out,rs2_out,branch_addr
    );
    
    always @(posedge clk or negedge rst)
    begin
    if(!rst)begin
           branch_en       <= 0;
           branch_addr     <= 0;
    end 
    else begin 
     if(halt == 1'b0 && taken_branch == 1'b0)begin
       instruction_out <= instruction_in;
       rs2_out         <= rs2;
       branch_en       <= 0;
       alu_out         <= 32'bx;
       case(instruction_in[6:0])
//---------------------OP------------------------------//
            `OP:begin
                if(instruction_in[31:25] == `FN7_F1)begin
                    case(instruction_in[14:12])
                        `FN3_ADD  : alu_out  <= rs1 + rs2;
                        `FN3_SLL  : alu_out  <= rs1 << rs2[4:0];
                        `FN3_SLT  : alu_out  <= rs1 < rs2;
                        `FN3_SLTU : alu_out  <= $unsigned(rs1) < $unsigned(rs2);
                        `FN3_XOR  : alu_out  <= rs1 ^ rs2;
                        `FN3_SRL  : alu_out  <= rs1 >> rs2[4:0];
                        `FN3_OR   : alu_out  <= rs1 | rs2;
                        `FN3_AND  : alu_out  <= rs1 & rs2;
                    endcase end
                    
                else if(instruction_in[31:25] == `FN7_F2) begin
                     case(instruction_in[14:12])
                        `FN3_SUB  : alu_out <= rs1 - rs2;
                        `FN3_SRA  : alu_out <= $signed(rs1) >>> rs2[4:0];
                     endcase end
                end
//------------------------------------OP_IMM----------------------------------------//
            `OP_IMM:begin
                case(instruction_in[14:12])   
                        `FN3_ADDI  : alu_out  <= rs1 + {{20{instruction_in[31]}},instruction_in[31:20]};
                        `FN3_SLTI  : alu_out  <= rs1 < {{20{instruction_in[31]}},instruction_in[31:20]};  
                        `FN3_SLTIU : alu_out  <= $unsigned(rs1) < $unsigned({{20{instruction_in[31]}},instruction_in[31:20]});
                        `FN3_XORI  : alu_out  <= rs1 ^ {{20{instruction_in[31]}},instruction_in[31:20]};
                        `FN3_ORI   : alu_out  <= rs1 | {{20{instruction_in[31]}},instruction_in[31:20]};
                        `FN3_ANDI  : alu_out  <= rs1 & {{20{instruction_in[31]}},instruction_in[31:20]};
                        `FN3_SLLI  : alu_out  <= rs1 << instruction_in[24:20];
                        `FN3_SRLI  : alu_out  <= rs1 >> instruction_in[24:20];
                        `FN3_SRAI  : alu_out  <= $signed(rs1) >>> rs2[4:0];
                   endcase
                end  
//------------------------------------BRANCH----------------------------------------//
            `BRANCH:begin
                case(instruction_in[14:12])   
                        `FN3_BEQ  :  {instruction_out,branch_en, branch_addr}  <= (rs1 == rs2) ?  {32'b0,1'b1, pc_in + {{20{instruction_in[31]}}, instruction_in[30:25], instruction_in[11:7],1'b0}} : 0; 
                        `FN3_BNE  :  {instruction_out,branch_en, branch_addr}  <= (rs1 != rs2) ?  {32'b0,1'b1, pc_in + {{20{instruction_in[31]}}, instruction_in[30:25], instruction_in[11:7],1'b0}} : 0; 
                        `FN3_BLT  :  {instruction_out,branch_en, branch_addr}  <= (rs1 < rs2)  ?  {32'b0,1'b1, pc_in + {{20{instruction_in[31]}}, instruction_in[30:25], instruction_in[11:7],1'b0}} : 0; 
                        `FN3_BGE  :  {instruction_out,branch_en, branch_addr}  <= (rs1 > rs2)  ?  {32'b0,1'b1, pc_in + {{20{instruction_in[31]}}, instruction_in[30:25], instruction_in[11:7],1'b0}} : 0; 
                        `FN3_BLTU :  {instruction_out,branch_en, branch_addr}  <= ($unsigned(rs1) < $unsigned(rs2)) ? {32'b0,1'b1, pc_in + {{20{instruction_in[31]}},instruction_in[30:25], instruction_in[11:7],1'b0}} : 0; 
                        `FN3_BGEU :  {instruction_out,branch_en, branch_addr}  <= ($unsigned(rs1) > $unsigned(rs2)) ? {32'b0,1'b1, pc_in + {{20{instruction_in[31]}},instruction_in[30:25], instruction_in[11:7],1'b0}} : 0; 
                   endcase
                end                        
//---------------------LUI------------------------------//
            `LUI   :  begin 
                      alu_out <=  {instruction_in[31:12], {12{1'b0}}}; end 
//---------------------ALUI------------------------------//
            `AUIPC :  begin 
                      alu_out <=  pc_in + {instruction_in[31:12],{12{1'b0}}};
                      end
//---------------------JAL------------------------------//
            `JAL   : begin
                       branch_en   <= 1'b1;                      
                       alu_out     <= pc_in + 1;
                       branch_addr <= pc_in +{{12{instruction_in[31]}},instruction_in[31:12]};
                     end
//---------------------JALR------------------------------//
            `JALR  :  begin
                       branch_en   <= 1'b1;                      
                       alu_out     <= pc_in + 1;
                       branch_addr <= (rs1 +{{20{instruction_in[31]}},instruction_in[31:20]}) & 32'b1111_1111_1111_1111_1111_1111_1111_1110;
                     end
//---------------------LOAD------------------------------//
            `LOAD  :  begin 
                      alu_out <= rs1 + {{20{instruction_in[31]}},instruction_in[31:20]}; end   
//---------------------STORE------------------------------//
            `STORE :   begin 
                      alu_out <=  rs1 + {{20{instruction_in[31]}}, instruction_in[31:25],instruction_in[11:7]};
                      case(instruction_in[14:12])  
                          `FN3_SB  : mem_data_out  <= {{24{1'b0}},rs2[7:0]};
                          `FN3_SH  : mem_data_out  <= {{16{1'b0}},rs2[15:0]};
                          `FN3_SW  : mem_data_out  <= rs2;
                          `FN3_SBU : mem_data_out  <= $unsigned(rs2[7:0]);
                          `FN3_SHU : mem_data_out  <= $unsigned( {{16{1'b0}},rs2[15:0]} );
                      endcase
                      
                      end             
              endcase end
            else begin 
                 instruction_out <= 32'b0;
                 alu_out         <= 32'b0;
          end
       end
    end
endmodule
