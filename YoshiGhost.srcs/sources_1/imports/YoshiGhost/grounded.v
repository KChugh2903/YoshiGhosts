module grounded (
    input wire clk, rst,
    input wire [9:0] yoshi_x, yoshi_y,
    input wire jumping_up,
    input wire direction,
    output wire grounded
);

localparam MAX_X = 640;
localparam MAX_Y = 480;

localparam TILE_WIDTH = 16;
localparam TILE_HEIGHT = 16;

localparam X_D   = 9;
localparam LA    = 19;
localparam LB    = 13;
localparam RA    = 11;
localparam RB    =  5;
localparam LEFT  =  0;
localparam RIGHT =  1;
 
reg grounded_reg, grounded_next;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        grounded_reg <= 1;
    end else begin
        grounded_reg <= grounded_next;
    end
end

always @* begin
    grounded_next = grounded_reg;
		if(!jumping_up) begin
			if(direction == LEFT && (yoshi_y == 132 - 2*TILE_HEIGHT) && (yoshi_x >= 16) && (yoshi_x < 160 - LB)) begin
				grounded_next = 1;
            end else if(direction == RIGHT && (yoshi_y == 132 - 2*TILE_HEIGHT) && (yoshi_x >= 16) && (yoshi_x < 160 - RB)) begin
				grounded_next = 1;
            end else if(direction == LEFT && (yoshi_y == 132 - 2*TILE_HEIGHT) && (yoshi_x >= 480 - LA) && (yoshi_x < 624)) begin
				grounded_next = 1;
            end else if(direction == RIGHT && (yoshi_y == 132 - 2*TILE_HEIGHT) && (yoshi_x >= 480 - RA) && (yoshi_x < 624)) begin
				grounded_next = 1;
            end else if(direction == LEFT && (yoshi_y == 215 - 2*TILE_HEIGHT) && (yoshi_x >= 80 - LA) && (yoshi_x < 561 - LB)) begin
				grounded_next = 1;
            end else if(direction == RIGHT && (yoshi_y == 215 - 2*TILE_HEIGHT) && (yoshi_x >= 80 - RA) && (yoshi_x < 561 - RB)) begin
				grounded_next = 1;
            end else if(direction == LEFT && (yoshi_y == 298 - 2*TILE_HEIGHT) && (yoshi_x >= 16) && (yoshi_x < 256 - LB)) begin
				grounded_next = 1;
            end else if(direction == RIGHT && (yoshi_y == 298 - 2*TILE_HEIGHT) && (yoshi_x >= 16) && (yoshi_x < 256 - RB)) begin
				grounded_next = 1;
            end else if(direction == LEFT && (yoshi_y == 298 - 2*TILE_HEIGHT) && (yoshi_x >= 384 - LA) && (yoshi_x < 624 - LB)) begin
				grounded_next = 1;
            end else if(direction == RIGHT && (yoshi_y == 298 - 2*TILE_HEIGHT) && (yoshi_x >= 384 - RA) && (yoshi_x < 624 - RB)) begin
				grounded_next = 1;
            end else if(direction == LEFT && (yoshi_y == 381 - 2*TILE_HEIGHT) && (yoshi_x > 112 - LA) && (yoshi_x < 529 - LB)) begin
				grounded_next = 1;
            end else if(direction == RIGHT && (yoshi_y == 381 - 2*TILE_HEIGHT) && (yoshi_x > 112 - RA) && (yoshi_x < 529 - RB)) begin
				grounded_next = 1;
            end else if((yoshi_y == MAX_Y - 2*TILE_HEIGHT - 16)) begin
				grounded_next = 1;
            end else begin 
				grounded_next = 0;
			end
        end else begin 
			grounded_next = 0;
        end  
end

assign grounded = grounded_reg;

endmodule