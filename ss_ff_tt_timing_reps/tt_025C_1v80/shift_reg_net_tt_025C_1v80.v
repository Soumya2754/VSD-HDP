/* Generated by Yosys 0.26+4 (git sha1 5ea2c290a, clang 10.0.0-4ubuntu1 -fPIC -Os) */

module dff_asyncres(clk, async_reset, d, q);
  wire _0_;
  wire _1_;
  wire _2_;
  input async_reset;
  wire async_reset;
  input clk;
  wire clk;
  input d;
  wire d;
  output q;
  wire q;
  sky130_fd_sc_hd__clkinv_1 _3_ (
    .A(_0_),
    .Y(_1_)
  );
  sky130_fd_sc_hd__dfrtp_1 _4_ (
    .CLK(clk),
    .D(d),
    .Q(q),
    .RESET_B(_2_)
  );
  assign _0_ = async_reset;
  assign _2_ = _1_;
endmodule

module mux_4x1(i0, i1, i2, i3, s, y);
  wire _00_;
  wire _01_;
  wire _02_;
  wire _03_;
  wire _04_;
  wire _05_;
  wire _06_;
  wire _07_;
  wire _08_;
  wire _09_;
  wire _10_;
  wire _11_;
  wire _12_;
  wire _13_;
  wire _14_;
  wire _15_;
  input i0;
  wire i0;
  input i1;
  wire i1;
  input i2;
  wire i2;
  input i3;
  wire i3;
  input [1:0] s;
  wire [1:0] s;
  output y;
  wire y;
  sky130_fd_sc_hd__mux4_2 _16_ (
    .A0(_09_),
    .A1(_10_),
    .A2(_11_),
    .A3(_12_),
    .S0(_13_),
    .S1(_14_),
    .X(_15_)
  );
  assign _14_ = s[1];
  assign _13_ = s[0];
  assign _12_ = i3;
  assign _11_ = i2;
  assign _10_ = i1;
  assign _09_ = i0;
  assign y = _15_;
endmodule

module shift_reg(p, s, sr, sl, clk, reset, q, out_clk);
  input clk;
  wire clk;
  output [3:0] out_clk;
  wire [3:0] out_clk;
  input [3:0] p;
  wire [3:0] p;
  output [3:0] q;
  wire [3:0] q;
  input reset;
  wire reset;
  input [1:0] s;
  wire [1:0] s;
  input sl;
  wire sl;
  input sr;
  wire sr;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  dff_asyncres d1 (
    .async_reset(reset),
    .clk(clk),
    .d(w1),
    .q(q[0])
  );
  dff_asyncres d2 (
    .async_reset(reset),
    .clk(clk),
    .d(w2),
    .q(q[1])
  );
  dff_asyncres d3 (
    .async_reset(reset),
    .clk(clk),
    .d(w3),
    .q(q[2])
  );
  dff_asyncres d4 (
    .async_reset(reset),
    .clk(clk),
    .d(w4),
    .q(q[3])
  );
  mux_4x1 m1 (
    .i0(q[0]),
    .i1(sr),
    .i2(q[1]),
    .i3(p[0]),
    .s(s),
    .y(w1)
  );
  mux_4x1 m2 (
    .i0(q[1]),
    .i1(q[0]),
    .i2(q[2]),
    .i3(p[1]),
    .s(s),
    .y(w2)
  );
  mux_4x1 m3 (
    .i0(q[2]),
    .i1(q[1]),
    .i2(q[3]),
    .i3(p[2]),
    .s(s),
    .y(w3)
  );
  mux_4x1 m4 (
    .i0(q[3]),
    .i1(q[2]),
    .i2(sl),
    .i3(p[3]),
    .s(s),
    .y(w4)
  );
  assign out_clk = { 3'h0, clk };
endmodule
