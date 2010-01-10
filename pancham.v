/*****************************************************************
 Pancham is an MD5 compliant IP core for cryptographic 
 applications. 
 Copyright (C) 2003  Swapnajit Mittra, Project VeriPage
 (Contact email: verilog_tutorial at hotmail.com
  Website      : http://www.angelfire.com/ca/verilog)

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the 
 
 Free Software Foundation, Inc.
 59 Temple Place, Suite 330
 Boston, MA  02111-1307 
 USA
 ******************************************************************/
/* 
 * This is the main module that computes a 128-bit message 
 * digest from a maximum of 128-bit long input message using
 * MD5 algorithm.
 *
 */

`include "pancham.h"

module pancham (
        clk
      , reset	
      , msg_in
      , msg_in_width
      , msg_in_valid

      , msg_output
      , msg_out_valid
      , ready
      );

//--------------------------------
//
// Input/Output declarations 
//
//--------------------------------
input          clk;                      // input clock
input          reset;                    // global reset
input  [0:127] msg_in;                   // input message, max width = 128 bits
input    [0:7] msg_in_width;             // actual input message width
input          msg_in_valid;             // input message is valid, active high
                                       
output [0:127] msg_output;               // output message, always 128 bit wide
output         msg_out_valid;            // if asserted, output message is valid
output         ready;                    // the core is ready for an input message

//--------------------------------
//
// Variable declarations
//
//--------------------------------
// inputs
wire          clk;        
wire          reset;
wire  [0:127] msg_in;     
wire    [0:7] msg_in_width;          
wire          msg_in_valid;

// output                 
wire  [0:127] msg_output; 
reg           msg_out_valid;
wire          ready;

// scratch pads
reg    [0:1] round;
reg  [0:511] msg_appended;
reg   [0:31] a;
reg   [0:31] A;
reg   [0:31] AA;
reg   [0:31] next_A;
reg   [0:31] b;
reg   [0:31] B;
reg   [0:31] BB;
reg   [0:31] next_B;
reg   [0:31] c;
reg   [0:31] C;
reg   [0:31] CC;
reg   [0:31] next_C;
reg   [0:31] d;
reg   [0:31] D;
reg   [0:31] DD;
reg   [0:31] next_D;
reg   [0:31] m;
reg   [0:31] s; 
reg   [0:31] t;
reg    [3:0] phase;         // Counter to determine 16 phases within each round.
wire  [0:31] next_a;
reg    [7:0] current_state;
reg    [7:0] next_state;
reg [8*11:1] ascii_state;

//--------------------------------
//
// Parameter definitions
// 
//--------------------------------

parameter SALT_A         = 32'h67452301;
parameter SALT_B         = 32'hefcdab89;
parameter SALT_C         = 32'h98badcfe;
parameter SALT_D         = 32'h10325476;

parameter ONE            = 72'h1;
                         
parameter IDLE_BIT       = 0;
parameter IDLE           = ONE << IDLE_BIT;
                         
parameter ROUND1_BIT     = 1;
parameter ROUND1         = ONE << ROUND1_BIT;
                         
parameter ROUND2_BIT     = 2;
parameter ROUND2         = ONE << ROUND2_BIT;
                         
parameter ROUND3_BIT     = 3;
parameter ROUND3         = ONE << ROUND3_BIT;
                         
parameter ROUND4_BIT     = 4;
parameter ROUND4         = ONE << ROUND4_BIT;
                         
parameter FINISH_OFF_BIT = 5;
parameter FINISH_OFF     = ONE << FINISH_OFF_BIT;

parameter TURN_ARND_BIT  = 6;
parameter TURN_ARND      = ONE << TURN_ARND_BIT;


//--------------------------------
//
// Submodule instantiation
//
//--------------------------------
pancham_round ROUND (
     .a      (a    ) 
   , .b      (b    ) 
   , .c      (c    ) 
   , .d      (d    ) 
   , .m      (m    )
   , .s      (s    ) 
   , .t      (t    ) 
   , .round  (round)

   , .next_a (next_a) 
);

//--------------------------------
//
// Actual code starts here
//
//--------------------------------

always @(current_state
   or    msg_in_valid
   or    A
   or    B
   or    C
   or    D
   or    phase
   or    msg_appended
   or    next_a
   or    AA
   or    BB
   or    CC
   or    DD

   ) begin // {
   round = `ROUND1;
   next_A = A;
   next_B = B; 
   next_C = C; 
   next_D = D;
   
   a = 32'h0;
   b = 32'h0;
   c = 32'h0;
   d = 32'h0;
   m = 32'h0;
   s = 32'h0;
   t = 32'h0;
   
   next_state = current_state; 

   case (1'b1) // synopsys full_case parallel_case 

   current_state[IDLE_BIT]: 
   begin // {
      // synopsys translate_off
      ascii_state = "IDLE";
      // synopsys translate_on

      if (msg_in_valid)  
         next_state = ROUND1;
   end // }

   //----------------------------------------------------------------
   //--------------------------- ROUND 1 ----------------------------
   //----------------------------------------------------------------
   current_state[ROUND1_BIT]: 
   begin // {
      // synopsys translate_off
      ascii_state = "ROUND1";
      // synopsys translate_on

      round = `ROUND1;

      case (phase)
      4'b0000: begin a=A; b=B; c=C; d=D; m=msg_appended[480:511]; s=32'd07; t= `T_1; next_A=next_a; end
      4'b0001: begin a=D; b=A; c=B; d=C; m=msg_appended[448:479]; s=32'd12; t= `T_2; next_D=next_a; end
      4'b0010: begin a=C; b=D; c=A; d=B; m=msg_appended[416:447]; s=32'd17; t= `T_3; next_C=next_a; end
      4'b0011: begin a=B; b=C; c=D; d=A; m=msg_appended[384:415]; s=32'd22; t= `T_4; next_B=next_a; end
      4'b0100: begin a=A; b=B; c=C; d=D; m=msg_appended[352:383]; s=32'd07; t= `T_5; next_A=next_a; end
      4'b0101: begin a=D; b=A; c=B; d=C; m=msg_appended[320:351]; s=32'd12; t= `T_6; next_D=next_a; end
      4'b0110: begin a=C; b=D; c=A; d=B; m=msg_appended[288:319]; s=32'd17; t= `T_7; next_C=next_a; end
      4'b0111: begin a=B; b=C; c=D; d=A; m=msg_appended[256:287]; s=32'd22; t= `T_8; next_B=next_a; end
      4'b1000: begin a=A; b=B; c=C; d=D; m=msg_appended[224:255]; s=32'd07; t= `T_9; next_A=next_a; end
      4'b1001: begin a=D; b=A; c=B; d=C; m=msg_appended[192:223]; s=32'd12; t=`T_10; next_D=next_a; end
      4'b1010: begin a=C; b=D; c=A; d=B; m=msg_appended[160:191]; s=32'd17; t=`T_11; next_C=next_a; end
      4'b1011: begin a=B; b=C; c=D; d=A; m=msg_appended[128:159]; s=32'd22; t=`T_12; next_B=next_a; end
      4'b1100: begin a=A; b=B; c=C; d=D; m=msg_appended[96:127];  s=32'd7;  t=`T_13; next_A=next_a; end
      4'b1101: begin a=D; b=A; c=B; d=C; m=msg_appended[64:95];   s=32'd12; t=`T_14; next_D=next_a; end
      4'b1110: begin a=C; b=D; c=A; d=B; m=msg_appended[32:63];   s=32'd17; t=`T_15; next_C=next_a; end
      4'b1111: begin a=B; b=C; c=D; d=A; m=msg_appended[0:31];    s=32'd22; t=`T_16; next_B=next_a; end
      endcase

      // $display (" ROUND1_1: msg_appended[480:511] = %x", msg_appended[480:511]);
      // $display (" ROUND1_1: msg_appended[0:511] = %x", msg_appended[0:511]);

      if (phase == 4'b1111)
         next_state = ROUND2;
   end // }
   //----------------------------------------------------------------
   //--------------------------- ROUND 2 ----------------------------
   //----------------------------------------------------------------

   current_state[ROUND2_BIT]:
   begin // {
      // synopsys translate_off
      ascii_state = "ROUND2";
      // synopsys translate_on
 
      round = `ROUND2;
      case (phase) 
      4'b0000: begin a=A; b=B; c=C; d=D; m=msg_appended[448:479]; s=32'd05; t=`T_17; next_A=next_a; end
      4'b0001: begin a=D; b=A; c=B; d=C; m=msg_appended[288:319]; s=32'd09; t=`T_18; next_D=next_a; end
      4'b0010: begin a=C; b=D; c=A; d=B; m=msg_appended[128:159]; s=32'd14; t=`T_19; next_C=next_a; end
      4'b0011: begin a=B; b=C; c=D; d=A; m=msg_appended[480:511]; s=32'd20; t=`T_20; next_B=next_a; end
      4'b0100: begin a=A; b=B; c=C; d=D; m=msg_appended[320:351]; s=32'd05; t=`T_21; next_A=next_a; end
      4'b0101: begin a=D; b=A; c=B; d=C; m=msg_appended[160:191]; s=32'd09; t=`T_22; next_D=next_a; end
      4'b0110: begin a=C; b=D; c=A; d=B; m=msg_appended[0:31];    s=32'd14; t=`T_23; next_C=next_a; end
      4'b0111: begin a=B; b=C; c=D; d=A; m=msg_appended[352:383]; s=32'd20; t=`T_24; next_B=next_a; end
      4'b1000: begin a=A; b=B; c=C; d=D; m=msg_appended[192:223]; s=32'd05; t=`T_25; next_A=next_a; end
      4'b1001: begin a=D; b=A; c=B; d=C; m=msg_appended[32:63];   s=32'd9;  t=`T_26; next_D=next_a; end
      4'b1010: begin a=C; b=D; c=A; d=B; m=msg_appended[384:415]; s=32'd14; t=`T_27; next_C=next_a; end
      4'b1011: begin a=B; b=C; c=D; d=A; m=msg_appended[224:255]; s=32'd20; t=`T_28; next_B=next_a; end
      4'b1100: begin a=A; b=B; c=C; d=D; m=msg_appended[64:95];   s=32'd05; t=`T_29; next_A=next_a; end
      4'b1101: begin a=D; b=A; c=B; d=C; m=msg_appended[416:447]; s=32'd09; t=`T_30; next_D=next_a; end
      4'b1110: begin a=C; b=D; c=A; d=B; m=msg_appended[256:287]; s=32'd14; t=`T_31; next_C=next_a; end
      4'b1111: begin a=B; b=C; c=D; d=A; m=msg_appended[96:127];  s=32'd20; t=`T_32; next_B=next_a; end
      endcase

      if (phase == 4'b1111)
         next_state = ROUND3;
   end // }
   //----------------------------------------------------------------
   //--------------------------- ROUND 3 ----------------------------
   //----------------------------------------------------------------
 
   current_state[ROUND3_BIT]:
   begin // {
      // synopsys translate_off
      ascii_state = "ROUND3";
      // synopsys translate_on
 
      round = `ROUND3;
      case (phase) 
      4'b0000: begin a=A; b=B; c=C; d=D; m=msg_appended[320:351]; s=32'd04; t=`T_33; next_A=next_a; end
      4'b0001: begin a=D; b=A; c=B; d=C; m=msg_appended[224:255]; s=32'd11; t=`T_34; next_D=next_a; end
      4'b0010: begin a=C; b=D; c=A; d=B; m=msg_appended[128:159]; s=32'd16; t=`T_35; next_C=next_a; end
      4'b0011: begin a=B; b=C; c=D; d=A; m=msg_appended[32:63];   s=32'd23; t=`T_36; next_B=next_a; end
      4'b0100: begin a=A; b=B; c=C; d=D; m=msg_appended[448:479]; s=32'd04; t=`T_37; next_A=next_a; end
      4'b0101: begin a=D; b=A; c=B; d=C; m=msg_appended[352:383]; s=32'd11; t=`T_38; next_D=next_a; end
      4'b0110: begin a=C; b=D; c=A; d=B; m=msg_appended[256:287]; s=32'd16; t=`T_39; next_C=next_a; end
      4'b0111: begin a=B; b=C; c=D; d=A; m=msg_appended[160:191]; s=32'd23; t=`T_40; next_B=next_a; end
      4'b1000: begin a=A; b=B; c=C; d=D; m=msg_appended[64:95];   s=32'd04; t=`T_41; next_A=next_a; end
      4'b1001: begin a=D; b=A; c=B; d=C; m=msg_appended[480:511]; s=32'd11; t=`T_42; next_D=next_a; end
      4'b1010: begin a=C; b=D; c=A; d=B; m=msg_appended[384:415]; s=32'd16; t=`T_43; next_C=next_a; end
      4'b1011: begin a=B; b=C; c=D; d=A; m=msg_appended[288:319]; s=32'd23; t=`T_44; next_B=next_a; end
      4'b1100: begin a=A; b=B; c=C; d=D; m=msg_appended[192:223]; s=32'd04; t=`T_45; next_A=next_a; end
      4'b1101: begin a=D; b=A; c=B; d=C; m=msg_appended[96:127];  s=32'd11; t=`T_46; next_D=next_a; end
      4'b1110: begin a=C; b=D; c=A; d=B; m=msg_appended[0:31];    s=32'd16; t=`T_47; next_C=next_a; end
      4'b1111: begin a=B; b=C; c=D; d=A; m=msg_appended[416:447]; s=32'd23; t=`T_48; next_B=next_a; end
      endcase

      if (phase == 4'b1111)
         next_state = ROUND4;
   end // }
   //----------------------------------------------------------------
   //--------------------------- ROUND 4 ----------------------------
   //----------------------------------------------------------------
 
   current_state[ROUND4_BIT]:
   begin // {
      // synopsys translate_off
      ascii_state = "ROUND4";
      // synopsys translate_on
 
      round = `ROUND4;
      case (phase)
      4'b0000: begin a=A; b=B; c=C; d=D; m=msg_appended[480:511]; s=32'd06; t=`T_49; next_A=next_a; end
      4'b0001: begin a=D; b=A; c=B; d=C; m=msg_appended[256:287]; s=32'd10; t=`T_50; next_D=next_a; end
      4'b0010: begin a=C; b=D; c=A; d=B; m=msg_appended[32:63];   s=32'd15; t=`T_51; next_C=next_a; end
      4'b0011: begin a=B; b=C; c=D; d=A; m=msg_appended[320:351]; s=32'd21; t=`T_52; next_B=next_a; end
      4'b0100: begin a=A; b=B; c=C; d=D; m=msg_appended[96:127];  s=32'd06; t=`T_53; next_A=next_a; end
      4'b0101: begin a=D; b=A; c=B; d=C; m=msg_appended[384:415]; s=32'd10; t=`T_54; next_D=next_a; end
      4'b0110: begin a=C; b=D; c=A; d=B; m=msg_appended[160:191]; s=32'd15; t=`T_55; next_C=next_a; end
      4'b0111: begin a=B; b=C; c=D; d=A; m=msg_appended[448:479]; s=32'd21; t=`T_56; next_B=next_a; end
      4'b1000: begin a=A; b=B; c=C; d=D; m=msg_appended[224:255]; s=32'd06; t=`T_57; next_A=next_a; end
      4'b1001: begin a=D; b=A; c=B; d=C; m=msg_appended[0:31];    s=32'd10; t=`T_58; next_D=next_a; end
      4'b1010: begin a=C; b=D; c=A; d=B; m=msg_appended[288:319]; s=32'd15; t=`T_59; next_C=next_a; end
      4'b1011: begin a=B; b=C; c=D; d=A; m=msg_appended[64:95];   s=32'd21; t=`T_60; next_B=next_a; end
      4'b1100: begin a=A; b=B; c=C; d=D; m=msg_appended[352:383]; s=32'd06; t=`T_61; next_A=next_a; end
      4'b1101: begin a=D; b=A; c=B; d=C; m=msg_appended[128:159]; s=32'd10; t=`T_62; next_D=next_a; end
      4'b1110: begin a=C; b=D; c=A; d=B; m=msg_appended[416:447]; s=32'd15; t=`T_63; next_C=next_a; end
      4'b1111: begin a=B; b=C; c=D; d=A; m=msg_appended[192:223]; s=32'd21; t=`T_64; next_B=next_a; end
      endcase

      if (phase == 4'b1111)
         next_state = FINISH_OFF;
   end // }
   //----------------------------------------------------------------

   current_state[FINISH_OFF_BIT]: 
   begin // {
      // synopsys translate_off
      ascii_state = "FINISH_OFF";
      // synopsys translate_on

      next_A = AA + A;
      next_B = BB + B;
      next_C = CC + C;
      next_D = DD + D;

      next_state = TURN_ARND;
   end // }
   //----------------------------------------------------------------

   // One cycle for making the system to come to reset state
   current_state[TURN_ARND_BIT]: 
   begin // {
      // synopsys translate_off
      ascii_state = "TURN_ARND";
      // synopsys translate_on

      next_state = IDLE;
   end // }
 
   endcase 
end // }

//--------------------------------
//
// Flops and other combinatorial 
// logic definition
//
//--------------------------------

// Outputs
assign msg_output = {{A[24:31], A[16:23], A[8:15], A[0:7]}
                    ,{B[24:31], B[16:23], B[8:15], B[0:7]}
		    ,{C[24:31], C[16:23], C[8:15], C[0:7]}
		    ,{D[24:31], D[16:23], D[8:15], D[0:7]}};
always @(posedge clk)
   msg_out_valid <= current_state[FINISH_OFF_BIT];

assign ready = current_state[IDLE_BIT];

// Internal scratch pads
always @(posedge clk) 
   if (next_state[IDLE_BIT]) begin // {
      AA <= 32'h0;
      BB <= 32'h0;
      CC <= 32'h0;
      DD <= 32'h0;
   end // }
   else if (next_state[ROUND1_BIT] && current_state[IDLE_BIT]) begin // {
      AA <= A;
      BB <= B;
      CC <= C;
      DD <= D;
   end // }

always @(posedge clk) 
   if (next_state[IDLE_BIT]) 
      msg_appended <= 512'h0;
   else if (next_state[ROUND1_BIT] && current_state[IDLE_BIT]) begin // {
      msg_appended <= ((8'h80 << msg_in_width) | msg_in)  
                    | ((64'h0 | msg_in_width) << 448);
   end // }

// Initialize A, B, C and D and then compute them
always @(posedge clk) 
   if (reset 
   ||  next_state[IDLE_BIT]) begin // { 
      A <= SALT_A;
      B <= SALT_B;
      C <= SALT_C;
      D <= SALT_D;
   end // }
   else begin // {
      A <= next_A;
      B <= next_B;
      C <= next_C;
      D <= next_D;
   end // }

// Determine one of the 16 phases within each round
always @(posedge clk)
   if (reset) 
      phase <= 4'b0;
   else if (next_state[ROUND1_BIT] && current_state[IDLE_BIT])
      phase <= 4'b0;
   else 
      phase <= phase + 4'b1;

// Assign current_state based on reset and the next_state
always @(posedge clk)
   if (reset) 
      current_state <= IDLE;
   else 
      current_state <= next_state;
endmodule
