/* Taken from MP3 */

module pc #(parameter width = 32)
(
    input clk,
    input rst,
    input load,
    input [width-1:0] in,
    output logic [width-1:0] out
);

logic [width-1:0] data = 1'b0;

always_ff @(posedge clk)
begin
    if (rst)
    begin
        data <= 32'h00000060;
    end
    else if (load)
    begin
        data <= in;
    end
    else
    begin
        data <= data;
    end
end

always_comb
begin
    out = data;
end

endmodule : pc
