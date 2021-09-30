

module one_hot #(
    parameter width = 32, 
    parameter X = 4
)
(
    onehot,
    i_data,
    o_data
);

input [X-1:0] onehot;
input [width-1:0] i_data [0:X-1];
output [width-1:0] o_data;

always_comb begin
    o_data = 'z;
    for(int i = 0; i < X; i++) 
    begin
        if (onehot == (1 << i))
            o_data = i_data[i];
    end
end

endmodule




