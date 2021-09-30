import rv32i_types::*;

package control;
typedef struct packed {
    logic[1:0] pc_mux_select;
    logic load_pc;
    logic mem_read;
    logic mem_write;
    logic[3:0] mem_byte_enable;
    logic load_regfile;
    logic use_predictor;

} if_control_word;

typedef struct packed {
    logic w_en;
    logic [4:0] dest;
    logic load_regfile;
    logic [1:0] adder_mux;
} id_control_word;

typedef struct packed {
    logic alumux1_sel;
    alumux::alumux2_sel_t alumux2_sel;
    rv32i_types::branch_funct3_t cmp_op;
    logic cmp_mux;
	 mulmux::mulmux_sel_t mulmux_sel;
    rv32i_types::alu_ops aluop;
    logic load_regfile;
} exe_control_word;

typedef struct packed {
    logic mar_mux_select;
    logic mem_read;
    logic mem_write;
    logic[3:0] mem_byte_enable;
    logic load_regfile;
} mem_control_word;

typedef struct packed {
    regfilemux::regfilemux_sel_t reg_mux_select;
} wb_control_word;

endpackage : control
