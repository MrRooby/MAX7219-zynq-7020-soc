`timescale 1ns / 1ps

module clock_div(
    input  wire clk_100mhz,
    input  wire rst,
    output reg  clk_en_10mhz
);

    reg [3:0] counter;

    always @(posedge clk_100mhz or posedge rst) begin
        if (rst) begin
            counter      <= 4'd0;
            clk_en_10mhz <= 1'b0;
        end else begin
            if (counter == 4'd9) begin
                counter      <= 4'd0;
                clk_en_10mhz <= 1'b1;
            end else begin
                counter      <= counter + 1'b1;
                clk_en_10mhz <= 1'b0;
            end
        end
    end

endmodule
