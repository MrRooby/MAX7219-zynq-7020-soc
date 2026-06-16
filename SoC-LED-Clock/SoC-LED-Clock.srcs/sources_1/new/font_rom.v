`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2026 08:59:07 PM
// Design Name: 
// Module Name: font_rom
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
module font_rom (
    input clk,
    input      [6:0] ascii_code,
    input      [2:0] row_index,
    output reg [7:0] row_data
);

    reg [63:0] full_char;

    // Map ASCII codes to 64-bit character bitmaps (8x8 grid)
    always @(*) begin
        case (ascii_code)
            // Numbers (0x30 - 0x39)
            7'h30: full_char = 64'h003C666E76663C00; // 0
            7'h31: full_char = 64'h0018381818183C00; // 1
            7'h32: full_char = 64'h003C66060C30607E; // 2
            7'h33: full_char = 64'h003C66061C06663C; // 3
            7'h34: full_char = 64'h000C1C2C4C7E0C0C; // 4
            7'h35: full_char = 64'h007E607C0606663C; // 5
            7'h36: full_char = 64'h003C607C6666663C; // 6
            7'h37: full_char = 64'h007E060C10202020; // 7
            7'h38: full_char = 64'h003C66663C66663C; // 8
            7'h39: full_char = 64'h003C66663E060C38; // 9

            // Symbols
            7'h3A: full_char = 64'h0000181800181800; // :

            // Lowercase English Letters (0x61 - 0x7A)
            7'h61: full_char = 64'h00003C063E663A00; // a
            7'h62: full_char = 64'h60607C6666667C00; // b
            7'h63: full_char = 64'h00003C6260623C00; // c
            7'h64: full_char = 64'h06063E6666663E00; // d
            7'h65: full_char = 64'h00003C667E603C00; // e
            7'h66: full_char = 64'h1C24207C20202000; // f
            7'h67: full_char = 64'h00003E66663E063C; // g
            7'h68: full_char = 64'h60607C6666666600; // h
            7'h69: full_char = 64'h1800181818183C00; // i
            7'h6A: full_char = 64'h0C000C0C0C0C3C1C; // j
            7'h6B: full_char = 64'h6060666C786C6600; // k
            7'h6C: full_char = 64'h3010101010101E00; // l
            7'h6D: full_char = 64'h00006C5656565600; // m
            7'h6E: full_char = 64'h0000786464646400; // n
            7'h6F: full_char = 64'h00003C6666663C00; // o
            7'h70: full_char = 64'h00007C66667C6060; // p
            7'h71: full_char = 64'h00003E66663E0606; // q
            7'h72: full_char = 64'h00006C7260606000; // r
            7'h73: full_char = 64'h00003C603C063C00; // s
            7'h74: full_char = 64'h00107C1010100C00; // t
            7'h75: full_char = 64'h0000666666663E00; // u
            7'h76: full_char = 64'h00006666663C1800; // v
            7'h77: full_char = 64'h000066666E7E3600; // w
            7'h78: full_char = 64'h0000663C183C6600; // x
            7'h79: full_char = 64'h000066663E063C30; // y
            7'h7A: full_char = 64'h00007E0C18307E00; // z

            default: full_char = 64'h0000000000000000; // Space / Blank
        endcase
    end

    // Extract the requested 8-bit row slice from the 64-bit configuration
    always @(posedge clk) begin
        case (row_index)
            3'd0: row_data <= full_char[63:56];
            3'd1: row_data <= full_char[55:48];
            3'd2: row_data <= full_char[47:40];
            3'd3: row_data <= full_char[39:32];
            3'd4: row_data <= full_char[31:24];
            3'd5: row_data <= full_char[23:16];
            3'd6: row_data <= full_char[15:8];
            3'd7: row_data <= full_char[7:0];
            default: row_data <= 8'b00000000;
        endcase
    end

endmodule
