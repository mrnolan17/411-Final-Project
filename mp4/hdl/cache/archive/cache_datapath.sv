/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */
import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module cache_datapath #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input logic clk,                        // Clock
    input logic rst,                        // Reset
    output logic[255:0] mem_rdata256,       // Read data from cache
    input logic[255:0] mem_wdata256,        // Write data to cache from CPU
    input rv32i_word mem_address,           // CPU memory address
    input logic cache_write,                // Write signal for cache
    input logic cache_read,                 // Read signal for cache
    output logic in_cache,                  // Signals if address is already cached
    input logic from_processor,             // Signals if the data to write is from the CPU
    input logic write,                      // Write signal
    input logic read,                       // Read Signal
    output logic dirty_overwrite,           // Signals if the cache has a dirty value to write
    input logic lru_update,                 // Signals if the LRU should be updated
    input logic miss_cache_read,            // Signals if we can read from array that doesnt match tags

    output rv32i_word pmem_address,         // Address to read from pmem
    input logic[255:0] pmem_rdata,          // Read data from pmem
    output logic[255:0] pmem_wdata,         // Write data to pmem
    input logic[31:0] mem_byte_enable256    // Write enable bit (for CPU)
);

logic [23:0] tag, tag_one_out, tag_two_out;
logic [2:0] index;
logic [4:0] offset;
logic [255:0] data_one_out, data_two_out, data_input;
logic use_one, use_two;
logic lru_bit;
logic lru_in;
// logic write_lru;
logic tag_compare_one_out, tag_compare_two_out;
logic cache_dataout, write_one, write_one_t, write_two_t, write_two, read_one, read_two, valid_one_out, valid_two_out, valid_out;
logic dirty_one_out, dirty_two_out;

logic [31:0] data_write_one_en, data_write_two_en;

assign in_cache = (tag_compare_one_out | tag_compare_two_out) ? 1'b1 & valid_out : 1'b0 & valid_out;

always_comb begin
    unique case (miss_cache_read)
        1'b0: begin
            use_one = tag_compare_one_out & valid_one_out;
            use_two = tag_compare_two_out & valid_two_out;
            pmem_address = {tag, index, 5'd0};
        end
        1'b1: begin
            use_one = ~lru_bit;
            use_two = lru_bit;
            pmem_address = (lru_bit) ? {tag_two_out, index, 5'd0} : {tag_one_out, index, 5'd0};
        end
        default: begin
            use_one = 1'b0;
            use_two = 1'b0;
            pmem_address = {tag, index, 5'd0};
        end
    endcase
end

assign lru_in = use_one | write_one;
// assign read_one = cache_read & use_one;
// assign read_two = cache_read & use_two;


assign valid_out = (tag_compare_one_out) ? valid_one_out : valid_two_out;

assign data_input = (from_processor) ? mem_wdata256 : pmem_rdata;

assign data_write_one_en = (write_one) ? ((from_processor) ? mem_byte_enable256 : 32'hFFFFFFFF) : 32'd0;
assign data_write_two_en = (write_two) ? ((from_processor) ? mem_byte_enable256 : 32'hFFFFFFFF) : 32'd0;
// assign write_lru = write_one | write_two | cache_read;

assign pmem_wdata = (use_one) ? data_one_out : data_two_out;
assign dirty_overwrite = (dirty_one_out & valid_one_out & (use_one | write_one_t)) | (dirty_two_out & valid_two_out & (use_two | write_two_t));

// Get the correct address
// always_comb begin
//     unique case (use_one)
//         1'b0: pmem_address = {tag_two_out, index, 5'd0}; 
//         1'b1: pmem_address = {tag_one_out, index, 5'd0};
//         default: pmem_address = {tag, index, 5'd0}; // Should never happen
//     endcase
// end

// Get the correct address
always_comb begin
    unique case ({use_one, write_one, write_two})
        3'b000: mem_rdata256 = data_two_out; 
        3'b100: mem_rdata256 = data_one_out;
        3'b010: mem_rdata256 = pmem_rdata; 
        3'b110: mem_rdata256 = pmem_rdata;
        3'b001: mem_rdata256 = pmem_rdata; 
        3'b101: mem_rdata256 = pmem_rdata;
        default: mem_rdata256 = 256'dX; // Should never happen
    endcase
end

// Write mux
always_comb begin
    unique case ({use_one, use_two, lru_bit})
        3'b000: begin
            write_one_t = 1'b1;
            write_two_t = 1'b0;
        end
        3'b001: begin
            write_one_t = 1'b0;
            write_two_t = 1'b1;
        end
        3'b010: begin
            write_one_t = 1'b0;
            write_two_t = 1'b1;
        end
        3'b011: begin
            write_one_t = 1'b0;
            write_two_t = 1'b1;
        end
        3'b100: begin
            write_one_t = 1'b1;
            write_two_t = 1'b0;
        end
        3'b101: begin
            write_one_t = 1'b1;
            write_two_t = 1'b0;
        end
        3'b110: begin // Shouldn't ever happen
            write_one_t = 1'b1;
            write_two_t = 1'b0;
        end
        3'b111: begin // Shouldn't ever happen
            write_one_t = 1'b0;
            write_two_t = 1'b1;
        end
        default: begin
            write_one_t = 1'b0;
            write_two_t = 1'b0;
        end
    endcase
end

assign write_one = write_one_t & cache_write;
assign write_two = write_two_t & cache_write;

addr_decoder parser (
    .in(mem_address),
    .tag(tag),
    .index(index),
    .offset(offset)
    );

data_array data_one (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_write_one_en),
    .rindex(index),
    .windex(index),
    .datain(data_input),
    .dataout(data_one_out)
    );

data_array data_two (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_write_two_en),
    .rindex(index),
    .windex(index),
    .datain(data_input),
    .dataout(data_two_out)
    );

tag_comparator tag_compare [2] (
    .a({tag_one_out, tag_two_out}),
    .b(tag),
    .f({tag_compare_one_out, tag_compare_two_out})
    );

// tag_comparator tag_compare_two (
//     .a(tag_two_out),
//     .b(tag),
//     .f(tag_compare_two_out)
//     );

array #(.s_index(3), .width(24)) tag_one (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(write_one),
    .rindex(index),
    .windex(index),
    .datain(tag),
    .dataout(tag_one_out)
    );

array #(.s_index(3), .width(24)) tag_two (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(write_two),
    .rindex(index),
    .windex(index),
    .datain(tag),
    .dataout(tag_two_out)
    );

array #(.s_index(3), .width(1)) valid_one (
    .clk(clk),
    .rst(rst),
    .read(1'b1), // Whether to read the value at the address or not
    .load(write_one), // Whether to write a new value at the address
    .rindex(index),
    .windex(index),
    .datain(1'b1),
    .dataout(valid_one_out)
    );

array #(.s_index(3), .width(1)) valid_two (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(write_two),
    .rindex(index),
    .windex(index),
    .datain(1'b1),
    .dataout(valid_two_out)
    );

array #(.s_index(3), .width(1)) dirty_one (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(write_one),
    .rindex(index),
    .windex(index),
    .datain(from_processor),
    .dataout(dirty_one_out)
    );

array #(.s_index(3), .width(1)) dirty_two (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(write_two),
    .rindex(index),
    .windex(index),
    .datain(from_processor),
    .dataout(dirty_two_out)
    );

array #(.s_index(3), .width(1)) LRU (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(lru_update),
    .rindex(index),
    .windex(index),
    .datain(lru_in),
    .dataout(lru_bit)
    );

endmodule : cache_datapath
