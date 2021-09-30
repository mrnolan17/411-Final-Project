import rv32i_types::*;

module mp4
(
    input clk,
    input rst,

    input pmem_resp,
    input [63:0] pmem_rdata,
    output logic pmem_read,
    output logic pmem_write,
    output rv32i_word pmem_address,
    output [63:0] pmem_wdata
);


logic i_mem_resp;
rv32i_word i_mem_rdata;
logic i_mem_read;
logic i_mem_write;
logic [3:0] i_mem_byte_enable;
rv32i_word i_mem_address;
rv32i_word i_mem_wdata;

rv32i_word hit_counter;
rv32i_word miss_counter;

logic d_mem_resp;
rv32i_word d_mem_rdata;
logic d_mem_read;
logic d_mem_write;
logic [3:0] d_mem_byte_enable;
rv32i_word d_mem_address;
rv32i_word d_mem_wdata;

//icache to arbiter
logic icache_read;
logic icache_write;
logic [255:0] icache_data;
logic [31:0] icache_address;
logic icache_resp;
logic [255:0] icache_wdata;

//dcache to arbiter
logic dcache_read;
logic dcache_write;
logic [255:0] dcache_data_i;
logic [255:0] dcache_data_o;
logic [31:0] dcache_address;
logic dcache_resp;

// arbiter to l2
logic [255:0] l2_cache_rdata;
logic [255:0] l2_cache_wdata;
logic [31:0] l2_cache_address;
logic l2_cache_write;
logic l2_cache_read;
logic l2_cache_resp;

// l2 to cachline
logic [255:0] line_o;
logic resp_o;
logic [255:0] line_i;
logic [31:0] address_i;
logic read_i;
logic write_i;


cpu CPU
(
    .clk(clk),
    .rst(rst),

    .i_mem_resp(i_mem_resp),
    .i_mem_rdata(i_mem_rdata),
    .i_mem_read(i_mem_read),
    .i_mem_write(i_mem_write),
    .i_mem_byte_enable(i_mem_byte_enable),
    .i_mem_address(i_mem_address),
    .i_mem_wdata(i_mem_wdata),

    .d_mem_resp(d_mem_resp),
    .d_mem_rdata(d_mem_rdata),
    .d_mem_read(d_mem_read),
    .d_mem_write(d_mem_write),
    .d_mem_byte_enable(d_mem_byte_enable),
    .d_mem_address(d_mem_address),
    .d_mem_wdata(d_mem_wdata)
);


// cache icache (
//     .clk(clk),
//     .rst(rst),
	
//     .pmem_resp(icache_resp),
//     .pmem_rdata(icache_data),
// 	.pmem_address(icache_address),
// 	.pmem_wdata(icache_wdata),
// 	.pmem_read(icache_read),
// 	.pmem_write(icache_write),
    
// 	.mem_address(i_mem_address),
// 	.mem_rdata(i_mem_rdata),
// 	.mem_wdata(i_mem_wdata),
// 	.mem_read(i_mem_read),
// 	.mem_write(i_mem_write),
// 	.mem_byte_enable(i_mem_byte_enable),
// 	.mem_resp(i_mem_resp)
	

// );

// cache dcache (
//     .clk(clk),
//     .rst(rst),

//     .pmem_resp(dcache_resp),
//     .pmem_rdata(dcache_data_o),
// 	.pmem_address(dcache_address),
// 	.pmem_wdata(dcache_data_i),
// 	.pmem_read(dcache_read),
// 	.pmem_write(dcache_write),
	
// 	.mem_address(d_mem_address),
// 	.mem_rdata(d_mem_rdata),
// 	.mem_wdata(d_mem_wdata),
// 	.mem_read(d_mem_read),
// 	.mem_write(d_mem_write),
// 	.mem_byte_enable(d_mem_byte_enable),
// 	.mem_resp(d_mem_resp)

// );

cache icache (
    .clk(clk),
    // .rst(rst),
	
    .pmem_resp(icache_resp),
    .pmem_rdata(icache_data),
	.pmem_address(icache_address),
	.pmem_wdata(icache_wdata),
	.pmem_read(icache_read),
	.pmem_write(icache_write),
    
	.mem_address(i_mem_address),
	.mem_rdata_cpu(i_mem_rdata),
	.mem_wdata_cpu(i_mem_wdata),
	.mem_read(i_mem_read),
	.mem_write(i_mem_write),
	.mem_byte_enable_cpu(i_mem_byte_enable),
	.mem_resp(i_mem_resp)
	

);

cache dcache (
    .clk(clk),
    // .rst(rst),

    .pmem_resp(dcache_resp),
    .pmem_rdata(dcache_data_o),
	.pmem_address(dcache_address),
	.pmem_wdata(dcache_data_i),
	.pmem_read(dcache_read),
	.pmem_write(dcache_write),
	
	.mem_address(d_mem_address),
	.mem_rdata_cpu(d_mem_rdata),
	.mem_wdata_cpu(d_mem_wdata),
	.mem_read(d_mem_read),
	.mem_write(d_mem_write),
	.mem_byte_enable_cpu(d_mem_byte_enable),
	.mem_resp(d_mem_resp)

);

arbiter arbiter (
    .clk(clk),
    .rst(rst),

    .icache_read,
    .icache_write,
    .icache_address,
    .icache_data,
    .icache_resp,

    .dcache_read,
    .dcache_write,
    .dcache_address,
    .dcache_data_i,
    .dcache_data_o,
    .dcache_resp,

    // .data_o(line_o),
    // .resp_o,
    // .data_i(line_i),
    // .address_i,
    // .read_i,
    // .write_i

    // .l2_cache_rdata(line_o),
    // .l2_cache_wdata(line_i),
    // .l2_cache_address(address_i),
    // .l2_cache_write(write_i),
    // .l2_cache_read(read_i),
    // .l2_cache_resp(resp_o)

    .l2_cache_rdata,
    .l2_cache_wdata,
    .l2_cache_address,
    .l2_cache_write,
    .l2_cache_read,
    .l2_cache_resp
);

l2_cache l2_cache (
    .clk(clk),
    .rst(rst),
	
    .pmem_resp(resp_o),
    .pmem_rdata(line_o),
	.pmem_address(address_i),
	.pmem_wdata(line_i),
	.pmem_read(read_i),
	.pmem_write(write_i),

    .hit_counter,
    .miss_counter,
    
	.mem_address(l2_cache_address),
	.mem_rdata(l2_cache_rdata),
	.mem_wdata(l2_cache_wdata),
	.mem_read(l2_cache_read),
	.mem_write(l2_cache_write),
	.mem_resp(l2_cache_resp)
);

cacheline_adaptor cacheline_adaptor(
    .clk(clk),
    .reset_n(~rst),

    .address_i,
    .read_i,
    .write_i,
    .line_i,
    .line_o,
    .resp_o,

    .burst_i(pmem_rdata),
    .burst_o(pmem_wdata),
    .address_o(pmem_address),
    .read_o(pmem_read),
    .write_o(pmem_write),
    .resp_i(pmem_resp)
);

/*
cache icache (
    .clk(clk),
    // .rst(rst),
    
    .pmem_resp(icache_resp),
    .pmem_rdata(icache_data),
    .pmem_address(icache_address),
    .pmem_wdata(icache_wdata),
    .pmem_read(icache_read),
    .pmem_write(icache_write),
    
    .mem_address(i_mem_address),
    .mem_rdata_cpu(i_mem_rdata),
    .mem_wdata_cpu(i_mem_wdata),
    .mem_read(i_mem_read),
    .mem_write(i_mem_write),
    .mem_byte_enable_cpu(i_mem_byte_enable),
    .mem_resp(i_mem_resp)
    

);

cache dcache (
    .clk(clk),
    // .rst(rst),

    .pmem_resp(dcache_resp),
    .pmem_rdata(dcache_data_o),
    .pmem_address(dcache_address),
    .pmem_wdata(dcache_data_i),
    .pmem_read(dcache_read),
    .pmem_write(dcache_write),
    
    .mem_address(d_mem_address),
    .mem_rdata_cpu(d_mem_rdata),
    .mem_wdata_cpu(d_mem_wdata),
    .mem_read(d_mem_read),
    .mem_write(d_mem_write),
    .mem_byte_enable_cpu(d_mem_byte_enable),
    .mem_resp(d_mem_resp)

);

arbiter_old arbiter (
    .clk(clk),
    .rst(rst),

    .icache_read,
    .icache_write,
    .icache_address,
    .icache_data,
    .icache_resp,

    .dcache_read,
    .dcache_write,
    .dcache_address,
    .dcache_data_i,
    .dcache_data_o,
    .dcache_resp,

    .data_o(line_o),
    .resp_o,
    .data_i(line_i),
    .address_i,
    .read_i,
    .write_i
);

cacheline_adaptor cacheline_adaptor(
    .clk(clk),
    .reset_n(~rst),

    .line_i,
    .line_o,
    .address_i,
    .read_i,
    .write_i,
    .resp_o,

    .burst_i(pmem_rdata),
    .burst_o(pmem_wdata),
    .address_o(pmem_address),
    .read_o(pmem_read),
    .write_o(pmem_write),
    .resp_i(pmem_resp)
);
*/
endmodule
