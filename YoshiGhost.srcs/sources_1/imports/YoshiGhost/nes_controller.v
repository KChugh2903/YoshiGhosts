module nes_controller(
    input wire clk, rst,
    input wire data,
    output reg latch, nes_clk,
    output wire A,B, select, start, up, down, left, right
);

localparam [3:0] latch_en     = 4'h0,  // assert latch for 12 us
                    read_A_wait  = 4'h1,  // read A / wait 6 us
                    read_B       = 4'h2,  // read B ...
                    read_select  = 4'h3,  
                    read_start   = 4'h4,
                    read_up      = 4'h5,
                    read_down    = 4'h6,
                    read_left    = 4'h7,
                    read_right   = 4'h8;

reg [10:0] count_reg, count_next;
reg [3:0] state_reg, state_next;
reg A_reg, B_reg, select_reg, start_reg,
    up_reg, down_reg, left_reg, right_reg;
reg A_next, B_next, select_next, start_next,
   up_next, down_next, left_next, right_next;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        count_reg  <= 0;
        state_reg  <= 0;
        A_reg      <= 0;
        B_reg      <= 0;
        select_reg <= 0;
        start_reg  <= 0;
        up_reg     <= 0;
        down_reg   <= 0;
        left_reg   <= 0;
        right_reg  <= 0;
    end else begin
        count_reg  <= count_next;
        state_reg  <= state_next;
        A_reg      <= A_next;
        B_reg      <= B_next;
        select_reg <= select_next;
        start_reg  <= start_next;
        up_reg     <= up_next;
        down_reg   <= down_next;
        left_reg   <= left_next;
        right_reg  <= right_next;
    end
end

always @* begin
    latch = 0;
    nes_clk = 0;
    count_next = count_reg;
    A_next = A_reg;
    B_next = B_reg;
    select_next = select_reg;
    start_next = start_reg;
    up_next = up_reg;
    down_next = down_reg;
    left_next = left_reg;
    right_next = right_reg;
    state_next = state_reg;

    case(state_reg)
        latch_en:
            begin
                latch = 1;
                if (count_reg < 1200) begin
                    count_next = count_reg + 1;
                end else if (count_reg == 1200) begin
                    count_next = 0;
                    state_next = read_A_wait;
                end
            end
        read_A_wait:
            begin
                A_next = data;
                if (count_reg < 600) begin
                    count_next = count_reg + 1;
                end else if (count_reg == 600) begin
                    count_next = 0;
                    state_next = read_B;
                end
            end
        read_B:
            begin
                if (count_reg < 1200) begin
                    count_next = count_reg + 1;
                end
                if (count_reg <= 600) begin
                    nes_clk = 1;
                end else if (count_reg > 600) begin
                    nes_clk = 0;
                end
                if (count_reg == 600) begin
                    B_next = data;
                end
                //state is over
                if (count_reg == 1200) begin
                    count_next = 0;
                    state_next = read_select;
                end
            end
        read_select:
            begin
                if (count_reg < 1200) begin
                    count_next = count_reg + 1;
                end
                if (count_reg <= 600) begin
                    nes_clk = 1;
                end else if (count_reg > 600) begin
                    nes_clk = 0;
                end
                if (count_reg == 600) begin
                    select_next = data;
                end
                //state is over
                if (count_reg == 1200) begin
                    count_next = 0;
                    state_next = read_start;
                end
            end
        read_start:
            begin
                if (count_reg < 1200) begin
                    count_next = count_reg + 1;
                end
                if (count_reg <= 600) begin
                    nes_clk = 1;
                end else if (count_reg > 600) begin
                    nes_clk = 0;
                end
                if (count_reg == 600) begin
                    start_next = data;
                end
                //state is over
                if (count_reg == 1200) begin
                    count_next = 0;
                    state_next = read_up;
                end
            end
        read_up:
            begin
                if (count_reg < 1200) begin
                    count_next = count_reg + 1;
                end
                if (count_reg <= 600) begin
                    nes_clk = 1;
                end else if (count_reg > 600) begin
                    nes_clk = 0;
                end
                if (count_reg == 600) begin
                    up_next = data;
                end
                //state is over
                if (count_reg == 1200) begin
                    count_next = 0;
                    state_next = read_down;
                end
            end
        read_down:
            begin
                if (count_reg < 1200) begin
                    count_next = count_reg + 1;
                end
                if (count_reg <= 600) begin
                    nes_clk = 1;
                end else if (count_reg > 600) begin
                    nes_clk = 0;
                end
                if (count_reg == 600) begin
                    down_next = data;
                end
                //state is over
                if (count_reg == 1200) begin
                    count_next = 0;
                    state_next = read_left;
                end
            end
        read_left:
            begin
                if (count_reg < 1200) begin
                    count_next = count_reg + 1;
                end
                if (count_reg <= 600) begin
                    nes_clk = 1;
                end else if (count_reg > 600) begin
                    nes_clk = 0;
                end
                if (count_reg == 600) begin
                    left_next = data;
                end
                //state is over
                if (count_reg == 1200) begin
                    count_next = 0;
                    state_next = read_right;
                end
            end
        read_right:
            begin
                if (count_reg < 1200) begin
                    count_next = count_reg + 1;
                end
                if (count_reg <= 600) begin
                    nes_clk = 1;
                end else if (count_reg > 600) begin
                    nes_clk = 0;
                end
                if (count_reg == 600) begin
                    right_next = data;
                end
                //state is over
                if (count_reg == 1200) begin
                    count_next = 0;
                    state_next = latch_en;
                end
            end
    endcase
end

/* Assign outputs which are usually asserted when unpressed */

assign A = ~A_reg;
assign B = ~B_reg;
assign select = ~select_reg;
assign start  = ~start_reg;
assign up     = ~up_reg;
assign down   = ~down_reg;
assign left   = ~left_reg;
assign right  = ~right_reg;

endmodule