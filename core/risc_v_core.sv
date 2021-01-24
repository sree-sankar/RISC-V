`timescale 1ns / 1ps
`include "define.sv"


module risc_core(input logic clk, rst);
    //PC------->IF
    logic[`XLEN-1:0] PC,NPC;
    //IF------->ID
    logic[`XLEN-1:0] IF_ID_Instr;
    //ID------->EX
    logic[`XLEN-1:0] ID_EX_PC,ID_EX_Instr,ID_EX_rs1,ID_EX_rs2;
    //EX------->MEM
    logic[`XLEN-1:0] EX_MEM_Instr,EX_MEM_Out,EX_MEM_rs2,EX_PC_Branch_Addr;
    //MEM------>WB 
    logic[`XLEN-1:0] MEM_WB_Instr,MEM_WB_Out,MEM_Addr,MEM_Data,MEM_Data_Out;
//------------------------------------------------ Control Signals ---------------------------------------------------//
    logic BRANCH_EN, TAKEN_BRANCH,MEM_WRITE_EN,REG_WRITE_EN,MEM_READ_EN,REG_READ_EN;
    logic [4:0] HALT;
//----------------------------------------------------- IF-->ID ------------------------------------------------------//
instr_fetch S0(.clk(clk),
               .rst(rst),
               .halt(HALT[0]),
               .branch_en(BRANCH_EN),
               .branch_addr(EX_PC_Branch_Addr),
               .taken_branch(TAKEN_BRANCH),
               .pc(PC),
               .next_pc(NPC),
               .mem_read_en(MEM_READ_EN),
               .reg_read_en(REG_READ_EN)
               );
//----------------------------------------------------- ID-->EX ------------------------------------------------------//
instr_decode S1(.clk(clk),
                .pc_in(PC),
                .halt(HALT[1]),
                .instruction_in(IF_ID_Instr),
                .instruction_out(ID_EX_Instr),
                .pc_out(ID_EX_PC));    
//----------------------------------------------------- EX-->MEM ------------------------------------------------------//
instr_execute S2(.clk(clk),
                 .rst(rst),
                 .taken_branch(TAKEN_BRANCH),
                 .halt(HALT[2]),
                 .pc_in(ID_EX_PC),
                 .instruction_in(ID_EX_Instr),
                 .rs1(ID_EX_rs1),
                 .rs2(ID_EX_rs2),
                 .alu_out(EX_MEM_Out),
                 .instruction_out(EX_MEM_Instr),
                 .rs2_out(EX_MEM_rs2),
                 .branch_en(BRANCH_EN),
                 .branch_addr(EX_PC_Branch_Addr),
                 .mem_data_out(MEM_Data));
//----------------------------------------------------- MEM-->WB ------------------------------------------------------//
mem_access S3(.clk(clk),
              .halt(HALT[3]),
              .taken_branch(TAKEN_BRANCH),
              .alu_in(EX_MEM_Out),
              .rs2(EX_MEM_rs2),
              .instruction_in(EX_MEM_Instr),
              .pc_in(PC),
              .instruction_out(MEM_WB_Instr),
              .mem_out(MEM_WB_Out),
              .mem_addr(MEM_Addr),
              .mem_write_en(MEM_WRITE_EN),
              .mem_data_in(MEM_Data_Out)
              );
//----------------------------------------------------- MEM-->WB ---------------------------------------------------------//
write_back S4(.clk(clk),
              .halt(HALT[4]),
              .taken_branch(TAKEN_BRANCH),
              .instruction_in(MEM_WB_Instr),
              .alu_in(MEM_WB_Out),
              .reg_write_en(REG_WRITE_EN)
              );
//-------------------------------------------------- Register Memory -----------------------------------------------------//
reg_memory Reg_Mem(.clk(clk),
                   .read_en(REG_READ_EN),
                   .write_en(REG_WRITE_EN),
                   .rs1_addr(ID_EX_Instr[19:15]),
                   .rs2_addr(ID_EX_Instr[24:20]),
                   .rd_addr (MEM_WB_Instr[11:7]),
                   .data_in(MEM_WB_Out),
                   .bypass_res(EX_MEM_Out),
                   .bypass_rd(EX_MEM_Instr[11:7]),
                   .rs1(ID_EX_rs1),.rs2(ID_EX_rs2));
//---------------------------------------------------- Instruction ------------------------------------------------------//
main_memory Mem_Fetch_Access(.clk(clk),
                             .pc_in(PC),
                             .data_in(MEM_Data),
                             .read_en(MEM_READ_EN),
                             .write_en(MEM_WRITE_EN),
                             .addr_in(EX_MEM_Out),
                             .instruction_out(IF_ID_Instr),
                             .data_out(MEM_Data_Out));                          
//---------------------------------------------------- Halt Control -----------------------------------------------------//
halt_control HC(.clk(clk),
                .rst(rst), 
                .halt(HALT),
                .mem_wb_instr(EX_MEM_Instr),
                .id_ex_instr(ID_EX_Instr),
                .taken_branch(TAKEN_BRANCH));
endmodule:risc_core

