/* MODIFY. The cache controller. It is a state machine
that controls the behavior of the cache. */
import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module l2_control (
    input logic clk,                // Clock
    input logic rst,                // Reset
    input logic pmem_resp,          // High when pmem finished operation
    output logic mem_resp_cache,    // Mem response signal for cache
    input logic mem_read,           // Input read signal from CPU
    input logic mem_write,          // Input write signal from CPU
    input rv32i_word mem_address,   // CPU memory address
    input logic in_cache,           // Signals if address is already cached
    input logic dirty_overwrite,    // Signals if the cache has a dirty value to write
    output logic from_processor,    // Signals if the data to write is from the CPU
    output logic lru_update,        // Signals if the LRU should be updated
    output logic miss_cache_read,   // Signals if we can read from array that doesnt match tags

    output logic pmem_read,         // Read signal for pmem
    output logic pmem_write,        // Write signal for pmem
    output logic cache_read,        // Read signal for cache
    output logic cache_write        // Write signal for cache

);



enum int unsigned {
    /* List of states */
    PTO, miss_one, read_hit, miss_two, write_hit
} state, next_states;

function void set_defaults();
    mem_resp_cache = 1'b0;
    pmem_read = 1'b0;
    pmem_write = 1'b0;
    cache_read = 1'b0;
    cache_write = 1'b0;
    from_processor = 1'b0;
    lru_update = 1'b0;
    miss_cache_read = 1'b0;
endfunction

// function void loadPC();
// endfunction


    /* Remember to deal with rst signal */

always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    unique case (state)
        PTO: begin
            cache_read = 1'b0;
        end
        miss_one: begin
            if (dirty_overwrite == 1'b1) begin // Dirty needs to be written
                pmem_write = 1'b1;
                cache_read = 1'b1;
                miss_cache_read = 1'b1; // Read from a cache that doesn't match tags
            end
        end
        read_hit: begin
            if (in_cache) begin
                mem_resp_cache = 1'b1;
                cache_read = 1'b1;
                lru_update = 1'b1;
            end
        end
        miss_two: begin
            pmem_read = 1'b1;
            if (pmem_resp == 1'b1) begin
                cache_write = 1'b1;
                pmem_read = 1'b0;
            end
            if (pmem_resp == 1'b1 && mem_read == 1'b1) begin
                mem_resp_cache = 1'b1;
                lru_update = 1'b1;
            end
        end
        write_hit: begin
            if (in_cache) begin
                mem_resp_cache = 1'b1;
                lru_update = 1'b1;
                cache_write = 1'b1;
                from_processor = 1'b1;
            end

        end
    endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
    next_states = state;
    unique case (state)
        PTO: begin
            // This is where things get interesting
            unique case ({mem_write, mem_read, in_cache}) // May have to change if read and write are both high
                3'b010: next_states = read_hit;
                3'b011: next_states = read_hit;
                3'b100: next_states = write_hit;
                3'b101: next_states = write_hit;
                // 3'b010: next_states = miss_one;
                // 3'b011: next_states = read_hit;
                // 3'b100: next_states = miss_one;
                // 3'b101: next_states = write_hit;
                default: next_states = state;
            endcase
        end
        miss_one: begin
            if (dirty_overwrite == 1'b1) begin
                if (pmem_resp == 1'b1) begin
                    next_states = miss_two;
                end
            end else
                next_states = miss_two;
        end
        read_hit: begin
            if (in_cache == 1'b0) begin
                next_states = miss_one;
            end else
            next_states = PTO; // This has to take 2 states max
        end
        miss_two: begin
            if (pmem_resp == 1'b1) begin
                if (mem_read == 1'b1)
                    next_states = PTO;
                else
                    next_states = write_hit;
            end
        end
        write_hit: begin
            if (in_cache == 1'b0) begin
                next_states = miss_one;
            end else
            next_states = PTO; // This has to take 2 states max
        end
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    if (rst == 1'b1) begin
        state <= PTO;
    end else begin
        state <= next_states;
    end
    
end


endmodule : l2_control
