
/* Course: CSCB58 SUMMER 2017
   Project Name - PC defender
   Member: Jikai Long, Michelle Pasquill
   Data Finished: July 27th, 2017
   Code Source:
https://github.com/MarioLongJACK/cscb58-project   Other Source Used: https://github.com/hughdingb58/b58project.git : datapath and control module
*/




// the following main module are from CSCB58 Lab6
module project58
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
        	// set HEX display to display health bar
		  HEX0,HEX1, HEX2, HEX3, HEX4, HEX6, HEX7,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [17:0]   SW;
	input   [3:0]   KEY;
	output [6:0] HEX0, HEX1, HEX2,HEX3,HEX4, HEX6, HEX7;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = SW[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	 reg [2:0] colour;// notice they were originally wire ,  I made them reg     edit:Mar20, 2:30am
    reg [6:0] x;
    reg [6:0] y;
    reg writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.mono.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.



    // The main player movement module is from Jerry Liu
    reg alwaysOne = 1'b1;
    reg alwaysZero = 1'b0;
	 reg speed1 = 2'b00;
	 reg speed2 = 2'b01;
	 reg speed3 = 2'b10;
   
    wire ld_x, ld_y;
    wire [3:0] stateNum;
    reg  [6:0] init_player_coord = 7'b0101111; // this is x coord
    wire [2:0] colour_player;
    wire [6:0] x_player;
    wire [6:0] y_player;
    wire writeEn_player;
    reg [25:0] counter_for_player = 26'b00000000000000000000000000;
    reg [6:0] init_y_p = 7'b1110000;
    reg [2:0] acolour_p = 3'b110;
    // Instansiate datapath                             
    datapath d0(.clk(CLOCK_50), .ld_x(ld_x), .ld_y(ld_y), .in(  init_player_coord), .reset_n(resetn), .x(x_player), .y(y_player), .colour(colour_player), .write(writeEn_player), .stateNum(stateNum), .init_y(init_y_p), .acolour(acolour_p));
   
    // Instansiate FSM control
    control c0(.clk(CLOCK_50), .move_r(SW[2]), .move_l(SW[5]), .move_d(SW[3]), .move_u(SW[4]), .reset_n(resetn), .ld_x(ld_x), .ld_y(ld_y), .stateNum(stateNum), .reset_game(reset_game), .dingding(counter_for_player), .how_fast(speed1));
    

    
    // --------------------------------------virus movement starts here, for all virus---------------------------------------------------------
    // ----------------------------------modify part of Jerry Liu's code for our use, added more modules for collision and health bar by Jikai Long
    wire ld_x_car0, ld_y_car0;
    wire [3:0] stateNum_car0;
    reg  [6:0] car0_coord = 7'b0101111;
    wire [2:0] colour_car0;
    wire [6:0] x_car0;
    wire [6:0] y_car0;
    wire writeEn_car0;
    reg [25:0] counter_for_car0 = 26'b00000000000000000000000001;
    reg [6:0] init_y_c0 = 7'b0000001;
    reg [2:0] ocolour_c0 = 3'b111;
    wire [2:0] acolour_c0;
    wire c0_movement;
    // Instansiate datapath                                
    datapath car_0_d(.clk(CLOCK_50), .ld_x(ld_x_car0), .ld_y(ld_y_car0), .in(  car0_coord), .reset_n(resetn), .x(x_car0), .y(y_car0), .colour(colour_car0), .write(writeEn_car0), .stateNum(stateNum_car0),  .init_y(init_y_c0), .acolour(acolour_c0));
   
    // Instansiate FSM control
    control car_0_c(.clk(CLOCK_50), .move_r(1'b0), .move_l(1'b0), .move_d(c0_movement),  .move_u(1'b0), .reset_n(resetn), .ld_x(ld_x_car0), .ld_y(ld_y_car0), .stateNum(stateNum_car0), .reset_game(alwaysZero), .dingding(counter_for_car0), .how_fast(speed2));
    //The outputs are: x_car0, y_car0, colour_car0, writeEn_car0

    // Instansiate collision generator to deal with collisions between characters added on July 15th by Jikai Long
    collision_generator collision_car0(.clock(CLOCK_50), .reset_bot(SW[8]), .player_x(x_player), .player_y(y_player), .bot_x(x_car0), .bot_y(y_car0), .bot_colour(ocolour_c0), .bot_output_colour(acolour_c0), .bot_movement(c0_movement), .hex_display(HEX0));

	 
	 
	 
	 
    //virus0 movement ends here----------------------------------------------------------------------------------------------------
    wire ld_x_car1, ld_y_car1;
    wire [3:0] stateNum_car1;
    reg  [6:0] car1_coord = 7'b0111111;
    wire [2:0] colour_car1;
    wire [6:0] x_car1;
    wire [6:0] y_car1;
    wire writeEn_car1;
    reg [25:0] counter_for_car1 = 26'b00000000000000000000000010;
    reg [6:0] init_y_c1 = 7'b0000011;
    reg [2:0] ocolour_c1 = 3'b111;
    wire [2:0] acolour_c1;
    wire c1_movement;
    // Instansiate datapath                                
    datapath car_1_d(.clk(CLOCK_50), .ld_x(ld_x_car1), .ld_y(ld_y_car1), .in(  car1_coord), .reset_n(resetn), .x(x_car1), .y(y_car1), .colour(colour_car1), .write(writeEn_car1), .stateNum(stateNum_car1),  .init_y(init_y_c1), .acolour(acolour_c1));
   
    // Instansiate FSM control
    control car_1_c(.clk(CLOCK_50), .move_r(1'b0), .move_l(1'b0), .move_d(c1_movement),  .move_u(1'b0), .reset_n(resetn), .ld_x(ld_x_car1), .ld_y(ld_y_car1), .stateNum(stateNum_car1), .reset_game(alwaysZero), .dingding(counter_for_car1), .how_fast(speed2));
    //The outputs are: x_car1, y_car1, colour_car1, writeEn_car1

    // Instansiate collision generator to deal with collisions between characters added on July 15th by Jikai Long
    collision_generator collision_car1(.clock(CLOCK_50), .reset_bot(SW[9]), .player_x(x_player), .player_y(y_player), .bot_x(x_car1), .bot_y(y_car1), .bot_colour(ocolour_c1), .bot_output_colour(acolour_c1), .bot_movement(c1_movement), .hex_display(HEX1));  
	//virus1 movement ends here----------------------------------------------------------------------------------------------------

	
	wire ld_x_car2, ld_y_car2;
    wire [3:0] stateNum_car2;
    reg  [6:0] car2_coord = 7'b1001111;
    wire [2:0] colour_car2;
    wire [6:0] x_car2;
    wire [6:0] y_car2;
    wire writeEn_car2;
    reg [25:0] counter_for_car2 = 26'b00000000000000000000000011;
    reg [6:0] init_y_c2 = 7'b0000001;
    reg [2:0] ocolour_c2 = 3'b111;
    wire [2:0] acolour_c2;
    wire c2_movement;
    // Instansiate datapath                                
    datapath car_2_d(.clk(CLOCK_50), .ld_x(ld_x_car2), .ld_y(ld_y_car2), .in(car2_coord), .reset_n(resetn), .x(x_car2), .y(y_car2), .colour(colour_car2), .write(writeEn_car2), .stateNum(stateNum_car2),  .init_y(init_y_c2), .acolour(acolour_c2));
   
    // Instansiate FSM control
    control car_2_c(.clk(CLOCK_50), .move_r(1'b0), .move_l(1'b0), .move_d(c2_movement),  .move_u(1'b0), .reset_n(resetn), .ld_x(ld_x_car2), .ld_y(ld_y_car2), .stateNum(stateNum_car2), .reset_game(alwaysZero), .dingding(counter_for_car2), .how_fast(speed2));
    //The outputs are: x_car1, y_car1, colour_car1, writeEn_car1

    // Instansiate collision generator to deal with collisions between characters added on July 15th by Jikai Long
    collision_generator collision_car2(.clock(CLOCK_50), .reset_bot(SW[10]), .player_x(x_player), .player_y(y_player), .bot_x(x_car2), .bot_y(y_car2), .bot_colour(ocolour_c2), .bot_output_colour(acolour_c2), .bot_movement(c2_movement), .hex_display(HEX2));  
	//virus2 movement ends here----------------------------------------------------------------------------------------------------

	
	
	wire ld_x_car3, ld_y_car3;
    wire [3:0] stateNum_car3;
    reg  [6:0] car3_coord = 7'b1001110;
    wire [2:0] colour_car3;
    wire [6:0] x_car3;
    wire [6:0] y_car3;
    wire writeEn_car3;
    reg [25:0] counter_for_car3 = 26'b00000000000000000000000100;
    reg [6:0] init_y_c3 = 7'b0000001;
    reg [2:0] ocolour_c3 = 3'b111;
    wire [2:0] acolour_c3;
    wire c3_movement;
    // Instansiate datapath                                
    datapath car_3_d(.clk(CLOCK_50), .ld_x(ld_x_car3), .ld_y(ld_y_car3), .in(  car3_coord), .reset_n(resetn), .x(x_car3), .y(y_car3), .colour(colour_car3), .write(writeEn_car3), .stateNum(stateNum_car3),  .init_y(init_y_c3), .acolour(acolour_c3));
   
    // Instansiate FSM control
    control car_3_c(.clk(CLOCK_50), .move_r(1'b0), .move_l(1'b0), .move_d(c3_movement),  .move_u(1'b0), .reset_n(resetn), .ld_x(ld_x_car3), .ld_y(ld_y_car3), .stateNum(stateNum_car3), .reset_game(alwaysZero), .dingding(counter_for_car3), .how_fast(speed2));
    //The outputs are: x_car1, y_car1, colour_car1, writeEn_car1

    // Instansiate collision generator to deal with collisions between characters added on July 15th by Jikai Long
    collision_generator collision_car3(.clock(CLOCK_50), .reset_bot(SW[11]), .player_x(x_player), .player_y(y_player), .bot_x(x_car3), .bot_y(y_car3), .bot_colour(ocolour_c3), .bot_output_colour(acolour_c3), .bot_movement(c3_movement), .hex_display(HEX3));  
	//virus3 movement ends here----------------------------------------------------------------------------------------------------

	wire ld_x_car4, ld_y_car4;
    wire [3:0] stateNum_car4;
    reg  [6:0] car4_coord = 7'b0101010;
    wire [2:0] colour_car4;
    wire [6:0] x_car4;
    wire [6:0] y_car4;
    wire writeEn_car4;
    reg [25:0] counter_for_car4 = 26'b00000000000000000000000101;
    reg [6:0] init_y_c4 = 7'b0000001;
    reg [2:0] ocolour_c4 = 3'b111;
    wire [2:0] acolour_c4;
    wire c4_movement;
    // Instansiate datapath                                
    datapath car_4_d(.clk(CLOCK_50), .ld_x(ld_x_car4), .ld_y(ld_y_car4), .in(  car4_coord), .reset_n(resetn), .x(x_car4), .y(y_car4), .colour(colour_car4), .write(writeEn_car4), .stateNum(stateNum_car4),  .init_y(init_y_c4), .acolour(acolour_c4));
   
    // Instansiate FSM control
    control car_4_c(.clk(CLOCK_50), .move_r(1'b0), .move_l(1'b0), .move_d(c4_movement),  .move_u(1'b0), .reset_n(resetn), .ld_x(ld_x_car4), .ld_y(ld_y_car4), .stateNum(stateNum_car4), .reset_game(alwaysZero), .dingding(counter_for_car4), .how_fast(speed2));
    //The outputs are: x_car1, y_car1, colour_car1, writeEn_car1

    // Instansiate collision generator to deal with collisions between characters added on July 15th by Jikai Long
    collision_generator collision_car4(.clock(CLOCK_50), .reset_bot(SW[12]), .player_x(x_player), .player_y(y_player), .bot_x(x_car4), .bot_y(y_car4), .bot_colour(ocolour_c4), .bot_output_colour(acolour_c4), .bot_movement(c4_movement), .hex_display(HEX4));  
	//virus4 movement ends here----------------------------------------------------------------------------------------------------
	
	// the following are the connection part between VGA Screen and user input from Jerry Liu arranged by Jikai
	always @(posedge CLOCK_50)
    begin
        if(writeEn_player) 
            begin
                writeEn <= writeEn_player;   
                x <= x_player;       
                y <= y_player;
                colour = colour_player; 
            end
        else if (writeEn_car0)    
            begin
                writeEn <= writeEn_car0;    
                x <= x_car0;                       
                y <= y_car0;
                colour <= colour_car0;
            end  
		  else if (writeEn_car1)    
            begin
                writeEn <= writeEn_car1;
                x <= x_car1;                       
                y <= y_car1;
                colour <= colour_car1;
            end  
		  else if (writeEn_car2)    
            begin
                writeEn <= writeEn_car2;
                x <= x_car2;                       
                y <= y_car2;
                colour <= colour_car2;
            end  
		  else if (writeEn_car3)    
            begin
                writeEn <= writeEn_car3;
                x <= x_car3;                       
                y <= y_car3;
                colour <= colour_car3;
            end
		  else if (writeEn_car4)    
            begin
                writeEn <= writeEn_car4;
                x <= x_car4;                       
                y <= y_car4;
                colour <= colour_car4;
            end  
	end

// added the overall timer for the game by Jikai and Michelle
timer overall_timer(.hex1(HEX6), .hex2(HEX7), .car0(c0_movement), .car1(c1_movement), .car2(c2_movement), .car3(c3_movement), .car4(c4_movement),  .clock(CLOCK_50), .reset(resetn));
endmodule	
// the arrangement of the main module is finished on 27th July, 2017


/* the following module:
control, datapath, rate_divider_for_cars are implemented by Jerry Liu and we didnt modify any of the code
*/

module control(clk, move_r, move_l, move_d, move_u, reset_n, ld_x, ld_y, stateNum, reset_game, dingding, how_fast);
    input [25:0] dingding; // dingding is the counter! It counts like this: Ding!!! Ding!!! Ding!!! Ding!!! Ding!!!
    input reset_game;
    input clk, move_r, move_l, move_d, move_u, reset_n;
	 input [1:0] how_fast;
    output reg ld_y, ld_x;
    reg [3:0] curr, next;
    output reg [3:0] stateNum;
    localparam    S_CLEAR    = 4'b0000;
    localparam S_LOAD_X    = 4'b0001;
    localparam S_WAIT_Y    = 4'b0010;
    localparam S_LOAD_Y    = 4'b0011;
   
    localparam    wait_input    = 4'b0100;
    localparam    clear_all    = 4'b0101;
    localparam    print_right    = 4'b0110;
    localparam    print_left    = 4'b0111;
    localparam    print_down    = 4'b1000;
    localparam    print_up    = 4'b1001;
    localparam  temp_selecting_state = 4'b1010;
    localparam after_drawing = 4'b1011;
    localparam cleanUp = 4'b1100;
    wire [26:0] press_now;   
    wire [26:0] press_now_for_car;   
    wire result_press_now;
	 reg [25:0] speed;
    //wire result_for_car;
    
	 always @(*)
	 begin
		if (how_fast == 2'b00)
		   speed <= 26'b0101111101011110000100;

		else if (how_fast == 2'b01)
		   speed <= 26'b010111110101111000010;
		else
		   speed <= 26'b01011111010111100001;
	 end
	 RateDividerForCar player_counter1(clk, press_now, reset_n, speed);
	 
    assign result_press_now = (press_now == dingding) ? 1 : 0;
   
    always @(*)
    begin: state_table
        case (curr)
            S_CLEAR: next = S_LOAD_X ;
            S_LOAD_X: next = S_WAIT_Y;
            S_WAIT_Y: next = S_LOAD_Y;
 
            S_LOAD_Y: next = temp_selecting_state; // the next line is edited on Mar 27
            temp_selecting_state: next = reset_game ? cleanUp : ( ((move_r || move_l || move_d || move_u) && result_press_now) ? clear_all : S_LOAD_Y );
           
            clear_all:
                begin
                    if(move_r)  // is this how to connect two wires ?????????????????????????????????????????????????????????
                        next <= print_right;
                    else if (move_l)    // if player isnt moving, then let the car move
                        next <= print_left;
                    else if (move_d)   // if player isnt moving, then let the car move
                        next <= print_down;
                    else if (move_u)   // if play er isnt moving, then let the car move
                        next <= print_up;
                end
            cleanUp: next = S_CLEAR;
            //
            print_right: next = reset_game ? S_LOAD_Y : after_drawing;
            print_left: next =  reset_game ? S_LOAD_Y : after_drawing;
            print_down: next = reset_game ? S_LOAD_Y : after_drawing;
            print_up: next = reset_game ? S_LOAD_Y : after_drawing;
            after_drawing: next= temp_selecting_state;
           
        default: next = S_CLEAR;
        endcase
    end

    always@(*)
    begin: enable_signals
        ld_x = 1'b0;
        ld_y = 1'b0;
        //write = 1'b0;
        stateNum = 4'b0000;
        case (curr)
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
            S_LOAD_Y: begin
                ld_y = 1'b1;
                end
            cleanUp: begin // this IS suppose to be the same as clear all (edited on mar27)
                stateNum = 4'b0001;
                ld_y = 1'b0;
                //write = 1'b1;
                end
            clear_all: begin
                stateNum = 4'b0001;
                ld_y = 1'b0;
                //write = 1'b1;
                end
           
            print_right: begin
                stateNum = 4'b0100;
                ld_y = 1'b0;
                //write = 1'b1;
                end
           
            print_down: begin
                stateNum = 4'b0011;
                ld_y = 1'b0;
                //write = 1'b1;
                end
               
            print_left: begin
                stateNum = 4'b0010;
                ld_y = 1'b0;
   
                //write = 1'b1;
                end
               
            print_up: begin
                stateNum = 4'b1001;
                ld_y = 1'b0;
   
                //write = 1'b1;
                end
               
            after_drawing: begin
                stateNum = 4'b1000;
                end
           
           
        endcase
    end

    always @(posedge clk)
    begin: states
        if(!reset_n)
            curr <= S_LOAD_X;
        else
            curr <= next;
    end
endmodule             


module datapath(clk, ld_x, ld_y, in, reset_n, x, y, colour, stateNum, write, init_y, acolour);
    input clk;
    input [6:0] in;
    input [6:0] init_y;
    input [2:0] acolour;
    input ld_x, ld_y;
    input reset_n;
    output reg [2:0] colour;
    output reg write;
    output reg [6:0] y;
    output reg [6:0] x;
    input [3:0] stateNum;

    always @(posedge clk)
    begin
        if(!reset_n)
        begin
            x <= 6'b000000;
            y <= 6'b000000;
            colour <= 3'b000;
        end
        else
        begin//car0 movement ends here----------------------------------------------------------------------------------------------------
            if(ld_x)
                begin
                    x[6:0] <= in;
                    y <= init_y;
                    write <= 1'b0;
                end
            else if(ld_y)
                begin
                    write <= 1'b0;
                end
               
            // The following is for clearing
            else if(stateNum == 4'b0001)
                begin
                    colour <= 3'b000;
                    write <= 1'b1;
                end
               
            // The following is for moving right
            else if(stateNum == 4'b0100)   
                begin
               
                    x[6:0] <= x + 6'b000001;
                    colour <= acolour;
                    write <= 1'b1;
                end
               
            // The following is for moving left
            else if(stateNum == 4'b0010)   
                begin
               
                    x[6:0] <= x - 6'b000001;
                    colour <= acolour;
                    write <= 1'b1;
                end
               
            // The following is for moving down
            else if(stateNum == 4'b0011)
					 begin
							begin
							if (x != 7'b1110000)
								begin
						  
								  y[6:0] <= y + 6'b000001;
								  colour <= acolour;
								  write <= 1'b1;
								end
							else
									write <= 1'b0;
							
							end
                end
             
            else if(stateNum == 4'b1001)//for moving up
                begin
                              
                    y[6:0] <= y - 6'b000001;
                    colour <= acolour;
                    write <= 1'b1;
                end
               
            else if(stateNum == 4'b1000)//after drawin//car0 movement ends here----------------------------------------------------------------------------------------------------g
                begin
                    write <= 1'b0;
                end
               
        end
    end
   
endmodule


module RateDividerForCar (clock, q, Clear_b, how_speedy);  // Note that car is 4 times faster than the player
    input [0:0] clock;
    input [0:0] Clear_b;
	 input [25:0] how_speedy;
    output reg [26:0] q; // declare q
    //wire [27:0] d; // declare d, not needed
    always@(posedge clock)   // triggered every time clock rises
    begin
    // else if (ParLoad == 1'b1) // Check if parallel load, not needed!!!!
    //        q <= d; // load d
        if (q == how_speedy) // when q is the maximum value for the counter, this number is 50 million - 1
            q <= 0; // q reset to 0
        else if (clock == 1'b1) // increment q only when Enable is 1
            q <= q + 1'b1;  // increment q
    //    q <= q - 1'b1;  // decrement q
    end
endmodule


//added by Jikai Long on 15th July
// this module will deal with collisions between characters 
module collision_generator(clock, reset_bot, player_x, player_y, bot_x, bot_y, bot_colour, bot_output_colour, bot_movement, hex_display);
	// initialize the input
	input clock, reset_bot;
	input [6:0] player_x, player_y, bot_x, bot_y;
	input [2:0] bot_colour;
	output reg [2:0] bot_output_colour;
	output reg bot_movement;
	reg [3:0] health;
	wire [19:0] time_counter;
	output [6:0] hex_display;
	// triggers everytime the clock rises 
	always @(posedge clock)
		begin 
		// if the bot is reset, restore full health
		if(reset_bot) 
			begin
			health <= 4'b1001;
			end
		// not reset and health is 0, drawing colour to be black and stop its movement
		
		else if(health == 4'b0000)
			begin
			bot_output_colour <= 3'd000;
			bot_movement <= 1'b0;
			end
		// health is not 0 when a collision happens, decreate health by 1
		else if(player_x == bot_x && player_y == bot_y )
			begin
				if(health == 4'b0001)
					begin 
					health <= 4'b0000;
					end
				else if(time_counter == 20'b000000000000001)
					begin
					health <= health -1;
					end
			end
		else    
			begin
			bot_output_colour <= bot_colour;
			bot_movement <= 1'b1;
			end
		end
	// display health on hex_decorder
	hex_decoder my_hex(.hex_digit(health), .segments(hex_display));
	rate_divider_for_health_bar my_health_divider(.clock(clock), .reset(reset_bot), .count(time_counter));
endmodule 

// added on 24th July 2017 by Jikai Long, a rate divider for health bar
module rate_divider_for_health_bar(clock, reset, count);
	input clock, reset; 
	output reg [19:0] count;
	always @ (posedge clock)
	begin
	if(reset)
		begin
		count <= 20'b10000000000000000000;
		end
	else	
		begin
		if(count == 20'b00000000000000000000)
			begin
			count <= 20'b10000000000000000000;
			end
		else
			begin
			count <= count - 1'b1;
			end
		end
	end
endmodule		
			
		
// hex display from previous lab

module hex_decoder(hex_digit, segments);

    input [3:0] hex_digit;

    output reg [6:0] segments;

   

    always @(*)

        case (hex_digit)

            4'h0: segments = 7'b100_0000;

            4'h1: segments = 7'b111_1001;

            4'h2: segments = 7'b010_0100;

            4'h3: segments = 7'b011_0000;

            4'h4: segments = 7'b001_1001;

            4'h5: segments = 7'b001_0010;

            4'h6: segments = 7'b000_0010;

            4'h7: segments = 7'b111_1000;

            4'h8: segments = 7'b000_0000;

            4'h9: segments = 7'b001_1000;

            4'hA: segments = 7'b000_1000;

            4'hB: segments = 7'b000_0011;

            4'hC: segments = 7'b100_0110;
	
            4'hD: segments = 7'b010_0001;

            4'hE: segments = 7'b000_0110;

            4'hF: segments = 7'b000_1110;   

            default: segments = 7'h7f;
				endcase
endmodule


// added on 26th July, 2017 by Michelle, an overall timer implemented for the score counter
module timer (hex1, hex2, car0, car1, car2, car3, car4,  clock, reset);
input clock;
				
input reset;
input [0:0] car0, car1, car2, car3, car4;
output [6:0] hex1, hex2;

reg [7:0] count = 8'b00000000;
reg [28:0] speed = 29'b0111011100110101100101010000000;
reg [28:0] out;

always @(posedge clock)
	begin
		if(!reset)
		begin
			count <= 4'b0000;
		end
		else
		begin
			if ((out == speed) && ((car0 != 1'b0) || (car1 != 1'b0) || (car2 != 1'b0) || (car3 != 1'b0) || (car4 !=1'b0)))
				begin
				out <= 0;
				count <= count + 1'b1;
				end
			else if ((clock == 1'b1) && ((car0 != 1'b0) || (car1 != 1'b0) || (car2 != 1'b0) || (car3 != 1'b0) || (car4 != 1'b0)))
				begin
				out <= out + 1'b1;
				end
		end
	end

// Put Hex decoder here, and input count as the number.
hex_decoder first_4_digit(.hex_digit(count[3:0]), .segments(hex1));
hex_decoder last_4_digit(.hex_digit(count[7:4]), .segments(hex2));

endmodule
