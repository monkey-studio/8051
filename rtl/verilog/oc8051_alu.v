//////////////////////////////////////////////////////////////////////
//// 								  ////
//// alu for 8051 Core 						  ////
//// 								  ////
//// This file is part of the 8051 cores project 		  ////
//// http://www.opencores.org/cores/8051/ 			  ////
//// 								  ////
//// Description 						  ////
//// Implementation of aritmetic unit  according to 		  ////
//// 8051 IP core specification document. Uses divide.v and 	  ////
//// multiply.v							  ////
//// 								  ////
//// To Do: 							  ////
////  pc signed add                                               ////
//// 								  ////
//// Author(s): 						  ////
//// - Simon Teran, simont@opencores.org 			  ////
//// 								  ////
//////////////////////////////////////////////////////////////////////
//// 								  ////
//// Copyright (C) 2001 Authors and OPENCORES.ORG 		  ////
//// 								  ////
//// This source file may be used and distributed without 	  ////
//// restriction provided that this copyright statement is not 	  ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
//// 								  ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version. 						  ////
//// 								  ////
//// This source is distributed in the hope that it will be 	  ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 	  ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details. 							  ////
//// 								  ////
//// You should have received a copy of the GNU Lesser General 	  ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml 			  ////
//// 								  ////
//////////////////////////////////////////////////////////////////////
//
// ver: 1
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"



module oc8051_alu (clk, rst, op_code, src1, src2, src3, srcCy, srcAc, bit_in, des1, des2, des1_r, desCy, desAc, desOv);
//
// op_code      (in)  operation code [oc8051_decoder.alu_op -r]
// src1         (in)  first operand [oc8051_alu_src1_sel.des]
// src2         (in)  second operand [oc8051_alu_src2_sel.des]
// src3         (in)  third operand [oc8051_alu_src3_sel.des]
// srcCy        (in)  carry input [oc8051_cy_select.data_out]
// srcAc        (in)  auxiliary carry input [oc8051_psw.data_out[6] ]
// bit_in       (in)  bit input, used for logic operatins on bits [oc8051_ram_sel.bit_out]
// des1         (out) 
// des1_r       (out)
// des2         (out)
// desCy        (out) carry output [oc8051_ram_top.bit_data_in, oc8051_acc.bit_in, oc8051_b_register.bit_in, oc8051_psw.cy_in, oc8051_ports.bit_in]
// desAc        (out) auxiliary carry output [oc8051_psw.ac_in]
// desOv        (out) Overflow output [oc8051_psw.ov_in]
//

input srcCy, srcAc, bit_in, clk, rst; input [3:0] op_code; input [7:0] src1, src2, src3;
output desCy, desAc, desOv;
output [7:0] des1, des2;
output [7:0] des1_r;

reg desCy, desAc, desOv;
reg [7:0] des1, des2;

reg [7:0] des1_r;

//
//add
//
wire [4:0] add1, add2, add3, add4;
wire [3:0] add5, add6, add7, add8;
wire [1:0] add9, adda, addb, addc;

//
//sub
//
wire [4:0] sub1, sub2, sub3, sub4;
wire [3:0] sub5, sub6, sub7, sub8;
wire [1:0] sub9, suba, subb, subc;

//
//mul
//
  wire [7:0] mulsrc1, mulsrc2;
  wire mulOv;
  reg enable_mul;

//
//div
//
wire [7:0] divsrc1,divsrc2;
wire divOv;
reg enable_div;

//
//da
//
reg da_tmp;
//reg [8:0] da1;

oc8051_multiply oc8051_mul1(.clk(clk), .rst(rst), .enable(enable_mul), .src1(src1), .src2(src2), .des1(mulsrc1), .des2(mulsrc2), .desOv(mulOv));
oc8051_divide oc8051_div1(.clk(clk), .rst(rst), .enable(enable_div), .src1(src1), .src2(src2), .des1(divsrc1), .des2(divsrc2), .desOv(divOv));

/* Add */
assign add1 = {1'b0,src1[3:0]};
assign add2 = {1'b0,src2[3:0]};
assign add3 = {3'b000,srcCy};
assign add4 = add1+add2+add3;

assign add5 = {1'b0,src1[6:4]};
assign add6 = {1'b0,src2[6:4]};
assign add7 = {1'b0,1'b0,1'b0,add4[4]};
assign add8 = add5+add6+add7;

assign add9 = {1'b0,src1[7]};
assign adda = {1'b0,src2[7]};
assign addb = {1'b0,add8[3]};
assign addc = add9+adda+addb;

/* Sub */
assign sub1 = {1'b1,src1[3:0]};
assign sub2 = {1'b0,src2[3:0]};
assign sub3 = {1'b0,1'b0,1'b0,srcCy};
assign sub4 = sub1-sub2-sub3;

assign sub5 = {1'b1,src1[6:4]};
assign sub6 = {1'b0,src2[6:4]};
assign sub7 = {1'b0,1'b0,1'b0, !sub4[4]};
assign sub8 = sub5-sub6-sub7;

assign sub9 = {1'b1,src1[7]};
assign suba = {1'b0,src2[7]};
assign subb = {1'b0,!sub8[3]};
assign subc = sub9-suba-subb;


always @(op_code or src1 or src2 or srcCy or srcAc or bit_in or src3 or mulsrc1 or mulsrc2 or mulOv or divsrc1 or divsrc2 or divOv or addc or add8 or add4 or sub4 or sub8 or subc or da_tmp)
begin

  case (op_code)
//operation add
    `OC8051_ALU_ADD: begin
      des1 = {addc[0],add8[2:0],add4[3:0]};
      des2 = src3+ {7'b0, addc[1]};
      desCy = addc[1];
      desAc = add4[4];
      desOv = addc[1] ^ add8[3];

      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation subtract
    `OC8051_ALU_SUB: begin
      des1 = {subc[0],sub8[2:0],sub4[3:0]};
      des2 = 8'h00;
      desCy = !subc[1];
      desAc = !sub4[4];
      desOv = !subc[1] ^ sub8[3];

      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation multiply
    `OC8051_ALU_MUL: begin
      des1 = mulsrc1;
      des2 = mulsrc2;
      desOv = mulOv;
      desCy = 1'b0;
      desAc = 1'bx;
      enable_mul = 1'b1;
      enable_div = 1'b0;
    end
//operation divide
    `OC8051_ALU_DIV: begin
      des1 = divsrc1;
      des2 = divsrc2;
      desOv = divOv;
      desAc = 1'bx;
      desCy = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b1;
    end
//operation decimal adjustment
    `OC8051_ALU_DA: begin
/*      da1= {1'b0, src1};
      if (srcAc==1'b1 | da1[3:0]>4'b1001) da1= da1+ 9'b0_0000_0110;

      da1[8]= da1[8] | srcCy;

      if (da1[8]==1'b1) da1=da1+ 9'b0_0110_0000;
      des1=da1[7:0];
      des2=8'h00;
      desCy=da1[8];*/

      if (srcAc==1'b1 | src1[3:0]>4'b1001) {da_tmp, des1[3:0]} = {1'b0, src1[3:0]}+ 5'b00110;
      else {da_tmp, des1[3:0]} = {1'b0, src1[3:0]};

      if (srcCy==1'b1 | src1[7:4]>4'b1001)
        {desCy, des1[7:4]} = {srcCy, src1[7:4]}+ 5'b00110 + {4'b0, da_tmp};
      else {desCy, des1[7:4]} = {srcCy, src1[7:4]} + {4'b0, da_tmp};

      des2 = 8'h00;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation not
// bit operation not
    `OC8051_ALU_NOT: begin
      des1 = ~src1;
      des2 = 8'h00;
      desCy = !srcCy;
      desAc = 1'bx;
      desOv = 1'bx;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation and
//bit operation and
    `OC8051_ALU_AND: begin
      des1 = src1 & src2;
      des2 = 8'h00;
      desCy = srcCy & bit_in;
      desAc = 1'bx;
      desOv = 1'bx;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation xor
// bit operation xor
    `OC8051_ALU_XOR: begin
      des1 = src1 ^ src2;
      des2 = 8'h00;
      desCy = srcCy ^ bit_in;
      desAc = 1'bx;
      desOv = 1'bx;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation or
// bit operation or
    `OC8051_ALU_OR: begin
      des1 = src1 | src2;
      des2 = 8'h00;
      desCy = srcCy | bit_in;
      desAc = 1'bx;
      desOv = 1'bx;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation rotate left
// bit operation cy= cy or (not ram)
    `OC8051_ALU_RL: begin
      des1 = {src1[6:0], src1[7]};
      des2 = 8'h00;
      desCy = srcCy | !bit_in;
      desAc = 1'bx;
      desOv = 1'bx;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation rotate left with carry and swap nibbles
    `OC8051_ALU_RLC: begin
      des1 = {src1[6:0], srcCy};
      des2 = {src1[3:0], src1[7:4]};
      desCy = src1[7];
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation rotate right
    `OC8051_ALU_RR: begin
      des1 = {src1[0], src1[7:1]};
      des2 = 8'h00;
      desCy = srcCy & !bit_in;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation rotate right with carry
    `OC8051_ALU_RRC: begin
      des1 = {srcCy, src1[7:1]};
      des2 = 8'h00;
      desCy = src1[0];
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation pcs Add
    `OC8051_ALU_PCS: begin
      if (src1[7]) begin
        des1 = src2+src1;
        des2 = src3;
      end else {des2, des1} = {src3,src2} + {8'h00, src1};
      desCy = 1'b0;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
//operation exchange
//if carry = 0 exchange low order digit
    `OC8051_ALU_XCH: begin
      if (srcCy)
      begin
        des1 = src2;
        des2 = src1;
      end else begin
        des1 = {src1[7:4],src2[3:0]};
        des2 = {src2[7:4],src1[3:0]};
      end
      desCy = 1'b0;
      desAc = 1'b0;
      desOv = 1'b0;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
    default: begin
      des1 = src1;
      des2 = src2;
      desCy = srcCy;
      desAc = srcAc;
      desOv = 1'bx;
      enable_mul = 1'b0;
      enable_div = 1'b0;
    end
  endcase
end

always @(posedge clk or posedge rst)
  if (rst) begin
    des1_r <= #1 8'h0;
  end else begin
    des1_r <= #1 des1;
  end

endmodule