import rv32i_types::*;
import control::*;
import regfile::*;

module exe_datapath
(
    input clk,
    input rst,

    input if_control_word if_control,
    input id_control_word id_control,
    input exe_control_word exe_control,
    input mem_control_word mem_control,
    input wb_control_word wb_control,
    input id_exe_regfile reg_in,
	 input exe_mem_regfile mem_reg,
	 input mem_wb_regfile wb_reg,
    input rv32i_word wb_out,

    output exe_mem_regfile reg_out,
	 output logic div_stall
);

rv32i_word div_out, alu_out, alumux1_out, alumux2_out, cmpmux_out, forwardmux1_out, forwardmux2_out;
logic div_done, div_start;
logic [1:0] forwardmux1_sel, forwardmux2_sel;
logic [63:0] mul_out;
logic br_en_;
always_comb begin
	unique case(reg_in.opcode)
		op_jal : reg_out.br_en = 1'b1;
		op_jalr : reg_out.br_en = 1'b1;
		default : reg_out.br_en = br_en_;
	endcase
end

alu ALU
(
    .aluop(exe_control.aluop),
    .a(alumux1_out),
    .b(alumux2_out),
    .f(alu_out)
);

comparator COMPARATOR
(
    .cmpop(exe_control.cmp_op),
    .a(forwardmux1_out),
    .b(cmpmux_out),
    .f(br_en_)
);

forwarder FORWARDER
(
    .rs1(reg_in.rs1),
    .rs2(reg_in.rs2),
    .mem_reg,
    .wb_reg,

    .forwardmux1_sel,
    .forwardmux2_sel
);

wallace_mul MULTIPLIER(
	 .a(forwardmux1_out),
	 .b(forwardmux2_out),
	 .mulop(reg_in.funct3[1:0]),
	 .f(mul_out)
);

divider DIVIDER(
	 .clk,
	 .start(div_start),
	 .a(forwardmux1_out),
	 .b(forwardmux2_out),
	 .divop(reg_in.funct3[1:0]),
	 .done(div_done),
	 .f(div_out)
);


always_comb begin : MUXES
	div_start = 1'b0;
	div_stall = 1'b0;
	if((reg_in.opcode == op_reg) && (reg_in.funct7 == 7'b1) && (reg_in.funct3[2] == 1'b1)) begin
		div_start = 1'b1;
		if(!div_done) div_stall = 1'b1;
	end


	unique case(forwardmux1_sel)
		2'b01 : forwardmux1_out = mem_reg.alu_out;
		2'b10 : forwardmux1_out = wb_out;
		default : forwardmux1_out = reg_in.rs1_out;
	endcase
	
	unique case(forwardmux2_sel)
		2'b01 : forwardmux2_out = mem_reg.alu_out;
		2'b10 : forwardmux2_out = wb_out;
		default : forwardmux2_out = reg_in.rs2_out;
	endcase

	unique case(exe_control.mulmux_sel)
		mulmux::mul		: reg_out.alu_out = mul_out[31:0];
		mulmux::mulh	: reg_out.alu_out = mul_out[63:32];
		mulmux::mulhsu	: reg_out.alu_out = mul_out[63:32];
		mulmux::mulhu	: reg_out.alu_out = mul_out[63:32];
		mulmux::div		: reg_out.alu_out = div_out;
		mulmux::divu	: reg_out.alu_out = div_out;
		mulmux::rem		: reg_out.alu_out = div_out;
		mulmux::remu	: reg_out.alu_out = div_out;
		default			: reg_out.alu_out = alu_out;
	endcase
	
	unique case(exe_control.alumux1_sel)
		1'b0: alumux1_out = forwardmux1_out;
		default: alumux1_out = reg_in.pc;
	endcase
	
    unique case (exe_control.alumux2_sel)
        alumux::i_imm: alumux2_out = reg_in.i_imm;
        alumux::u_imm: alumux2_out = reg_in.u_imm;
        alumux::b_imm: alumux2_out = reg_in.b_imm;
        alumux::s_imm: alumux2_out = reg_in.s_imm;
        alumux::j_imm: alumux2_out = reg_in.j_imm;
        default: alumux2_out = forwardmux2_out;
    endcase

	unique case(exe_control.cmp_mux)
		1'b0: cmpmux_out = forwardmux2_out;
		default: cmpmux_out = reg_in.i_imm;
	endcase
end

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
	reg_out.rs1_out = reg_in.rs1_out;
	reg_out.rs2_out = reg_in.rs2_out;
   reg_out.prediction = reg_in.prediction;
    reg_out.all_prediction = reg_in.all_prediction;
   
	
end

endmodule
