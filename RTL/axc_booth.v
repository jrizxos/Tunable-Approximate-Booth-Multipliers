`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Ioannins Rizos
// Design Name: Tunable Approximate Booth Multiplier
// Module Name: axc_booth
//
// Aditional comments: This RTL code is part of the paper submission: I. Rizos, G. Papatheodorou, A. Efthymiou "Tunable Approximate Booth 
// Multiplier". Submitted for ISVLSI 2025. Code provided under the LISCENCE attached to this repository.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module axc_booth #(
        parameter integer NA=12,                                    // Bit width of A (in [2:32])
        parameter integer NB=12,                                    // Bit width of B (in [2:32] & must be NB>=NA)
        parameter integer NC=$clog2(NA)+1                           // Bit width of C ( = ceil(log2(NA))+1 )
    )(
        input   wire                 CLK,                           // Clock
        input   wire                 START,                         // Start (active-high)
        input   wire  [NA-1:0]       A_in,                          // Multiplicant
        input   wire  [NB-1:0]       B_in,                          // Multiplier
        input   wire  [NC-1:0]       C_in,                          // Ammount of Cycles to run
        output  wire  [NA+NB-1:0]    N_out,                         // Product
        output  wire                 Done_out                       // Multiplication done or ammount of cycles met 
    );

// Input Registers //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg  [NB-1:0]       B_reg;                                          // B (Multiplier) register
reg  [NC-1:0]       C_reg;                                          // C (Ammount of Cycles) register

// Transition Detect Signals ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [NA-1:0]       Pos_trans_wire;                                 // Positive transitions wire
wire [NA-1:0]       Neg_trans_wire;                                 // Negative transitions wire
reg  [NA-1:0]       Pos_trans_reg;                                  // Positive transitions register
reg  [NA-1:0]       Neg_trans_reg;                                  // Negative transitions register

// Priority Enforcer Signals ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [NA-1:0]       PE_in_wire;                                     // PE input selector wire
wire [NA-1:0]       OH_wire;                                        // One-Hot wire                 
reg                 Polarity_reg;                                   // Polarity register: currently doing 0:addition or 1:subtraction 
reg  [NA-1:0]       PE_mask_reg;                                    // Mask register for priority enforcer

// Barrel Shifter Signals ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [NA+NB-2:0]    PP_wire;                                        // Partial Product wire

// Acummulator Signals //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg  [NA+NB-1:0]    Res_reg;                                        // Result register

// State Machine Signals ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam integer SC = 3;                                          // state count
localparam STATE_IDLE   = 3'b001;
localparam STATE_START  = 3'b010;
localparam STATE_MULT   = 3'b100;
reg  [SC-1:0]       State_reg;                                      // state register (one-hot)


// Transition Detect ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
transition_detect #( .NA(NA) ) TD_inst (.A_in(A_in), .P_out(Pos_trans_wire), .N_out(Neg_trans_wire));


// Priority Enforcer ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire                PE_last;                                        // PE reports that this is the last 1 in the input
reg [1:0]           Prev_PE_done;                                   // Saved previous PE was last, thus done now
reg                 Done_reg;                                       // Done_out register
assign PE_in_wire = Polarity_reg ? Neg_trans_reg & PE_mask_reg : Pos_trans_reg & PE_mask_reg;

lookahead_penf_last #( .WIDTH(NA) ) PE_inst (.A_in(PE_in_wire), .OH_out(OH_wire), .last(PE_last));


// Done_out control /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign Done_out = Done_reg;
always @( posedge CLK ) begin
    case(State_reg) 
        STATE_IDLE: begin                                           // when IDLE reset
            Prev_PE_done <= 0; 
            if(START) Done_reg <= 0;
        end
        STATE_MULT: begin                                           // when MULT 
            if(Prev_PE_done[0]==0 & PE_last==1) begin               // if first PE done appears
                Prev_PE_done[0] <= 1;                               // register it
                Prev_PE_done[1] <= Polarity_reg;                    // and the polarity it appeared in
            end                                                     // then assert whether or not we are done
            Done_reg <= Done_reg | ((C_reg==0) | (Prev_PE_done[0] & PE_last & (Polarity_reg!=Prev_PE_done[1])));
        end
        default: Prev_PE_done <= 0;  
    endcase
end


// Barrel Shifter ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
barrel_shifter #( .NA(NA), .NB(NB) ) BS_inst (.B_in(B_reg), .S_in(OH_wire), .N_out(PP_wire));


// Acummulator //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @( posedge CLK ) begin
    if(START) begin                                                 // when START reset
        Res_reg <= 0;
    end
    else if(State_reg==STATE_MULT) begin                            // when MULT
        if(!Polarity_reg) begin                                     // Add or subtract based on Polarity_reg
            Res_reg <= Res_reg + PP_wire;
        end
        else begin
            Res_reg <= Res_reg - PP_wire;
        end
    end
end
assign N_out = Res_reg;


// State Machine ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @( posedge CLK ) begin
    case(State_reg) 
        STATE_IDLE: begin                                       
            if(START) begin                                         // IDLE -> START (when START)
                State_reg <= STATE_START;                           // set next state

                B_reg <= B_in;                                      // copy inputs B and C to registers
                C_reg <= C_in;

                PE_mask_reg <= {NA{1'b1}};                          // enable PE mask

                Polarity_reg <= 0;
            end
        end
        STATE_START: begin                                          // START -> MULT (always)
            State_reg <= STATE_MULT;                                // set next state                           
            Pos_trans_reg <= Pos_trans_wire;                        // transfer pos and neg transitions of A to registers
            Neg_trans_reg <= Neg_trans_wire;                    
        end
        STATE_MULT: begin                                       
            if(Done_out) begin                                      // MULT -> IDLE (when Done)
                State_reg <= STATE_IDLE;                            // set next state
                Pos_trans_reg <= 0;
                Neg_trans_reg <= 0;
                C_reg <= 0;                                         // kinda hacky way to keep Done_out asserted until Start again
            end
            else begin
                PE_mask_reg <= ~OH_wire & PE_mask_reg;
                Polarity_reg <= !Polarity_reg;                      // update Polarity_reg
                C_reg <= C_reg - 1;                                 // increment cycles
            end
        end
        default: State_reg <= STATE_IDLE;                           // set next state
    endcase
end

endmodule
