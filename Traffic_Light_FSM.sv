`timescale 1ns / 1ps 

module Traffic_Light_FSM (
    input logic clk,  // Clock 
    input logic reset,  // Reset
    input logic TAORB, // Traffic on A (1) or on B (0)
    output logic [5:0] led // Light bits
);

    // State encoding
    typedef enum logic [1:0] {
        GREENRED = 2'b00,  // Green for A, Red for B
        YELLOWRED = 2'b01, // Yellow for A, Red for B
        REDGREEN = 2'b10,  // Red for A, Green for B
        REDYELLOW = 2'b11  // Red for A, Yellow for B
    } state_t;

    // State variables
    state_t state_reg, state_next;
    
	 // Internal timer to hold the 5 seconds
    logic [2:0] timer;

    // 1-Second Divider Registers
    logic [26:0] r_count = 0; 

    // Sequential logic for state transition
    always_ff @(posedge clk or posedge reset) begin
			if (reset) begin
				r_count   <= 27'b0; // 100MHz clock counter reset
            state_reg <= GREENRED;  // Reset to initial state
				timer     <= 3'd0;
			end
			else begin
            // 1. Update the FSM state
            state_reg <= state_next;
            
            // 2. Counter and Timer logic ONLY runs during yellow states
            if (state_reg == YELLOWRED || state_reg == REDYELLOW) begin      
                // Advance the 100MHz counter
                if (r_count < 99) begin  //originally 99999999 which is 1 second made it 1 microsecond to show better in test
                    r_count <= r_count + 1;
                end 
					 else begin
                    r_count <= 27'b0;
                    timer   <= timer + 3'd1;
                end
            end 
				
				else begin
                // Light is Green or Red: Keep ALL timers and counters at 0
                r_count <= 27'b0;
                timer   <= 3'd0; 
				end
        end
    end

    // Combinational logic for state transition and LED control
    always_comb begin
        // Default assignments
        state_next = state_reg;
        led = 6'b001100;  // Default state: Green for A, Red for B

        case (state_reg)
            GREENRED: begin
                if (!TAORB) begin
                    state_next = YELLOWRED;
                    led = 6'b010100; // Yellow for A, Red for B
                end
                else begin
                    state_next = GREENRED;
                    led = 6'b001100; // Green for A, Red for B (stay in GREENRED)
                end
            end
            YELLOWRED: begin
					// DESIGN NOTE: TAORB is deliberately ignored in this state. 
               // For safety, once a yellow light phase begins, the FSM must lock 
               // and complete its full 5-second sequence before transitioning. 
               // Canceling a yellow transition early would cause erratic, unsafe lights.
					if (timer >= 3'd5) begin 
						state_next = REDGREEN;
						led = 6'b100001; // Red for A, Green for B
					end
					else begin
						state_next = YELLOWRED;
						led = 6'b010100; // Yellow for A, Red for B
					end
            end
            REDGREEN: begin
                if (TAORB) begin
                    state_next = REDYELLOW;
                    led = 6'b100010; // Red for A, Yellow for B
                end
                else begin
                    state_next = REDGREEN;
                    led = 6'b100001; // Red for A, Green for B (stay in REDGREEN)
                end
            end
            REDYELLOW: begin
					// DESIGN NOTE: TAORB is deliberately ignored in this state. 
					// For safety, once a yellow light phase begins, the FSM must lock 
               // and complete its full 5-second sequence before transitioning. 
               // Canceling a yellow transition early would cause erratic, unsafe lights.
					if (timer >= 3'd5) begin
						state_next = GREENRED;
						led = 6'b001100; // Green for A, Red for B
					end
					else begin
                    state_next = REDYELLOW;
                    led = 6'b100010; // Red for A, Yellow for B
               end
				end
            default: state_next = GREENRED; // Default state in case of invalid behavior
        endcase
    end
endmodule