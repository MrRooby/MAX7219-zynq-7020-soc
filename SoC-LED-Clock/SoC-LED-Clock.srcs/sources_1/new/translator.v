`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2026 08:49:38 PM
// Design Name: 
// Module Name: translator
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
module translator #(
    parameter N = 4 // Number of modules
)(
    input              clk,
    input              start,
    input  [(8*N)-1:0] ascii_data,   // 8 bits per character * N modules
    output reg [15:0]  max_packet,   // 16-bit packet to send to SPI engine
    output reg         packet_valid, // Tells SPI engine to transmit
    output reg         ready
);

    // State Machine Encodings
    localparam IDLE      = 2'd0,
               FETCH     = 2'd1,
               TRANSLATE = 2'd2,
               DONE      = 2'd3;

    reg [1:0]         state = IDLE;
    reg [2:0]         row_idx;
    reg [$clog2(N):0] mem_idx; // Tracks which module/character we are processing

    reg  [6:0] ascii_code;
    wire [7:0] row_data;

    // Instantiate Font ROM
    font_rom ascii_rom (
        .clk(clk),
        .ascii_code(ascii_code),
        .row_index(row_idx),
        .row_data(row_data)
    );

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                ready        <= 1'b1;
                packet_valid <= 1'b0;
                row_idx      <= 3'd0;
                mem_idx      <= 0;
                
                if (start) begin
                    ready <= 1'b0;
                    state <= FETCH;
                end
            end

            FETCH: begin
                // Safely extract the target 8-bit ASCII character from the wide input bus
                ascii_code <= ascii_data[(mem_idx * 8) +: 8];
                state      <= TRANSLATE;
            end

            TRANSLATE: begin
                // Assemble standard MAX7219 16-bit packet: {4'b0000, Address(1-8), Data(8-bit)}
                max_packet   <= {4'b0000, (row_idx + 1'b1), row_data};
                packet_valid <= 1'b1; // Strobe to downstream SPI Master
                
                // Sequence control
                if (mem_idx == N - 1) begin
                    mem_idx <= 0;
                    if (row_idx == 3'd7) begin
                        state <= DONE;
                    end else begin
                        row_idx <= row_idx + 1'b1;
                        state   <= FETCH;
                    end
                end else begin
                    mem_idx <= mem_idx + 1'b1;
                    state   <= FETCH;
                end
            end

            DONE: begin
                packet_valid <= 1'b0;
                ready        <= 1'b1;
                state        <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
endmodule
