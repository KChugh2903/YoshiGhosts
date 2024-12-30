module platforms (
    input wire clk,
    input wire video_on,
    input wire [9:0] x,y,
    output reg [11:0] rgb_out,
    output reg platforms_on
);

reg [6:0] row;
reg [3:0] col;

wire [11:0] walls_color_dara, blocks_color_data;

walls_rom walls_unit (.clk(clk), .row(row[4:0]), .col(col), .color_data(walls_color_data));
blocks_rom blocks_unit (.clk(clk), .row(row), .col(col), .color_data(blocks_color_data));

localparam offset = 16;

always @* begin
    platforms_on = 0;
    row = 0;
    col = 0;
    rgb_out = 12'h000;
    if (video_on) begin
        if((y > 131 && y < 148 && x >= 16 && x < 160)) begin
            row = y - 132 + offset;              
            col = x + 16;                      
            if (blocks_color_data != 12'b011011011110) begin
                platforms_on = 1;                  
                rgb_out = blocks_color_data;     
            end
        end        
        if((y > 131 && y < 148 && x >= 480 && x < 624)) begin
            row = y - 132 + offset;
            col = x;
            if(blocks_color_data != 12'b011011011110) begin
                platforms_on = 1;
                rgb_out = blocks_color_data;
                end
        end 
        if((y > 214 && y < 231 && x > 80 && x < 561)) begin
            row = y - 215 + offset;
            col = x - 81;
            if(blocks_color_data != 12'b011011011110) begin
                platforms_on = 1;
                rgb_out = blocks_color_data;
            end
        end 
            
        if((y > 297 && y < 314 && x >= 16 && x < 256)) begin
            row = y - 298 + offset;
            col = x;
            if(blocks_color_data != 12'b011011011110) begin
                platforms_on = 1;
                rgb_out = blocks_color_data;
            end
        end 
            
        // 'E'
        if((y > 297 && y < 314 && x >= 384 && x < 624)) begin
            row = y - 298 + offset;
            col = x;
            if(blocks_color_data != 12'b011011011110) begin
                platforms_on = 1;
                rgb_out = blocks_color_data;
            end
        end 
            
        // 'F'
        if((y > 380 && y < 397 && x > 112 && x < 529)) begin
            row = y - 381 + offset;
            col = x - 113;
            if(blocks_color_data != 12'b011011011110) begin
                platforms_on = 1;
                rgb_out = blocks_color_data;
            end
        end

        // 'G' bottom row 
        if(y > 463) begin
            row = y - 464;
            col = x;
            if(walls_color_data != 12'b011011011110) begin
                platforms_on = 1;
                rgb_out = walls_color_data;
            end
        end
            
        // top row
        if(y >= 0 && y < 16) begin
            row = y;
            col = x;
            if(walls_color_data != 12'b011011011110) begin
                platforms_on = 1;
                rgb_out = walls_color_data;
            end
        end
        
        // left column
        if(x < 16) begin
            row = y;
            col = x;
            if(walls_color_data != 12'b011011011110) begin
                platforms_on = 1;
                rgb_out = walls_color_data;
            end
        end

        // right column
        if(x > 623) begin
            row = y;
            col = x;
            if(walls_color_data != 12'b011011011110) begin
                platforms_on = 1;
                rgb_out = walls_color_data;
            end
        end	
    end	
end


endmodule