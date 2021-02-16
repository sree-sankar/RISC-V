`include"define.sv"


module instr_fetch(
                input  logic clk,halt,rst,branch_en,
                input  logic[`XLEN-1:0] branch_addr,
                output logic [`XLEN-1:0]pc,next_pc,
                output logic taken_branch,mem_read_en,reg_read_en
                );
                    
    always_ff @(posedge clk or negedge rst)
    begin
         if(!rst) begin
            pc              <= 0;
            next_pc         <= 4;
            taken_branch    <= 1'b0;
            mem_read_en     <= 1'b1;
            reg_read_en     <= 1'b1;
            end
        else begin

            if(halt == 1'b0 && branch_en == 1'b1 ) begin
               pc           <= branch_addr;
               next_pc      <= branch_addr + 4;
               taken_branch <= 1'b1;end 
               
            else if(halt == 1'b0 && branch_en == 1'b0 )begin
               pc           <= next_pc;
               next_pc      <= next_pc + 4;
               taken_branch <= 1'b0; end  
         end
         
       end      
endmodule:instr_fetch
