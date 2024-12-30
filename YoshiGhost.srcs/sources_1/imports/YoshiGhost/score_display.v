module score_display(
    input wire clk, rst,
    input wire new_score,
    input wire [13:0] score,
    input wire [9:0] x,y,
    output reg [7:0] sseg,
    output reg [3:0] an,
    output reg score_on
);

wire [3:0] bcd3, bcd2, bcd1, bcd0;

binary2bcd bcd_unit (.clk(clk), .rst(rst), .start(new_score),
                        .in(score), .bcd3(bcd3), .bcd2(bcd2), .bcd1(bcd1), .bcd0(bcd0));

reg [3:0] decode_reg, decode_next;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        decode_reg <= 0;
    end else begin
        decode_reg <= decode_next;
    end
end

always @* begin
    case(decode_reg)
        0: sseg = 8'b10000001;
        1: sseg = 8'b11001111;
        2: sseg = 8'b10010010;
        3: sseg = 8'b10000110;
        4: sseg = 8'b11001100;
        5: sseg = 8'b10100100;
        6: sseg = 8'b10100000;
        7: sseg = 8'b10001111;
        8: sseg = 8'b10000000;
        9: sseg = 8'b10000100;
        default: sseg = 8'b11111111;
    endcase
end

reg [16:0] m_count_reg;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        m_count_reg <= 0;
    end else begin
        m_count_reg <= m_count_reg + 1;
    end
end

always @* begin
    	case (m_count_reg[16:15])
			0:  begin
			    an = 4'b1110;
                decode_next = bcd0;
                end
			1:  begin
               	an = 4'b1101;
                decode_next = bcd1;
                end    
                    
            2:  begin
                an = 4'b1011;
                decode_next = bcd2;
                end
                    
            3:  begin
                an = 4'b0111;
                decode_next = bcd3;
                end 
		endcase
end

reg [7:0] row;
reg [3:0] col;

wire color_data;

numbers_rom numbers_rom_unit(.clk(clk), .row(row), .col(col), .color_data(color_data));

always @* begin
    score_on = 0;
    row = 0;
    col = 0;
    
    if(x >= 336 && x < 352 && y >= 16 && y < 32) begin
        col = x - 336;
        row = y - 16 + (bcd3 * 16); 
        if(color_data == 1'b1) begin  
            score_on = 1;
        end
    end
    
    if(x >= 352 && x < 368 && y >= 16 && y < 32)
        begin
        col = x - 336;
        row = y - 16 + (bcd2 * 16); 
        if(color_data == 1'b1) begin
            score_on = 1;
        end
    end
    
    if(x >= 368 && x < 384 && y >= 16 && y < 32)
        begin
        col = x - 336;
        row = y - 16 + (bcd1 * 16); 
        if(color_data == 1'b1) begin
            score_on = 1;
        end
    end
    
    if(x >= 384 && x < 400 && y >= 16 && y < 32)
        begin
        col = x - 336;
        row = y - 16 + (bcd0 * 16);
        if(color_data == 1'b1) begin
            score_on = 1;
        end
    end
end


endmodule