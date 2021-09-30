module divider_unsigned
(
      input logic clk,
      // divopals are self-explainatory
      input logic start,
      input logic [31:0] a,
      input logic [31:0] b,
      output logic [31:0] q,
      output logic [31:0] r,
      output logic done
);

enum int unsigned {
      // list of states
      idle              = 0,
      shift_sub         = 1
} state, next_state;

logic [5:0] counter, next_counter;
logic [31:0] Q;
logic [31:0] R;

// next state condition
always_ff @(posedge clk) begin
      state <= next_state;
      counter <= next_counter;
      q <= Q;
      r <= R;
end

// next state logic

// state output logic
always_comb begin
      unique case (state)
            idle: begin
                  Q = 32'b0;
                  R = 32'b0;
                  next_counter = 6'd31;
                  if(start && counter == 6'd31) next_state = shift_sub;
                  else next_state = idle;
						if(counter != 6'd31) done = 1'b1;
						else done = 1'b0;
            end

            shift_sub: begin
                  if (b <= r) begin
                        Q[31:0] = {q[30:0], 1'b1};
                        if (counter < 6'd32)
                              R[31:0] = {r - b, a[counter]};
                        else
                              R[31:0] = r - b;
                  end else begin
                        Q = {q[30:0], 1'b0};
                        if (counter < 6'd32)
                              R[31:0] = {r[30:0], a[counter]};
                        else
                              R[31:0] = r[31:0];
                  end

                  next_counter = counter - 32'd1;
                  if(counter == -6'd1) next_state = idle;
                  else next_state = shift_sub;
done = 1'b0;
            end
      endcase
end

endmodule


module divider (
      input logic clk,
      // divopals are self-explainatory
      input logic [1:0] divop,
      input logic start,
      input logic [31:0] a,
      input logic [31:0] b,
      output logic [31:0] f,
      output logic done
);

logic [31:0] N, D, Q, R;

divider_unsigned d
(
      .clk(clk),
      .start(start),
      .a(N),
      .b(D),
      .q(Q),
      .r(R),
      .done(done)
);

logic net_q;
assign neg_q = a[31] ^ b[31];
assign neg_r = a[31];

always_comb begin
      unique case (divop)
            2'b00: begin
                  N = a[31] ? (~a) + 32'd1 : a;
                  D = b[31] ? (~b) + 32'd1 : b;
                  f = neg_q ? (~Q) + 32'd1 : Q;
            end

            2'b01: begin
                  N = a;
                  D = b;
                  f = Q;
            end

            2'b10: begin
                  N = a[31] ? (~a) + 32'd1 : a;
                  D = b[31] ? (~b) + 32'd1 : b;
                  f = neg_r ? (~R) + 32'd1 : R;
            end

            2'b11: begin
                  N = a;
                  D = b;
                  f = R;
            end

            default: begin
                  N = a[31] ? (~a) + 32'd1 : a;
                  D = b[31] ? (~b) + 32'd1 : b;
                  f = neg_q ? (~Q) + 32'd1 : Q;
            end
      endcase
end

endmodule