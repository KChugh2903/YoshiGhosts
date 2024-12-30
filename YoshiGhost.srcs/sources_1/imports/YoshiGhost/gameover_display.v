module gameover_display(
    input wire clk,
    input wire [9:0] x,y,
    output wire [11:0] rgb_out,
    output wire gameover_on
);

wire [3:0] row;
wire [6:0] col;
assign row = y - 72;
assign col = x - 282;

assign gameover_on = (x >= 282 && x < 360 && y >= 72 && y < 86 && rgb_out != 12'b011011011110) ? 1 : 0;

gameover_rom gameover_rom_unit (.clk(clk), .row(row), .col(col), .color_data(rgb_out));

endmodule