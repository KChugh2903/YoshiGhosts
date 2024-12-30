module display_top(
    input wire clk, hard_rst,   //clk, rst
    input wire data,            //input data from NES to FPGA
    output wire latch, nes_clk, //output from FPGA to nes controller
    output wire hsync, vsync,  //outputs VGA signals to VGA port
    output wire [11:0] rgb,   //output RGB signals to VGA DAC
    output wire [7:0] sseg,  //output signals to control LED digit segments
    output wire [3:0] an        //Multiplex seven-segment display
);

wire up, left, right, start;
localparam idle = 3'b001;
localparam gameover = 3'b100;
wire [1:0] num_hearts;
wire [2:0] game_state;
wire game_en, game_rst, rst;
assign rst = hard_rst || game_rst;
wire [9:0] x,y;
wire video_on, pixel_tick;
reg [11:0] rgb_reg, rgb_next;
wire [9:0] yoshi_x, yoshi_y;
wire [9:0] ghost_crazy_x, ghost_crazy_y;
wire [9:0] ghost_top_x, ghost_top_y;
wire [9:0] ghost_bottom_x, ghost_bottom_y;
wire grounded, jumping_up, direction, collision;
wire [13:0] score;
wire new_score;
wire [11:0] yoshi_rgb, platforms_rgb, ghost_crazy_rgb, ghost_bottom_rgb, 
            ghost_top_rgb, bg_rgb, eggs_rgb, hearts_rgb, game_logo_rgb, gameover_rgb;

wire yoshi_on, platforms_on, ghost_crazy_on, ghost_bottom_on, 
     ghost_top_on, eggs_on, score_on, hearts_on, game_logo_on, gameover_on;

wire [25:0] speed_offset; //amount of speed incrase is calculated from current game score and routed to ghosts

assign speed_offset = (({14'b0, score[13:2]} << 12) < 2500000) ? ({14'b0, score[13:2]} << 12) : 2500000;

wire yoshi_up, yoshi_left, yoshi_right;
assign yoshi_up = up & game_en;
assign yoshi_left = left & game_en;
assign yoshi_right = right & game_en;

wire gameover_yoshi;
assign gameover_yoshi = (game_state == gameover) ? 1 : 0;

vga_sync vsync_unit (.clk(clk), .rst(hard_rst), .hsync(hsync), .vsync(vsync),
                            .video_on(video_on), .p_tick(pixel_tick), .x(x), .y(y));

//nes controller
nes_controller controller (.clk(clk), .rst(hard_rst), .data(data), .latch(latch), .nes_clk(nes_clk),
                .A(up), .B(), .select(), .start(start), .up(), .down(), .left(left), .right(right));

yoshi_sprite yoshi_unit(.clk(clk), .rst(rst), .btnU(yoshi_up),
                .btnL(yoshi_left), .btnR(yoshi_right), .video_on(video_on), .x(x), .y(y),
                .grounded(grounded), .game_over_yoshi(game_over_yoshi), .collision(collision),
                .rgb_out(yoshi_rgb),.yoshi_on(yoshi_on), .yoshi_x(yoshi_x), .yoshi_y(yoshi_y), 
                .jumping_up(jumping_up), .direction(direction));

//crazy ghost circuit						 
ghost_crazy ghost_crazy_unit (.clk(clk), .rst(rst), .yoshi_x(yoshi_x), .yoshi_y(yoshi_y),
                    .x(x), .y(y), .speed_offset(speed_offset), .ghost_crazy_x(ghost_crazy_x), 
                    .ghost_crazy_y(ghost_crazy_y), .ghost_crazy_on(ghost_crazy_on), .rgb_out(ghost_crazy_rgb));

//top ghost circuit
ghost_top ghost_top_unit (.clk(clk), .rst(rst), .yoshi_x(yoshi_x), .yoshi_y(yoshi_y),
                .x(x), .y(y), .speed_offset(speed_offset), .ghost_top_x(ghost_top_x), .ghost_top_y(ghost_top_y),
                .ghost_top_on(ghost_top_on), .rgb_out(ghost_top_rgb));

//bottom ghost circuit
ghost_bottom ghost_bottom_unit (.clk(clk), .rst(rst), .yoshi_x(yoshi_x), .yoshi_y(yoshi_y),
                .x(x), .y(y), .speed_offset(speed_offset), .ghost_bottom_x(ghost_bottom_x), .ghost_bottom_y(ghost_bottom_y),
                .ghost_bottom_on(ghost_bottom_on), .rgb_out(ghost_bottom_rgb));

//platform sprites circuit
platforms platforms_unit (.clk(clk), .video_on(video_on), .x(x), .y(y), .rgb_out(platforms_rgb),
                        .platforms_on(platforms_on));

//circuit that determines if yoshi sprite is on the ground or a platform
grounded grounded_unit (.clk(clk), .rst(rst), .yoshi_x(yoshi_x), .yoshi_y(yoshi_y), .jumping_up(jumping_up),
                        .direction(direction), .grounded(grounded));

// background rom circuit
background_ghost_rom background_unit (.clk(clk), .row(y[7:0]), .col(x[7:0]), .color_data(bg_rgb));

//enemy collision detection circuit
enemy_collision enemy_collision_unit (.direction(direction), .yoshi_x(yoshi_x), .yoshi_y(yoshi_y), .ghost_crazy_x(ghost_crazy_x),
                                            .ghost_crazy_y(ghost_crazy_y), .ghost_top_x(ghost_top_x), .ghost_top_y(ghost_top_y), .ghost_bottom_x(ghost_bottom_x),
                        .ghost_bottom_y(ghost_bottom_y), .collision(collision)); 

// eggs circuit
eggs eggs_unit(.clk(clk), .rst(rst), .yoshi_x(yoshi_x), .yoshi_y(yoshi_y), .direction(direction),
            .x(x), .y(y), .eggs_on(eggs_on), .rgb_out(eggs_rgb), .score(score), .new_score(new_score));

//score display circuit
score_display score_display_unit (.clk(clk), .rst(rst), .new_score(new_score), .score(score),
                    .x(x), .y(y), .sseg(sseg), .an(an), .score_on(score_on));		   

//hearts display circuit
hearts_display hearts_display_unit (.clk(clk), .x(x), .y(y), .num_hearts(num_hearts),
                    .color_data(hearts_rgb), .hearts_on(hearts_on));

// game FSM circuit
game_state_machine game_FSM (.clk(clk), .hard_rst(hard_rst), .start(start), .collision(collision),
                    .num_hearts(num_hearts), .game_state(game_state), .game_en(game_en),
                    .game_rst(game_rst));

//start screen logo display circuit
game_logo_display game_logo_display_unit (.clk(clk), .x(x), .y(y), .rgb_out(game_logo_rgb),
                                            .game_logo_on(game_logo_on));

// gameover display circuit
gameover_display gameover_display_unit (.clk(clk), .x(x), .y(y), .rgb_out(gameover_rgb),
                                        .gameover_on(gameover_on));


always @* begin
    if (~video_on) begin
        rgb_next = 12'b0; // black
    end else if(score_on) begin
        rgb_next = 12'hFFF;
        
    end else if (hearts_on) begin
        rgb_next = hearts_rgb;
        
    end else if (game_logo_on && game_state == idle) begin
        rgb_next = game_logo_rgb;
            
    end else if (gameover_on && game_state == gameover) begin
        rgb_next = gameover_rgb;
            
    end else if (ghost_crazy_on && game_state != idle) begin
        rgb_next = ghost_crazy_rgb;
            
    end else if (ghost_bottom_on && game_state != idle) begin
        rgb_next = ghost_bottom_rgb;
            
    end else if (ghost_top_on && game_state != idle) begin
        rgb_next = ghost_top_rgb;
            
    end else if (yoshi_on && game_state != idle) begin
        rgb_next = yoshi_rgb;       
            
    end else if (eggs_on && game_en) begin
        rgb_next = eggs_rgb;

    end else if (platforms_on) begin
        rgb_next = platforms_rgb;
            
    end else begin
        rgb_next = bg_rgb;

    end			
end

always @(posedge clk) begin
    if (pixel_tick) begin
        rgb_reg <= rgb_next;
    end
end

assign rgb = rgb_reg;

endmodule