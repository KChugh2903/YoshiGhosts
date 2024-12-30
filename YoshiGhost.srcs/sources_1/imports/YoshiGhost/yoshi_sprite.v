module yoshi_sprite(
    input wire clk, rst,
    input wire btnU, btnL, btnR,
    input wire video_on,
    input wire [9:0] x,y,
    input wire grounded,
    input wire game_over_yoshi,
    input wire collision,
    output reg [11:0] rgb_out,
    output reg yoshi_on,
    output wire [9:0] yoshi_x, yoshi_y,
    output wire jumping_up,
    output wire direction
);

localparam MAX_X = 640;
localparam MAX_Y = 480;
localparam MIN_Y = 16;

localparam TILE_WIDTH = 16;
localparam TILE_HEIGHT = 16;

localparam X_MAX = 25;

localparam X_D = 9;

reg [9:0] sprite_x_reg, sprite_y_reg;
reg [9:0] sprite_x_next, sprite_y_next;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        sprite_x_reg <= 320;
        sprite_y_reg <= MAX_Y - TILE_HEIGHT << 1 - 16;
    end else begin
        sprite_x_reg <= sprite_x_next;
        sprite_y_reg <= sprite_y_next;
    end
end

localparam LEFT = 0;
localparam RIGHT = 1;

reg dir_reg, dir_next;
always @(posedge clk, posedge rst) begin
    if (rst) begin
        dir_reg <= RIGHT;
    end else begin
        dir_reg <= dir_next;
    end
end

always @* begin
    dir_next = dir_reg;
    if (btnL && !btnR) begin
        dir_next = LEFT;
    end else begin
        dir_next = RIGHT;
    end
end

localparam [1:0] no_dir = 2'b00, left = 2'b01, right = 2'b10;

/*
The x_time_reg is a countdown register that simulates x-axis motion and momentum for sprite movements,
decrementing on clock edges. Its initial value sets the motion speed. Holding a directional button
causes progressive accelerations by decrementing from smaller initial values, until reaching a preset
maximum speed defined by the minimum countdown time. Grounded sprites can change x-direction instantly,
while airborne sprites maintain constant momentum, following a parabolic trajectory. Midair direction
changes are possible by pressing the opposite button, but these are delayed due to the need to overcome
initial momentum, aligning with standard 2D game physics.
*/


localparam TIME_START_X  =   800000;  // starting value for x_time & x_start registers
localparam TIME_STEP_X   =     6000;  // increment/decrement step for x_time register between sprite position updates
localparam TIME_MIN_X    =   500000;  // minimum time_x reg value (fastest updates between position movement
           
reg [1:0] x_state_reg, x_state_next;  // register for FSMD x motion state
reg [19:0] x_time_reg, x_time_next;   // register to keep track of count down/up time for x motion
reg [19:0] x_start_reg, x_start_next; // register to keep track of start time for count down/up for x motion

always @(posedge clk, posedge rst) begin
    if (rst) begin
        x_state_reg <= no_dir;
        x_start_reg <= 0;
        x_time_reg <= 0;
    end else begin
        x_state_reg <= x_state_next;
        x_start_reg <= x_start_next;
        x_time_reg <= x_time_next;
    end
end

always @* begin
    sprite_x_next = sprite_x_reg;
    x_state_next = x_state_reg;
    x_start_next = x_start_reg;
    x_time_next = x_time_reg;
    case(x_state_reg)
        no_dir:
            begin
                if(btnL && !btnR && (sprite_x_reg >= 1))begin
                    x_state_next = left;                                     
                    x_time_next  = TIME_START_X;                            
                    x_start_next = TIME_START_X;                            
                end else if(!btnL && btnR && (sprite_x_reg + 1 < MAX_X - TILE_WIDTH - X_D + 1)) begin
                    x_state_next = right;                                     
                    x_time_next  = TIME_START_X;                             
                    x_start_next = TIME_START_X;                             
                end
            end
       left:
            begin
                if(x_time_reg > 0) begin                                        
                    x_time_next = x_time_reg - 1;                             
                end else if(x_time_reg == 0) begin 
                    if(sprite_x_reg >= 17) begin                                       
                        sprite_x_next = sprite_x_reg - 1;
                    end                             
                    if(btnL && x_start_reg > TIME_MIN_X) begin                                               
                        x_start_next = x_start_reg - TIME_STEP_X;            
                        x_time_next  = x_start_reg - TIME_STEP_X;             
                    end else if(btnR && x_start_reg < TIME_START_X) begin                                                 
                        x_start_next = x_start_reg + TIME_STEP_X;              
                        x_time_next  = x_start_reg + TIME_STEP_X;               
                    end else begin
                        x_start_next = x_start_reg;                        
                        x_time_next  = x_start_reg;                             
                    end
                end
                    
                if(grounded && (!btnL || (btnL && btnR))) begin                 
                    x_state_next = no_dir;  
                end else if(!grounded && btnR && x_start_reg >= TIME_START_X)  begin
                    x_state_next = right;                                    
                    x_time_next  = TIME_START_X;                     
                    x_start_next = TIME_START_X;                       
                end
            end
                
        right:
            begin
                if (x_time_reg > 0) begin
                    x_time_next = x_time_reg - 1;   
                end else if(x_time_reg == 0)  begin
                    if(sprite_x_reg + 1 < MAX_X - TILE_WIDTH - X_D - 15) begin             
                        sprite_x_next = sprite_x_reg + 1;                              
                    end
                    if(btnR && x_start_reg > TIME_MIN_X) begin                                          
                        x_start_next = x_start_reg - TIME_STEP_X;       
                        x_time_next  = x_start_reg - TIME_STEP_X;      
                    end else if(btnL && x_start_reg < TIME_START_X) begin                                          
                        x_start_next = x_start_reg + TIME_STEP_X;    
                        x_time_next  = x_start_reg + TIME_STEP_X;   
                    end else begin
                        x_start_next = x_start_reg;                     
                        x_time_next  = x_start_reg;                   
                    end
                end
                        
                if(grounded && (!btnR || (btnL && btnR))) begin                    
                    x_state_next = no_dir;
                end else if(!grounded && btnL && x_start_reg >= TIME_START_X) begin
                    x_state_next = left;                                     
                    x_time_next  = TIME_START_X;                              
                    x_start_next = TIME_START_X;                           
                end
            end	
    endcase
end

/***********************************************************************************/
/*              FSMD for Sprite standing/walking states, and y motion              */  
/***********************************************************************************/  

/*
Motion in the y dimension is managed by a system that simulates gravity, incorporating a terminal velocity. 
Upon pressing the jump/up button, a start countdown value is loaded into the jump_t_reg, which decrements 
on clock edges until reaching zero, at which point the y position of the sprite is updated. With each update, 
the starting time loaded into the register increases, slowing the sprite's ascent until a maximum time value is 
reached, after which the sprite begins to descend. During descent, the jump_t_reg continues decrementing until 
zero, updating the sprite's position with increasingly shorter intervals between each update, accelerating the fall 
until a terminal velocity is achieved. This results in a motion where Yoshi jumps, slows as he reaches the apex, 
then accelerates downward. 

The duration the jump/up button is held increments the extra_up_reg, allowing Yoshi to achieve a higher jump based 
on how long the button is held. 

As the jumping mechanics necessitate different animations for ascending versus descending, the same finite state machine 
(FSM) that handles standing and walking also determines how Yoshi is drawn when jumping.
*/
localparam [2:0] standing = 3'b000, walking = 3'b001, jump_up = 3'b010, jump_extra = 3'b011, jump_down = 3'b100;

localparam TIME_START_Y = 100000;
localparam TIME_STEP_Y = 8000;
localparam TIME_MAX_Y = 600000;
localparam TIME_TERM_Y = 250000;
localparam BEGIN_COUNT_EXTRA = 450000;
localparam TILE_1_MAX = 7000000;
localparam TILE_2_MAX = 14000000;
localparam WALK_T_MAX = 21000000;

reg [2:0] state_reg_y, state_next_y;
reg [24:0] walk_t_reg, walk_t_next;
reg [19:0] jump_t_reg, jump_t_next;
reg [19:0] start_reg_y, start_next_y;
reg [6:0] dy;
reg [25:0] extra_up_reg, extra_up_next;

reg [7:0] btnU_reg;
wire btnU_edge;

assign btnU_edge = ~(&btnU_reg) & btnU;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        state_reg_y  <= standing;
        walk_t_reg   <= 0;
        jump_t_reg   <= 0;
        start_reg_y  <= 0;
        extra_up_reg <= 0;
        btnU_reg     <= 0;
    end else begin
        state_reg_y  <= state_next_y;
        walk_t_reg   <= walk_t_next;
        jump_t_reg   <= jump_t_next;
        start_reg_y  <= start_next_y;
        extra_up_reg <= extra_up_next;
        btnU_reg     <= {btnU_reg[6:0], btnU};
    end
end

always @* begin
    state_next_y  = state_reg_y;
    walk_t_next   = walk_t_reg;
    jump_t_next   = jump_t_reg;
    start_next_y  = start_reg_y;
    extra_up_next = extra_up_reg;
    sprite_y_next      = sprite_y_reg;
    dy            = 0;
    case(state_reg_y)
        standing:
            begin
                dy = 0;                  
                if((btnL && !btnR)  || (!btnL && btnR)) begin
                    state_next_y = walking;   
                    walk_t_next = 0;              
                end
                if(btnU_edge) begin
                    state_next_y = jump_up;      
                    start_next_y = TIME_START_Y;      
                    jump_t_next = TIME_START_Y;    
                    extra_up_next = 0;
                end
            end

        walking:
            begin
                if(!grounded) begin
                    state_next_y = jump_down;      
                    start_next_y = TIME_MAX_Y;   
                    jump_t_next  = TIME_MAX_Y;        
                end
                        
                if((!btnL && !btnR) || (btnL && btnR)) begin 
                    state_next_y = standing;           
                end

                if(btnU_edge) begin
                    state_next_y = jump_up;          
                    start_next_y = TIME_START_Y;      
                    jump_t_next = TIME_START_Y;        
                    extra_up_next = 0;               
                end
                            
                if(walk_t_reg < WALK_T_MAX) begin          
                    walk_t_next = walk_t_reg + 1;      
                end else begin
                    walk_t_next = 0; 
                end                
                    
                if(walk_t_reg <= TILE_1_MAX) begin         
                    dy = TILE_HEIGHT;                         
                end else if (walk_t_reg <= TILE_2_MAX) begin   
                    dy = 2*TILE_HEIGHT;                        
                end else if(walk_t_reg < WALK_T_MAX) begin     
                    dy = 0;                
                end            
            end
        
        jump_up:
            begin
                dy = 3*TILE_HEIGHT;                                   
                if(jump_t_reg > 0)  begin
                    jump_t_next = jump_t_reg - 1;              
                end
                if(jump_t_reg == 0) begin
                    if(btnU && start_reg_y > BEGIN_COUNT_EXTRA) begin
                        extra_up_next = extra_up_reg + 1;    
                    end
                end  
                if( sprite_y_next > MIN_Y) begin               
                    sprite_y_next = sprite_y_reg - 1;                
                end else  begin
                    state_next_y = jump_down;              
                    start_next_y = TIME_MAX_Y;             
                    jump_t_next  = TIME_MAX_Y;               
                end
                            
                if(start_reg_y <= TIME_MAX_Y) begin
                    start_next_y = start_reg_y + TIME_STEP_Y; 
                    jump_t_next = start_reg_y + TIME_STEP_Y; 
                end else begin
                    state_next_y = jump_extra;             
                    extra_up_next = extra_up_reg << 1;
                    start_next_y = TIME_MAX_Y;              
                    jump_t_next  = TIME_MAX_Y;               
                end
            end

        jump_extra:
            begin
                dy = 3 * TILE_HEIGHT;
                if (extra_up_reg == 0) begin
                    state_next_y = jump_down;   
                    start_next_y = TIME_MAX_Y;  
                    jump_t_next  = TIME_MAX_Y;        
                end
                if (jump_t_reg > 0) begin
                    jump_t_next = jump_t_reg - 1;
                end

                if (jump_t_reg == 0) begin
                    extra_up_next = extra_up_reg - 1;    
                    if( sprite_y_next > MIN_Y) begin    
                        sprite_y_next = sprite_y_reg - 1;    
                    end else begin 				
                        state_next_y = jump_down;   
                    end
                    start_next_y = TIME_MAX_Y;       
                    jump_t_next = TIME_MAX_Y;          
                end
            end
        
        jump_down:
            begin
                dy = 2 * TILE_HEIGHT;
                if (jump_t_reg > 0) begin
                    jump_t_next = jump_t_reg - 1;
                end

                if (jump_t_reg == 0) begin
                    if (!grounded) begin
                        sprite_y_next = sprite_y_reg + 1;
                        if (start_reg_y > TIME_TERM_Y) begin
                            start_next_y = start_reg_y - TIME_STEP_Y;
                            jump_t_next = start_reg_y - TIME_STEP_Y;
                        end else begin
                        jump_t_next = TIME_TERM_Y;
                    end
                    end else begin
                        state_next_y = standing;
                    end
                end
            end
    endcase
end



/*Rom Indexing*/

wire [3:0] col;
wire [6:0] row;

assign col = (dir_reg == RIGHT && head_on)  ? (X_D + TILE_WIDTH - 1 - (x - sprite_x_reg)) :
                (dir_reg == LEFT  && head_on)  ?                 ((x - sprite_x_reg)) :
                (dir_reg == RIGHT && torso_on) ?       (TILE_WIDTH - 1 - (x - sprite_x_reg)) :
                (dir_reg == LEFT  && torso_on) ?           ((x - sprite_x_reg - X_D)) : 0;

assign row = head_on ? (y - sprite_y_reg) : torso_on ? (dy + y - sprite_y_reg) : 0;

wire [11:0] color_data_yoshi, color_data_yoshi_ghost;

yoshi_rom yoshi_rom_unit (.clk(clk), .row(row), .col(col), .color_data(color_data_yoshi));

yoshi_ghost_rom yoshi_ghost_rom_unit (.clk(clk), .row(row), .col(col), .color_data(color_data_yoshi_ghost));

wire head_on, torso_on;

assign head_on = (dir_reg == RIGHT) && (x >= sprite_x_reg + X_D) && (x <= sprite_x_reg + X_MAX - 1) && (y >= sprite_y_reg) && (y <= sprite_y_reg + TILE_HEIGHT - 1) ? 1
                   : (dir_reg == LEFT) && (x >= sprite_x_reg) && (x <= sprite_x_reg + TILE_WIDTH - 1) && (y >= sprite_y_reg) && (y <= sprite_y_reg + TILE_HEIGHT - 1) ? 1 : 0;
   
assign torso_on = (dir_reg == RIGHT) && (x >= sprite_x_reg) && (x <= sprite_x_reg + TILE_WIDTH - 1) && (y >= sprite_y_reg + TILE_HEIGHT) && (y <= sprite_y_reg + 2*TILE_HEIGHT - 1) ? 1
                : (dir_reg == LEFT) && (x >= sprite_x_reg + X_D) && (x <= sprite_x_reg + X_MAX - 1) && (y >= sprite_y_reg + TILE_HEIGHT) && (y <= sprite_y_reg + 2*TILE_HEIGHT - 1) ? 1 : 0;

assign yoshi_x = sprite_x_reg;
assign yoshi_y = sprite_y_reg;

assign jumping_up = (state_reg_y == jump_up) ? 1 : 0;

assign direction = dir_reg;

reg [27:0] collision_time_reg;

wire [27:0] collision_time_next;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        collision_time_reg <= 0;
    end else begin
        collision_time_reg <= collision_time_next;
    end
end

assign collision_time_next = collision ? 200000000 : collision_time_reg > 0 ? collision_time_reg - 1 : 0;

always @* begin
    yoshi_on = 0;
    rgb_out = 0;
    if(head_on || torso_on && video_on) begin
        if(game_over_yoshi || collision_time_reg > 0) begin
            rgb_out = color_data_yoshi_ghost;  
        end else begin
            rgb_out = color_data_yoshi;            
        end
        if(rgb_out != 12'b011011011110) begin         
                yoshi_on = 1;           
        end        
    end
end

endmodule