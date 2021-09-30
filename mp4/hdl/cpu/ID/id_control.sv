import rv32i_types::*;
import control::*;
import regfile::*;

module id_control
(
	input if_id_regfile reg_in,
    input mem_wb_regfile mem_reg,
    input logic is_bubbling,

    output id_control_word id_control_out
);

always_comb begin
	unique case(is_bubbling) // Signal that determines whether the previous pipe should bubble
		1'b0: id_control_out.load_regfile = 1'b1;
		default: id_control_out.load_regfile = 1'b0;
	endcase
end

always_comb begin
	// Default
	id_control_out.w_en = 1'b0;
	id_control_out.dest = mem_reg.rd;
	id_control_out.adder_mux = 2'b00;

/*
	if (one of last three instructions was a successful branch) begin
		id_control_out.w_en = 1'b0;
	end else  */
	begin
		unique case (mem_reg.opcode)
			op_imm: id_control_out.w_en = 1'b1;
			op_lui: id_control_out.w_en = 1'b1;
			op_load: id_control_out.w_en = 1'b1;
			op_auipc: id_control_out.w_en = 1'b1;
			op_jal: id_control_out.w_en = 1'b1;
			op_jalr: id_control_out.w_en = 1'b1;
			op_reg: id_control_out.w_en = 1'b1;
			default: id_control_out.w_en = 1'b0;
		endcase
	end
	begin
		unique case (reg_in.opcode)
			op_br: id_control_out.adder_mux = 2'b10;
			op_jal: id_control_out.adder_mux = 2'b01;
			op_jalr: id_control_out.adder_mux = 2'b00;
			default: id_control_out.adder_mux = 2'b00;
		endcase
	end

end

endmodule
