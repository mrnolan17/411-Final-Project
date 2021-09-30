import rv32i_types::*;
import control::*;
import regfile::*;

module wb_control
(
    input mem_wb_regfile mem_reg,

    output wb_control_word wb_control_out
);

always_comb begin
	// This case statement decides the fate of reg_mux_select
	unique case (mem_reg.opcode)
		op_imm: begin
			unique case (mem_reg.funct3)
                3'b010: wb_control_out.reg_mux_select = regfilemux::br_en;
                3'b011: wb_control_out.reg_mux_select = regfilemux::br_en;
                default: wb_control_out.reg_mux_select = regfilemux::alu_out;
            endcase
		end
		op_lui: begin
			wb_control_out.reg_mux_select = regfilemux::u_imm;
		end
		op_load: begin
			unique case (mem_reg.funct3)
				3'b000: wb_control_out.reg_mux_select = regfilemux::lb;
	            3'b001: wb_control_out.reg_mux_select = regfilemux::lh;
	            3'b010: wb_control_out.reg_mux_select = regfilemux::lw;
	            3'b100: wb_control_out.reg_mux_select = regfilemux::lbu;
	            3'b101: wb_control_out.reg_mux_select = regfilemux::lhu;
	            default: wb_control_out.reg_mux_select = regfilemux::lw;
	        endcase
		end
		op_auipc: begin
			wb_control_out.reg_mux_select = regfilemux::alu_out;
		end
		op_jal: begin
			wb_control_out.reg_mux_select = regfilemux::pc_plus4;
		end
		op_jalr: begin
			wb_control_out.reg_mux_select = regfilemux::pc_plus4;
		end
		op_reg: begin
			if (mem_reg.funct3[2:1] == 2'b01 && mem_reg.funct7 != 7'b1)
                wb_control_out.reg_mux_select = regfilemux::br_en;
            else
                wb_control_out.reg_mux_select = regfilemux::alu_out;
		end
		default: wb_control_out.reg_mux_select = regfilemux::alu_out;
	endcase

end


endmodule
