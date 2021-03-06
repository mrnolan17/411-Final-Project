import rv32i_types::*;

package regfile;

typedef struct packed {
    rv32i_types::rv32i_opcode opcode;
    logic[2:0] funct3;
    logic[6:0] funct7;
    rv32i_types::rv32i_reg rs1;
    rv32i_types::rv32i_reg rs2;
    rv32i_types::rv32i_reg rd;
    rv32i_types::rv32i_word i_imm;
    rv32i_types::rv32i_word u_imm;
    rv32i_types::rv32i_word b_imm;
    rv32i_types::rv32i_word s_imm;
    rv32i_types::rv32i_word j_imm;

    rv32i_types::rv32i_word pc;
    logic prediction;
    logic[3:0] all_prediction;
} if_id_regfile;

typedef struct packed {
    rv32i_types::rv32i_opcode opcode;
    logic[2:0] funct3;
    logic[6:0] funct7;
    rv32i_types::rv32i_reg rs1;
    rv32i_types::rv32i_reg rs2;
    rv32i_types::rv32i_reg rd;
    rv32i_types::rv32i_word i_imm;
    rv32i_types::rv32i_word u_imm;
    rv32i_types::rv32i_word b_imm;
    rv32i_types::rv32i_word s_imm;
    rv32i_types::rv32i_word j_imm;

    rv32i_types::rv32i_word pc;
    rv32i_types::rv32i_word rs1_out;
    rv32i_types::rv32i_word rs2_out;
    logic prediction;
    logic[3:0] all_prediction;

} id_exe_regfile;

typedef struct packed {
    rv32i_types::rv32i_opcode opcode;
    logic[2:0] funct3;
    logic[6:0] funct7;
    rv32i_types::rv32i_reg rs1;
    rv32i_types::rv32i_reg rs2;
    rv32i_types::rv32i_reg rd;
    rv32i_types::rv32i_word i_imm;
    rv32i_types::rv32i_word u_imm;
    rv32i_types::rv32i_word b_imm;
    rv32i_types::rv32i_word s_imm;
    rv32i_types::rv32i_word j_imm;

    rv32i_types::rv32i_word pc;
    rv32i_types::rv32i_word rs1_out;
    rv32i_types::rv32i_word rs2_out;
    rv32i_types::rv32i_word alu_out;
    logic br_en;
    logic prediction;
    logic[3:0] all_prediction;

} exe_mem_regfile;

typedef struct packed {
    rv32i_types::rv32i_opcode opcode;
    logic[2:0] funct3;
    logic[6:0] funct7;
    rv32i_types::rv32i_reg rs1;
    rv32i_types::rv32i_reg rs2;
    rv32i_types::rv32i_reg rd;
    rv32i_types::rv32i_word i_imm;
    rv32i_types::rv32i_word u_imm;
    rv32i_types::rv32i_word b_imm;
    rv32i_types::rv32i_word s_imm;
    rv32i_types::rv32i_word j_imm;

    rv32i_types::rv32i_word pc;
    rv32i_types::rv32i_word rs1_out;
    rv32i_types::rv32i_word rs2_out;
    rv32i_types::rv32i_word alu_out;
    rv32i_types::rv32i_word mem_rdata;
    logic br_en;
    logic prediction;
    logic[3:0] all_prediction;
    
    logic[3:0] mem_byte_enable;

} mem_wb_regfile;


endpackage : regfile
