/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */
import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module l2_datapath #(
    parameter s_offset = 5,
    parameter s_index  = 2,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index,
    parameter way_bits = 1,
    parameter num_ways = 2**way_bits
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

logic [s_tag-1:0] tag;

// logic [23:0] tag_one_out, tag_two_out;
logic [s_tag-1:0] tag_final;
logic [0:num_ways-1][s_tag-1:0] tag_out ;

logic [s_index-1:0] index;
logic [s_offset-1:0] offset;
logic [255:0] data_input;

// logic [255:0] data_one_out, data_two_out;
logic [0:num_ways-1][255:0] data_out ;
logic [255:0] inter_data;
// logic use_one, use_two;
logic [0:num_ways-1] USE;
// logic lru_bit [0:num_ways-1];
// logic lru_bit;
// logic lru_in; 
// logic write_lru;

// logic tag_compare_one_out, tag_compare_two_out;
logic [0:num_ways-1] tag_compare_out;
logic cache_dataout;

// logic write_one, write_one_t, write_two_t, write_two, valid_one_out, valid_two_out, valid_out;
logic [0:num_ways-1] write_a;
logic [0:num_ways-1] write_t;
logic [0:num_ways-1] valid_out_i;
logic valid_out;

// logic dirty_one_out, dirty_two_out;
logic [0:num_ways-1] dirty_out;

// logic [31:0] data_write_one_en, data_write_two_en;
logic [0:num_ways-1][31:0] data_write_en ;

assign in_cache = (tag_compare_out > 0) ? valid_out : 1'b0;

// PLRU LOGIC AND SIGNALS BELOW

logic [way_bits-1:0] lru_in, lru_bits, lru_in_t, lru_bits_t;
logic [num_ways-1:0] lru_array, lru_array_t;

assign lru_bits_t = lru_bits;
// assign lru_in = lru_in_t;
assign lru_array = lru_array_t;

//*-------------------pLRU Decision making-----------------------*//
// always_comb begin
//     if (USE[0]) begin
//         lru_in_t = {1'b1, 1'b1, lru_bits_t[0]}; // [2,1,0]
//     end
//     else if (USE[1]) begin
//         lru_in_t = {1'b1, 1'b0, lru_bits_t[0]}; // [2,1,0]
//     end
//     else if (USE[2]) begin
//         lru_in_t = {1'b0, lru_bits_t[1], 1'b1}; // [2,1,0]
//     end
//     else if (USE[3]) begin
//         lru_in_t = {1'b0, lru_bits_t[1], 1'b0}; // [2,1,0]
//     end
//     // else begin
//     //     lru_in_t = 3'b0;
//     // end
// 	else begin
// 		lru_in_t = lru_bits_t;
// 	end

//     casex({lru_bits_t[2], lru_bits_t[1], lru_bits_t[0]}) // [2,1,0]
//     3'b00x : lru_array_t = 4'b0001; // 4'b{3,2,1,0}
//     3'b01x : lru_array_t = 4'b0010; // 4'b{3,2,1,0}
//     3'b1x0 : lru_array_t = 4'b0100; // 4'b{3,2,1,0}
//     3'b1x1 : lru_array_t = 4'b1000; // 4'b{3,2,1,0}
//     default : lru_array_t = 4'b0000; // 4'b{3,2,1,0}
//   endcase
// end

//*-------------------END OF PLRU LOGIC-----------------------*//

// always_comb begin
//     unique case ({lru_array_t[0], lru_array_t[1], lru_array_t[2], lru_array_t[3]})
//     4'b1000: tag_final = tag_out[0];
//     4'b0100: tag_final = tag_out[1];
//     4'b0010: tag_final = tag_out[2];
//     4'b0001: tag_final = tag_out[3];
//     default: tag_final = tag;
//     endcase
// end

always_comb begin
    unique case (miss_cache_read)
        1'b0: begin
            for (int i = 0; i < num_ways; i++) begin
                USE[i] = tag_compare_out[i] & valid_out_i[i];
                // pmem_address = (lru_bits == i) ? {tag_out[i], index, 5'd0} : pmem_address;
            end
            // USE[0] = tag_compare_out[0] & valid_out_i[0];
            // USE[1] = tag_compare_out[1] & valid_out_i[1];
            // USE[2] = tag_compare_out[2] & valid_out_i[2];
            // USE[3] = tag_compare_out[3] & valid_out_i[3];
            pmem_address = {tag, index, 5'd0};
        end
        1'b1: begin
            //not sure
            pmem_address = {tag, index, 5'd0};
            for (int i = 0; i < num_ways; i++) begin
                USE[i] = (lru_bits == i) ? 1'b1 : 1'b0;
                pmem_address = (lru_bits == i) ? {tag_out[i], index, 5'd0} : pmem_address;
            end
            // USE[0] = lru_array_t[0];
            // USE[1] = lru_array_t[1];
            // USE[2] = lru_array_t[2];
            // USE[3] = lru_array_t[3];
            // pmem_address = (lru_bits[0]) ? {tag_out[1], index, 5'd0} : {tag_out[0], index, 5'd0};
            // pmem_address = lru_bits[1] ? ((lru_bits[0]) ? {tag_out[3], index, 5'd0} : {tag_out[2], index, 5'd0}) : ((lru_bits[0]) ? {tag_out[1], index, 5'd0} : {tag_out[0], index, 5'd0});
            // pmem_address =  {tag_final, index, 5'd0};
        end
        default: begin
            USE = 0;
            // USE[0] = 1'b0;
            // USE[1] = 1'b0;
            // USE[2] = 1'b0;
            // USE[3] = 1'b0;
            pmem_address = {tag, index, 5'd0};
        end
    endcase
end

// assign lru_in = USE[0] | write_a[0];
// assign read_one = cache_read & USE[0];
// assign read_two = cache_read & USE[1];


always_comb begin
    lru_in = 0;
    for (int i = 0; i < num_ways; i++) begin
        lru_in = (USE[i] | write_a[i]) ? i : lru_in;
    end

    valid_out = 1'b0;
    for (int i = 0; i < num_ways; i++) begin
        valid_out = (tag_compare_out[i]) ? valid_out_i[i] : valid_out;
    end

    for (int i = 0; i < num_ways; i++) begin
        data_write_en[i] = (write_a[i]) ? (32'hFFFFFFFF) : 32'd0;
    end

    // unique casex ({tag_compare_out[0], tag_compare_out[1], tag_compare_out[2], tag_compare_out[3]})
    // 4'b1xxx: valid_out = valid_out_i[0];
    // 4'b01xx: valid_out = valid_out_i[1];
    // 4'b001x: valid_out = valid_out_i[2];
    // 4'b0001: valid_out = valid_out_i[3];
    // default: valid_out = 1'b0;
    // endcase
end

// assign valid_out = (tag_compare_out[0]) ? valid_out_i[0] : valid_out_i[1];

assign data_input = (from_processor) ? mem_wdata : pmem_rdata;

// assign data_write_en[0] = (write_a[0]) ? (32'hFFFFFFFF) : 32'd0;
// assign data_write_en[1] = (write_a[1]) ? (32'hFFFFFFFF) : 32'd0;
// assign data_write_en[2] = (write_a[2]) ? (32'hFFFFFFFF) : 32'd0;
// assign data_write_en[3] = (write_a[3]) ? (32'hFFFFFFFF) : 32'd0;
// assign write_lru = write_one | write_two | cache_read;

// assign pmem_wdata = (USE[0]) ? data_out[0] : data_out[1];

///not sure
// assign pmem_wdata = USE[1] ? (((USE[0]) ? data_out[0] : data_out[1])) : ((USE[0]) ? data_out[0] : data_out[1]);

assign pmem_wdata = inter_data;
assign mem_rdata = inter_data;

always_comb begin
    // case ({USE[0],USE[1],USE[2],USE[3]})
    //     4'b1000: inter_data = data_out[0]; 
    //     4'b0100: inter_data = data_out[1];
    //     4'b0010: inter_data = data_out[2]; 
    //     4'b0001: inter_data = data_out[3];  
    //     default: inter_data = pmem_rdata;
    // endcase
    inter_data = pmem_rdata;
    for (int i = 0; i < num_ways; i++) begin
        inter_data = (USE[i] == 1'b1) ? data_out[i] : inter_data;
    end
end
// assign dirty_overwrite = (dirty_out[0] & valid_out_i[0] & (USE[0] | write_t[0])) | (dirty_out[1] & valid_out_i[1] & (USE[1] | write_t[1])) | (dirty_out[2] & valid_out_i[2] & (USE[2] | write_t[2])) | (dirty_out[3] & valid_out_i[3] & (USE[3] | write_t[3]));

always_comb begin
    dirty_overwrite = 0;
    for (int i = 0; i < num_ways; i++) begin
        dirty_overwrite = dirty_overwrite | (dirty_out[i] & valid_out_i[i] & (USE[i] | write_t[i]));
    end
end

// Get the correct address
// always_comb begin
//     unique case (USE[0])
//         1'b0: pmem_address = {tag_two_out, index, 5'd0}; 
//         1'b1: pmem_address = {tag_one_out, index, 5'd0};
//         default: pmem_address = {tag, index, 5'd0}; // Should never happen
//     endcase
// end



// Get the correct address
// always_comb begin
//     unique case ({USE[0], USE[1], USE[2], USE[3]})
//         3'b000: mem_rdata = data_out[1]; 
//         3'b100: mem_rdata = data_out[0];
//         3'b010: mem_rdata = pmem_rdata; 
//         3'b110: mem_rdata = pmem_rdata;
//         3'b001: mem_rdata = pmem_rdata; 
//         3'b101: mem_rdata = pmem_rdata;
//         default: mem_rdata = 256'dX; // Should never happen
//     endcase
// end

// ---------------------THIS IS DEFINITELY WRONG not quite sure how to deal with this signal Did not parameterize this part yet (below)------------------------------ //
// Write mux
always_comb begin
    write_t = 0;
    if (USE > 0)
    for (int i = 0; i < num_ways; i++) begin
        write_t[i] = USE[i];
    end
    else
    for (int i = 0; i < num_ways; i++) begin
        write_t[i] = (lru_bits == i) ? 1'b1 : 1'b0;
    end
    // unique casex ({USE[0], USE[1], USE[2], USE[3], lru_array_t[3], lru_array_t[2], lru_array_t[1], lru_array_t[0]}) // [3,2,1,0]
    //     8'b00000001: begin
    //         write_t[0] = 1'b1;
    //         write_t[1] = 1'b0;
    //         write_t[2] = 1'b0;
    //         write_t[3] = 1'b0;
    //     end
    //     8'b00000010: begin
    //         write_t[0] = 1'b0;
    //         write_t[1] = 1'b1;
    //         write_t[2] = 1'b0;
    //         write_t[3] = 1'b0;
    //     end
    //     8'b00000100: begin
    //         write_t[0] = 1'b0;
    //         write_t[1] = 1'b0;
    //         write_t[2] = 1'b1;
    //         write_t[3] = 1'b0;
    //     end
    //     8'b00001000: begin
    //         write_t[0] = 1'b0;
    //         write_t[1] = 1'b0;
    //         write_t[2] = 1'b0;
    //         write_t[3] = 1'b1;
    //     end

    //     8'b1000xxxx: begin
    //         write_t[0] = 1'b1;
    //         write_t[1] = 1'b0;
    //         write_t[2] = 1'b0;
    //         write_t[3] = 1'b0;
    //     end
    //     8'b0100xxxx: begin
    //         write_t[0] = 1'b0;
    //         write_t[1] = 1'b1;
    //         write_t[2] = 1'b0;
    //         write_t[3] = 1'b0;
    //     end
    //     8'b0010xxxx: begin
    //         write_t[0] = 1'b0;
    //         write_t[1] = 1'b0;
    //         write_t[2] = 1'b1;
    //         write_t[3] = 1'b0;
    //     end
    //     8'b0001xxxx: begin
    //         write_t[0] = 1'b0;
    //         write_t[1] = 1'b0;
    //         write_t[2] = 1'b0;
    //         write_t[3] = 1'b1;
    //     end
    //     default: begin
    //         write_t[0] = 1'b0;
    //         write_t[1] = 1'b0;
    //         write_t[2] = 1'b0;
    //         write_t[3] = 1'b0;
    //     end
    // endcase
end

// ---------------------Did not parameterize this part yet (above)------------------------------ //

// assign write_a[0] = write_t[0] & cache_write;
// assign write_a[1] = write_t[1] & cache_write;
// assign write_a[2] = write_t[2] & cache_write;
// assign write_a[3] = write_t[3] & cache_write;
assign write_a = (cache_write) ? write_t : 0;

addr_decoder #(.s_offset(s_offset), .s_index(s_index)) parser (
    .in(mem_address),
    .tag(tag),
    .index(index),
    .offset(offset)
    );

data_array_2 #(.s_offset(s_offset), .s_index(s_index)) data_array [num_ways] (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_write_en),
    .rindex(index),
    .windex(index),
    .datain(data_input),
    .dataout(data_out)
    );

tag_comparator #(.width(s_tag)) tag_compare [num_ways] (
    .a(tag_out),
    .b(tag),
    .f(tag_compare_out)
    );

// addr_decoder parser (
//     .in(mem_address),
//     .tag(tag),
//     .index(index),
//     .offset(offset)
//     );

// data_array_2 data_array [num_ways] (
//     .clk(clk),
//     .rst(rst),
//     .read(1'b1),
//     .write_en(data_write_en),
//     .rindex(index),
//     .windex(index),
//     .datain(data_input),
//     .dataout(data_out)
//     );

// tag_comparator tag_compare [num_ways] (
//     .a(tag_out),
//     .b(tag),
//     .f(tag_compare_out)
//     );

array_2 #(.s_index(s_index), .width(s_tag)) tag_array [num_ways] (
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

array_2 #(.s_index(s_index), .width(1)) valid_array [num_ways] (
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

array_2 #(.s_index(s_index), .width(1)) dirty_array [num_ways] (
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

lru_arr #(.s_index(s_index), .way_bits(way_bits)) LRU (
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(lru_update),
    .rindex(index),
    .windex(index),
    .datain(~lru_in),
    .dataout(lru_bits)
    );







endmodule : l2_datapath
