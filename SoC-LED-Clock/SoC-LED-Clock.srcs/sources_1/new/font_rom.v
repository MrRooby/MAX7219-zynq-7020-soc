`timescale 1ns / 1ps

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
            // Space & Punctuation (0x20 - 0x2F)
            7'h20: full_char = 64'h0000000000000000; // Space
            7'h21: full_char = 64'h1818181818001800; // !
            7'h22: full_char = 64'h2424240000000000; // "
            7'h23: full_char = 64'h24247E247E242400; // #
            7'h24: full_char = 64'h1C3E603C067C1800; // $
            7'h25: full_char = 64'h0062660C18324600; // %
            7'h26: full_char = 64'h386C3876DC6E3A00; // &
            7'h27: full_char = 64'h1818300000000000; // '
            7'h28: full_char = 64'h0C18303030180C00; // (
            7'h29: full_char = 64'h30180C0C0C183000; // )
            7'h2A: full_char = 64'h0024183C18240000; // *
            7'h2B: full_char = 64'h0018187E18180000; // +
            7'h2C: full_char = 64'h0000000000181830; // ,
            7'h2D: full_char = 64'h0000007E00000000; // -
            7'h2E: full_char = 64'h0000000000181800; // .
            7'h2F: full_char = 64'h00060C1830604000; // /

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

            // Punctuation & Symbols (0x3A - 0x40)
            7'h3A: full_char = 64'h0000181800181800; // :
            7'h3B: full_char = 64'h0000181800181830; // ;
            7'h3C: full_char = 64'h00060C1830180C06; // <
            7'h3D: full_char = 64'h00007E007E000000; // =
            7'h3E: full_char = 64'h006030180C183060; // >
            7'h3F: full_char = 64'h003C46060C180018; // ?
            7'h40: full_char = 64'h003C425A5A523C00; // @

            // Uppercase English Letters (0x41 - 0x5A)
            7'h41: full_char = 64'h00182442427E4242; // A
            7'h42: full_char = 64'h007C42427C42427C; // B
            7'h43: full_char = 64'h003C42404040423C; // C
            7'h44: full_char = 64'h0078444242424478; // D
            7'h45: full_char = 64'h007E40407C40407E; // E
            7'h46: full_char = 64'h007E40407C404040; // F
            7'h47: full_char = 64'h003C42404E42423C; // G
            7'h48: full_char = 64'h004242427E424242; // H
            7'h49: full_char = 64'h003C18181818183C; // I
            7'h4A: full_char = 64'h001E06060606463C; // J
            7'h4B: full_char = 64'h0042444830484442; // K
            7'h4C: full_char = 64'h004040404040407E; // L
            7'h4D: full_char = 64'h0042665A42424242; // M
            7'h4E: full_char = 64'h004262524A464242; // N
            7'h4F: full_char = 64'h003C42424242423C; // O
            7'h50: full_char = 64'h007C42427C404040; // P
            7'h51: full_char = 64'h003C4242424A443A; // Q
            7'h52: full_char = 64'h007C42427C484442; // R
            7'h53: full_char = 64'h003C42403C02423C; // S
            7'h54: full_char = 64'h007E181818181818; // T
            7'h55: full_char = 64'h004242424242423C; // U
            7'h56: full_char = 64'h0042424242422418; // V
            7'h57: full_char = 64'h00424242425A6642; // W
            7'h58: full_char = 64'h0042241818182442; // X
            7'h59: full_char = 64'h0042422418181818; // Y
            7'h5A: full_char = 64'h007E060C1830607E; // Z

            // Symbols (0x5B - 0x60)
            7'h5B: full_char = 64'h003C20202020203C; // [
            7'h5C: full_char = 64'h0040201008040201; // \
            7'h5D: full_char = 64'h003C04040404043C; // ]
            7'h5E: full_char = 64'h0018240000000000; // ^
            7'h5F: full_char = 64'h000000000000007E; // _
            7'h60: full_char = 64'h0030180C00000000; // `

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

            // Remaining Symbols (0x7B - 0x7E)
            7'h7B: full_char = 64'h000C18183018180C; // {
            7'h7C: full_char = 64'h0018181818181818; // |
            7'h7D: full_char = 64'h003018180C181830; // }
            7'h7E: full_char = 64'h003A5C0000000000; // ~

            default: full_char = 64'h0000000000000000; // Unhandled / Control character
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
