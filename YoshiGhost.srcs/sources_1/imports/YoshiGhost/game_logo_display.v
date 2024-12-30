module game_logo_display (
    input wire clk,
    input wire [9:0] x,y,
    output wire [11:0] rgb_out,
    output wire game_logo_on
);

wire [5:0] row, col;
assign row = y - 64;
assign col = x - 136;

assign game_logo_on = (x >= 136 && x < 504 && y >= 64 && y < 99 && rgb_out != 12'b011011011110) ? 1 : 0;

game_logo_rom game_logo_rom_unit (.clk(clk), .row(row), .col(col), .color_data(rgb_out));

endmodule