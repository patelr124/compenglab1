`timescale 1ns / 1ps

module simpleprocessor(
    input clk,
    input reset,
    output [4:0] state,
    output reg [2:0] op_code,
    output reg [15:0] AC, MD, IR,
    output reg [11:0] PC, MA, A,
    
    reg [1:0] PC_C,
    reg [2:0] ALU_C,
    reg [4:0] PRstate, Nstate,
    reg [16:0] temp,
    reg C, MD_E, AC_E, IR_E, MA_E, PC_E, MA_C, A_C, MEM_C, AM_BIT 
    );
    
    // op codes
    parameter NOT=3'b000, ADC = 3'b001, JPA = 3'b010,
            INCA = 3'b011, STA = 3'b100, LDA = 3'b101, ZERO = 16'b0000000000000000;
            
    //states
    parameter S0 = 5'h00, S1 = 5'h01, S2 = 5'h02, S3 = 5'h03, S4 = 5'h04,
            S5 = 5'h05, S6 = 5'h06, S7 = 5'h07, S8 = 5'h08, S9 = 5'h09,
            S10 = 5'h0A, S11 = 5'h0B, S12 = 5'h0C, S13 = 5'h0D, S14 = 5'h0E, 
            S15 = 5'h0F, S16 = 5'h10;
            
    reg [15:0] memory [0:11];
    
    initial begin
        $readmemb("data.mem", memory);
//        0000000000000001	// NOT with mem addy = 1, AM = 0
//        0010000000000010 	// ADC with mem addy = 2, AM = 0
//        0011000000000010 	// ADC with mem addy = 2, AM bit = 1
//        0100000000000011 	// JPA with AM = 0, mem addy = 3
//        0101000000000011	// JPA with AM = 1, mem addy = 3
//        0110000000000100	// INCA with AM = 0, mem addy = 4
//        1000000000000101	// STA with AM = 0. mem addy = 5
//        1001000000000101	// STA with AM = 1, mem addy = 5
//        1010000000000111	// LDA with AM = 0, mem addy = 7
//        1011000000000111	// LDA with AM =1, mem addy = 7
    end   
    
    // DATAPATH
    always @ (posedge clk) 
    begin
        if(reset==1'b1) 
        begin
            MD = ZERO; 
        	IR = ZERO;
        	AC = ZERO;
        	MA = 12'b000000000000;
        	PC = 12'b000000000000;
        	A = 12'b000000000000;
        	temp = ZERO; //temp 1
        end
        else begin
        
            // if MD or IR are enabled then READ is also enabled
            if(IR_E == 1'b1) begin
                IR = memory[A];
            end
            
            if(MD_E == 1'b1) begin
                MD = memory[A];
            end
            
            if (AC_E == 1'b1) begin
                case(ALU_C)
                    3'b000 : temp = ~AC;
                    3'b001 : temp = AC + C + MD;
                    3'b010 : temp = AC + 1'b1;
                    3'b011 : temp = ZERO;
                    3'b100 : temp = MD;
                endcase
                 
            end
            
            //PC mux
            if (PC_E == 1'b1) begin
                case(PC_C)
                    2'b00 : PC = PC + 1'b1;
                    2'b01 : PC = IR;
                    2'b10 : PC = MD;
                endcase
            end
            
            //MA mux
            if (MA_E == 1'b1) begin
                case(MA_C)
                    1'b0 : MA = IR;
                    1'b1 : MA = MD;
                endcase
            end
            
            case(A_C)
                1'b0 : A = PC;
                1'b1 : A = MA;
            endcase
            
            case(MEM_C)
                1'b1 : memory[A] = AC;
            endcase

        end
        
        AC = temp[15:0];
        C = temp[16];
        op_code = IR[15:13];
        AM_BIT = IR[12];
    end
    
    // CONTROLLER
    always @ (posedge clk) begin
        if(reset==1'b1) begin
            PRstate = S0;
        end
        else begin
            PRstate = Nstate;
        end
    end
    
    // CURRENT STATES
    always @ (PRstate) begin
        MD_E = 1'b0;
        IR_E = 1'b0;
        AC_E = 1'b0;
        MA_E = 1'b0;
        PC_E = 1'b0;
        MA_C = 1'b0;
        A_C = 1'b0;
        MEM_C = ZERO;
        PC_C = 2'b00;
        
        if(PRstate == S0) begin
            IR = memory[PC];
            MEM_C = 1'b0;
            IR_E = 1'b1;
            A_C = 1'b0;
        end
        
        if(PRstate == S1) begin
            IR_E = 1'b1;
            PC_E = 1'b1;
            PC_C = 2'b00;
        end
        
        if(PRstate == S2) begin
            ALU_C = 3'b000;
            AC_E = 1'b1;
        end
        
        if(PRstate == S3) begin
            ALU_C = 3'b000;
            AC_E = 1'b1;
        end
        
        if(PRstate == S4) begin
            MA_E = 1'b1;
            MA_C = 1'b0;
            A_C = 1'b1;
        end
        
        if(PRstate == S5) begin
            MD_E = 1'b1;
            MEM_C = 1'b0;
            A_C = 1'b1;
        end
        
        if(PRstate == S6) begin
            PC_E = 1'b1;
            PC_C = 2'b10;
        end
        
        if(PRstate == S7) begin
            PC_C = 2'b01;
            PC_E = 1'b1;
        end
        
        if(PRstate == S8) begin
            MA_E = 1'b1;
            MA_C = 1'b0;
            A_C = 1'b1;
        end
        
        if(PRstate == S9) begin
            MEM_C = 1'b0;
            MD_E = 1'b1;
        end
        
        if(PRstate == S10) begin
            MA_E = 1'b1;
            MA_C = 2'b1;
        end
        
        if(PRstate == S11) begin
            AC_E = 1'b1;
            MEM_C = 1'b1;
            A_C = 1'b1;
            ALU_C = 3'b011;
        end
        
        if(PRstate == S12) begin
            MD_E = 1'b1;
            MEM_C = 1'b0;
            A_C = 1'b1;
        end
        
        if(PRstate == S13) begin
            MD_E = 1'b1;
            MEM_C = 1'b1;
            A_C = 1'b1;
        end
        
        if(PRstate == S14) begin
            MD_E = 1'b1;
            MEM_C = 1'b0;
            A_C = 1'b1;
        end
        
        if(PRstate == S15) begin
            ALU_C = 3'b001;
            AC_E = 1'b1;
            
        end
        
        if(PRstate == S16) begin
            AC_E = 1'b1;
            ALU_C = 3'b100;
        end
    end
    
    // NEXT STATES
    always @ (posedge clk) begin
        case(PRstate)
            S0 : Nstate = S1;
            
            S1 : begin
                    if(op_code == NOT) begin
                        Nstate = S2;
                    end 
                    else if (op_code == INCA) begin
                              Nstate = S3;
                         end
                         else if (op_code != JPA) begin
                              Nstate = S8;
                         end
                         else if (AC <= ZERO) begin
                              Nstate = S0;
                         end
                         else if (AM_BIT == 1'b1) begin
                              Nstate = S4;
                         end
                         else Nstate = S7;
                         
                 end
                 
            S2 : Nstate = S0;
            S3 : Nstate = S0;
            S4 : Nstate = S5;
            S5 : Nstate = S6;
            S6 : Nstate = S0;
            S7 : Nstate = S0;
            S8 : begin
                    if(op_code != STA) begin
                        Nstate = S12;
                    end
                    
                    else if (AM_BIT == 1'b1) begin
                        Nstate = S9;
                    end
                    else
                        Nstate = S11;
                    end
                    
            S9 : Nstate = S10;
            S10 : Nstate = S11;
            S11 : Nstate = S0;
            S12 : begin
                    if(AM_BIT == 1'b1) begin
                        Nstate = S13;
                    end
                    else if (op_code == ADC) begin
                        Nstate = S15;
                    end
                    else Nstate = S16;
                    end
            S13 : Nstate = S14;
            S14 : begin
                    if(op_code == ADC) begin
            	       Nstate = S15;
        	        end
                    else Nstate = S16;
                    end
        	
        	S15 : Nstate = S0;
        	S16 : Nstate = S0;
        endcase
    end
    assign state = PRstate;
endmodule
