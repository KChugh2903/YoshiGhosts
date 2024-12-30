module hearts_display(
    input wire clk,
    input wire [9:0] x,y,
    input wire [1:0] num_hearts,
    output wire [11:0] color_data,
    output reg hearts_on
);

reg [4:0] row;
reg [3:0] col;

hearts_rom hearts_rom_unit(.clk(clk), .row(row), .col(col), .color_data(color_data));
always @* begin
    row = 0;
    col = 0;
    hearts_on = 0;
    if(x >= 240 && x < 256 && y >= 16 && y < 32) begin
        col = x - 240;                 
        if(num_hearts > 0) begin              
            row = y - 16;                
        end else begin 
            row = y;               
        end 
        if(color_data != 12'b011011011110) begin
            hearts_on = 1;  
        end              
    end
		
    if(x >= 256 && x < 272 && y >= 16 && y < 32) begin
        col = x - 256;       
        if(num_hearts > 1) begin        
            row = y - 16;         
        end else begin 
            row = y; 
        end            
        if(color_data != 12'b011011011110) begin
            hearts_on = 1; 
        end            
    end
		
		
		// if vga pixel within beart 3 (right)
	if(x >= 272 && x < 288 && y >= 16 && y < 32) begin
        col = x - 272;                  
        if(num_hearts > 2) begin             
            row = y - 16;        
        end else begin 
            row = y;             
        end if(color_data != 12'b011011011110) begin
            hearts_on = 1;   
        end        
	end
end

endmodule

