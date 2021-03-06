import rv32i_types::*;
import control::*;
import regfile::*;

module mem_datapath
(
    input clk,
    input rst,
    input rv32i_word mem_rdata,
    output rv32i_word mem_wdata,
    output rv32i_word mem_address,

    input if_control_word if_control,
    input id_control_word id_control,
    input exe_control_word exe_control,
    input mem_control_word mem_control,
    input wb_control_word wb_control,
    input exe_mem_regfile reg_in,

    output mem_wb_regfile reg_out,
    output rv32i_word mar_out
);
logic [31:0] hit_counter, miss_counter;

always_ff @(posedge clk)
begin
    if (rst)
    begin
        hit_counter <= '0;
        miss_counter <= '0;
    end
    if (reg_in.opcode == op_br)
    begin
        if (reg_in.br_en == reg_in.prediction)
            hit_counter <= hit_counter + 1;
        else
            miss_counter <= miss_counter + 1;
    end

end

assign mem_address = {mar_out[31:2], 2'b00};
always_comb begin
    unique case (mem_control.mem_byte_enable)
        4'b0010: mem_wdata = reg_in.rs2_out << 8;
        4'b0100: mem_wdata = reg_in.rs2_out << 16;
        4'b1100: mem_wdata = reg_in.rs2_out << 16;
        4'b1000: mem_wdata = reg_in.rs2_out << 24;
        default: mem_wdata = reg_in.rs2_out;
    endcase
end

always_comb begin
	unique case(mem_control.mar_mux_select)
		1'b0: mar_out = reg_in.pc;
		default: mar_out = reg_in.alu_out;
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
	reg_out.alu_out = reg_in.alu_out;
	reg_out.br_en = reg_in.br_en;
	reg_out.mem_byte_enable = mem_control.mem_byte_enable;
    if (mem_control.mem_read)
    	reg_out.mem_rdata = mem_rdata;
    else reg_out.mem_rdata = 0;
    reg_out.prediction = reg_in.prediction;
    reg_out.all_prediction = reg_in.all_prediction;
    
	
end


endmodule
