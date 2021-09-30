import rv32i_types::*;
import regfile::*;

module forwarder
(
    input [4:0] rs1,
    input [4:0] rs2,
    input exe_mem_regfile mem_reg,
    input mem_wb_regfile wb_reg,

    output logic [1:0] forwardmux1_sel,
    output logic [1:0] forwardmux2_sel
);

logic mem_wen, wb_wen;

always_comb begin
	unique case (mem_reg.opcode)
		op_imm: mem_wen = 1'b1;
		op_lui: mem_wen = 1'b1;
		op_load: mem_wen = 1'b1;
		op_auipc: mem_wen = 1'b1;
		op_jal: mem_wen = 1'b1;
		op_jalr: mem_wen = 1'b1;
		op_reg: mem_wen = 1'b1;
		default : mem_wen = 1'b0;
	endcase
	
	unique case (wb_reg.opcode)
		op_imm: wb_wen = 1'b1;
		op_lui: wb_wen = 1'b1;
		op_load: wb_wen = 1'b1;
		op_auipc: wb_wen = 1'b1;
		op_jal: wb_wen = 1'b1;
		op_jalr: wb_wen = 1'b1;
		op_reg: wb_wen = 1'b1;
		default : wb_wen = 1'b0;
	endcase
	
	if(mem_wen && mem_reg.rd && (mem_reg.rd == rs1)) forwardmux1_sel = 2'b01;
	
	else if(wb_wen && wb_reg.rd && (wb_reg.rd == rs1)) forwardmux1_sel = 2'b10;
	
	else forwardmux1_sel = 2'b00;
		
	if(mem_wen && mem_reg.rd && (mem_reg.rd == rs2)) forwardmux2_sel = 2'b01;
	
	else if(wb_wen && wb_reg.rd && (wb_reg.rd == rs2)) forwardmux2_sel = 2'b10;
	
	else forwardmux2_sel = 2'b00;
end

endmodule : forwarder