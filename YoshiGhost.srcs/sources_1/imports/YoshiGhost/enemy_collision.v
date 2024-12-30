module enemy_collision(
    input direction,
    input wire [9:0] yoshi_x, yoshi_y,
    input wire [9:0] ghost_crazy_x, ghost_crazy_y,
    input wire [9:0] ghost_top_x, ghost_top_y,
    input wire [9:0] ghost_bottom_x, ghost_bottom_y,
    output wire collision
);

localparam LEFT = 0;
localparam RIGHT = 1;
 
reg collide;

always @* begin
		collide = 0;

		if(direction == LEFT) begin
			// if yoshi and ghost_crazy are within each other, assert collide
			if((ghost_crazy_x + 13 > yoshi_x && ghost_crazy_x < yoshi_x + 13 && ghost_crazy_y + 13 > yoshi_y && ghost_crazy_y < yoshi_y + 13) ||
			   (ghost_crazy_x + 13 > yoshi_x + 9 && ghost_crazy_x < yoshi_x + 16 && ghost_crazy_y + 13 > yoshi_y + 13 && ghost_crazy_y < yoshi_y + 18)) begin
                collide = 1;
            end
			// if yoshi and ghost_top are within each other, assert collide  
			else if((ghost_top_x + 13 > yoshi_x && ghost_top_x < yoshi_x + 13 && ghost_top_y + 13 > yoshi_y && ghost_top_y < yoshi_y + 13) ||
			        (ghost_top_x + 13 > yoshi_x + 9 && ghost_top_x < yoshi_x + 16 && ghost_top_y + 13 > yoshi_y + 13 && ghost_top_y < yoshi_y + 18)) begin
            	collide = 1;
            end

			// if yoshi and ghost_bottom are within each other, assert collide  
			else if((ghost_bottom_x + 13 > yoshi_x && ghost_bottom_x < yoshi_x + 13 && ghost_bottom_y + 13 > yoshi_y && ghost_bottom_y < yoshi_y + 13) ||
			        (ghost_bottom_x + 13 > yoshi_x + 9 && ghost_bottom_x < yoshi_x + 16 && ghost_bottom_y + 13 > yoshi_y + 13 && ghost_bottom_y < yoshi_y + 18)) begin
                collide = 1;
            end
			  
		end

		if(direction == RIGHT) begin
			// if yoshi and ghost_crazy are within each other, assert collide
			if((ghost_crazy_x + 13 > yoshi_x + 9 && ghost_crazy_x < yoshi_x + 16 && ghost_crazy_y + 13 > yoshi_y && ghost_crazy_y < yoshi_y + 13) ||
			   (ghost_crazy_x + 13 > yoshi_x && ghost_crazy_x < yoshi_x + 13 && ghost_crazy_y + 13 > yoshi_y + 13 && ghost_crazy_y < yoshi_y + 18)) begin
                	collide = 1;
            end
			// if yoshi and ghost_top are within each other, assert collide
			else if((ghost_top_x + 13 > yoshi_x + 9 && ghost_top_x < yoshi_x + 16 && ghost_top_y + 13 > yoshi_y && ghost_top_y < yoshi_y + 13) ||
			        (ghost_top_x + 13 > yoshi_x && ghost_top_x < yoshi_x + 13 && ghost_top_y + 13 > yoshi_y + 13 && ghost_top_y < yoshi_y + 18)) begin
                    collide = 1;
            end
			
			
			// if yoshi and ghost_bottom are within each other, assert collide
			else if((ghost_bottom_x + 13 > yoshi_x + 9 && ghost_bottom_x < yoshi_x + 16 && ghost_bottom_y + 13 > yoshi_y && ghost_bottom_y < yoshi_y + 13) ||
			        (ghost_bottom_x + 13 > yoshi_x && ghost_bottom_x < yoshi_x + 13 && ghost_bottom_y + 13 > yoshi_y + 13 && ghost_bottom_y < yoshi_y + 18)) begin
                    collide = 1;
            end
		end
end
assign collision = collide;

endmodule