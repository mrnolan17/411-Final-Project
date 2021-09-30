import rv32i_types::*;
import control::*;
import regfile::*;

module id_top
(
    input clk,
    input rst,
    input rv32i_word wb_out,
    input logic is_bubbling,

    input if_control_word if_control,
    output id_control_word id_control,
    input exe_control_word exe_control,
    input mem_control_word mem_control,
    input wb_control_word wb_control,
    input if_id_regfile reg_in,
    input mem_wb_regfile mem_reg,

    output id_exe_regfile reg_out,
    output rv32i_types::rv32i_word pc_addr
);

id_datapath datapath
(
    .clk(clk),
    .rst(rst),
    .wb_out(wb_out),

    .if_control(if_control),
    .id_control(id_control),
    .exe_control(exe_control),
    .mem_control(mem_control),
    .wb_control(wb_control),
    .reg_in(reg_in),

    .reg_out(reg_out)
);

id_control control
(
    .reg_in(reg_in),
    .mem_reg(mem_reg),
    .is_bubbling(is_bubbling),

    .id_control_out(id_control)
);

always_comb begin
    unique case (id_control.adder_mux)
        2'b00: pc_addr = reg_in.pc + reg_in.i_imm;
        2'b01: pc_addr = reg_in.pc + reg_in.j_imm;
        2'b10: pc_addr = reg_in.pc + reg_in.b_imm;
        default: pc_addr = reg_in.pc + reg_in.i_imm;
    endcase
end

endmodule
