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
  input [31:0] ascii_data_0,
  input [31:0] ascii_data_1,
  // AXI_GPIO_1
  input [1:0]  blink_idx,
  input [3:0]  ctrl_reg,
  
  output clk_out,
  output load,
  output d_out
);

// Internal Control Decoding Wires
wire start_trans;
wire start_fifo;

// Unpack specific control execution bits from the AXI GPIO register bus
assign start_trans = ctrl_reg[0]; // Bit 0 kicks off translation
assign start_fifo  = ctrl_reg[1]; // Bit 1 drives the FIFO transmission pipeline

// Internal Submodule Core Interconnect Wires
wire [31:0] max_packet;
wire        packet_valid;
wire [63:0] data;
wire        ready;
wire        busy;

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
