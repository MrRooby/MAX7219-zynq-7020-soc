`timescale 1ns / 1ps

module state_machine(
  input clk,

  // AXI_GPIO_0
  input [31:0] ascii_data,
  input [7:0]  ctrl_reg,
  
  output clk_out,
  output load,
  output d_out
);

localparam IDLE              = 4'd1;
localparam DECODE_OFF        = 4'd2;
localparam SEND_CTRL_REG     = 4'd3;
localparam WAIT_SEND_SIMPLE  = 4'd4;
localparam START_SEND        = 4'd5;
localparam STEP_ROW          = 4'd6;
localparam START_TRANSLATION = 4'd7;
localparam WAIT_TRANS        = 4'd8;
localparam TRANSLATION       = 4'd9;
localparam BRIGHTNESS_CHANGE = 4'd10;

reg [3:0] state = IDLE;

reg [1:0] brightness = 2'b1;
reg [1:0] blink_idx;
reg [3:0] row_idx = 4'b0;
reg start_fifo;
reg start_trans   = 0;
reg [63:0] data = 64'b0;
wire busy;
wire packet_valid;
wire ready;

translator #(
  .N(4)
) trans (
  .clk(clk),
  .start(start_trans),
  .ascii_data(ascii_data[27:0]),  // 7 bits per character * N modules
  .row_idx(row_idx[2:0]),       // which font row to fetch
  .row_packet(packet),          // 16-bit packet to send to SPI engine
  .packet_valid(packet_valid),  // Tells SPI engine to transmit
  .ready(ready)                 // ready
);

dot_matrix_fifo #(
  .N(4)                         // number of cascaded MAX7219
) fifo (
  .load(load),                  // CS / LOAD  (idle high)
  .clk_out(clk_out),            // SCLK       (idle low)
  .d_out(d_out),                // DIN / MOSI
  .clk_in(clk),                 // system clock (e.g. 10 MHz from PLL)
  .start(start_fifo),           // 1-cycle pulse to begin a frame
  .data(data),                  // frame: word for each device, MSB-first 16bit * N
  .busy(busy)
);

// CTRL register
localparam ENABLE     = 2'b00;
localparam BLINK_IDX  = 2'b11;
localparam BRIGHTNESS = 2'b01;
localparam ASCII      = 2'b10;

reg [7:0] prev_ctrl_val = 8'b11;

always @(posedge clk) begin
  prev_ctrl_val <= ctrl_reg;

  if (!busy && prev_ctrl_val != ctrl_reg) begin
    case (ctrl_reg[7:6])
      ENABLE : begin
        if (ctrl_reg[0]) begin
          state <= DECODE_OFF;
        end else begin
        end
      end

      BLINK_IDX: begin
        blink_idx <= ctrl_reg[1:0];
      end

      BRIGHTNESS: begin
        state <= BRIGHTNESS_CHANGE;
      end

      ASCII : begin
        state <= TRANSLATION;
      end

      default : ;
    endcase
  end

    case (state)
      IDLE : begin
        start_fifo <= 0;
      end

      // Turning off decoding 
      DECODE_OFF : begin
        data  <= {4{16'b0000_1001_0000_0000}};
        state <= SEND_CTRL_REG;
        start_fifo <= 1;
      end

      BRIGHTNESS_CHANGE : begin
        data <= {4{4'b0000, 4'b1010, 4'b0000, ctrl_reg[1:0], 2'b00}};
        state <= SEND_CTRL_REG;
        start_fifo <= 1;
      end

      SEND_CTRL_REG : begin
        start_fifo <= 0;
        if (busy) state <= SEND_CTRL_REG;
        else begin
          state <= WAIT_SEND_SIMPLE;
        end
      end

      WAIT_SEND_SIMPLE : begin
        if (busy) state <= WAIT_SEND_SIMPLE;
        else state <= IDLE;
      end
      
      // ASCII data send and translation
      TRANSLATION : begin
        row_idx     <= 0;
        start_trans <= 0;
        state <= START_TRANSLATION;
      end

      START_TRANSLATION : begin
        start_trans <= 1;
        if (packet_valid && ready) begin
          state       <= START_SEND;
          start_trans <= 0;
        end else begin 
          state <= START_TRANSLATION;
        end
      end
      
      START_SEND : begin
        start_fifo <= 1'b1;
        data <= packet;
        state <= WAIT_TRANS;
      end

      WAIT_TRANS: begin
        start_fifo <= 1'b0;
        if (busy) begin
          state <= WAIT_TRANS;
        end else begin
          state <= STEP_ROW;
        end
      end

      STEP_ROW : begin
        if (row_idx == 7) begin
          state <= IDLE;
        end else begin
          row_idx <= row_idx + 1;
          state <= START_TRANSLATION;
        end
      end
      
      default: state <= IDLE;
    endcase
end

endmodule
