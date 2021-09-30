import rv32i_types::*;
import control::*;
import regfile::*;

module branch_predictor_top
(
    input clk,
    input rst,
    input load_stall,

    input if_control_word if_control,

    input if_id_regfile reg_out,
    input logic true,
    input logic br_en,

    output logic prediction,
    output logic[3:0] all_prediction,
    input logic[31:0] waddr
);

logic [1:0] local_p, global_p, global_p2, global_p3;
logic [2:0] history;
logic flag, flag1, flag2;
logic [1:0] prediction1, prediction2;

register #(.width(3)) history_ (
    .clk  (clk),
    .rst (rst),
    .load (br_en && ~load_stall), // (if_control.use_predictor && ~load_stall) or (br_en && ~load_stall)
    .in   ({true, history[2:1]}), // {prediction, history[2:1]} or {true, history[2:1]}
    .out  (history)
    );

local_bp localbp // Just a regfile
(
    .clk(clk),
    .rst(rst),
    .load_stall(load_stall),
    .address(reg_out.pc),
    .true,
    .br_en,
    .waddr,
     
    .if_control(if_control),
    .prediction(local_p)
);

global_bp #(.H_width(1)) globalbp  // Just a regfile
(
    .clk(clk),
    .rst(rst),
    .load_stall(load_stall),
    .address(reg_out.pc),
    .history(history[0]),
    .true,
    .br_en,
    .waddr,

     
    .if_control(if_control),
    .prediction(global_p)
);

global_bp #(.H_width(2)) globalbp2  // Just a regfile
(
    .clk(clk),
    .rst(rst),
    .load_stall(load_stall),
    .address(reg_out.pc),
    .history(history[1:0]),
    .true,
    .br_en,
    .waddr,
     
    .if_control(if_control),
    .prediction(global_p2)
);
global_bp #(.H_width(3)) globalbp3  // Just a regfile
(
    .clk(clk),
    .rst(rst),
    .load_stall(load_stall),
    .address(reg_out.pc),
    .history(history),
    .true,
    .br_en,
    .waddr,

     
    .if_control(if_control),
    .prediction(global_p3)
);
always_comb begin
    all_prediction = {local_p, global_p, global_p2, global_p3};
    unique case({local_p, global_p})
        4'b0000: flag1 = 1'b1;
        4'b0001: flag1 = 1'b0;
        4'b0010: flag1 = 1'b0;
        4'b0011: flag1 = 1'b1;
        4'b0100: flag1 = 1'b1;
        4'b0101: flag1 = 1'b1;
        4'b0110: flag1 = 1'b1;
        4'b0111: flag1 = 1'b1;
        4'b1000: flag1 = 1'b1;
        4'b1001: flag1 = 1'b1;
        4'b1010: flag1 = 1'b1;
        4'b1011: flag1 = 1'b1;
        4'b1100: flag1 = 1'b1;
        4'b1101: flag1 = 1'b0;
        4'b1110: flag1 = 1'b0;
        4'b1111: flag1 = 1'b1;
        default: flag1 = 1'b1;
    endcase // {local_p, global_p}endcase

    if (flag1 == 1'b0) begin
        prediction1 = local_p;
    end else begin
        prediction1 = global_p;
    end
end

always_comb begin
    unique case({prediction1, global_p2})
        4'b0000: flag2 = 1'b1;
        4'b0001: flag2 = 1'b0;
        4'b0010: flag2 = 1'b0;
        4'b0011: flag2 = 1'b1;
        4'b0100: flag2 = 1'b1;
        4'b0101: flag2 = 1'b1;
        4'b0110: flag2 = 1'b1;
        4'b0111: flag2 = 1'b1;
        4'b1000: flag2 = 1'b1;
        4'b1001: flag2 = 1'b1;
        4'b1010: flag2 = 1'b1;
        4'b1011: flag2 = 1'b1;
        4'b1100: flag2 = 1'b1;
        4'b1101: flag2 = 1'b0;
        4'b1110: flag2 = 1'b0;
        4'b1111: flag2 = 1'b1;
        default: flag2 = 1'b1;
    endcase // {local_p, global_p}endcase

    if (flag == 1'b0) begin
        prediction2 = prediction1;
    end else begin
        prediction2 = global_p2;
    end
end

always_comb begin
    unique case({prediction2, global_p3})
        4'b0000: flag = 1'b1;
        4'b0001: flag = 1'b0;
        4'b0010: flag = 1'b0;
        4'b0011: flag = 1'b1;
        4'b0100: flag = 1'b1;
        4'b0101: flag = 1'b1;
        4'b0110: flag = 1'b1;
        4'b0111: flag = 1'b1;
        4'b1000: flag = 1'b1;
        4'b1001: flag = 1'b1;
        4'b1010: flag = 1'b1;
        4'b1011: flag = 1'b1;
        4'b1100: flag = 1'b1;
        4'b1101: flag = 1'b0;
        4'b1110: flag = 1'b0;
        4'b1111: flag = 1'b1;
        default: flag = 1'b1;
    endcase // {local_p, global_p}endcase

    if (flag == 1'b0) begin
        prediction = prediction2[1];
    end else begin
        prediction = global_p3[1];
    end
end

endmodule
