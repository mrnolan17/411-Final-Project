import rv32i_types::*;
import control::*;
import regfile::*;

module mem_top
(
    input clk,
    input rst,
    input logic is_bubbling,

    input mem_resp,
    input rv32i_word mem_rdata,
    output rv32i_word mem_wdata,
    output rv32i_word mem_address,

    input if_control_word if_control,
    input id_control_word id_control,
    input exe_control_word exe_control,
    output mem_control_word mem_control,
    input wb_control_word wb_control,
    input exe_mem_regfile reg_in,

    output mem_wb_regfile reg_out
);

rv32i_word mar_out;

mem_datapath datapath
(
    .clk(clk),
    .rst(rst),
    .mem_rdata(mem_rdata),
    .mem_wdata(mem_wdata),
    .mem_address(mem_address),

    .if_control(if_control),
    .id_control(id_control),
    .exe_control(exe_control),
    .mem_control(mem_control),
    .wb_control(wb_control),
    .reg_in(reg_in),

    .reg_out(reg_out),
    .mar_out(mar_out)
);

mem_control control
(
    .mem_resp(mem_resp),
    .exe_reg(reg_in),
    .mar_out(mar_out),
    .is_bubbling(is_bubbling),

    .mem_control_out(mem_control)
);

endmodule
