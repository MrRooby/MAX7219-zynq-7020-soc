`timescale 1ns / 1ps

module translator #(
    parameter N = 4 // Number of modules
)(
    input             clk,
    input             start,
    input [N-1:0][6:0] ascii_data,   // 7 bits per character * N modules
    input [2:0]       row_idx,
    
    output reg [(16*N)-1:0] row_packet,   // 16-bit packet to send to SPI engine
    output reg        packet_valid, // Tells SPI engine to transmit
    output reg        ready
);

    // State Machine Encodings
    localparam IDLE     = 3'd0;
    localparam FETCH    = 3'd1;
    localparam DONE     = 3'd2;
    localparam WAIT_ROM = 3'd3;
    localparam STORE    = 3'd4;

    reg [2:0] state       = IDLE;
    reg [6:0] ascii_code  = 7'b0;
    reg [$clog2(N):0] idx = 0;
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
                ascii_code   <= 7'b0;
                idx          <= 1'b0;
                
                if (start) begin
                    ready <= 1'b0;
                    state <= FETCH;
                end
            end

            FETCH: begin
                ascii_code   <= ascii_data[idx];
                state        <= WAIT_ROM;
            end
            
            WAIT_ROM: begin
                state <= STORE;
            end
            
            STORE: begin
                // MAX7219 digit registers are 1..8, so address = row_idx + 1
                row_packet[(N-1-idx)*16+:16] <= {4'b0000, ({1'b0, row_idx} + 4'd1), row_data};
                idx <= idx + 1'b1;   
                state <= (idx == N-1) ? DONE : FETCH;
                if (idx == N-1) begin
                    state <= DONE;
                    idx <= 0;
                end else begin
                    idx <= idx + 1;
                    state <= FETCH;
                end
            end

            DONE: begin
                ready        <= 1'b1;
                packet_valid <= 1'b1;
                state        <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
endmodule
