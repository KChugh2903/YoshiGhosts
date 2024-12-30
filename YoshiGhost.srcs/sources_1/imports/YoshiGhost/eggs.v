module eggs(
    input wire clk, rst,
    input wire [9:0] yoshi_x, yoshi_y,
    input direction,
    input wire [9:0] x,y,
    output eggs_on,
    output wire [11:0] rgb_out,
    output wire [13:0] score,
    output wire new_score
);

localparam LEFT = 0;
localparam RIGHT = 1;
localparam waiting = 1'b0;
localparam respawn = 1'b1;


//How to go through platforms
reg [2:0] platform_select_reg;
wire [2:0] platform_select_next;

reg [9:0] egg_x_reg, egg_x_next, egg_y_reg, egg_y_next;
reg [5:0] egg_type_reg, egg_type_next;



always @(posedge clk, posedge rst) begin
    if (rst) begin
        platform_select_reg <= 0;
        egg_x_reg    <= 296;
        egg_y_reg    <= 364;
        egg_type_reg <= 0;
    end else begin
        platform_select_reg <= platform_select_next;
        egg_x_reg    <= egg_x_next;
        egg_y_reg    <= egg_y_next;
        egg_type_reg <= egg_type_next;
    end
end
assign platform_select_next = platform_select_reg + 1;

//Egg location spawn points
reg[7:0] A_reg; // [ 16, 144]
reg[9:0] B_reg; // [480, 608]
reg[9:0] C_reg; // [ 80, 545]
reg[8:0] D_reg; // [ 16, 240]
reg[9:0] E_reg; // [384, 608]
reg[9:0] F_reg; // [112, 513]
reg[9:0] G_reg; // [ 16, 608]

always @(posedge clk, posedge rst) begin
    if (rst) begin
        A_reg <=  16;
        B_reg <= 480;
        C_reg <=  80;
        D_reg <=  16;
        E_reg <= 384;
        F_reg <= 296;
        G_reg <=  16;
    end else begin
        A_reg <= (A_reg <= 144) ? A_reg + 1 :  16;
        B_reg <= (B_reg <= 608) ? B_reg + 1 : 480;
        C_reg <= (C_reg <= 545) ? C_reg + 1 :  80;
        D_reg <= (D_reg <= 240) ? D_reg + 1 :  16;
        E_reg <= (E_reg <= 608) ? E_reg + 1 : 384;
        F_reg <= (F_reg <= 513) ? F_reg + 1 : 112;
        G_reg <= (G_reg <= 608) ? G_reg + 1 :  16;
    end
end

reg [1:0] state_reg, state_next;
//FSM state register
always @(posedge clk, posedge rst) begin
    if (rst) begin
        state_reg <= waiting;
    end else begin
        state_reg <= state_next;
    end
end


//New score update
reg new_score_reg, new_score_next;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        new_score_reg <= 0;
    end else begin
        new_score_reg <= new_score_next;
    end
end

always @* begin
    state_next = state_reg;
    egg_x_next = egg_x_reg;
    egg_y_next = egg_y_reg;
    egg_type_next = egg_type_reg;
    new_score_next = 0;
    case(state_reg) 
            waiting: // egg already spawned, waiting for yoshi to get it
                begin
                    if(direction == LEFT && (egg_x_reg + 13 > yoshi_x && egg_x_reg < yoshi_x + 13 && egg_y_reg + 13 > yoshi_y && egg_y_reg < yoshi_y + 13) ||
                        (egg_x_reg + 13 > yoshi_x + 9 && egg_x_reg < yoshi_x + 16 && egg_y_reg + 13 > yoshi_y + 13 && egg_y_reg < yoshi_y + 18))
                            begin
                                new_score_next = 1;    // signal new score ready
                                state_next = respawn; // go to respawn state
                            end

                        else if(direction == RIGHT && (egg_x_reg + 13 > yoshi_x + 9 && egg_x_reg < yoshi_x + 16 && egg_y_reg + 13 > yoshi_y && egg_y_reg < yoshi_y + 13) ||
                            (egg_x_reg + 13 > yoshi_x && egg_x_reg < yoshi_x + 13 && egg_y_reg + 13 > yoshi_y + 13 && egg_y_reg < yoshi_y + 18))
                            begin
                                new_score_next = 1;    // signal new score ready
                                state_next = respawn; // go to respawn state
                            end
                end
            respawn: 
                begin
                    if(platform_select_reg == 0) begin
                        egg_y_next    = 116;
                        egg_x_next    = A_reg;
                        egg_type_next = A_reg[5:0];
                    end else if(platform_select_reg == 1) begin
                        egg_y_next    = 116;
                        egg_x_next    = B_reg;
                        egg_type_next = B_reg[5:0];
                    end else if(platform_select_reg == 2) begin
                        egg_y_next    = 199;
                        egg_x_next    = C_reg;
                        egg_type_next = C_reg[5:0];
                    end else if(platform_select_reg == 3) begin
                        egg_y_next    = 282;
                        egg_x_next    = D_reg;
                        egg_type_next = D_reg[5:0];
                    end else if(platform_select_reg == 4) begin
                        egg_y_next    = 282;
                        egg_x_next    = E_reg;
                        egg_type_next = E_reg[5:0];
                    end else if(platform_select_reg == 5) begin
                        egg_y_next    = 365;
                        egg_x_next    = F_reg;
                        egg_type_next = F_reg[5:0];
                    end else begin
                        egg_y_next    = 448;
                        egg_x_next    = G_reg;
                        egg_type_next = G_reg[5:0];
                    end
                    state_next = waiting; // go back to waiting state
                end
    endcase
end

wire [6:0] egg_type_offset;
assign egg_type_offset = (egg_type_reg <= 29) ? 0 :
                            (egg_type_reg > 29  && egg_type_reg <= 44) ? 16 :
                            (egg_type_reg > 44  && egg_type_reg <= 54) ? 32 :
                            (egg_type_reg > 54  && egg_type_reg <= 62) ? 48 : 64;

reg [13:0] score_reg;
wire[13:0] score_next;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        score_reg <= 0;
    end else begin
        score_reg <= score_next;
    end

end
assign score_next = (rst || new_score_next && score_reg == 9999) ? 0 : 
    new_score_next && egg_type_offset ==  0 ? score_reg +   20: // green   egg: p = 30/64, score =  10
    new_score_next && egg_type_offset == 16 ? score_reg +   40: // red     egg: p = 15/64, score =  20
    new_score_next && egg_type_offset == 32 ? score_reg +   60: // blue    egg: p = 10/64, score =  50
    new_score_next && egg_type_offset == 48 ? score_reg +  200: // yellow  egg: p = 08/64, score =  100
    new_score_next && egg_type_offset == 64 ? score_reg +  500: // special egg: p = 01/64, score =  500
    score_reg;

assign score = score_reg;
wire [3:0] col;
wire [6:0] row;

assign col = x - egg_x_reg;
assign row = y + egg_type_offset - egg_y_reg;

eggs_rom eggs_rom_unit(.clk(clk), .row(row), .col(col), .color_data(rgb_out));

assign eggs_on = (x >= egg_x_reg && x < egg_x_reg + 16 && y >= egg_y_reg && y < egg_y_reg + 16)
                     && (rgb_out != 12'b011011011110) ? 1 : 0;

endmodule