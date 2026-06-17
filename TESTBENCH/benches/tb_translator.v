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

integer r; // Declare variable here

initial begin
    clk = 0;
    // ascii_data = {7'h63, 7'h68, 7'h75, 7'h6A}; 
    // ascii_data = {7'h63, 7'h69, 7'h70, 7'h61}; 
    ascii_data = {7'h64, 7'h75, 7'h70, 7'h61};
    start = 0;
    row_idx = 0;

    for (r = 0; r < 8; r = r + 1) begin
        row_idx = r;
        start = 1;
        #10 start = 0;
        
        // Wait until the translator finishes and sets packet_valid
        wait(packet_valid);
        
        $display("Row %0d Packet: %h", r, row_packet);
        
        // Wait until it drops before starting next row
        @(negedge packet_valid); 
        #10;
    end
    #20 $finish;
end

endmodule