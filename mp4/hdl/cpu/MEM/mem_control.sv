import rv32i_types::*;
import control::*;
import regfile::*;

module mem_control
(
    input mem_resp, // Not used for now. Magic memory.
    input exe_mem_regfile exe_reg,
    input rv32i_word mar_out,
    input logic is_bubbling,

    output mem_control_word mem_control_out
);
logic trap;
logic [3:0] wmask, rmask;

/* From MP2 */
always_comb
begin : trap_check
    trap = 0;
    rmask = '0;
    wmask = '0;

    case (exe_reg.opcode)
        op_lui, op_auipc, op_imm, op_reg, op_jal, op_jalr, op_flush:;

        op_br: begin
            case (branch_funct3_t'(exe_reg.funct3))
                beq, bne, blt, bge, bltu, bgeu:;
                default: trap = 1;
            endcase
        end

        op_load: begin
            case (load_funct3_t'(exe_reg.funct3))
                lw: rmask = 4'b1111;
                lh, lhu: unique case (mar_out[1])
                        1'b0: rmask = 4'b0011;
                        1'b1: rmask = 4'b1100;
                    endcase
                lb, lbu: unique case (mar_out[1:0])
                        2'b00: rmask = 4'b0001;
                        2'b01: rmask = 4'b0010;
                        2'b10: rmask = 4'b0100;
                        2'b11: rmask = 4'b1000;
                    endcase
                default: trap = 1;
            endcase
        end

        op_store: begin
            case (store_funct3_t'(exe_reg.funct3))
                sw: wmask = 4'b1111;
                sh: unique case (mar_out[1])
                        1'b0: wmask = 4'b0011;
                        1'b1: wmask = 4'b1100;
                    endcase
                sb: unique case (mar_out[1:0])
                        2'b00: wmask = 4'b0001;
                        2'b01: wmask = 4'b0010;
                        2'b10: wmask = 4'b0100;
                        2'b11: wmask = 4'b1000;
                    endcase
                default: trap = 1;
            endcase
        end

        default: trap = 1;
    endcase
end

always_comb begin
	unique case(is_bubbling) // Signal that determines whether the previous pipe should bubble
		1'b0: mem_control_out.load_regfile = 1'b1;
		default: mem_control_out.load_regfile = 1'b0;
	endcase
end

always_comb begin
	/*
	if (one of last three instructions was a successful branch) begin
		mem_control_out.mem_read = 1'b0;
		mem_control_out.mem_write = 1'b0;
		mem_control_out.mem_byte_enable = 4'h0; // Don't care
	end else */
	begin
		unique case(exe_reg.opcode) // Check if load  or store operation
			op_store: begin
				mem_control_out.mem_read = 1'b0;
				mem_control_out.mem_write = 1'b1;
				mem_control_out.mem_byte_enable = wmask; // Mask obtained in same way as MP2
                mem_control_out.mar_mux_select = marmux::alu_out;
			end
			op_load: begin
				mem_control_out.mem_read = 1'b1;
				mem_control_out.mem_write = 1'b0;
				mem_control_out.mem_byte_enable = rmask; // Mask obtained in same way as MP2
                mem_control_out.mar_mux_select = marmux::alu_out;
			end
			default: begin
				mem_control_out.mem_read = 1'b0;
				mem_control_out.mem_write = 1'b0;
				mem_control_out.mem_byte_enable = 4'h0; // Don't care
                mem_control_out.mar_mux_select = marmux::pc_out;
			end
		endcase
	end

end


endmodule
