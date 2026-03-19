`timescale 1ns / 1ps

module tb_Traffic_Light_FSM;

		logic clk;
		logic reset;
		logic TAORB;
		logic [5:0] led;

		Traffic_Light_FSM uut (
        .clk(clk),
        .reset(reset),
        .TAORB(TAORB),
        .led(led)
		);

    
    //100 MHz = 10 nanosecond period. So it toggles every 5 ns.
    always #5 clk = ~clk;


    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        TAORB = 1;

        // Wait 100ns for reset to finish
        #100;
        reset = 0;

        // Stimulate the inputs to simulate transitions
        #15000 TAORB = 0;  // Change TA0RB to trigger a transition
        #15000 TAORB = 1; // Change TA0RB again

        // Further stimulus to check all states
        #15000 TAORB = 0;  // Trigger another transition
        #15000 TAORB = 1;

        // Add more stimulus as needed to test different states
        #15000;

        // Finish the simulation
        $stop;
		  
    end

		// Monitor the current state and input signals
		initial begin
		// synthesis translate_off
        $monitor("Time = %0t | clk = %b | reset = %b | TA0RB = %b | led = %b | timer=%d | state=%b", 
                 $time, clk, reset, TAORB, led, uut.Traffic_Light_FSM.timer, uut.Traffic_Light_FSM.state_reg);
		// synthesis translate_on
		end
		
endmodule
