`timescale 1ns / 1ps
module simpleprocessor_tb;
	reg clk;
	reg reset;
	//reg RWn;
	wire [2:0] op_code;
	wire [4:0] state;
	wire [11:0] PC, A, MA;
	wire [15:0] IR, AC, MD;
	
	reg [15:0] memory [0:9];
	parameter zero = 16'b0000000000000000; //easy zero set instead of long zero
	
	//initalizing unit under test (uut)
	simpleprocessor uut1 ( 
    	.clk(clk),
    	.reset(reset),
    	//.RWn(RWn),
    	.state(state),
    	.op_code(op_code),
    	.IR(IR),
    	.PC(PC),
    	.A(A),
    	.AC(AC),
    	.MD(MD),
    	.MA(MA));
    	
	initial begin
    	$readmemb("data.mem", memory);
//    	/*
//            0000000000000001	// NOT with mem addy = 1, AM = 0
//            0010000000000010 	// ADC with mem addy = 2, AM = 0
//            0011000000000010 	// ADC with mem addy = 2, AM bit = 1
//            0100000000000011 	// JPA with AM = 0, mem addy = 3
//            0101000000000011	// JPA with AM = 1, mem addy = 3
//            0110000000000100	// INCA with AM = 0, mem addy = 4
//            1000000000000101	// STA with AM = 0. mem addy = 5
//            1001000000000101	// STA with AM = 1, mem addy = 5
//            1010000000000111	// LDA with AM = 0, mem addy = 7
//            1011000000000111	// LDA with AM =1, mem addy = 7
//         	*/
    	
    	clk = 1; // initialize clock
    	reset = 1; // set reset
    	#1000 //wait 1000 for everything to catch up
    	
    	reset = 0; //disables reset
	end
	always @(clk)#500 clk <= ~clk; // sets clock to pulse every 500
	
	//always @(RWn)#500 clk <= ~clk;
endmodule