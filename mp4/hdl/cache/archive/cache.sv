/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */
import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input logic clk,
    input logic rst,
    output rv32i_word mem_rdata,
    input rv32i_word mem_wdata,
    input rv32i_word mem_address,
    input logic mem_write,
    input logic mem_read,
    input logic[3:0] mem_byte_enable,
    output logic mem_resp,

    output rv32i_word pmem_address,
    input logic[255:0] pmem_rdata,
    output logic[255:0] pmem_wdata,
    output logic pmem_read,
    output logic pmem_write,
    input logic pmem_resp
);

logic mem_resp_cache;
// logic mem_resp_off_cache;
logic[31:0] mem_byte_enable256;
logic [255:0] mem_rdata256, mem_wdata256;
logic from_processor, cache_read, cache_write, dirty_overwrite, in_cache, lru_update, miss_cache_read;

assign mem_resp = mem_resp_cache;
// always_comb begin // A mux implementation
//     unique case (mem_resp_return)
//         1'b0: mem_resp = pmem_resp;
//         1'b1: mem_resp = mem_resp_cache;
//     endcase
// end

cache_control control
(
    .clk(clk),
    .rst(rst),
    .pmem_resp(pmem_resp),
    .mem_resp_cache(mem_resp_cache),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_address(mem_address),
    .in_cache(in_cache),
    .dirty_overwrite(dirty_overwrite),
    .from_processor(from_processor),
    .lru_update(lru_update),
    .miss_cache_read(miss_cache_read),

    .pmem_read(pmem_read),
    .pmem_write(pmem_write),
    .cache_read(cache_read),
    .cache_write(cache_write)
);


cache_datapath datapath
(
    .clk(clk),
    .rst(rst),
    .mem_rdata256(mem_rdata256),
    .mem_wdata256(mem_wdata256),
    .mem_address(mem_address),
    .cache_write(cache_write),
    .cache_read(cache_read),
    .in_cache(in_cache),
    .from_processor(from_processor),
    .write(cache_write), 
    .read(cache_read),
    .dirty_overwrite(dirty_overwrite),
    .lru_update(lru_update),
    .miss_cache_read(miss_cache_read),

    .pmem_address(pmem_address),
    .pmem_rdata(pmem_rdata),
    .pmem_wdata(pmem_wdata),
    .mem_byte_enable256(mem_byte_enable256)
);

bus_adapter bus_adapter
(
    .mem_wdata256(mem_wdata256),
    .mem_rdata256(mem_rdata256),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    .mem_byte_enable(mem_byte_enable),
    .mem_byte_enable256(mem_byte_enable256),
    .address(mem_address)
);

endmodule : cache
