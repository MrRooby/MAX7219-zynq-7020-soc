`timescale 1ns / 1ps

// -------------------------------------------------------------------------
// Testbench for state_machine.v
//
// Mirrors how the ARM firmware (ARM_CORE/arm_application/display.h + config.h)
// actually drives the PL through the two AXI-GPIO registers:
//
//   ASCII_REG  : 4 glyphs * 7 bit, packed by PACK4(c0,c1,c2,c3)
//   CTRL_REG   : [7:6] op | [5] kick | [1:0] arg
//
// The PL detects a new command only when the "kick" bit (bit 5) TOGGLES
// (see state_machine.v: cmd_valid = ctrl_s2[5] ^ ctrl_s3[5]). The firmware
// flips that bit on every display_cmd(), so this TB does the same via the
// display_cmd task instead of just writing a raw value like the old version.
// -------------------------------------------------------------------------

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

    // ---- CTRL_REG opcodes (must match config.h / state_machine.v) ----------
    localparam [1:0] CTRL_ENABLE     = 2'b00; // arg[0]=1 -> init / no-decode
    localparam [1:0] CTRL_BRIGHTNESS = 2'b01; // arg = level 0..3
    localparam [1:0] CTRL_ASCII      = 2'b10; // render packed ASCII_REG glyphs
    localparam [1:0] CTRL_BLINK      = 2'b11; // arg -> blink_idx

    // "kick" bit mirror of firmware's static display_kick
    reg display_kick = 1'b0;

    // Clock Generation (100 MHz -> 10ns period)
    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("state.vcd");
        $dumpvars(0, tb_state_machine);
    end

    // -------------------------------------------------------------------
    // display_cmd(op, arg) - faithful model of firmware display_cmd():
    //   display_kick ^= 1;
    //   CTRL_REG = op | (display_kick << 5) | (arg & 3);
    // CTRL_REG keeps its value between commands (just like the AXI register).
    // -------------------------------------------------------------------
    task display_cmd(input [1:0] op, input [1:0] arg);
        begin
            @(posedge clk);
            display_kick = ~display_kick;
            ctrl_reg = {op, display_kick, 3'b000, arg};
        end
    endtask

    // -------------------------------------------------------------------
    // display_send(c0,c1,c2,c3) - model of firmware display_send():
    //   pack glyphs with PACK4, write ASCII_REG, then kick a CTRL_ASCII render.
    //   PACK4: c0->bits[6:0], c1->[13:7], c2->[20:14], c3->[27:21]
    // -------------------------------------------------------------------
    task display_send(input [6:0] c0, input [6:0] c1,
                      input [6:0] c2, input [6:0] c3);
        begin
            @(posedge clk);
            ascii_data = {4'b0, c3, c2, c1, c0};
            display_cmd(CTRL_ASCII, 2'b00);
        end
    endtask

    initial begin
        // Initialize Inputs
        clk = 0;
        ascii_data = 32'h0;
        ctrl_reg = 8'h0;

        #50;

        // ---------------------------------------------------------
        // Test Case 1: display_init() sequence
        //   display_cmd(CTRL_ENABLE, 1)  -> DECODE_OFF, send no-decode frame
        //   display_set_brightness(1)    -> BRIGHTNESS_CHANGE, send frame
        // Each control frame is one 64-bit SPI frame (~1.3us). Wait for it.
        // ---------------------------------------------------------
        $display("[%0t] TC1: display_init (enable no-decode + brightness)", $time);
        display_cmd(CTRL_ENABLE, 2'b01);
        #4000;
        display_cmd(CTRL_BRIGHTNESS, 2'b01);
        #4000;

        // ---------------------------------------------------------
        // Test Case 2: brightness sweep 0..3
        // ---------------------------------------------------------
        $display("[%0t] TC2: brightness sweep", $time);
        display_cmd(CTRL_BRIGHTNESS, 2'b00);
        #4000;
        display_cmd(CTRL_BRIGHTNESS, 2'b11);
        #4000;

        // ---------------------------------------------------------
        // Test Case 3: BLINK_IDX update (no SPI frame, just latches blink_idx)
        // ---------------------------------------------------------
        $display("[%0t] TC3: blink index update", $time);
        display_cmd(CTRL_BLINK, 2'b10);
        #1000;

        // ---------------------------------------------------------
        // Test Case 4: ASCII render of "1234" (drives the translator +
        // 8 SPI frames, one per font row). This is the long sequence.
        // ---------------------------------------------------------
        $display("[%0t] TC4: render glyphs 1 2 3 4", $time);
        display_send("1", "2", "3", "4");
        #20000;

        // ---------------------------------------------------------
        // Test Case 5: a second render with different content
        // ---------------------------------------------------------
        $display("[%0t] TC5: render glyphs 1 2 : 5 9", $time);
        display_send("1", "2", "5", "9");
        #20000;

        // ---------------------------------------------------------
        // Test Case 6: preemption - kick a brightness command while an
        // ASCII render is still in flight (firmware can do this from IRQ).
        // The FSM should abort the current frame and service the new cmd.
        // ---------------------------------------------------------
        $display("[%0t] TC6: preempt mid-render", $time);
        display_send("8", "8", "8", "8");
        #3000;                       // let it get a few rows in...
        display_cmd(CTRL_BRIGHTNESS, 2'b10);  // ...then preempt
        #6000;

        // Finish simulation
        $display("[%0t] Simulation finished.", $time);
        $finish;
    end

    // Optional: Monitor output lines for activity in the console
    initial begin
        $monitor("Time = %0t | ctrl_reg = %b | load = %b | clk_out = %b | d_out = %b",
                 $time, ctrl_reg, load, clk_out, d_out);
    end

endmodule
