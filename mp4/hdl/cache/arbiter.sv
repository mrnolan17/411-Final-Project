module arbiter( 
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
    // input logic [255:0] data_o,
    // input logic resp_o,

    // output logic [255:0] data_i,
    // output logic [31:0] address_i,
    // output logic read_i,
    // output logic write_i

    /* L2 Cache */
    input logic [255:0] l2_cache_rdata,
    output logic [255:0] l2_cache_wdata,
    output logic [31:0] l2_cache_address,
    output logic l2_cache_write,
    output logic l2_cache_read,
    input logic l2_cache_resp

);

enum int unsigned {
    /* List of states */
    idle, icache_ready, dcache_ready
} state, next_states;

function void set_defaults();
    l2_cache_read          = 1'b0;
    l2_cache_write         = 1'b0;
    l2_cache_address       = 32'b0;
    l2_cache_wdata          = 256'b0;
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
            l2_cache_address = icache_address;
            l2_cache_read = icache_read;
            l2_cache_write = icache_write;
            // l2_cache_wdata = 256'b0;
            icache_data = l2_cache_rdata;
            icache_resp = l2_cache_resp;
        end 
        dcache_ready: begin
            l2_cache_address = dcache_address;
            l2_cache_read = dcache_read;
            l2_cache_write = dcache_write;
            l2_cache_wdata = dcache_data_i;
            dcache_data_o = l2_cache_rdata;
            dcache_resp = l2_cache_resp;
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
            if ((dcache_read || dcache_write) && l2_cache_resp)
                next_states = dcache_ready;
            else if (~l2_cache_resp)
                next_states = icache_ready;
            else
                next_states = idle;
            end
        dcache_ready:begin
            if (l2_cache_resp && (icache_read == 0))
                next_states = idle;
            else if (l2_cache_resp && (icache_read))
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

endmodule:arbiter