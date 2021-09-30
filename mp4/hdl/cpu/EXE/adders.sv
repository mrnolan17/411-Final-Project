module HA(
input logic a,b,
output logic sum, cout
);

assign sum = a^b;
assign cout = a&b;

endmodule


module FA(
input logic a, b, c,
output logic sum, cout
);

assign sum=a^b^c;

assign cout = (a&b) | (a&c)  | (b&c);

endmodule


module lad4(input logic [3:0] a4, b4,
input C0,
output logic [3:0]sum4,
output logic p4, g4);
logic c1, c2, c3;
logic [3:0] p, g;
always_comb
begin
p = a4 ^ b4;
g = a4 & b4;
c1 = (C0 & p[0]) | g[0];
c2 = (C0 & p[0] & p[1]) | (p[1] & g[0]) | (g[1]);
c3 = (C0 & p[0] & p[1] & p[2]) | (p[1] & p[2] & g[0]) | (p[2] & g[1]) | (g[2]);
p4 = p[0] & p[1] & p[2] & p[3];
g4 = (g[3]) | (g[2] & p[3]) | (g[1] & p[3] & p[2]) | (g[0] & p[3] & p[2] & p[1]);
end

FA FA0(.a(a4[0]), .b(b4[0]), .c(C0), .sum(sum4[0]));
FA FA1(.a(a4[1]), .b(b4[1]), .c(c1), .sum(sum4[1]));
FA FA2(.a(a4[2]), .b(b4[2]), .c(c2), .sum(sum4[2]));
FA FA3(.a(a4[3]), .b(b4[3]), .c(c3), .sum(sum4[3]));

endmodule


module carry_lookahead_adder16
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
input logic C,
    output  logic[15:0]     Sum,
    output  logic           CO,
output logic Pg, Gg
);
logic C1, C2, C3;
logic [3:0] P, G;

lad4 la0(.a4(A[3:0]), .b4(B[3:0]), .C0(C), .sum4(Sum[3:0]), .p4(P[0]), .g4(G[0]));
lad4 la1(.a4(A[7:4]), .b4(B[7:4]), .C0(C1), .sum4(Sum[7:4]), .p4(P[1]), .g4(G[1]));
lad4 la2(.a4(A[11:8]), .b4(B[11:8]), .C0(C2), .sum4(Sum[11:8]), .p4(P[2]), .g4(G[2]));
lad4 la3(.a4(A[15:12]), .b4(B[15:12]), .C0(C3), .sum4(Sum[15:12]), .p4(P[3]), .g4(G[3]));

always_comb
begin
Gg = (G[0] & P[1] & P[2] & P[3]) | (G[1] & P[2] & P[3]) | (G[2] & P[3]) | (G[3]);
Pg = (P[0] & P[1] & P[2] & P[3]) | (G[0] & P[1] & P[2] & P[3]);
C1 = (C & P[0]) | (G[0]);
C2 = (C & P[0] & P[1]) | (G[0] & P[1]) | (G[1]);
C3 = (C & P[0] & P[1] & P[2]) | (G[0] & P[1] & P[2]) | (G[1] & P[2]) | (G[2]);
CO = (C & P[0] & P[1] & P[2] & P[3]) | (G[0] & P[1] & P[2] & P[3]) | (G[1] & P[2] & P[3]) | (G[2] & P[3]) | (G[3]);
end

endmodule
     
 
module carry_lookahead_adder64
(
    input   logic[63:0]     A,
    input   logic[63:0]     B,
    output  logic[63:0]     Sum,
    output  logic           CO
);
logic C1, C2, C3;
logic [3:0] P, G;

carry_lookahead_adder16 cla0(.A(A[15:0]), .B(B[15:0]), .C(0), .Sum(Sum[15:0]), .Pg(P[0]), .Gg(G[0]));
carry_lookahead_adder16 cla1(.A(A[31:16]), .B(B[31:16]), .C(C1), .Sum(Sum[31:16]), .Pg(P[1]), .Gg(G[1]));
carry_lookahead_adder16 cla2(.A(A[47:32]), .B(B[47:32]), .C(C2), .Sum(Sum[47:32]), .Pg(P[2]), .Gg(G[2]));
carry_lookahead_adder16 cla3(.A(A[63:48]), .B(B[63:48]), .C(C3), .Sum(Sum[63:48]), .Pg(P[3]), .Gg(G[3]));

always_comb
begin
C1 = (0 & P[0]) | (G[0]);
C2 = (0 & P[0] & P[1]) | (G[0] & P[1]) | (G[1]);
C3 = (0 & P[0] & P[1] & P[2]) | (G[0] & P[1] & P[2]) | (G[1] & P[2]) | (G[2]);
CO = (0 & P[0] & P[1] & P[2] & P[3]) | (G[0] & P[1] & P[2] & P[3]) | (G[1] & P[2] & P[3]) | (G[2] & P[3]) | (G[3]);
end

endmodule