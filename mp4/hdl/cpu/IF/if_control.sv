import rv32i_types::*;
import control::*;
import regfile::*;

module if_control
(
	input mem_resp, // Not used right now. Magic memory.
    input exe_mem_regfile mem_reg, // mem_wb_regfile?
    input if_id_regfile id_reg,
    input if_id_regfile reg_out,
    input logic is_bubbling,
    input logic prediction,

    output if_control_word if_control_out
);
logic flag;
always_comb begin
	unique case(is_bubbling) // Signal that determines whether the previous pipe should bubble
		1'b0: if_control_out.load_regfile = 1'b1;
		default: if_control_out.load_regfile = 1'b0;
	endcase
end

assign if_control_out.mem_write = 1'b0; // Instruction should be read only
assign if_control_out.mem_byte_enable = 4'hF; // Always read full word

always_comb begin
	flag = 1'b1;
	if_control_out.pc_mux_select = 2'b00; // Default increment PC
	if_control_out.use_predictor = 1'b0;

	// unique case(is_bubbling) // Signal that determines whether the previous pipe should bubble
	// 	1'b0: begin
			if_control_out.mem_read = 1'b1; // Don't read if bubbling
			if_control_out.load_pc = 1'b1;
	// 	end
	// 	default: begin
	// 		if_control_out.mem_read = 1'b0; // Read if not bubbling
	// 		if_control_out.load_pc = 1'b0;
	// 	end
	// endcase

	// First check if we need to change PC based on MEM
	if (mem_reg.opcode == op_br || mem_reg.opcode == op_jalr) begin
		unique case({mem_reg.br_en, mem_reg.prediction})
			2'b00: begin 
				if_control_out.pc_mux_select = 2'b00;
			end
			2'b01: begin 
				if_control_out.pc_mux_select = 2'b10;
				flag = 1'b0;
			end
			2'b10: begin 
				if_control_out.pc_mux_select = 2'b01;
				flag = 1'b0;
			end
			2'b11: begin 
				if_control_out.pc_mux_select = 2'b00;
			end
			default: begin 
				if_control_out.pc_mux_select = 2'b00;
			end
		endcase
	end

	if (flag == 1'b1 && is_bubbling)
		if_control_out.load_pc = 1'b0;

	// if (flag == 1'b1 && prediction == 1'b1 && (reg_out.opcode == op_br || reg_out.opcode == op_jal)) // Don't load the next value for PC.
	// 	if_control_out.load_pc = 1'b0;


	// Then we check if we need to change PC based on the prediction
	if (flag == 1'b1 & id_reg.prediction == 1'b1) begin
		if_control_out.pc_mux_select = 2'b11;
	end

	// Branch predictor control
	if (reg_out.opcode == op_br)
		if_control_out.use_predictor = 1'b1;
	// if (mem_reg.br_en) begin // branch prediction
	// 	if (mem_reg.opcode == op_br) begin
	// 		if_control_out.pc_mux_select = {1'b0, prediction}; // Choose the branching address
	// 		if_control_out.use_predictor = 1'b1;
	// 	end else if (mem_reg.opcode == op_jal | mem_reg.opcode == op_jalr) begin
	// 		if_control_out.pc_mux_select = 2'b01; // Choose the branching address
	// 		if_control_out.use_predictor = 1'b0;
	// 	end
	// end
end

endmodule
 