import rv32i_types::*;
import control::*;
import regfile::*;

module exe_top
(
    input clk,
    input rst,
    input logic is_bubbling,

    input if_control_word if_control,
    input id_control_word id_control,
    output exe_control_word exe_control,
    input mem_control_word mem_control,
    input wb_control_word wb_control,
    input id_exe_regfile reg_in,
	 input exe_mem_regfile mem_reg,
	 input mem_wb_regfile wb_reg,
    input rv32i_word wb_out,

    output exe_mem_regfile reg_out,
	 output logic div_stall
);

exe_datapath datapath
(
    .clk(clk),
    .rst(rst),

    .if_control(if_control),
    .id_control(id_control),
    .exe_control(exe_control),
    .mem_control(mem_control),
    .wb_control(wb_control),
    .reg_in(reg_in),
	 .mem_reg(mem_reg),
	 .wb_reg(wb_reg),
    .wb_out(wb_out),

    .reg_out(reg_out),
	 .div_stall(div_stall)
);

exe_control control
(
    .id_reg(reg_in),
    .is_bubbling(is_bubbling),

    .exe_control_out(exe_control)
);

endmodule
