//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.11.2020 12:07:34
// Design Name: 
// Module Name: define
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//
//

`define XLEN 32
`define ADDR_LEN 1024 
//OPCode[6:0]
`define OP         7'b0110011 //Instruction : ADD,SUB,AND
`define OP_IMM     7'b0010011 //Immediate Instruction : ADDI,SUBI,SULI
`define LUI        7'b0110111 //Load Upperimmidiate
`define AUIPC      7'b0010111 //Add Upperimmidiate
`define JAL        7'b1101111 //Jump Instruction
`define JALR       7'b1100111 //Jump Indirect Instruction
`define BRANCH     7'b1100011 //Branch Instruction
`define STORE      7'b0100011 //Store Instruction
`define LOAD       7'b0000011 //Load Instruction
`define MISC_MEM   7'b0100011 //IO & Memory Access Instruction

//-----------------Function 3 [14:12]---------------------------//
//OP
`define FN3_ADD    3'b000 //ADD
`define FN3_SUB    3'b000 //SUB
`define FN3_SLL    3'b001 //Shift Left Logic
`define FN3_SLT    3'b010 //Compare signed
`define FN3_SLTU   3'b011 //Compare unsigned
`define FN3_XOR    3'b100 //XOR
`define FN3_SRL    3'b101 //Shift Right Logic
`define FN3_SRA    3'b101 //Shift Right Arithmetic
`define FN3_OR     3'b110 //OR
`define FN3_AND    3'b111 //AND
//Immediate
`define FN3_ADDI   3'b000 //ADD 
`define FN3_SLTI   3'b010 //Compare 
`define FN3_SLTIU  3'b011 //Compare Signed 
`define FN3_XORI   3'b100 //XOR 
`define FN3_ORI    3'b110 //OR 
`define FN3_ANDI   3'b111 //AND 
`define FN3_SLLI   3'b001 
`define FN3_SRLI   3'b101 
`define FN3_SRAI   3'b101 
//Branch
`define FN3_BEQ    3'b000 //Branch if Equal 
`define FN3_BNE    3'b001 //Branch if Not Equal
`define FN3_BLT    3'b100 //Branch if less than
`define FN3_BGE    3'b101 //Branch if greater than
`define FN3_BLTU   3'b110 //
`define FN3_BGEU   3'b111 //
//Load
`define FN3_LB     3'b000 //
`define FN3_LH     3'b001 //
`define FN3_LW     3'b010 //
`define FN3_LBU    3'b100 //
`define FN3_LHU    3'b101 //
//Store
`define FN3_SB     3'b000 //
`define FN3_SH     3'b001 //
`define FN3_SW     3'b010 //
`define FN3_SBU    3'b100 //
`define FN3_SHU    3'b101 //
//Load
`define FN3_FENCE  3'b000 //
`define FN3_FENCEI 3'b001 //


//-----------------Function 7 [31:25]---------------------------//
//OP
`define FN7_F1     7'b0000000 //ADD
`define FN7_F2     7'b0100000 //SUB
//`define FN7_SLL    7'b0000000 //Shift Left Logic
//`define FN7_SLT    7'b0000000 //Compare signed
//`define FN7_SLTU   7'b0000000 //Compare unsigned
//`define FN7_XOR    7'b0000000 //XOR
//`define FN7_SRL    7'b0000000 //Shift Right Logic
//`define FN7_SRA    7'b0100000 //Shift Right Arithmetic
//`define FN7_OR     7'b0000000 //OR
//`define FN7_AND    7'b0000000 //AND
////OP-IMM
//`define FN7_SLLI   7'b0000000 //Shift Left Immediate
//`define FN7_SRLI   7'b0000000 //Shift Right Immediate
//`define FN7_SRAI   7'b0100000 //Shift Right Immediate