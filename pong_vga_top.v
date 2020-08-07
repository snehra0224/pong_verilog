`timescale 1ns / 1ps

module pong_vga_top(
	input ClkPort,
	input BtnC,
	input BtnU,
	input BtnD,
	input BtnL, 
	input BtnR,
	
	//VGA signal
	output hSync, vSync,
	output [3:0] vgaR, vgaG, vgaB,
	
	//SSG signal 
	output An0, An1, An2, An3, An4, An5, An6, An7,
	output Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	
	output MemOE, MemWR, RamCS, QuadSpiFlashCS
	);
	
	wire bright;
	wire[9:0] hc, vc;
	wire[15:0] score;
	wire[15:0] score1;
	wire[15:0] score2;
	wire [6:0] ssdOut;
	wire [7:0] anode;
	wire [11:0] rgb;
	display_controller dc(.clk(ClkPort), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));
	pong_vga_bitchange vbc(.clk(ClkPort), .start_btn(BtnC), .bright(bright), .p1_button_u(BtnL), .p1_button_d(BtnD), .p2_button_u(BtnU), .p2_button_d(BtnR), .hCount(hc), .vCount(vc), .rgb(rgb), .score1(score1), .score2(score2));
	counter cnt(.clk(ClkPort), .displayNumber1(score1), .displayNumber2(score2), .anode(anode), .ssdOut(ssdOut));
	
	assign Dp = 1;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg} = ssdOut[6 : 0];
    assign {An7, An6, An5, An4, An3, An2, An1, An0} = {anode};

	
	assign vgaR = rgb[11 : 8];
	assign vgaG = rgb[7  : 4];
	assign vgaB = rgb[3  : 0];
	
	// disable mamory ports
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

endmodule