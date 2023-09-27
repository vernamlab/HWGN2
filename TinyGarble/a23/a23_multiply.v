//////////////////////////////////////////////////////////////////
//                                                              //
//  Multiplication Module for Amber 2 Core                      //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  64-bit Booth signed or unsigned multiply and                //
//  multiply-accumulate supported. It takes about 38 clock      //
//  cycles to complete an operation.                            //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////



// bit 0 go, bit 1 accumulate
// Command:
//  4'b01 :  MUL   - 32 bit multiplication
//  4'b11 :  MLA   - 32 bit multiply and accumulate
//
//  34-bit Booth adder
//  The adder needs to be 34 bit to deal with signed and unsigned 32-bit
//  multiplication inputs. This adds 1 extra bit. Then to deal with the
//  case of two max negative numbers another bit is required.
//

module a23_multiply (
input                       i_clk,
input                       i_rst,

input       [31:0]          i_a_in,         // Rds
input       [31:0]          i_b_in,         // Rm
input       [1:0]           i_function,
input                       i_execute,

output      [31:0]          o_out,
output      [1:0]           o_flags,        // [1] = N, [0] = Z
output                      o_done    // goes high 2 cycles before completion                                          
);


wire        enable;
wire        accumulate;

reg  [31:0] product;
reg  [3:0]  count;

assign enable         = i_function[0];
assign accumulate     = i_function[1];

assign o_out   = product;

assign o_flags = {o_out[31], o_out == 32'd0 }; 
assign o_done  = 1'b1;


always @(posedge i_clk or posedge i_rst) begin
  if (i_rst) begin
    product <= 32'b0;
    count <= 4'b0;
  end else if(enable) begin
    count <= count + 1;
    if (i_execute && count == 0) begin
      product <= i_a_in*i_b_in;
    end else if (i_execute && accumulate && count == 3) begin
      product <= product + i_a_in;
    end
  end else begin
    product <= 32'b0;
    count <= 4'b0;
  end
end

// wire [33:0] multiplier;
// wire [33:0] multiplier_bar;
// wire [33:0] sum;
// wire [33:0] sum34_b;

// reg  [5:0]  count;
// reg  [5:0]  count_nxt;
// reg  [67:0] product;
// reg  [67:0] product_nxt;
// reg  [1:0]  flags_nxt;
// wire [32:0] sum_acc1;           // the MSB is the carry out for the upper 32 bit addition
// assign multiplier     =  { 2'd0, i_a_in} ;
// assign multiplier_bar = ~{ 2'd0, i_a_in} + 34'd1 ;

// assign sum34_b        =  product[1:0] == 2'b01 ? multiplier     :
//                          product[1:0] == 2'b10 ? multiplier_bar :
//                                                  34'd0          ;


// // -----------------------------------
// // 34-bit adder - booth multiplication
// // -----------------------------------
// assign sum =  product[67:34] + sum34_b;
 
// // ------------------------------------
// // 33-bit adder - accumulate operations
// // ------------------------------------
// assign sum_acc1 = {1'd0, product[32:1]} + {1'd0, i_a_in};


// always @*
// begin
//   // Defaults
//   count_nxt           = count;
//   product_nxt         = product;
  
//   // update Negative and Zero flags
//   // Use registered value of product so this adds an extra cycle
//   // but this avoids having the 64-bit zero comparator on the
//   // main adder path
//   flags_nxt   = { product[32], product[32:1] == 32'd0 }; 
    

//   if ( count == 6'd0 )
//     product_nxt = {33'd0, 1'd0, i_b_in, 1'd0 } ;
//   else if ( count <= 6'd33 )
//     product_nxt = { sum[33], sum, product[33:1]} ;
//   else if ( count == 6'd34 && accumulate )
//   begin
//     // Note that bit 0 is not part of the product. It is used during the booth
//     // multiplication algorithm
//     product_nxt         = { product[64:33], sum_acc1[31:0], 1'd0}; // Accumulate
//   end
        
//   // Multiplication state counter
//   if (count == 6'd0)  // start
//     count_nxt   = enable ? 6'd1 : 6'd0;
//   else if ((count == 6'd34 && !accumulate) ||  // MUL
//            (count == 6'd35 &&  accumulate)  )  // MLA
//     count_nxt   = 6'd0;
//   else
//     count_nxt   = count + 1'd1;

// end


//   always @ ( posedge i_clk or posedge i_rst)
//   if (i_rst) begin
//     product         <= 'd0;
//     count           <= 'd0;
//     o_done          <= 'd0;
//   end else if (enable)
//   begin 
//     if(i_execute) begin
//           product         <= product_nxt;
//     end
//     count           <= count_nxt;
//     o_done          <= count == 6'd31;
//   end

// Outputs
// assign o_out   = product[32:1]; 
// assign o_flags = flags_nxt;
                     
endmodule


