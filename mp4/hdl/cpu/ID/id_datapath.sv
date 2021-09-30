import rv32i_types::*;
import control::*;
import regfile::*;

module id_datapath
(
    input clk,
    input rst,
    input rv32i_word wb_out,

    input if_control_word if_control,
    input id_control_word id_control,
    input exe_control_word exe_control,
    input mem_control_word mem_control,
    input wb_control_word wb_control,
    input if_id_regfile reg_in,

    output id_exe_regfile reg_out
);

id_regfile REGFILE
(
	.clk(clk),
    .rst(rst),
    .load(id_control.w_en),
    .in(wb_out),
    .src_a(reg_in.rs1),
    .src_b(reg_in.rs2),
    .dest(id_control.dest), // Use dest from wb block
    .reg_a(reg_out.rs1_out),
    .reg_b(reg_out.rs2_out)

);

always_comb begin
	reg_out.opcode = reg_in.opcode;
	reg_out.funct3 = reg_in.funct3;
	reg_out.funct7 = reg_in.funct7;
	reg_out.rs1 = reg_in.rs1;
	reg_out.rs2 = reg_in.rs2;
	reg_out.rd = reg_in.rd;
	reg_out.i_imm = reg_in.i_imm;
	reg_out.u_imm = reg_in.u_imm;
	reg_out.b_imm = reg_in.b_imm;
	reg_out.s_imm = reg_in.s_imm;
	reg_out.j_imm = reg_in.j_imm;
	reg_out.pc = reg_in.pc;
    reg_out.prediction = reg_in.prediction;
    reg_out.all_prediction = reg_in.all_prediction;
end

endmodule
