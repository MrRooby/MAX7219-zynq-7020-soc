`timescale 1ns / 1ps

module tb_state_machine;

    // Inputs to the Unit Under Test (UUT)
    reg clk;
    reg [31:0] ascii_data;
    reg [7:0] ctrl_reg;

    // Outputs from the Unit Under Test (UUT)
    wire clk_out;
    wire load;
    wire d_out;

    // Instantiate the Unit Under Test (UUT)
    state_machine uut (
        .clk(clk),
        .ascii_data(ascii_data),
        .ctrl_reg(ctrl_reg),
        .clk_out(clk_out),
        .load(load),
        .d_out(d_out)
    );

    // Clock Generation (100 MHz -> 10ns period)
    always begin
        #5 clk = ~clk;
    end
    
    initial begin
        $dumpfile("state.vcd");
        $dumpvars(0, tb_state_machine);
    end

    initial begin
        // Initialize Inputs
        clk = 0;
        ascii_data = 32'h0;
        ctrl_reg = 8'h0;

        // Wait for global reset / initialization stability
        #100;

        // ---------------------------------------------------------
        // Test Case 1: Trigger ENABLE Sequence
        // ctrl_reg[7:6] = 2'b00 (ENABLE mode), ctrl_reg[0] = 1'b1
        // ---------------------------------------------------------
        #20;
        ctrl_reg = 8'b0000_0001; 
        #20;
        ctrl_reg = 8'h0; // Clear command strobe if needed
        
        #2000; // Allow time for state machine progression (ENABLE -> SEND_CTRL_REG -> WAIT_SEND_SIMPLE)

        // ---------------------------------------------------------
        // Test Case 2: Trigger BRIGHTNESS Change
        // ctrl_reg[7:6] = 2'b01 (BRIGHTNESS mode), ctrl_reg[1:0] = 2'b11 (Value 3)
        // ---------------------------------------------------------
        #20;
        ctrl_reg = 8'b0100_0011; 
        #20;
        ctrl_reg = 8'h0;

        #200;

        // ---------------------------------------------------------
        // Test Case 3: Trigger BLINK_IDX Update
        // ctrl_reg[7:6] = 2'b11 (BLINK_IDX mode), ctrl_reg[1:0] = 2'b10
        // ---------------------------------------------------------
        #20;
        ctrl_reg = 8'b1100_0010;
        #20;
        ctrl_reg = 8'h0;

        #100;

        // ---------------------------------------------------------
        // Test Case 4: Trigger ASCII Translation Sequence
        // ctrl_reg[7:6] = 2'b10 (ASCII mode)
        // ---------------------------------------------------------
        #20;
        ascii_data = 32'h04142434; // Example ASCII packet data
        ctrl_reg = 8'b1000_0000;
        #20;
        ctrl_reg = 8'h0;

        // Note: The duration here depends heavily on the sub-modules 
        // (translator & fifo) asserting ready/busy/packet_valid lines.
        #2000; 

        // Finish simulation
        $display("Simulation finished.");
        $finish;
    end

    // Optional: Monitor output lines for activity in the console
    initial begin
        $monitor("Time = %0t | ctrl_reg = %b | load = %b | clk_out = %b | d_out = %b", 
                 $time, ctrl_reg, load, clk_out, d_out);
    end

endmodule
