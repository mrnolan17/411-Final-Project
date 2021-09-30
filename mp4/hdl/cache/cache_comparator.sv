module tag_comparator #(parameter width = 24)(
    input logic[width-1:0] a,
    input logic[width-1:0] b,
    output logic f
    );

assign f = (a == b) ? 1'b1 : 1'b0;

endmodule
