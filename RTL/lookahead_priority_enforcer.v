`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Aristides Efthymiou
// Design Name: Tunable Approximate Booth Multiplier
// Module Name: lookahead_penf_last
//
// Aditional comments: This RTL code is part of the paper submission: I. Rizos, G. Papatheodorou, A. Efthymiou "Tunable Approximate Booth 
// Multiplier". Submitted for ISVLSI 2025. Code provided under the LISCENCE attached to this repository.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module ripple_penf_last #(
        parameter integer WIDTH = 4
    )( 
        input  wire                 stop_in,
        input  wire [WIDTH-1:0]     A_in,
        input  wire                 trailing1_in,
        output wire [WIDTH-1:0]     B_out,
        output wire                 stop_out,
        output wire                 last_out,
        output wire                 slicestop_out
    );

    wire [WIDTH-1:0] stop;
    wire [WIDTH-1:0] trailing;
    wire [WIDTH-1:0] last;

    genvar i;

    generate
        assign stop[WIDTH-1] = stop_in;
        for (i = WIDTH-1; i > 0; i = i - 1) begin
        assign B_out[i] = A_in[i] & ~stop[i];
        assign stop[i-1] = stop[i] | A_in[i];
        end
        assign B_out[0] = A_in[0] & ~stop[0];
        assign slicestop_out = stop[0] | A_in[0];
        assign stop_out = |A_in;

        assign trailing[0] = trailing1_in;
        assign last[0] = B_out[0] & ~trailing[0];
        for (i = 1; i < WIDTH; i = i + 1) begin
            assign trailing[i] = A_in[i-1] | trailing[i-1];
            assign last[i] = B_out[i] & ~trailing[i];
        end
        assign last_out = |last;
    endgenerate
endmodule

module lookahead_penf_last #(
        parameter integer WIDTH = 29
    )(
        input  wire [WIDTH-1:0] A_in,
        output wire [WIDTH-1:0] OH_out,
        output wire last
    );
   
    localparam integer NUM_4BIT_MODULES = WIDTH / 4;
    localparam integer REMAINING_BITS = WIDTH % 4;

    wire [NUM_4BIT_MODULES:0] stop;
    wire [NUM_4BIT_MODULES:0] lastSlice;
    
    wire finalStop;
    
    genvar i;

    generate
        if (REMAINING_BITS > 0) begin
        ripple_penf_last #(.WIDTH(REMAINING_BITS))
        u0 (.stop_in(1'b0),
            .A_in(A_in[WIDTH-1 -: REMAINING_BITS]),
            .B_out(OH_out[WIDTH-1 -: REMAINING_BITS]),
            .stop_out(stop[NUM_4BIT_MODULES]),
            .slicestop_out(),
            .trailing1_in(|stop[NUM_4BIT_MODULES-1:0]),
            .last_out(lastSlice[NUM_4BIT_MODULES])
            );
        end else begin
        assign stop[NUM_4BIT_MODULES] = 1'b0;
        assign lastSlice[NUM_4BIT_MODULES] = 1'b0;
        end

        for (i = NUM_4BIT_MODULES-1; i >= 0; i = i - 1) begin : gen4bslice
        if (i > 0) begin
            ripple_penf_last #(.WIDTH(4))
            u4b (.stop_in(|stop[NUM_4BIT_MODULES:i+1]),
                .A_in(A_in[i*4 +: 4]),
                .B_out(OH_out[i*4 +: 4]),
                .stop_out(stop[i]),
                .slicestop_out(),  // unconnected - not needed.
                .trailing1_in(|stop[i-1:0]),
                .last_out(lastSlice[i])
                );
        end else begin
            ripple_penf_last #(.WIDTH(4))
            u4b (.stop_in(|stop[NUM_4BIT_MODULES:i+1]),
                .A_in(A_in[i*4 +: 4]),
                .B_out(OH_out[i*4 +: 4]),
                .stop_out(stop[i]),
                .slicestop_out(finalStop),
                .trailing1_in(1'b0),
                .last_out(lastSlice[i])
                );
        end
        end
        assign last = |lastSlice | ~finalStop;
    endgenerate
endmodule
