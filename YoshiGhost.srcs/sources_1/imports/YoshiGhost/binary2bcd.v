module binary2bcd(
    input wire clk, rst,
    input wire start, //starting binary to BCD conversion
    input wire [13:0] in, //signal for binary input to convert
    output wire [3:0] bcd3, bcd2, bcd1, bcd0
);

reg state_reg, state_next;
reg [13:0] input_reg, input_next;
reg [3:0] count_reg, count_next;
reg [3:0] bcd3_reg, bcd2_reg, bcd1_reg, bcd0_reg;
reg [3:0] bcd3_next, bcd2_next, bcd1_next, bcd0_next;
wire [3:0] bcd3_temp, bcd2_temp, bcd1_temp, bcd0_temp;

localparam idle = 1'b0, convert = 1'b1;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        state_reg <= idle;
        input_reg <= 0;
        count_reg <= 0;
        bcd3_reg <= 0;
        bcd2_reg <= 0;
        bcd1_reg <= 0;
        bcd0_reg <= 0;
    end else begin
        state_reg <= state_next;
        input_reg <= input_next;
        count_reg <= count_next;
        bcd3_reg <= bcd3_next;
        bcd2_reg <= bcd2_next;
        bcd1_reg <= bcd1_next;
        bcd0_reg <= bcd0_next;
    end
end

always @* begin
    state_next = state_reg;
    input_next = input_reg;
    count_next = count_reg;
    bcd0_next = bcd0_reg;
    bcd1_next = bcd1_reg;
    bcd2_next = bcd2_reg;
    bcd3_next = bcd3_reg;
    case(state_reg)
        idle:
            begin
                if (start) begin
                    state_next <= convert;
                    bcd0_next <= 0;
                    bcd1_next <= 0;
                    bcd2_next <= 0;
                    bcd3_next <= 0;
                    count_next <= 0;
                    input_next <= in;
                end
            end
        convert:
            begin
                input_next = input_reg << 1; //left shift input
                bcd0_next = {bcd0_temp[2:0], input_reg[13]}; //left shift in MSB of input to LSB of BCD0
                bcd1_next = {bcd1_temp[2:0], bcd0_temp[3]}; //left shift MSB of BCD0 into LSB of BCD1
                bcd2_next = {bcd2_temp[2:0], bcd1_temp[3]};
                bcd3_next = {bcd3_temp[2:0], bcd2_temp[3]};
                count_next = count_reg + 1;
                /*If the algorithm is done of all 14 bits, go back to idle*/
                if (count_next == 14) begin
                    state_next = idle;
                end
            end
    endcase
end

assign bcd0_temp = (bcd0_reg > 4) ? bcd0_reg + 3 : bcd0_reg;
assign bcd1_temp = (bcd1_reg > 4) ? bcd1_reg + 3 : bcd1_reg;
assign bcd2_temp = (bcd2_reg > 4) ? bcd2_reg + 3 : bcd2_reg;
assign bcd3_temp = (bcd3_reg > 4) ? bcd3_reg + 3 : bcd3_reg;

assign bcd0 = bcd0_reg;
assign bcd1 = bcd1_reg;
assign bcd2 = bcd2_reg;
assign bcd3 = bcd3_reg;

endmodule