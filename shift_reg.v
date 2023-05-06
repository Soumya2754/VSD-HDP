module shift_reg(input [3:0]p, input [1:0]s, input sr,sl,clk,reset, output [3:0]q,out_clk);
  wire w1,w2,w3,w4;
  assign out_clk = clk;
  dff_asyncres d1(clk,reset,w1,q[0]);
  dff_asyncres d2(clk,reset,w2,q[1]);
  dff_asyncres d3(clk,reset,w3,q[2]);
  dff_asyncres d4(clk,reset,w4,q[3]);
  mux_4x1 m1(.i0(q[0]), .i1(sr), .i2(q[1]), .i3(p[0]), .s(s), .y(w1));
  mux_4x1 m2(.i0(q[1]), .i1(q[0]), .i2(q[2]), .i3(p[1]), .s(s), .y(w2));
  mux_4x1 m3(.i0(q[2]), .i1(q[1]), .i2(q[3]), .i3(p[2]), .s(s), .y(w3));
  mux_4x1 m4(.i0(q[3]), .i1(q[2]), .i2(sl), .i3(p[3]), .s(s), .y(w4));
endmodule

