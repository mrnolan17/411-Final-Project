/* A register array to be used for tag arrays, LRU array, etc. */

module lru_arr #(
    parameter s_index = 3,
    parameter way_bits = 3
)
(
    clk,
    rst,
    read,
    load,
    rindex,
    windex,
    datain,
    dataout
);

localparam num_sets = 2**s_index;
localparam num_ways = 2**way_bits;

input clk;
input rst;
input read;
input load;
input [s_index-1:0] rindex;
input [s_index-1:0] windex;
input [way_bits-1:0] datain;
output logic [way_bits-1:0] dataout;
logic out_mux;

logic [num_ways-2:0] tree_in, load_tree, tree_pass, tree_out;
logic [way_bits-1:0] digit_out;

logic [num_ways-2:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;
logic [num_ways-2:0] _dataout;
// assign dataout = _dataout;

always_ff @(posedge clk)
begin
    if (rst) begin
        for (int i = 0; i < num_sets; ++i)
            data[i] <= '0;
    end
    else begin
        if (read)
            tree_out <= data[rindex];

        if(load) // Set the data to be the converted tree
            for (int i = 0; i < way_bits; ++i) begin
                for (int j = 0; j < 2**(i); ++j) begin
                    data[windex][num_ways-1-2**i-j] <= (load_tree[num_ways-1-2**i-j]) ? ~datain[way_bits-1-i] : data[windex][num_ways-1-2**i-j];
                end
            end
            // for (int i = 0; i < num_ways-1; ++i)
            //     data[windex][i] <= (load_tree[i]) ?  : data[windex][i];
            // data[windex] <= datain;
    end
end

always_comb begin
    digit_out = 0;
    tree_pass = 0; // Reads
    out_mux = 1;
    // if (load  & (rindex == windex))
        // out_mux = 0;
    unique case(out_mux)
        1'b1 : begin // Tree to binary conversion
            tree_pass[num_ways-2] = 1'b1;
            for (int i = 1; i < way_bits; ++i) begin
                for (int j = 0; j < 2**(i-1); ++j) begin
                    tree_pass[num_ways-1-2**i-j-1] = tree_pass[num_ways-1-2**(i-1)-j]&~tree_out[num_ways-1-2**i-j];
                    tree_pass[num_ways-1-2**i-j] = tree_pass[num_ways-1-2**(i-1)-j]&tree_out[num_ways-1-2**i-j];
                end
            end

            for (int i = 0; i < way_bits; ++i) begin
                for (int j = 0; j < 2**(i); ++j) begin
                    digit_out[way_bits-1-i] = digit_out[way_bits-1-i] + (tree_pass[num_ways-1-2**i-j]&~tree_out[num_ways-1-2**i-j]);
                end
            end
            dataout = digit_out;
        end
        default : dataout = datain;
    endcase
    // Writes
    load_tree[num_ways-2] = 1'b1;
    for (int i = 1; i < way_bits; ++i) begin
        for (int j = 0; j < 2**(i); j+=2) begin
            load_tree[num_ways-1-2**i-j] = load_tree[num_ways-1-2**(i-1)-j/2]&(1-datain[way_bits-i]);
            load_tree[num_ways-1-2**i-j-1] = load_tree[num_ways-1-2**(i-1)-j/2]&(datain[way_bits-i]);
        end
    end

end

endmodule : lru_arr
