import rv32i_types::*;
import control::*;
import regfile::*;

module regfiles_top
(
    input clk,
    input rst,

    input logic load_if_id,
    input logic load_id_exe,
    input logic load_exe_mem,
    input logic load_mem_wb,

    input if_id_regfile if_id_in,
    input id_exe_regfile id_exe_in,
    input exe_mem_regfile exe_mem_in,
    input mem_wb_regfile mem_wb_in,

    output if_id_regfile if_id_out,
    output id_exe_regfile id_exe_out,
    output exe_mem_regfile exe_mem_out,
    output mem_wb_regfile mem_wb_out,
	 
	 output logic load_stall,
     output logic skip_one_instr
);

logic should_flush;
// Should flush if branch prediction incorrect.
always_comb begin
    should_flush = 1'b0;
    skip_one_instr = 1'b0;
    if (exe_mem_out.br_en != exe_mem_out.prediction) begin
        if (exe_mem_out.opcode == op_br | exe_mem_out.opcode == op_jal | exe_mem_out.opcode == op_jalr)
            should_flush = 1'b1; // Flush
    end
	 
	 load_stall = 1'b0;
	 if((id_exe_out.opcode == op_load) && ((id_exe_out.rd == if_id_out.rs1) || (id_exe_out.rd == if_id_out.rs2)) || id_exe_out.opcode == op_lui) 
	     load_stall = 1'b1;

    // if ((if_id_out.opcode == op_br & if_id_out.prediction == 1) | if_id_out.opcode == op_jal | if_id_out.opcode == op_jalr)
    if ((if_id_out.opcode == op_br & if_id_out.prediction == 1) | if_id_out.opcode == op_jal)

        skip_one_instr = 1'b1;
end



if_id_reg IF_ID
(
    .clk(clk),
    .rst(rst|should_flush|skip_one_instr),
    .load(load_if_id && !load_stall),
    .should_flush(should_flush),

    .sig_in(if_id_in),
    .sig_out(if_id_out)
);

id_exe_reg ID_EXE
(
    .clk(clk),
    .rst(rst|should_flush),
    .load(load_id_exe),
    .should_flush(should_flush | load_stall),

    .sig_in(id_exe_in),
    .sig_out(id_exe_out)
);

exe_mem_reg EXE_MEM
(
    .clk(clk),
    .rst(rst|should_flush),
    .load(load_exe_mem),
    .should_flush(should_flush),

    .sig_in(exe_mem_in),
    .sig_out(exe_mem_out)
);

mem_wb_reg MEM_WB
(
    .clk(clk),
    .rst(rst),
    .load(load_mem_wb),

    .sig_in(mem_wb_in),
    .sig_out(mem_wb_out)
);

endmodule
