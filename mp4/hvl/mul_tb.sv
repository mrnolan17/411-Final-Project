module mul_tb;
`timescale 1ns/10ps


logic [31:0] a, b, c;
logic [1:0] mulop;
logic [63:0] j, k, f, curr_product;

wallace_mul w (.*);

initial begin
		assign curr_product = w.curr_product;
		for(j = 0; j < 32'hFFFFFFFF; j = j+32'h0183DBB5) begin
				for(k = j%32'h01A1D4CF; k < 32'hFFFFFFFF; k = k+32'h01A1D4CF) begin
						for(int i = 1; i < 4; i++) begin
								mulop = i;
								a = j[31:0];
								b = k[31:0];
								#1
								if(i == 1) begin
									if ($signed(f) != $signed(a) * $signed(b)) begin
										$error("S Product Error! %d * %d != %d", $signed(a), $signed(b), $signed(f));
									end
								end
								if(i == 2) begin
									if(b >= 32'h80000000) begin
										if ($signed(f) != $signed(a) * k) begin
											$error("SU Product Error1! %d * %d != %d, %d", $signed(a), k, $signed(f), ($signed(a) * k));
										end
									end
									else begin
										if ($signed(f) != $signed(a) * b) begin
											$error("SU Product Error2! %d * %d != %d, %d", $signed(a), b, $signed(f), ($signed(a) * b));
										end
									end
	
								end
								if(i == 3) begin
									if ($unsigned(f) != $unsigned(a) * $unsigned(b)) begin
										$error("U Product Error! %d * %d != %d", $unsigned(a), $unsigned(b), $unsigned(f));
									end
								end
						end
				end
		end
		$finish;
		
end



endmodule