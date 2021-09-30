import rv32i_types::*;
import control::*;
import regfile::*;

module exe_control
(
    input id_exe_regfile id_reg,
    input logic is_bubbling,

    output exe_control_word exe_control_out
);

always_comb begin
	unique case(is_bubbling) // Signal that determines whether the previous pipe should bubble
		1'b0: exe_control_out.load_regfile = 1'b1;
		default: exe_control_out.load_regfile = 1'b0;
	endcase
end

always_comb begin
	// Default
	exe_control_out.alumux1_sel = alumux::rs1_out;
	exe_control_out.alumux2_sel = alumux::i_imm; // Don't care
	exe_control_out.cmp_mux = 1'b0;
	exe_control_out.aluop = alu_add;
	exe_control_out.cmp_op = branch_funct3_t'(id_reg.funct3);
	exe_control_out.mulmux_sel = mulmux::alu;
	unique case (id_reg.opcode)
		op_imm: begin
			// Take Defaults
			exe_control_out.cmp_mux = 1'b1;
			unique case(id_reg.funct3)
                3'b000: exe_control_out.aluop = alu_add;
                3'b001: exe_control_out.aluop = alu_sll;
                3'b010: exe_control_out.cmp_op = blt; // Use given RTL
                3'b011: exe_control_out.cmp_op = bltu; // Use given RTL
                3'b100: exe_control_out.aluop = alu_xor;
                3'b110: exe_control_out.aluop = alu_or;
                3'b101: begin
                    if (id_reg.funct7 == 7'b0000000) begin // left
                        exe_control_out.aluop = alu_srl;
                    end else begin
                        exe_control_out.aluop = alu_sra;
                    end
                end
                3'b111: exe_control_out.aluop = alu_and;
                default: exe_control_out.aluop = alu_add;
			endcase
		end
		op_br: begin
			exe_control_out.alumux1_sel = alumux::pc_out;
			exe_control_out.alumux2_sel = alumux::b_imm;
		end
		op_load: begin
            // Take Defaults
		end
		op_store: begin
            exe_control_out.alumux1_sel = alumux::rs1_out;
            exe_control_out.alumux2_sel = alumux::s_imm;
		end
		op_auipc: begin
            exe_control_out.alumux1_sel = alumux::pc_out;
            exe_control_out.alumux2_sel = alumux::u_imm;
		end
		op_jal: begin
            exe_control_out.alumux1_sel = alumux::pc_out;
            exe_control_out.alumux2_sel = alumux::j_imm;
		end
		op_jalr: begin
        	// Take Defaults
		end
		op_reg: begin
			if (id_reg.funct7[5] == 1'b1) begin// Subtract and sr
                unique case (id_reg.funct3)
                    3'b000: exe_control_out.aluop = alu_sub;
                    3'b101: exe_control_out.aluop = alu_sra;
                    default: exe_control_out.aluop = alu_add;
                endcase
			end else if(id_reg.funct7 == 7'b1) begin //mul and div
					 unique case (id_reg.funct3)
						  3'b000: exe_control_out.mulmux_sel = mulmux::mul;
						  3'b001: exe_control_out.mulmux_sel = mulmux::mulh;
						  3'b010: exe_control_out.mulmux_sel = mulmux::mulhsu;
						  3'b011: exe_control_out.mulmux_sel = mulmux::mulhu;
						  3'b100: exe_control_out.mulmux_sel = mulmux::div;
						  3'b101: exe_control_out.mulmux_sel = mulmux::divu;
						  3'b110: exe_control_out.mulmux_sel = mulmux::rem;
						  3'b111: exe_control_out.mulmux_sel = mulmux::remu;
					 endcase
         end else begin
                unique case (id_reg.funct3)
                    3'b000: exe_control_out.aluop = alu_add;
                    3'b001: exe_control_out.aluop = alu_sll;
                    3'b010: exe_control_out.cmp_op = blt;
                    3'b011: exe_control_out.cmp_op = bltu;
                    3'b100: exe_control_out.aluop = alu_xor;
                    3'b101: exe_control_out.aluop = alu_srl;
                    3'b110: exe_control_out.aluop = alu_or;
                    3'b111: exe_control_out.aluop = alu_and;
                    default: exe_control_out.aluop = alu_add;
                endcase
                //setALU(alumux::pc_out, alumux::u_imm, 1'b1, alu_ops'(funct3));
            end
			if (id_reg.funct7[5] == 1'b1) begin// Subtract and sr
                unique case (id_reg.funct3)
                    3'b000: begin
                    	exe_control_out.alumux1_sel = alumux::rs1_out; 
                    	exe_control_out.alumux2_sel = alumux::rs2_out;
                    end
                    default: begin
                    	exe_control_out.alumux1_sel = alumux::rs1_out;
                    	exe_control_out.alumux2_sel = alumux::rs2_out;
                    end
                endcase
            end else begin
                exe_control_out.alumux1_sel = alumux::rs1_out;
                exe_control_out.alumux2_sel = alumux::rs2_out;
            end
		end
        default: ;
	endcase
end

endmodule
