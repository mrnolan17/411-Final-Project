/* From MP3. Author: Andrew Gacek */
import rv32i_types::*;

module comparator
(
    input branch_funct3_t cmpop,
    input [31:0] a, b,
    output logic f
);

always_comb
begin
    unique case (cmpop)
        3'b000: f = a == b ? 1'b1 : 1'b0;
        3'b001: f = a != b ? 1'b1 : 1'b0;
        3'b100: f = $signed(a) < $signed(b) ? 1'b1 : 1'b0;
        3'b101: f = $signed(a) >= $signed(b) ? 1'b1 : 1'b0;
        3'b110: f = $unsigned(a) < $unsigned(b) ? 1'b1 : 1'b0;
        3'b111: f = $unsigned(a) >= $unsigned(b) ? 1'b1 : 1'b0;
        default:  f=1'b0;
    endcase
end

endmodule : comparator
