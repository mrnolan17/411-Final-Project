import rv32i_types::*;
import control::*;
import regfile::*;

module global_bp #(parameter width = 2, parameter H_width = 2)
(
    input clk,
    input rst,
    input logic load_stall,
    input rv32i_word address,
    input logic[H_width-1:0] history,
     
    input if_control_word if_control,
    input logic true,
    input logic br_en,
    output logic [width-1:0] prediction,
    input logic[31:0] waddr
);

logic [127:0] data [2**H_width];
logic [1:0] d_in;
logic [6:0] loc1, loc0;
logic [6:0] loc1w, loc0w;

logic [31:0] one_counter, zero_counter;

always_ff @(posedge clk)
begin
    if (rst)
    begin
        for (int i=0; i<2**H_width; i=i+1) begin
            data[i] <= 128'h66666666666666666666666666666666;
        end
        one_counter <= '0;
        zero_counter <= '0;
    end
    else if (if_control.use_predictor)
    begin
        if (prediction[width-1])
            one_counter <= one_counter + 1;
        else
            zero_counter <= zero_counter + 1;
    end
    if (~rst & br_en) begin
        data[history][loc1w] <= d_in[1];
        data[history][loc0w] <= d_in[0];
    end

end

always_comb
begin
    loc1w = {waddr[7:2], 1'b1};
    loc0w = {waddr[7:2], 1'b0};

    loc1 = {address[7:2], 1'b1};
    loc0 = {address[7:2], 1'b0};

    prediction = {data[history][loc1], data[history][loc0]};

    unique case({data[history][loc1], data[history][loc0], true})
        3'b000: d_in = 2'b00;
        3'b001: d_in = 2'b01;
        3'b010: d_in = 2'b00;
        3'b011: d_in = 2'b10;
        3'b100: d_in = 2'b01;
        3'b101: d_in = 2'b11;
        3'b110: d_in = 2'b10;
        3'b111: d_in = 2'b11;
    endcase
end

endmodule
