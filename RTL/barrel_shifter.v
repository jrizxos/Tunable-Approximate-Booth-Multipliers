`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Ioannins Rizos
// Design Name: Tunable Approximate Booth Multiplier
// Module Name: barrel_shifter
//
// Aditional comments: This RTL code is part of the paper submission: I. Rizos, G. Papatheodorou, A. Efthymiou "Tunable Approximate Booth 
// Multiplier". Submitted for ISVLSI 2025. Code provided under the LISCENCE attached to this repository.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module barrel_shifter #(
        parameter integer NA=8,
        parameter integer NB=8
    )(
        input  wire [NB-1:0]      B_in,
        input  wire [NA-1:0]      S_in,
        output wire [NA+NB-2:0]   N_out
    );
    
    wire [NA+NB-2:0] B_ext = {{(NA-1){B_in[NB-1]}}, B_in};          // Sign extend B_in to the full width before shifting
    
    wire [NA+NB-2:0] shift_results[0:NA-1];                         // Wire array for all possible shifts
    reg  [NA+NB-2:0] shifted_value;                                 // Shifted value register

    genvar i;
    generate
        for (i = 0; i < NA; i = i + 1) begin : Shift_Logic          // Does all possible shifts and places them in wire array
            assign shift_results[i] = B_ext << i;
        end
    endgenerate
   
    integer j;
    always @(*) begin                                               // CLK ssynchronus update
        shifted_value = {NA+NB-1{1'b0}};                            // Reset shifted_value
        for (j = 0; j < NA; j = j + 1) begin
            if (S_in[j]) begin                                      // Select the correct shifted value
                shifted_value = shifted_value | shift_results[j];
            end
        end
    end

    assign N_out = shifted_value;

endmodule
