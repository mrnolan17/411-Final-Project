module addr_decoder #(
    parameter s_offset = 5,
    parameter s_index = 3,
	parameter s_tag = 32 - s_offset - s_index
)(
    input logic [31:0] in,
    output logic [s_tag-1:0] tag,
    output logic [s_index-1:0] index,
    output logic [s_offset-1:0] offset
    );

assign tag = in[31:32-s_tag];
assign index = in[s_offset+s_index-1:s_offset];
assign offset = in[s_offset-1:0];

endmodule


module l2_decoder (
    input logic [31:0] in,
    output logic [23:0] tag,
    output logic [7:0] index
    );

assign tag = in[31:8];
assign index = in[7:0];

endmodule