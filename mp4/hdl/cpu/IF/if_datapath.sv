import rv32i_types::*;
import control::*;
import regfile::*;

module if_datapath
(
    input clk,
    input rst,
    input rv32i_word mem_rdata,
	 
	input load_stall,

    input if_control_word if_control,
    input id_control_word id_control,
    input exe_control_word exe_control,
    input mem_control_word mem_control,
    input wb_control_word wb_control,
    input exe_mem_regfile reg_in,
    input id_exe_regfile id_reg,
    input rv32i_word pc_addr,
    input logic p_out,
    input logic[3:0] all_prediction,

    output if_id_regfile reg_out
);

logic prediction;
rv32i_word pc_in;

pc PC(
    .clk  (clk),
    .rst (rst),
    .load (if_control.load_pc),
    // .load (if_control.load_pc && ~load_stall),
    .in   (pc_in),
    .out  (reg_out.pc)
);

decoder DECODER
(
    .in(mem_rdata),
    .funct3(reg_out.funct3),
    .funct7(reg_out.funct7),
    .opcode(reg_out.opcode),
    .i_imm(reg_out.i_imm),
    .s_imm(reg_out.s_imm),
    .b_imm(reg_out.b_imm),
    .u_imm(reg_out.u_imm),
    .j_imm(reg_out.j_imm),
    .rs1(reg_out.rs1),
    .rs2(reg_out.rs2),
    .rd(reg_out.rd)
);

always_comb begin
    // if ((id_exe_regfile.prediction == 1 & id_exe_regfile.opcode == op_br) | id_exe_regfile.opcode == op_jal | id_exe_regfile.opcode == op_jalr) 
    //     pc_in = pc_addr;
    // else begin
        reg_out.all_prediction = all_prediction;
	   unique case(if_control.pc_mux_select)
		  2'b00: pc_in = reg_out.pc + 4;
          2'b01: pc_in = reg_in.alu_out;
          2'b10: pc_in = reg_in.pc + 4;
          2'b11: pc_in = pc_addr;
		  default: pc_in = reg_out.pc + 4;
	   endcase
    // end
end

always_comb begin
    if (reg_out.opcode == op_jal) //  | reg_out.opcode == op_jalr)
        prediction = 1'b1;
    else if (reg_out.opcode == op_br)
        prediction = p_out;
    else
        prediction = 1'b0;
    reg_out.prediction = prediction;
end


endmodule
