import rv32i_types::*;
import control::*;
import regfile::*;

module wb_top
(
    input clk,
    input rst,

    input if_control_word if_control,
    input id_control_word id_control,
    input exe_control_word exe_control,
    input mem_control_word mem_control,
    output wb_control_word wb_control,
    input mem_wb_regfile reg_in,

    output rv32i_word wb_out

);

wb_datapath datapath
(
    .clk(clk),
    .rst(rst),

    .if_control(if_control),
    .id_control(id_control),
    .exe_control(exe_control),
    .mem_control(mem_control),
    .wb_control(wb_control),
    .reg_in(reg_in),

    .wb_out(wb_out)

);

wb_control control
(
    .mem_reg(reg_in),

    .wb_control_out(wb_control)
);

endmodule
