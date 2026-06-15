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
  input clk_out,
  input start_trans,
  input [31:0] ascii_data,
  input [63:0] data,
  input start_fifo,

  output ready,
  output packet_valid,
  output [31:0] max_packet,
  output load,
  output d_out,
  output busy
);


translator #(
  .N(4)
) trans (
  .clk(clk),
  .start(start_trans),
  .ascii_data(ascii_data),   // 8 bits per character * N modules
  .max_packet(max_packet),   // 16-bit packet to send to SPI engine
  .packet_valid(packet_valid), // Tells SPI engine to transmit
  .ready(ready)         // ready
);

dot_matrix_fifo #(
  .N(4)                       // number of cascaded MAX7219
) fifo (
  .load(load),                      // CS / LOAD  (idle high)
  .clk_out(clk_out),                   // SCLK       (idle low)
  .d_out(d_out),                     // DIN / MOSI
  .clk_in(clk),           // system clock (e.g. 10 MHz from PLL)
  .start(start_fifo),            // 1-cycle pulse to begin a frame
  .data(data),             // frame: word for each device, MSB-first
  .busy(busy)
);

endmodule
