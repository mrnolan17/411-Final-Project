import rv32i_types::*;
import control::*;
import regfile::*;

module if_top
(
    input clk,
    input rst,
    input rv32i_word mem_rdata,
    input mem_resp,
    input logic is_bubbling,
	 input load_stall,

    output if_control_word if_control_,
    input id_control_word id_control,
    input exe_control_word exe_control,
    input mem_control_word mem_control,
    input wb_control_word wb_control,
    input if_id_regfile if_id_reg,
    input id_exe_regfile id_reg,
    input exe_mem_regfile reg_in,
    input rv32i_types::rv32i_word pc_addr,

    output if_id_regfile reg_out
);
logic p_out;
logic br;
always_comb begin
    br = (reg_in.opcode == op_br) ? 1'b1 : 1'b0;
end
logic [3:0] all_prediction;
branch_predictor_top bp_top
(
    .clk(clk),
    .rst(rst),
    .load_stall(load_stall),

    .if_control(if_control_),
    .br_en(br),
    .true(reg_in.br_en),

    .reg_out(reg_out),
    .prediction(p_out),
    .all_prediction(all_prediction),
    .waddr(reg_in.pc)
);

if_datapath datapath
(
    .clk(clk),
    .rst(rst),
    .mem_rdata(mem_rdata),
	 .load_stall(load_stall),
	 
    .if_control(if_control_),
    .id_control(id_control),
    .exe_control(exe_control),
    .mem_control(mem_control),
    .wb_control(wb_control),
    .id_reg(id_reg),
    .reg_in(reg_in),
    .pc_addr(pc_addr),
    .p_out(p_out),
    .all_prediction(all_prediction),

    .reg_out(reg_out)
);

if_control control
(
    .mem_resp(mem_resp),
    .mem_reg(reg_in),
    .id_reg(if_id_reg),
    .reg_out(reg_out),
    .is_bubbling(is_bubbling),
    .prediction(reg_out.prediction),

    .if_control_out(if_control_)
);


endmodule
