import rv32i_types::*;
import control::*;
import regfile::*;

module cpu
(
    input clk,
    input rst,

    input i_mem_resp,
    input rv32i_word i_mem_rdata,
    output logic i_mem_read,
    output logic i_mem_write,
    output logic [3:0] i_mem_byte_enable,
    output rv32i_word i_mem_address,
    output rv32i_word i_mem_wdata,

    input d_mem_resp,
    input rv32i_word d_mem_rdata,
    output logic d_mem_read,
    output logic d_mem_write,
    output logic [3:0] d_mem_byte_enable,
    output rv32i_word d_mem_address,
    output rv32i_word d_mem_wdata
);

logic load_stall_if;
logic load_stall_mem;
logic load_stall_data;
logic div_stall,skip_one_instr;

rv32i_word wb_out, pc_addr;

if_control_word if_control;
id_control_word id_control;
exe_control_word exe_control;
mem_control_word mem_control;
wb_control_word wb_control;

if_id_regfile if_id_in, if_id_out;
id_exe_regfile id_exe_in, id_exe_out;
exe_mem_regfile exe_mem_in, exe_mem_out;
mem_wb_regfile mem_wb_in, mem_wb_out;

assign i_mem_read = if_control.mem_read;
assign i_mem_write = if_control.mem_write;
assign i_mem_byte_enable = if_control.mem_byte_enable;
assign i_mem_address = if_id_in.pc;
assign i_mem_wdata = 32'd0;

assign d_mem_read = mem_control.mem_read;
assign d_mem_write = mem_control.mem_write;
assign d_mem_byte_enable = mem_control.mem_byte_enable;
assign load_stall_if = ~i_mem_resp;
always_comb begin
    load_stall_mem = 0;
    if (exe_mem_out.opcode == op_load | exe_mem_out.opcode == op_store) begin
        load_stall_mem = ~d_mem_resp;
    end
end

if_top IF
(
    .clk(clk),
    .rst(rst),
    .mem_rdata(i_mem_rdata),
    .mem_resp(i_mem_resp),
    .is_bubbling(load_stall_if|load_stall_data|load_stall_mem|div_stall),
    .load_stall(load_stall_if|load_stall_data|load_stall_mem|div_stall),
    // .is_bubbling(load_stall_if|load_stall_data|load_stall_mem|div_stall|skip_one_instr),
    // .load_stall(load_stall_if|load_stall_data|load_stall_mem|div_stall|skip_one_instr),


    .if_control_(if_control),
    .id_control(id_control),
    .exe_control(exe_control),
    .mem_control(mem_control),
    .wb_control(wb_control),
    .if_id_reg(if_id_out),
    .id_reg(id_exe_out),
    .reg_in(exe_mem_out),
    .pc_addr(pc_addr),

    .reg_out(if_id_in)
);

id_top ID
(
    .clk(clk),
    .rst(rst),
    .wb_out(wb_out),
    .is_bubbling(load_stall_mem|load_stall_if|div_stall),

    .if_control(if_control),
    .id_control(id_control),
    .exe_control(exe_control),
    .mem_control(mem_control),
    .wb_control(wb_control),
    .reg_in(if_id_out),
    .mem_reg(mem_wb_out),

    .reg_out(id_exe_in),
    .pc_addr(pc_addr)
);

exe_top EXE
(
    .clk(clk),
    .rst(rst),
    .is_bubbling(load_stall_mem|load_stall_if|div_stall),

    .if_control(if_control),
    .id_control(id_control),
    .exe_control(exe_control),
    .mem_control(mem_control),
    .wb_control(wb_control),
    .reg_in(id_exe_out),
	 .mem_reg(exe_mem_out),
	 .wb_reg(mem_wb_out),
	 .wb_out(wb_out),
	 
    .reg_out(exe_mem_in),
	 .div_stall(div_stall)
);

mem_top MEM
(
    .clk(clk),
    .rst(rst),
    .is_bubbling(load_stall_mem|load_stall_if),

    .mem_resp(d_mem_resp),
    .mem_rdata(d_mem_rdata),
    .mem_wdata(d_mem_wdata),
    .mem_address(d_mem_address),

    .if_control(if_control),
    .id_control(id_control),
    .exe_control(exe_control),
    .mem_control(mem_control),
    .wb_control(wb_control),
    .reg_in(exe_mem_out),

    .reg_out(mem_wb_in)
);

wb_top WB
(
    .clk(clk),
    .rst(rst),

    .if_control(if_control),
    .id_control(id_control),
    .exe_control(exe_control),
    .mem_control(mem_control),
    .wb_control(wb_control),
    .reg_in(mem_wb_out),

    .wb_out(wb_out)

);

regfiles_top REGFILES 
(
    .clk(clk),
    .rst(rst),
	 
    .load_if_id(if_control.load_regfile),
    .load_id_exe(id_control.load_regfile),
    .load_exe_mem(exe_control.load_regfile),
    .load_mem_wb(mem_control.load_regfile),
    .load_stall(load_stall_data),
    .*
);

endmodule : cpu
