`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:08:25 12/01/2017 
// Design Name: 
// Module Name:    counterVerilog 
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
//////////////////////////////////////////////////////////////////////////////////
module counter(
	input clk,
	input[15:0] displayNumber1,//player 1 score
	input[15:0] displayNumber2,//player 2 score
	output reg [7:0] anode,
	output reg [6:0] ssdOut	
    );
	 
	reg [20:0] refresh;
	reg [3:0] LEDNumber;
	wire [2:0] LEDCounter;
	
	
	always @ (posedge clk)
	begin
		refresh <= refresh + 21'd1;
	end
	assign LEDCounter = refresh[20:18];
	
	always @ (*)
	 begin
		case (LEDCounter)//scan across 8 SSDs, allowing us to display player 1 and 2 scores on SSDs as well as on screen
		3'b000: begin
			anode = 8'b01111111;
			LEDNumber = displayNumber1/1000;
				end
		3'b001: begin
			anode = 8'b10111111;
			LEDNumber = (displayNumber1 % 1000)/100;
				end
		3'b010: begin
			anode = 8'b11011111;
			LEDNumber = ((displayNumber1 % 1000)%100)/10;
				end
		3'b011: begin
			anode = 8'b11101111;
			LEDNumber = ((displayNumber1 % 1000)%100)%10;
				end
		3'b100: begin
			anode = 8'b11110111;
			LEDNumber = displayNumber2/1000;
				end
		3'b101: begin
			anode = 8'b11111011;
			LEDNumber = (displayNumber2 % 1000)/100;
				end
		3'b110: begin
			anode = 8'b11111101;
			LEDNumber = ((displayNumber2 % 1000)%100)/10;
				end
		3'b111: begin
			anode = 8'b11111110;
			LEDNumber = ((displayNumber2 % 1000)%100)%10;
				end		
		endcase
	end
	always @ (*)
    begin
        case (LEDNumber)//light the SSDs appropriately based on number to be displayed
        4'b0000: ssdOut = 7'b0000001;     
        4'b0001: ssdOut = 7'b1001111; 
        4'b0010: ssdOut = 7'b0010010; 
        4'b0011: ssdOut = 7'b0000110;  
        4'b0100: ssdOut = 7'b1001100;  
        4'b0101: ssdOut = 7'b0100100; 
        4'b0110: ssdOut = 7'b0100000;  
        4'b0111: ssdOut = 7'b0001111;  
        4'b1000: ssdOut = 7'b0000000;     
        4'b1001: ssdOut = 7'b0000100; 
        default: ssdOut = 7'b0000001; 
        endcase
    end
endmodule
