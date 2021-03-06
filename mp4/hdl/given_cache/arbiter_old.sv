module arbiter_old( 
    input logic clk,
    input logic rst,

    /* I-cache */
    input logic icache_read,
    input logic icache_write,
    input logic [31:0] icache_address,
    
    output logic [255:0] icache_data,
    output logic icache_resp,

    /* D-cache */
    input logic [255:0] dcache_data_i,
    input logic dcache_read,
    input logic dcache_write,
    input logic [31:0] dcache_address,
    
    output logic [255:0] dcache_data_o,
    output logic dcache_resp,

    /* Cacheline */
    input logic [255:0] data_o,
    input logic resp_o,

    output logic [255:0] data_i,
    output logic [31:0] address_i,
    output logic read_i,
    output logic write_i
);

enum int unsigned {
    /* List of states */
    idle, icache_ready, dcache_ready
} state, next_states;

function void set_defaults();
    read_i          = 1'b0;
    write_i         = 1'b0;
    address_i       = 32'b0;
    data_i          = 256'b0;
    icache_data   = 256'b0;
    icache_resp   = 1'b0;
    dcache_data_o   = 256'b0;
    dcache_resp   = 1'b0;
endfunction

always_comb begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    unique case (state)
        idle: begin
            // wait for miss
        end         
        icache_ready: begin
            address_i = icache_address;
            read_i = icache_read;
            write_i = icache_write;
            // data_i = 256'b0;
            icache_data = data_o;
            icache_resp = resp_o;
        end 
        dcache_ready: begin
            address_i = dcache_address;
            read_i = dcache_read;
            write_i = dcache_write;
            data_i = dcache_data_i;
            dcache_data_o = data_o;
            dcache_resp = resp_o;
        end
    endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
    unique case (state)
        idle:begin
            if (icache_read)
                next_states = icache_ready;
            else if ((dcache_read || dcache_write) && (icache_read == 0))
                next_states = dcache_ready;
            else
                next_states = idle;
            end
        icache_ready:begin
            if ((dcache_read || dcache_write) && resp_o)
                next_states = dcache_ready;
            else if (~resp_o)
                next_states = icache_ready;
            else
                next_states = idle;
            end
        dcache_ready:begin
            if (resp_o && (icache_read == 0))
                next_states = idle;
            else if (resp_o && (icache_read))
                            next_states = icache_ready;
            else
                            next_states = dcache_ready;
            end
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    if (rst) begin
        state <= idle;
    end
    else begin 
        state <= next_states;
    end
end

endmodule:arbiter_old