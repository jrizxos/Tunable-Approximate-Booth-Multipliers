`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Ioannins Rizos
// Design Name: Tunable Approximate Booth Multiplier
// Module Name: transition_detect
//
// Aditional comments: This RTL code is part of the paper submission: I. Rizos, G. Papatheodorou, A. Efthymiou "Tunable Approximate Booth 
// Multiplier". Submitted for ISVLSI 2025. Code provided under the LISCENCE attached to this repository.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module transition_detect #(
        parameter NA = 6
    )(
        input   wire [NA-1:0]     A_in,                             // Input number
        output  wire [NA-1:0]     P_out,                            // ith bit=1 if A_in[i] -> A_in[i-1] = 0 -> 1 (positive transition)
        output  wire [NA-1:0]     N_out                             // ith bit=1 if A_in[i] -> A_in[i-1] = 1 -> 0 (negative transition)
    );

    assign P_out[0] = 0;                                            // Always 0 because of imaginary 0 after number
    assign N_out[0] = A_in[0];                                      // Equal to LSB of input because of imaginary 0 after number
    
    genvar i;
    generate
        for (i = 1; i < NA; i = i + 1) begin : MSB
            assign P_out[i] = ~A_in[i] &  A_in[i-1];                // detect positive transition
            assign N_out[i] =  A_in[i] & ~A_in[i-1];                // detect negative transition
        end
    endgenerate
endmodule
