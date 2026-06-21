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
wire [63:0] packet;
wire busy;
wire packet_valid;
wire ready;
reg abort = 1'b0;

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
  .abort(abort),
  .busy(busy)
);

// CTRL register
localparam ENABLE     = 2'b00;
localparam BLINK_IDX  = 2'b11;
localparam BRIGHTNESS = 2'b01;
localparam ASCII      = 2'b10;

// ctrl_reg: [7:6]=opcode, [5]=kick (ARM toggles every write), [1:0]=arg
// Synchronize ctrl_reg into this clock domain (100 MHz AXI -> slow clk here)
reg [7:0] ctrl_s1 = 8'b0;
reg [7:0] ctrl_s2 = 8'b0;
reg [7:0] ctrl_s3 = 8'b0;
always @(posedge clk) begin
  ctrl_s1 <= ctrl_reg;
  ctrl_s2 <= ctrl_s1;
  ctrl_s3 <= ctrl_s2;
end

wire       cmd_valid = ctrl_s2[5] ^ ctrl_s3[5];  // 1 pulse per ARM write
wire [1:0] cmd_op    = ctrl_s2[7:6];
wire [1:0] cmd_arg   = ctrl_s2[1:0];

reg       cmd_pend = 1'b0;   // a captured command is waiting for the engine
reg [1:0] pend_op  = 2'b0;
reg [1:0] pend_arg = 2'b0;

always @(posedge clk) begin
  abort <= 1'b0;                       // default -> guarantees a 1-cycle pulse

  // 1) capture every write; preempt the current frame if one is in flight
  if (cmd_valid) begin
    cmd_pend <= 1'b1;
    pend_op  <= cmd_op;
    pend_arg <= cmd_arg;
    if (busy) begin
      abort       <= 1'b1;
      start_fifo  <= 1'b0;
      start_trans <= 1'b0;
      state       <= IDLE;
    end
  end

  // 2) dispatch once the engine is free (in IDLE, so case(state) won't fight us)
  else if (cmd_pend && !busy && state == IDLE) begin
    cmd_pend <= 1'b0;
    case (pend_op)
      ENABLE     : if (pend_arg[0]) state <= DECODE_OFF;
      BLINK_IDX  : blink_idx <= pend_arg;
      BRIGHTNESS : begin brightness <= pend_arg; state <= BRIGHTNESS_CHANGE; end
      ASCII      : state <= TRANSLATION;
      default    : ;
    endcase
  end

  // 3) frame FSM
  else begin
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
        data <= {4{4'b0000, 4'b1010, 4'b0000, brightness, 2'b00}};
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
end

endmodule
