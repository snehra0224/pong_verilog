`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:15:38 12/14/2017 
// Design Name: 
// Module Name:    vgaBitChange 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
// Date: 04/04/2020
// Author: Yue (Julien) Niu
// Description: Port from NEXYS3 to NEXYS4
//////////////////////////////////////////////////////////////////////////////////
module pong_vga_bitchange(
	input clk,
	input bright,
	input p1_button_u,
	input p1_button_d,
	input p2_button_u,
	input p2_button_d,
	input start_btn,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [15:0] score1,
	output reg [15:0] score2
   );
	
	parameter BLACK = 12'b0000_0000_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	//parameter BLUE = 12'b0000_0000_1111;

	wire p1_paddle;
	wire p2_paddle;
	wire ball;
	reg enable;

	reg [27:0]  divclk;

	reg reset;
	reg[49:0] I;
	reg[49:0] J;
	reg[49:0] K;

	//determines trajectory of the ball
	//00 = down and to the left
	//01 = down and to the right
	//10 = up and to the left
	//11 = up and to the right
	reg[1:0] trajectory_sign;

	reg[9:0] p1_paddle_mid;// center of paddle 1
	reg[9:0] p2_paddle_mid;//center of paddle 2
	reg[9:0] ball_mid_x;//x coordinate of ball center
	reg[9:0] ball_mid_y;//y coordinate of ball center
	reg[1:0] ball_shift_x;//shift values for ball in x direction
	reg[1:0] ball_shift_y;//shift values for ball in y direction

	initial begin
		p1_paddle_mid = 10'd275;
		p2_paddle_mid = 10'd275;
		ball_mid_x = 10'd464;
		ball_mid_y = 10'd275;
		score1 = 15'd0;
		score2 = 15'd0;
		reset = 1'b0;
		I = 50'd0;
		J = 50'd0;
		K = 50'd0;
		trajectory_sign = 2'b00;
		ball_shift_x = 2'd1;
		ball_shift_y = 2'd1;
		enable = 1'b0;
	end
	
	//divided clock to use for randomizing initial ball trajectory
	always @(posedge clk) 	
	    begin							
	        if (reset)
		        begin
					divclk <= 0;
					reset <= 1;
				end
	        else
				divclk <= divclk + 1'b1;
	    end

	always@ (*) // paint a white box on a red background
         begin 
         	//paint paddles, ball, and background
            if (p1_paddle == 1 || p2_paddle == 1 || ball == 1)
                rgb = WHITE;
            else
                rgb = BLACK;

            //paint the scores on the screen using seven segment approach
            if(score1 == 16'd0 && ((p1_seg1 == 1) || (p1_seg2 == 1) || (p1_seg3 == 1) || (p1_seg4 == 1) || (p1_seg5 == 1) || (p1_seg6 == 1)))
            	rgb = WHITE;
            if(score1 == 16'd1 && ((p1_seg2 == 1) || (p1_seg3 == 1)))
            	rgb = WHITE;
            if(score1 == 16'd2 && ((p1_seg1 == 1) || (p1_seg2 == 1) || (p1_seg7 == 1) || (p1_seg5 == 1) || (p1_seg4 == 1)))
            	rgb = WHITE;
            if(score1 == 16'd3 && ((p1_seg1 == 1) || (p1_seg2 == 1) || (p1_seg3 == 1) || (p1_seg4 == 1) || (p1_seg7 == 1)))
            	rgb = WHITE;
           	if(score1 == 16'd4 && ((p1_seg2 == 1) || (p1_seg3 == 1) || (p1_seg6 == 1) || (p1_seg7 == 1)))
           		rgb = WHITE;
           	if(score1 == 16'd5 && ((p1_seg1 == 1) || (p1_seg3 == 1) || (p1_seg4 == 1) || (p1_seg6 == 1) || (p1_seg7 == 1)))
           		rgb = WHITE;
           	if(score1 == 16'd6 && ((p1_seg1 == 1) || (p1_seg3 == 1) || (p1_seg4 == 1) || (p1_seg5 == 1) || (p1_seg6 == 1) || (p1_seg7 == 1)))
           		rgb = WHITE;
           	if(score1 == 16'd7 && ((p1_seg1 == 1) || (p1_seg2 == 1) || (p1_seg3 == 1)))
           		rgb = WHITE;
           	if(score1 == 16'd8 && ((p1_seg1 == 1) || (p1_seg2 == 1) || (p1_seg3 == 1) || (p1_seg4 == 1) || (p1_seg5 == 1) || (p1_seg6 == 1) || (p1_seg7 == 1)))
           		rgb = WHITE;
           	if(score1 == 16'd9 && ((p1_seg1 == 1) || (p1_seg2 == 1) || (p1_seg3 == 1) || (p1_seg6 == 1) || (p1_seg7 == 1)))
           		rgb = WHITE;
           	if(score1 == 16'd10 && (p1_one == 1 || (p1_seg1 == 1) || (p1_seg2 == 1) || (p1_seg3 == 1) || (p1_seg4 == 1) || (p1_seg5 == 1) || (p1_seg6 == 1)))
           		rgb = WHITE;

           	if(score2 == 16'd0 && ((p2_seg1 == 1) || (p2_seg2 == 1) || (p2_seg3 == 1) || (p2_seg4 == 1) || (p2_seg5 == 1) || (p2_seg6 == 1)))
            	rgb = WHITE;
            if(score2 == 16'd1 && ((p2_seg2 == 1) || (p2_seg3 == 1)))
            	rgb = WHITE;
            if(score2 == 16'd2 && ((p2_seg1 == 1) || (p2_seg2 == 1) || (p2_seg7 == 1) || (p2_seg5 == 1) || (p2_seg4 == 1)))
            	rgb = WHITE;
            if(score2 == 16'd3 && ((p2_seg1 == 1) || (p2_seg2 == 1) || (p2_seg3 == 1) || (p2_seg4 == 1) || (p2_seg7 == 1)))
            	rgb = WHITE;
           	if(score2 == 16'd4 && ((p2_seg2 == 1) || (p2_seg3 == 1) || (p2_seg6 == 1) || (p2_seg7 == 1)))
           		rgb = WHITE;
           	if(score2 == 16'd5 && ((p2_seg1 == 1) || (p2_seg3 == 1) || (p2_seg4 == 1) || (p2_seg6 == 1) || (p2_seg7 == 1)))
           		rgb = WHITE;
           	if(score2 == 16'd6 && ((p2_seg1 == 1) || (p2_seg3 == 1) || (p2_seg4 == 1) || (p2_seg5 == 1) || (p2_seg6 == 1) || (p2_seg7 == 1)))
           		rgb = WHITE;
           	if(score2 == 16'd7 && ((p2_seg1 == 1) || (p2_seg2 == 1) || (p2_seg3 == 1)))
           		rgb = WHITE;
           	if(score2 == 16'd8 && ((p2_seg1 == 1) || (p2_seg2 == 1) || (p2_seg3 == 1) || (p2_seg4 == 1) || (p2_seg5 == 1) || (p2_seg6 == 1) || (p2_seg7 == 1)))
           		rgb = WHITE;
           	if(score2 == 16'd9 && ((p2_seg1 == 1) || (p2_seg2 == 1) || (p2_seg3 == 1) || (p2_seg6 == 1) || (p2_seg7 == 1)))
           		rgb = WHITE;
           	if(score2 == 16'd10 && (p2_one == 1 || (p2_seg1 == 1) || (p2_seg2 == 1) || (p2_seg3 == 1) || (p2_seg4 == 1) || (p2_seg5 == 1) || (p2_seg6 == 1)))
           		rgb = WHITE;
        end

    //start the game using enable signal, and check to see if ball is in legal region
	always@ (posedge clk)
	   begin
		if(start_btn == 1'b1 && enable == 1'b0)
			begin
				enable <= 1'b1; //disable after 10 rounds
				if(score1 == 16'd10 || score2 == 16'd10)
					begin
						score1 = 16'd0;
						score2 = 16'd0;
					end
			end
				//ball exits legal region, increment score
				if((ball_mid_x + 5 >= 10'd727) && (enable == 1'b1) && (start_btn == 1'b0))
					begin
						enable <= 1'b0;
						score1 = score1 + 1;
					end 
				else if((ball_mid_x - 5 <= 10'd200) && (enable == 1'b1) && (start_btn == 1'b0))
					begin
						enable <= 1'b0;
						score2 = score2 + 1;
					end
		end

	//control paddle position for both players
	always@ (posedge clk)
	begin
		if(enable == 1'b1)
			//control player 1 paddle
			begin
				if ((p1_button_u == 1'b1) && (hCount >= 10'd144) && (hCount <= 10'd784) && (p1_paddle_mid >= 10'd64))
					begin
						if(I < 50'd500000)//paddle moves every 500000 clocks to account for high clock speed
							begin
								I = I + 50'd1;
							end
						else
							begin
								I = 50'd0;
								p1_paddle_mid = p1_paddle_mid - 10'd1;
							end
					end
				else if ((p1_button_d == 1'b1) && (hCount >= 10'd144) && (hCount <= 10'd784) && (p1_paddle_mid <= 10'd484))
					begin
						if(I < 50'd500000)//paddle moves every 500000 clocks to account for high clock speed
							begin
								I = I + 50'd1;
							end
						else
							begin
								I = 50'd0;
								p1_paddle_mid = p1_paddle_mid + 10'd1;
							end
					end
				//control player 2 paddle
				if ((p2_button_u == 1'b1) && (hCount >= 10'd144) && (hCount <= 10'd784) && (p2_paddle_mid >= 10'd64))
					begin
						if(J < 50'd500000)//paddle moves every 500000 clocks to account for high clock speed
							begin
								J = J + 50'd1;
							end
						else
							begin
								J = 50'd0;
								p2_paddle_mid = p2_paddle_mid - 10'd1;
							end
					end 
				else if ((p2_button_d == 1'b1) && (hCount >= 10'd144) && (hCount <= 10'd784) && (p2_paddle_mid <= 10'd484))
					begin
						if(J < 50'd500000)//paddle moves every 500000 clocks to account for high clock speed
							begin
								J = J + 50'd1;
							end
						else
							begin
								J = 50'd0;
								p2_paddle_mid = p2_paddle_mid + 10'd1;
							end
					end 
			end
		else//initialize paddle position when enable signal is low
			begin
				p1_paddle_mid = 10'd275;
				p2_paddle_mid = 10'd275;
			end
	end

	//handle ball movement and collisions
	always@(posedge clk)
	begin
		//initialize ball trajectory based on divclk, enabling pseudorandom start trajectory
		if(start_btn == 1'b1 && enable == 1'b0)
			begin
				trajectory_sign = divclk[1:0];
				ball_shift_x = 2'd1 + divclk[2];
				ball_shift_y = 2'd1 + divclk[2];
			end

		if(enable == 1'b1)
			begin
				//perform ball movement
				if(K < 50'd1000000)//ball moves every 500000 clocks to account for high clock speed
					begin
						K = K + 50'd1;
					end
				else
					begin
						K = 50'd0;
						case (trajectory_sign)//perform appropriate movement based on current ball trajectory
						2'b00:
				            begin
				                ball_mid_x = ball_mid_x - ball_shift_x;
				                ball_mid_y = ball_mid_y + ball_shift_y;
				            end
						2'b01:
				            begin 
				                ball_mid_x = ball_mid_x + ball_shift_x;
				                ball_mid_y = ball_mid_y + ball_shift_y;
				            end
						2'b10:
				            begin
				                ball_mid_x = ball_mid_x - ball_shift_x;
				                ball_mid_y = ball_mid_y - ball_shift_y;
				            end
						2'b11:
				            begin
				                ball_mid_x = ball_mid_x + ball_shift_x;
				                ball_mid_y = ball_mid_y - ball_shift_y;
				            end
						endcase
					end

				//wall collisions: shift values do not change when colliding with walls
				if(ball_mid_y + 5 >= 10'd516)
					if(trajectory_sign[0] == 0)//hit bottom wall while going left
						begin
							trajectory_sign <= 2'b10;
						end
					else					   //hit bottom wall while going right
						begin
							trajectory_sign <= 2'b11;
						end
				else if(ball_mid_y - 5 <= 10'd34)
					if(trajectory_sign[0] == 0)//hit top wall while going left
						begin
							trajectory_sign <= 2'b00;
						end
					else                       //hit top wall while going right
						begin
							trajectory_sign <= 2'b01;
						end

				//paddle collisions
				//check to see if ball has hit any part of paddle 1
				if(((ball_mid_x - 5 <= 10'd210) && (ball_mid_x - 5 >= 10'd200)) && ((ball_mid_y < p1_paddle_mid + 30) && (ball_mid_y > p1_paddle_mid - 30)))
					begin
						//adjust the trajectory of the ball appropriately
						if(trajectory_sign[1] == 1)
							begin
								trajectory_sign = 2'b11;
							end
						else
							begin
								trajectory_sign = 2'b01;
							end
						//modify the shift values for the ball based on what part of the paddle it collides with
						//there are 5 regions, and three different possible shift combinations
						//by varying the shift values, the angle of deflection of the paddle, as well as ball speed, are changed
						if((ball_mid_y <= p1_paddle_mid + 30) && (ball_mid_y >= p1_paddle_mid + 18))
							begin
								ball_shift_x = 2'd2;
								ball_shift_y = 2'd3;
							end
						else if ((ball_shift_y < p1_paddle_mid + 18) && (ball_shift_y >= p1_paddle_mid + 6))
							begin
								ball_shift_x = 2'd2;
								ball_shift_y = 2'd1;
							end
						else if ((ball_shift_y < p1_paddle_mid + 6) && (ball_shift_y >= p1_paddle_mid - 6))
							begin
								ball_shift_x = 2'd1;
								ball_shift_y = 2'd1;
							end
						else if ((ball_shift_y < p1_paddle_mid - 6) && (ball_shift_y >= p1_paddle_mid - 18))
							begin
								ball_shift_x = 2'd2;
								ball_shift_y = 2'd1;
							end
						else if ((ball_shift_y < p1_paddle_mid - 18) && (ball_shift_y >= p1_paddle_mid - 30))
							begin
								ball_shift_x = 2'd2;
								ball_shift_y = 2'd3;
							end
					end
				//check to see if ball has hit any part of paddle 2
				else if(((ball_mid_x + 5 >= 10'd717) && (ball_mid_x + 5 <= 10'd727)) && ((ball_mid_y < p2_paddle_mid + 30) && (ball_mid_y > p2_paddle_mid - 30)))
					begin
						//adjust the trajectory of the ball appropriately
						if(trajectory_sign[1] == 1)
							begin
								trajectory_sign = 2'b10;
							end
						else
							begin
								trajectory_sign = 2'b00;
							end
						//modify the shift values for the ball based on what part of the paddle it collides with
						//there are 5 regions, and three different possible shift combinations
						//by varying the shift values, the angle of deflection of the paddle, as well as ball speed, are changed
						if((ball_mid_y <= p2_paddle_mid + 30) && (ball_mid_y >= p2_paddle_mid + 18))
							begin
								ball_shift_x = 2'd2;
								ball_shift_y = 2'd3;
							end
						else if ((ball_shift_y < p2_paddle_mid + 18) && (ball_shift_y >= p2_paddle_mid + 6))
							begin
								ball_shift_x = 2'd2;
								ball_shift_y = 2'd1;
							end
						else if ((ball_shift_y < p2_paddle_mid + 6) && (ball_shift_y >= p2_paddle_mid - 6))
							begin
								ball_shift_x = 2'd1;
								ball_shift_y = 2'd1;
							end
						else if ((ball_shift_y < p2_paddle_mid - 6) && (ball_shift_y >= p2_paddle_mid - 18))
							begin
								ball_shift_x = 2'd2;
								ball_shift_y = 2'd1;
							end
						else if ((ball_shift_y < p2_paddle_mid - 18) && (ball_shift_y >= p2_paddle_mid - 30))
							begin
								ball_shift_x = 2'd2;
								ball_shift_y = 2'd3;
							end
					end 
			end
		else//initialize ball to center of screen when enable is low
			begin
				ball_mid_x <= 10'd464;
				ball_mid_y <= 10'd275;
			end
	end

	//reassign the paddle and ball regions as necessary
	assign p1_paddle = ((hCount >= 10'd200) && (hCount <= 10'd210)) && (vCount <= p1_paddle_mid + 30) && (vCount >= p1_paddle_mid - 30);
	assign p2_paddle = ((hCount >= 10'd717) && (hCount <= 10'd727)) && (vCount <= p2_paddle_mid + 30) && (vCount >= p2_paddle_mid - 30);
	assign ball = ((hCount >= ball_mid_x - 5) && (hCount <= ball_mid_x + 5)) && ((vCount <= ball_mid_y + 5) && (vCount >= ball_mid_y - 5));

	//seven segment display approach for showing score on screen
	assign p1_seg1 = ((hCount >= 10'd337) && (hCount <= 10'd357)) && ((vCount >= 10'd44) && (vCount <= 10'd49));
	assign p1_seg2 = ((hCount >= 10'd352) && (hCount <= 10'd357)) && ((vCount > 10'd49) && (vCount <= 10'd64));
	assign p1_seg3 = ((hCount >= 10'd352) && (hCount <= 10'd357)) && ((vCount > 10'd64) && (vCount <= 10'd79));
	assign p1_seg4 = ((hCount >= 10'd337) && (hCount <= 10'd357)) && ((vCount > 10'd79) && (vCount <= 10'd84));
	assign p1_seg5 = ((hCount >= 10'd337) && (hCount <= 10'd342)) && ((vCount > 10'd64) && (vCount <= 10'd79));
	assign p1_seg6 = ((hCount >= 10'd337) && (hCount <= 10'd342)) && ((vCount > 10'd49) && (vCount <= 10'd64));
	assign p1_seg7 = ((hCount >= 10'd337) && (hCount <= 10'd357)) && ((vCount > 10'd62) && (vCount <= 10'd67));
	assign p1_one = ((hCount >= 10'd317) && (hCount <= 10'd322)) && ((vCount >= 10'd44) && (vCount <= 10'd84));

	assign p2_seg1 = ((hCount >= 10'd570) && (hCount <= 10'd590)) && ((vCount >= 10'd44) && (vCount <= 10'd49));
	assign p2_seg2 = ((hCount >= 10'd585) && (hCount <= 10'd590)) && ((vCount > 10'd49) && (vCount <= 10'd64));
	assign p2_seg3 = ((hCount >= 10'd585) && (hCount <= 10'd590)) && ((vCount > 10'd64) && (vCount <= 10'd79));
	assign p2_seg4 = ((hCount >= 10'd570) && (hCount <= 10'd590)) && ((vCount > 10'd79) && (vCount <= 10'd84));
	assign p2_seg5 = ((hCount >= 10'd570) && (hCount <= 10'd575)) && ((vCount > 10'd64) && (vCount <= 10'd79));
	assign p2_seg6 = ((hCount >= 10'd570) && (hCount <= 10'd575)) && ((vCount > 10'd49) && (vCount <= 10'd64));
	assign p2_seg7 = ((hCount >= 10'd570) && (hCount <= 10'd590)) && ((vCount > 10'd62) && (vCount <= 10'd67));
	assign p2_one = ((hCount >= 10'd550) && (hCount <= 10'd555)) && ((vCount >= 10'd44) && (vCount <= 10'd84));

endmodule