module decoder2 (
    input logic [31:0] in,
    output logic [23:0] tag,
    output logic [2:0] index,
    output logic [4:0] offset
    );

assign tag = in[31:8];
assign index = in[7:5];
assign offset = in[4:0];

endmodule
