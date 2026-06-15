module ZD_TEST(LED, SW, PB_C, PB_U, PB_D, PB_R, PB_L);
output [7:0] LED;
input [7:0] SW;
input PB_C, PB_U, PB_D, PB_R, PB_L;

wire [7:0] PB = {3'b000, PB_C, PB_U, PB_D, PB_R, PB_L};

assign LED = SW ^ PB;

endmodule
