module ghost_top(
    input wire clk, rst,
    input wire [9:0] yoshi_x, yoshi_y,
    input wire  [9:0] x,y,
    input wire [25:0] speed_offset,
    output wire [9:0] ghost_top_x, ghost_top_y,
    output ghost_top_on,
    output wire [11:0] rgb_out
);

localparam MAX_X = 640;
localparam MAX_Y = 480;

localparam TILE_WIDTH = 16;

reg [9:0] sprite_x_reg, sprite_y_reg;
reg [9:0] sprite_x_next, sprite_y_next;

always @(posedge clk) begin
    sprite_x_reg <= sprite_x_next;
    sprite_y_reg <= sprite_y_next;
end

localparam LEFT = 0;
localparam RIGHT = 1;

reg dir_reg, dir_next;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        dir_reg <= RIGHT;
    end else begin
        dir_reg <= dir_next;
    end
end

always @* begin
    dir_next = dir_reg;
    if (yoshi_x < sprite_x_reg) begin
        dir_next = LEFT;
    end
    if (yoshi_x > sprite_x_reg) begin
        dir_next = RIGHT;
    end
end

/*sprite motion*/
localparam TIME_MAX = 4600000;

reg [25:0] time_reg;
wire [25:0] time_next;
reg tick_reg;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        time_reg <= 0;
    end else begin
        time_reg <= time_next;
    end
end

assign time_next = (time_reg < TIME_MAX - speed_offset) ? time_reg + 1 : 0;

wire tick;
assign tick = (time_reg == TIME_MAX - speed_offset) ? 1 : 0;

always @(posedge tick, posedge rst) begin
    if (rst) begin
        sprite_x_next = 608;
    end else if (yoshi_y <= 231) begin
        if (sprite_x_reg > yoshi_x) begin
            sprite_x_next = sprite_x_reg - 1;
        end else if (sprite_x_reg < yoshi_x) begin
            sprite_x_next = sprite_x_reg + 1;
        end else begin
            sprite_x_next = sprite_x_reg;
        end
    end else begin
        sprite_x_next = sprite_x_reg;
    end

    if (rst) begin
        sprite_y_next = 17;
    end else if (yoshi_y <= 231) begin
        if (sprite_y_reg > yoshi_y) begin
            sprite_y_next = sprite_y_reg - 1;
        end else if (sprite_y_reg < yoshi_y) begin
            sprite_y_next = sprite_y_reg + 1;
        end else begin
            sprite_y_next = sprite_y_reg;
        end
    end else begin
        sprite_y_next = sprite_y_reg;
    end
end

reg [25:0] face_t_reg;
wire [25:0] face_t_next;

wire [5:0] face_type;

always @(posedge clk, posedge rst) begin
    if(rst) begin
        face_t_reg <= 0;
    end else begin
        face_t_reg <= face_t_next;
    end
end


assign face_t_next = (face_t_reg < 40000000)? face_t_reg + 1 : 0;

assign face_type = (face_t_reg < 20000000 || yoshi_y < 297) ? 0 : 16;

wire [3:0] col;
wire [4:0] row;

assign col = dir_reg == RIGHT ? x - sprite_x_reg : (TILE_WIDTH - 1 - (x - sprite_x_reg)); 

assign row = y + face_type - sprite_y_reg;

wire [11:0] color_data;

ghost_normal_rom ghost_normal_unit (.clk(clk), .row(row), .col(col), .color_data(color_data));

wire ghost_on;
assign ghost_on = (x >= sprite_x_reg && x < sprite_x_reg + 16
                    && y >= sprite_y_reg && y < sprite_y_reg + 16)? 1 : 0;

assign ghost_bottom_on = ghost_on && rgb_out != 12'b011011011110 ? 1 : 0;

assign rgb_out = color_data;

assign ghost_top_x = sprite_x_reg;
assign ghost_top_y = sprite_y_reg;

endmodule