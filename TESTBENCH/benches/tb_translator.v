module tb_translator;

reg clk;
reg start;
reg [27:0] ascii_data;
reg [2:0] row_idx;

wire [63:0] row_packet;
wire packet_valid;
wire ready;

// reg [6:0] ascii_code;
// wire [7:0] row_data;

translator #(
    .N(4)
) UUT (
    .clk(clk),
    .start(start),
    .row_idx(row_idx),
    .ascii_data(ascii_data),
    .row_packet(row_packet),
    .packet_valid(packet_valid),
    .ready(ready)
);

// font_rom UUT_rom(
//     .clk(clk),
//     .ascii_code(ascii_code),
//     .row_index(row_index),
//     .row_data(row_data)
// );

// Clock generator: flips state every 5ns (10ns period)
always #5 clk = ~clk;

initial begin
    $dumpfile("TESTBENCH/sims/trans.vcd");
    // $dumpvars(0, tb_rom);
    $dumpvars(0, tb_translator);

    clk = 0; 
    ascii_data = {7'h63, 7'h68, 7'h75, 7'h6A};
    start = 0;
    row_idx = 0;

    #10 start = 1;

    repeat(40) begin
        @(posedge clk);
    end

    #20 $finish;
end

// initial begin
//     $monitor("Time=%0t | Row=%d | Data=%h", $time, row_index, row_data);
// end
always @(posedge clk) begin
    $display("Time=%0t | State=%d | idx=%d | row_packet=%h", $time, UUT.state, UUT.idx, row_packet);
end

endmodule