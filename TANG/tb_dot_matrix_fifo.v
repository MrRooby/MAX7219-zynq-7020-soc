`timescale 1ns / 1ps
//
// Testbench for the MAX7219 SPI engine.
// Watch load (CS), clk_out (SCLK) and d_out (DIN) in the VCD.
//
//   iverilog -o tb.out tb_dot_matrix_fifo.v dot_matrix_fifo.v
//   vvp tb.out
//   gtkwave tb.vcd
//
module tb_dot_matrix_fifo;

    localparam N = 4;

    reg              clk = 1'b0;
    reg              start = 1'b0;
    reg  [16*N-1:0]  data = 0;
    wire             load, clk_out, d_out, busy;

    dot_matrix_fifo #(.N(N)) dut (
        .load   (load),
        .clk_out(clk_out),
        .d_out  (d_out),
        .clk_in (clk),
        .start  (start),
        .data   (data),
        .busy   (busy)
    );

    // 10 MHz system clock -> 100 ns period (matches the PLL output)
    always #50 clk = ~clk;

    // send one full N*16-bit frame and wait for it to complete
    task send_frame(input [16*N-1:0] frame);
        begin
            @(posedge clk);
            data  <= frame;
            start <= 1'b1;
            @(posedge clk);
            start <= 1'b0;
            wait (busy);     // engine accepted the request
            wait (!busy);    // frame + LOAD latch done
            @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb_dot_matrix_fifo);

        repeat (4) @(posedge clk);

        // ---- required init frames (this is why real displays light up) ----
        send_frame({N{16'h0C01}});  // shutdown -> normal operation
        send_frame({N{16'h0B07}});  // scan limit -> all 8 rows
        send_frame({N{16'h0A0F}});  // intensity -> max
        send_frame({N{16'h0F00}});  // display test -> off

        // ---- your two packages ----
        send_frame({N{16'h0900}});  // package 1: decode off on all displays
        send_frame({N{16'h01FF}});  // package 2: light a line (digit0 = 0xFF)

        repeat (40) @(posedge clk);
        $display("Simulation finished.");
        $finish;
    end

    // text log of CS / SCLK / DIN transitions for quick inspection
    initial $monitor("t=%0t  CS=%b SCLK=%b DIN=%b busy=%b", $time, load, clk_out, d_out, busy);

endmodule
