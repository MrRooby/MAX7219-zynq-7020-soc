`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2026 02:15:52 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module top(
  input clk,

  // AXI_GPIO_0
  input [31:0] ascii_data,
  input [7:0]  ctrl_reg,
  
  output clk_out,
  output load,
  output d_out
);

state_machine main(
  .clk(clk),
  .ascii_data(ascii_data),
  .ctrl_reg(ctrl_reg),
  .clk_out(clk_out),
  .load(load),
  .d_out(d_out)
);

endmodule
