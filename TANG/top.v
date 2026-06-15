// MAX7219 16-bit word:  [15:12] don't care | [11:8] register addr | [7:0] data
//   0x0C -> 0x01  shutdown register = normal operation  (REQUIRED to light)
//   0x09 -> 0x00  decode mode       = no decode (raw segments)
//   0x0B -> 0x07  scan limit        = all 8 rows         (REQUIRED to show rows)
//   0x0A -> 0x0F  intensity         = max
//   0x0F -> 0x00  display test      = off
//   0x01 -> 0xFF  digit 0           = all 8 LEDs on  ("a line")
module top(
    input  clk,

    output load,        // CS  to all displays
    output d_out,       // DIN to first display
    output clk_out      // CLK to all displays
);

    localparam N = 4;   // number of cascaded MAX7219 modules

    wire clk_10MHz;
    wire pll_locked;

    pll my_pll (
        .clock_in (clk),
        .clock_out(clk_10MHz),
        .locked   (pll_locked)
    );

    reg              start = 1'b0;
    reg  [16*N-1:0]  data  = 0;
    wire             busy;

    dot_matrix_fifo #(.N(N)) fifo_out (
        .load   (load),
        .clk_out(clk_out),
        .d_out  (d_out),
        .clk_in (clk_10MHz),
        .start  (start),
        .data   (data),
        .busy   (busy)
    );

    // ---- command sequence (each word is broadcast to all N devices) ----
    // Digit registers power up with random data, so ALL 8 must be written
    // explicitly: digit 0 = the lit line, digits 1-7 = cleared to 0x00.
    localparam NUM_CMDS = 13;
    reg [3:0]  idx = 0;
    reg [15:0] cmd;

    always @(*) begin
        case (idx)
            4'd0:  cmd = 16'h0C01; // shutdown   -> normal operation
            4'd1:  cmd = 16'h0900; // decode mode-> off
            4'd2:  cmd = 16'h0B07; // scan limit -> all 8 rows
            4'd3:  cmd = 16'h0A0F; // intensity  -> max
            4'd4:  cmd = 16'h0F00; // display test -> off
            4'd5:  cmd = 16'h01FF; // digit 0 -> all LEDs on (a line)
            4'd6:  cmd = 16'h0200; // digit 1 -> off
            4'd7:  cmd = 16'h0300; // digit 2 -> off
            4'd8:  cmd = 16'h0400; // digit 3 -> off
            4'd9:  cmd = 16'h0500; // digit 4 -> off
            4'd10: cmd = 16'h0600; // digit 5 -> off
            4'd11: cmd = 16'h0700; // digit 6 -> off
            4'd12: cmd = 16'h0800; // digit 7 -> off
            default: cmd = 16'h0000;
        endcase
    end

    localparam S_LOAD = 2'd0,
               S_KICK = 2'd1,
               S_WAIT = 2'd2,
               S_DONE = 2'd3;
    reg [1:0] state = S_LOAD;

    always @(posedge clk_10MHz) begin
        if (!pll_locked) begin
            state <= S_LOAD;
            idx   <= 0;
            start <= 1'b0;
        end else begin
            case (state)
                S_LOAD: begin               // present current command to all devices
                    data  <= {N{cmd}};
                    start <= 1'b1;          // request a transfer
                    state <= S_KICK;
                end
                S_KICK: begin
                    start <= 1'b0;          // keep start a 1-cycle pulse
                    if (busy) state <= S_WAIT;
                end
                S_WAIT: begin               // wait for the frame to finish
                    if (!busy) begin
                        if (idx == NUM_CMDS-1)
                            state <= S_DONE;
                        else begin
                            idx   <= idx + 1'b1;
                            state <= S_LOAD;
                        end
                    end
                end
                S_DONE: state <= S_DONE;    // all commands sent; hold display
            endcase
        end
    end
endmodule
