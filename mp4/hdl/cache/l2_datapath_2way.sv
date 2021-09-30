/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */
import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module l2_datapath #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index,
    parameter num_ways = 2
)
(
    input logic clk,                        // Clock
    input logic rst,                        // Reset

    output logic[255:0] mem_rdata,          // Read data from cache to arbiter
    input logic[255:0] mem_wdata,           // Write data to cache from arbiter
    input rv32i_word mem_address,           // arbiter memory address

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
    output logic[255:0] pmem_wdata         // Write data to pmem
    // input logic[31:0] mem_byte_enable256    // Write enable bit (for CPU)
);

logic [23:0] tag;

// logic [23:0] tag_one_out, tag_two_out;
logic [23:0] tag_out [0:num_ways-1];

logic [2:0] index;
logic [4:0] offset;
logic [255:0] data_input;

// logic [255:0] data_one_out, data_two_out;
logic [255:0] data_out [0:num_ways-1];
// logic use_one, use_two;
logic USE [0:num_ways-1];
// logic lru_bit [0:num_ways-1];
logic lru_bit;
logic lru_in; 
// logic write_lru;

// logic tag_compare_one_out, tag_compare_two_out;
logic tag_compare_out [0:num_ways-1];
logic cache_dataout;

// logic write_one, write_one_t, write_two_t, write_two, valid_one_out, valid_two_out, valid_out;
logic write_a [0:num_ways-1];
logic write_t [0:num_ways-1];
logic valid_out_i [0:num_ways-1];
logic valid_out;

// logic dirty_one_out, dirty_two_out;
logic dirty_out [0:num_ways-1];

// logic [31:0] data_write_one_en, data_write_two_en;
logic [31:0] data_write_en [0:num_ways-1];

assign in_cache = (tag_compare_out[0] | tag_compare_out[1]) ? 1'b1 & valid_out : 1'b0 & valid_out;

always_comb begin
    unique case (miss_cache_read)
        1'b0: begin
            USE[0] = tag_compare_out[0] & valid_out_i[0];
            USE[1] = tag_compare_out[1] & valid_out_i[1];
            pmem_address = {tag, index, 5'd0};
        end
        1'b1: begin
            USE[0] = ~lru_bit;
            USE[1] = lru_bit;
            pmem_address = (lru_bit) ? {tag_out[1], index, 5'd0} : {tag_out[0], index, 5'd0};
        end
        default: begin
            USE[0] = 1'b0;
            USE[1] = 1'b0;
            pmem_address = {tag, index, 5'd0};
        end
    endcase
end

assign lru_in = USE[0] | write_a[0];
// assign read_one = cache_read & USE[0];
// assign read_two = cache_read & USE[1];


assign valid_out = (tag_compare_out[0]) ? valid_out_i[0] : valid_out_i[1];

assign data_input = (from_processor) ? mem_wdata : pmem_rdata;

assign data_write_en[0] = (write_a[0]) ? (32'hFFFFFFFF) : 32'd0;
assign data_write_en[1] = (write_a[1]) ? (32'hFFFFFFFF) : 32'd0;
// assign write_lru = write_one | write_two | cache_read;

assign pmem_wdata = (USE[0]) ? data_out[0] : data_out[1];
assign dirty_overwrite = (dirty_out[0] & valid_out_i[0] & (USE[0] | write_t[0])) | (dirty_out[1] & valid_out_i[1] & (USE[1] | write_t[1]));

// Get the correct address
// always_comb begin
//     unique case (USE[0])
//         1'b0: pmem_address = {tag_two_out, index, 5'd0}; 
//         1'b1: pmem_address = {tag_one_out, index, 5'd0};
//         default: pmem_address = {tag, index, 5'd0}; // Should never happen
//     endcase
// end

// Get the correct address
always_comb begin
    unique case ({USE[0], write_a[0], write_a[1]})
        3'b000: mem_rdata = data_out[1]; 
        3'b100: mem_rdata = data_out[0];
        3'b010: mem_rdata = pmem_rdata; 
        3'b110: mem_rdata = pmem_rdata;
        3'b001: mem_rdata = pmem_rdata; 
        3'b101: mem_rdata = pmem_rdata;
        default: mem_rdata = 256'dX; // Should never happen
    endcase
end

// Write mux
always_comb begin
    unique case ({USE[0], USE[1], lru_bit})
        3'b000: begin
            write_t[0] = 1'b1;
            write_t[1] = 1'b0;
        end
        3'b001: begin
            write_t[0] = 1'b0;
            write_t[1] = 1'b1;
        end
        3'b010: begin
            write_t[0] = 1'b0;
            write_t[1] = 1'b1;
        end
        3'b011: begin
            write_t[0] = 1'b0;
            write_t[1] = 1'b1;
        end
        3'b100: begin
            write_t[0] = 1'b1;
            write_t[1] = 1'b0;
        end
        3'b101: begin
            write_t[0] = 1'b1;
            write_t[1] = 1'b0;
        end
        // 3'b110: begin // Shouldn't ever happen
        //     write_t[0] = 1'b1;
        //     write_t[1] = 1'b0;
        // end
        // 3'b111: begin // Shouldn't ever happen
        //     write_t[0] = 1'b0;
        //     write_t[1] = 1'b1;
        // end
        default: begin
            write_t[0] = 1'b0;
            write_t[1] = 1'b0;
        end
    endcase
end

assign write_a[0] = write_t[0] & cache_write;
assign write_a[1] = write_t[1] & cache_write;

addr_decoder parser (
    .in(mem_address),
    .tag(tag),
    .index(index),
    .offset(offset)
    );

data_array_2 data_array [num_ways] (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en({data_write_en[0], data_write_en[1]}),
    .rindex(index),
    .windex(index),
    .datain(data_input),
    .dataout(data_out)
    );

// data_array data_two (
//     .clk(clk),
//     .rst(rst),
//     .read(1'b1),
//     .write_en(data_write_two_en),
//     .rindex(index),
//     .windex(index),
//     .datain(data_input),
//     .dataout(data_two_out)
//     );

tag_comparator tag_compare [num_ways] (
    .a(tag_out),
    .b(tag),
    .f(tag_compare_out)
    );

array_2 #(.s_index(3), .width(24)) tag_array [num_ways] (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(write_a),
    .rindex(index),
    .windex(index),
    .datain(tag),
    .dataout(tag_out)
    );

// array #(.s_index(3), .width(24)) tag_two (
//     .clk(clk),
//     .rst(rst),
//     .read(1'b1),
//     .load(write_two),
//     .rindex(index),
//     .windex(index),
//     .datain(tag),
//     .dataout(tag_two_out)
//     );

array_2 #(.s_index(3), .width(1)) valid_array [num_ways] (
    .clk(clk),
    .rst(rst),
    .read(1'b1), // Whether to read the value at the address or not
    .load(write_a), // Whether to write a new value at the address
    .rindex(index),
    .windex(index),
    .datain(1'b1),
    .dataout(valid_out_i)
    );

// array #(.s_index(3), .width(1)) valid_two (
//     .clk(clk),
//     .rst(rst),
//     .read(1'b1),
//     .load(write_two),
//     .rindex(index),
//     .windex(index),
//     .datain(1'b1),
//     .dataout(valid_two_out)
//     );

array_2 #(.s_index(3), .width(1)) dirty_array [num_ways] (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(write_a),
    .rindex(index),
    .windex(index),
    .datain(from_processor),
    .dataout(dirty_out)
    );

// array #(.s_index(3), .width(1)) dirty_two (
//     .clk(clk),
//     .rst(rst),
//     .read(1'b1),
//     .load(write_two),
//     .rindex(index),
//     .windex(index),
//     .datain(from_processor),
//     .dataout(dirty_two_out)
//     );

array_2 #(.s_index(3), .width(1)) LRU (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(lru_update),
    .rindex(index),
    .windex(index),
    .datain(lru_in),
    .dataout(lru_bit)
    );

endmodule : l2_datapath
