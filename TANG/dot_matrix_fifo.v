// SPI shift-out engine for cascaded MAX7219 displays.
//
// MAX7219 protocol:
//   - 16-bit words, MSB (D15) first.
//   - DIN is sampled on the RISING edge of CLK, so DIN must be set while
//     CLK is low and held across the rising edge.
//   - For N cascaded devices you shift N*16 bits with LOAD/CS held LOW,
//     then a RISING edge on LOAD/CS latches all words at once.
//
// Usage: put the full N*16-bit frame on `data`, pulse `start` for one
// clk_in cycle while `busy` is 0. `busy` stays high until the frame
// (and the LOAD latch pulse) is complete.
module dot_matrix_fifo #(
    parameter N = 4                       // number of cascaded MAX7219
)(
    output reg load,                      // CS / LOAD  (idle high)
    output reg clk_out,                   // SCLK       (idle low)
    output reg d_out,                     // DIN / MOSI

    input               clk_in,           // system clock (e.g. 10 MHz from PLL)
    input               start,            // 1-cycle pulse to begin a frame
    input  [(16*N)-1:0] data,             // frame: word for each device, MSB-first
    input               abort,            // 1-cycle pulse: drop current frame, return to IDLE

    output reg          busy
);
    localparam TOTAL_BITS = 16 * N;

    localparam IDLE  = 2'd0,
               SHIFT = 2'd1,
               LATCH = 2'd2;

    reg [1:0]                  state   = IDLE;
    reg [TOTAL_BITS-1:0]       shreg   = 0;
    reg [$clog2(TOTAL_BITS):0] bit_cnt = 0;
    reg                        phase   = 1'b0; // 0 = SCLK low (set data), 1 = SCLK high (sample)

    always @(posedge clk_in) begin
        // Abort: stop shifting immediately and release CS high. We do NOT latch
        // a partial frame as a valid one. Note: the MAX7219 shift register is
        // free-running, so any residual bits are harmless as long as the next
        // transfer clocks a full 16*N bits before LOAD -- which the state
        // machine always does.
        if (abort) begin
            load    <= 1'b1;
            clk_out <= 1'b0;
            d_out   <= 1'b0;
            busy    <= 1'b0;
            phase   <= 1'b0;
            bit_cnt <= TOTAL_BITS[$clog2(TOTAL_BITS):0];
            state   <= IDLE;
        end else
        case (state)
            IDLE: begin
                load    <= 1'b1;          // CS idle high
                clk_out <= 1'b0;          // SCLK idle low
                d_out   <= 1'b0;
                busy    <= 1'b0;
                phase   <= 1'b0;
                bit_cnt <= TOTAL_BITS[$clog2(TOTAL_BITS):0];
                if (start) begin
                    shreg <= data;
                    busy  <= 1'b1;
                    load  <= 1'b0;        // pull CS low to begin the frame
                    state <= SHIFT;
                end
            end

            SHIFT: begin
                if (phase == 1'b0) begin
                    // setup half-bit: SCLK low, present MSB on DIN
                    clk_out <= 1'b0;
                    d_out   <= shreg[TOTAL_BITS-1];
                    phase   <= 1'b1;
                end else begin
                    // sample half-bit: rising edge of SCLK clocks DIN in
                    clk_out <= 1'b1;
                    shreg   <= {shreg[TOTAL_BITS-2:0], 1'b0};
                    phase   <= 1'b0;
                    bit_cnt <= bit_cnt - 1'b1;
                    if (bit_cnt == 1)
                        state <= LATCH;
                end
            end

            LATCH: begin
                clk_out <= 1'b0;          // bring SCLK low first
                load    <= 1'b1;          // rising edge on CS latches all words
                busy    <= 1'b0;
                state   <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
endmodule
