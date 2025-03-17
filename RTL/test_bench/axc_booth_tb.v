`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Ioannins Rizos
// Design Name: Tunable Approximate Booth Multiplier Test Bench
// Module Name: axc_booth_bt
//
// Aditional comments: This RTL code is part of the paper submission: I. Rizos, G. Papatheodorou, A. Efthymiou "Tunable Approximate Booth 
// Multiplier". Submitted for ISVLSI 2025. Code provided under the LISCENCE attached to this repository.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module axc_booth_tb();
    parameter integer NA=8;             // Bit width of A
    parameter integer NB=8;             // Bit width of B

    reg                     CLK=1;      // Clock
    reg                     START;      // Start (active-high)
    reg   [NA-1:0]          A_in;       // Multiplicant
    reg   [NB-1:0]          B_in;       // Multiplier
    reg   [$clog2(NA):0]    C_in;       // Ammount of Cycles to run
    wire  [NA+NB-1:0]       N_out;      // Product
    wire                    Done_out;   // Multiplication done or ammount of cycles met 
    
    axc_booth #(.NA(NA), .NB(NB)) DUT (.CLK(CLK), .START(START), .A_in(A_in), .B_in(B_in), .C_in(C_in), .N_out(N_out), .Done_out(Done_out));
    
    always @(*) #1 CLK <= !CLK;         // clock oscillation

    integer i;
    initial begin
        $dumpfile("test.vcd");          // for iverilog waveform output
        $dumpvars(0,axc_booth_tb);
        
        #4;                             // initial wait

        for(i=NA; i>=1; i=i-1) begin    // for cycles in range [NA,1]
            C_in <= i;                  // the multiplications bellow will run for i cycles each

            A_in <= -1;                 // -1 x 7
            B_in <= 7;
            START <= 1;
            #2;
            START <= 0;
            #26;

            A_in <= 44;                 // 44 x 2
            B_in <= 2;
            START <= 1;
            #2;
            START <= 0;
            #26;

            A_in <= -27;                // -27 x 80
            B_in <= 80;
            START <= 1;
            #2;
            START <= 0;
            #26;

            A_in <= -127;               // -127 x 0
            B_in <= 0;
            START <= 1;
            #2;
            START <= 0;
            #26;

            A_in <= 127;                // 127 x 127
            B_in <= 127;
            START <= 1;
            #2;
            START <= 0;
            #26;

            A_in <= 85;                 // 85 x 4
            B_in <= 4;
            START <= 1;
            #2;
            START <= 0;
            #26;

            A_in <= -86;                // -86 x 4
            B_in <= 4;
            START <= 1;
            #2;
            START <= 0;
            #26;
        end

        $finish;
    end
    
endmodule
