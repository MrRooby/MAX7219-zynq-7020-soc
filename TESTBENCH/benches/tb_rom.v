module tb_rom;

reg clk;
reg [6:0] ascii_code;
reg [2:0] row_index;
wire [7:0] row_data;

font_rom UUT(
    .clk(clk),
    .ascii_code(ascii_code),
    .row_index(row_index),
    .row_data(row_data)
);

// Clock generator: flips state every 5ns (10ns period)
always #5 clk = ~clk;

initial begin
    $dumpfile("rom.vcd");
    $dumpvars(0, tb_rom);

    clk = 0; 
    ascii_code = 7'h61; 
    row_index = 3'd0;

    repeat(40) begin
        @(posedge clk);
        row_index <= row_index + 1;
    end

    #20 $finish;
end

initial begin
    $monitor("Time=%0t | Row=%d | Data=%h", $time, row_index, row_data);
end

endmodule