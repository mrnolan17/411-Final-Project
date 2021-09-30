import rv32i_types::*;
import control::*;
import regfile::*;

module wb_datapath
(
    input clk,
    input rst,

    input if_control_word if_control,
    input id_control_word id_control,
    input exe_control_word exe_control,
    input mem_control_word mem_control,
    input wb_control_word wb_control,
    input mem_wb_regfile reg_in,

    output rv32i_word wb_out

);

rv32i_word MDR_parsed;

always_comb begin
    unique case({reg_in.funct3[2], reg_in.mem_byte_enable})
        5'b10001: MDR_parsed = {24'd0, reg_in.mem_rdata[7:0]};
        5'b10011: MDR_parsed = {16'd0, reg_in.mem_rdata[15:0]};
        5'b10010: MDR_parsed = {24'd0, reg_in.mem_rdata[15:8]};
        5'b10100: MDR_parsed = {24'd0, reg_in.mem_rdata[23:16]};
        5'b11100: MDR_parsed = {16'd0, reg_in.mem_rdata[31:16]};
        5'b11000: MDR_parsed = {24'd0, reg_in.mem_rdata[31:24]};
        5'b00001: MDR_parsed = {{24{reg_in.mem_rdata[7]}}, reg_in.mem_rdata[7:0]};
        5'b00011: MDR_parsed = {{16{reg_in.mem_rdata[15]}}, reg_in.mem_rdata[15:0]};
        5'b00010: MDR_parsed = {{24{reg_in.mem_rdata[15]}}, reg_in.mem_rdata[15:8]};
        5'b00100: MDR_parsed = {{24{reg_in.mem_rdata[23]}}, reg_in.mem_rdata[23:16]};
        5'b01100: MDR_parsed = {{16{reg_in.mem_rdata[31]}}, reg_in.mem_rdata[31:16]};
        5'b01000: MDR_parsed = {{24{reg_in.mem_rdata[31]}}, reg_in.mem_rdata[31:24]};
        default: MDR_parsed = reg_in.mem_rdata;
    endcase
end

always_comb begin : MUXES
	
    unique case (wb_control.reg_mux_select)
        regfilemux::alu_out: wb_out = reg_in.alu_out;
        regfilemux::br_en: wb_out = {31'b0, reg_in.br_en};
        regfilemux::u_imm: wb_out = reg_in.u_imm;
        regfilemux::lw: wb_out = reg_in.mem_rdata;
        regfilemux::pc_plus4: wb_out = reg_in.pc + 4;
        regfilemux::lb: wb_out = {{24{MDR_parsed[7]}}, MDR_parsed[7:0]};
        regfilemux::lbu: wb_out = {24'd0, MDR_parsed[7:0]};
        regfilemux::lh: wb_out = {{16{MDR_parsed[15]}}, MDR_parsed[15:0]};
        default: wb_out = {16'd0, MDR_parsed[15:0]};
	endcase

end

endmodule
