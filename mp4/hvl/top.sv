module mp4_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// For local simulation, add signal for Modelsim to display by default
// Note that this signal does nothing and is not used for anything
bit f;

/****************************** End do not touch *****************************/

/************************ Signals necessary for monitor **********************/
// This section not required until CP2

assign rvfi.commit = 0; // Set high when a valid instruction is modifying regfile or PC
assign rvfi.halt = 0;   // Set high when you detect an infinite loop
initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO

/*
The following signals need to be set:
Instruction and trap:
    rvfi.inst
    rvfi.trap

Regfile:
    rvfi.rs1_addr
    rvfi.rs2_add
    rvfi.rs1_rdata
    rvfi.rs2_rdata
    rvfi.load_regfile
    rvfi.rd_addr
    rvfi.rd_wdata

PC:
    rvfi.pc_rdata
    rvfi.pc_wdata

Memory:
    rvfi.mem_addr
    rvfi.mem_rmask
    rvfi.mem_wmask
    rvfi.mem_rdata
    rvfi.mem_wdata

Please refer to rvfi_itf.sv for more information.
*/



/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
/*
The following signals need to be set:
icache signals:
    itf.inst_read
    itf.inst_addr
    itf.inst_resp
    itf.inst_rdata

dcache signals:
    itf.data_read
    itf.data_write
    itf.data_mbe
    itf.data_addr
    itf.data_wdata
    itf.data_resp
    itf.data_rdata

Please refer to tb_itf.sv for more information.
*/

assign itf.inst_read = dut.CPU.i_mem_read;
assign itf.inst_addr = dut.CPU.i_mem_address;
assign itf.inst_resp = dut.i_mem_resp;
assign itf.inst_rdata = dut.i_mem_rdata;

assign itf.data_read = dut.CPU.d_mem_read;
assign itf.data_write = dut.CPU.d_mem_write;
assign itf.data_mbe = dut.CPU.d_mem_byte_enable;
assign itf.data_addr = dut.CPU.d_mem_address;
assign itf.data_wdata = dut.CPU.d_mem_wdata;
assign itf.data_resp = dut.d_mem_resp;
assign itf.data_rdata = dut.d_mem_rdata;

// assign itf.inst_read = dut.CPU.i_mem_read;
// assign itf.inst_addr = dut.CPU.i_mem_address;
// assign itf.inst_resp = dut.CPU.i_mem_resp;
// assign itf.inst_rdata = dut.CPU.i_mem_rdata;

// assign itf.data_read = dut.CPU.d_mem_read;
// assign itf.data_write = dut.CPU.d_mem_write;
// assign itf.data_mbe = dut.CPU.d_mem_byte_enable;
// assign itf.data_addr = dut.CPU.d_mem_address;
// assign itf.data_wdata = dut.CPU.d_mem_wdata;
// assign itf.data_resp = dut.CPU.d_mem_resp;
// assign itf.data_rdata = dut.CPU.d_mem_rdata;

/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers =  dut.CPU.ID.datapath.REGFILE.data;

/*********************** Instantiate your design here ************************/
/*
The following signals need to be connected to your top level:
Clock and reset signals:
    itf.clk
    itf.rst

Burst Memory Ports:
    itf.mem_read
    itf.mem_write
    itf.mem_wdata
    itf.mem_rdata
    itf.mem_addr
    itf.mem_resp

Please refer to tb_itf.sv for more information.
*/

mp4 dut(
    .clk(itf.clk),
    .rst(itf.rst),

    .pmem_read(itf.mem_read),
    .pmem_write(itf.mem_write),
    .pmem_wdata(itf.mem_wdata),
    .pmem_rdata(itf.mem_rdata),
    .pmem_address(itf.mem_addr),
    .pmem_resp(itf.mem_resp)
);
/***************************** End Instantiation *****************************/

int local_taken = 0;
int local_nottaken = 0;
int global1_taken = 0;
int global1_nottaken = 0;
int global2_taken = 0;
int global2_nottaken = 0;
int global3_taken = 0;
int global3_nottaken = 0;
int taken = 0;
int nottaken = 0;

int local_correct = 0;
int local_incorrect = 0;
int global1_correct = 0;
int global1_incorrect = 0;
int global2_correct = 0;
int global2_incorrect = 0;
int global3_correct = 0;
int global3_incorrect = 0;
int correct = 0;
int incorrect = 0;

always @(posedge dut.clk) begin
    if ((dut.CPU.mem_wb_out.opcode == 7'b1100011)) begin
        local_taken <= local_taken + dut.CPU.mem_wb_out.all_prediction[3];
        local_nottaken <= local_nottaken + (1'b1 - dut.CPU.mem_wb_out.all_prediction[3]);
        global1_taken <= global1_taken + dut.CPU.mem_wb_out.all_prediction[2];
        global1_nottaken <= global1_nottaken + (1'b1 - dut.CPU.mem_wb_out.all_prediction[2]);
        global2_taken <= global2_taken + dut.CPU.mem_wb_out.all_prediction[1];
        global2_nottaken <= global2_nottaken + (1'b1 - dut.CPU.mem_wb_out.all_prediction[1]);
        global3_taken <= global3_taken + dut.CPU.mem_wb_out.all_prediction[0];
        global3_nottaken <= global3_nottaken + (1'b1 - dut.CPU.mem_wb_out.all_prediction[0]);
        taken <= taken + dut.CPU.mem_wb_out.prediction;
        nottaken <= nottaken + (1'b1-dut.CPU.mem_wb_out.prediction);


        local_correct <= local_correct + (dut.CPU.mem_wb_out.all_prediction[3] == dut.CPU.mem_wb_out.br_en);
        local_incorrect <= local_incorrect + ((1'b1-dut.CPU.mem_wb_out.all_prediction[3]) == dut.CPU.mem_wb_out.br_en);
        global1_correct <= global1_correct + (dut.CPU.mem_wb_out.all_prediction[2] == dut.CPU.mem_wb_out.br_en);
        global1_incorrect <= global1_incorrect + ((1'b1-dut.CPU.mem_wb_out.all_prediction[2]) == dut.CPU.mem_wb_out.br_en);
        global2_correct <= global2_correct + (dut.CPU.mem_wb_out.all_prediction[1] == dut.CPU.mem_wb_out.br_en);
        global2_incorrect <= global2_incorrect + ((1'b1-dut.CPU.mem_wb_out.all_prediction[1]) == dut.CPU.mem_wb_out.br_en);
        global3_correct <= global3_correct + (dut.CPU.mem_wb_out.all_prediction[0] == dut.CPU.mem_wb_out.br_en);
        global3_incorrect <= global3_incorrect + ((1'b1-dut.CPU.mem_wb_out.all_prediction[0]) == dut.CPU.mem_wb_out.br_en);
        correct <= correct + (dut.CPU.mem_wb_out.prediction == dut.CPU.mem_wb_out.br_en);
        incorrect <= incorrect + ((1'b1-dut.CPU.mem_wb_out.prediction) == dut.CPU.mem_wb_out.br_en);
    end
end

int l2_hits = 0;
int l2_misses = 0;

int i_hits = 0;
int i_misses = 0;

int d_hits = 0;
int d_misses = 0;

always @(posedge dut.clk) begin
    if (dut.l2_cache.control.state == 2 || dut.l2_cache.control.state == 4) begin
        l2_hits <= l2_hits + 1;
        l2_misses <= l2_misses + 0;
    end else if (dut.l2_cache.control.state == 1 || dut.l2_cache.control.state == 3) begin
        l2_hits <= l2_hits + 0;
        l2_misses <= l2_misses + 1;
    end else begin
        l2_hits <= l2_hits + 0;
        l2_misses <= l2_misses + 0;
    end

    if (dut.icache.control.mem_resp == 1) begin
        i_hits <= i_hits + 1;
        i_misses <= i_misses + 0;
    end else if (dut.icache.control.pmem_read == 1) begin
        i_hits <= i_hits + 0;
        i_misses <= i_misses + 1;
    end else begin
        i_hits <= i_hits + 0;
        i_misses <= i_misses + 0;
    end

    if (dut.dcache.control.mem_resp == 1) begin
        d_hits <= d_hits + 1;
        d_misses <= d_misses + 0;
    end else if (dut.dcache.control.pmem_read == 1) begin
        d_hits <= d_hits + 0;
        d_misses <= d_misses + 1;
    end else begin
        d_hits <= d_hits + 0;
        d_misses <= d_misses + 0;
    end
end

endmodule
