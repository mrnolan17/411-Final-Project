import rv32i_types::*;
import control::*;
import regfile::*;

module if_id_reg
(
    input clk,
    input rst,
    input logic load,
    input logic should_flush,

    input if_id_regfile sig_in,
    output if_id_regfile sig_out
);

logic [6:0] opcode_out;
assign sig_out.opcode = rv32i_types::rv32i_opcode'(opcode_out);

logic [6:0] opcode_in;
always_comb begin
    unique case(should_flush)
        1'b1: opcode_in = 7'd0;
        default: opcode_in = sig_in.opcode;
    endcase
end

register #(.width(7)) OPCODE(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (opcode_in),
    .out  (opcode_out)
);

register #(.width(3)) FUNCT3(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.funct3),
    .out  (sig_out.funct3)
);

register #(.width(7)) FUNCT7(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.funct7),
    .out  (sig_out.funct7)
);

register #(.width(5)) RS1(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.rs1),
    .out  (sig_out.rs1)
);

register #(.width(5)) RS2(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.rs2),
    .out  (sig_out.rs2)
);

register #(.width(5)) RD(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.rd),
    .out  (sig_out.rd)
);

register IIMM(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.i_imm),
    .out  (sig_out.i_imm)
);

register UIMM(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.u_imm),
    .out  (sig_out.u_imm)
);
register BIMM(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.b_imm),
    .out  (sig_out.b_imm)
);
register SIMM(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.s_imm),
    .out  (sig_out.s_imm)
);
register JIMM(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.j_imm),
    .out  (sig_out.j_imm)
);
register PC(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.pc),
    .out  (sig_out.pc)
);
register #(.width(1)) PRED(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.prediction),
    .out  (sig_out.prediction)
);
register #(.width(4)) PREDS(
    .clk  (clk),
    .rst (rst),
    .load (load),
    .in   (sig_in.all_prediction),
    .out  (sig_out.all_prediction)
);


endmodule