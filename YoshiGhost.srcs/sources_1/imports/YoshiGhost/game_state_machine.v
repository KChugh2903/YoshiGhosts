module game_state_machine(
    input wire clk, hard_rst,
    input wire start,
    input wire collision,
    output wire [1:0] num_hearts,
    output wire [2:0] game_state,
    output wire game_en,
    output reg game_rst
);

reg start_reg;
wire start_posedge;

always @(posedge clk, posedge hard_rst) begin
    if (hard_rst) begin
        start_reg <= 0;
    end else begin
        start_reg <= start;
    end
end

assign start_posedge = start & ~start_reg;
 
localparam [2:0] init     = 3'b000,  //init
			     idle     = 3'b001,  //idle
		         playing  = 3'b010,  //playing
			     hit      = 3'b011, //when yoshi gets hit
			     gameover = 3'b100;  // game over

reg [2:0] game_state_reg, game_state_next; // FSM state register
reg [27:0] timeout_reg, timeout_next;      // timer register to time yoshi's invincibility post ghost collision
reg [1:0] hearts_reg, hearts_next;         // register to store number of hearts
reg game_en_reg, game_en_next;             // register for game enable signal

always @(posedge clk, posedge hard_rst) begin
    if (hard_rst) begin
        game_state_reg <= 0;
        timeout_reg <= 20000000;
        hearts_reg <= 3;
        game_en_reg <= 0;
    end else begin
        game_state_reg <= game_state_next;
        timeout_reg <= timeout_next;
        hearts_reg <= hearts_next;
        game_en_reg <= game_en_next;
    end
end

always @* begin
    game_state_next = game_state_reg;
    timeout_next    = timeout_reg;
    hearts_next     = hearts_reg;
    game_en_next    = game_en_reg;
    game_rst = 0;
    case(game_state_reg)
        init:
            begin	
                if(timeout_reg > 0) begin                // decrement timeout_reg until 0 to let nes controller signals settle
                    timeout_next = timeout_reg - 1;
                end else begin
                    game_state_next = idle;  // go to idle game state
                end            
            end
            
        idle:
            begin
                if(start_posedge) begin               // player presses start button to begin game
                    game_en_next = 1;                 // game_en signal asserted next
                    game_rst   = 1;                 // assert reset game signal
                    game_state_next = playing;        // next state is playing
                end
            end
        
        playing:
            begin
                if(collision)  begin                        // if yoshi collides with ghost while playing
                    if(hearts_reg == 1) begin            // if on last heart
                        hearts_next = hearts_reg - 1; // decrement hearts_reg to 0
                        game_en_next = 0;             // disable game_en signal
                        game_state_next = gameover;   // go to gameover state
                    end else begin
                        hearts_next = hearts_reg - 1; // else decrement hearts_reg 
                        game_state_next = hit;        // go to hit state
                        timeout_next = 200000000;     // load timeout_reg for 2 seconds of invincibility
                    end
                end
            end
            
        hit:
            begin	                              // yoshi cannot be hit (have hearts decremented)
                if(timeout_reg > 0) begin              // decrement timeout_reg until 0 (2 seconds)
                    timeout_next = timeout_reg - 1;
                end else begin 
                    game_state_next = playing;        // go back to playing state
                end
            end
        
        gameover:                                 // gameover state
            begin
                if(start_posedge) begin                     // wait for player to press start button
                    hearts_next = 3;                  // reset hearts_reg to 3
                    game_state_next = init;           // go to init state
                    game_rst   = 1;                 // assert game_reset signal to reset all gameplay mechanics modules (see display_top)
                end
            end
	endcase
end

endmodule