`timescale 1ns / 1ps
module tb_shift_reg;
  reg [3:0]p;
  reg [1:0]s;
  reg sr,sl,clk,reset;
  wire [3:0]q;
  
  initial clk = 0;
  always #5 clk = ~clk;
  
  shift_reg r1(p,s,sr,sl,clk,reset,q);
  initial 
    begin
      reset = 1;
      #10 reset = 0; s = 2'b01; sr = 1;p = 4'b1000;
      #20 $display("%b", q);
      #10 reset = 0; s = 2'b10; sl = 1; sr = 0; p = 4'b1001;
      #20 $display("%b", q);
      #10 reset = 0; s = 2'b11; p = 4'b1010;
      #20 $display("%b", q);
      $finish;
    end
  
  initial
    begin
      $dumpfile("shift_reg.vcd");
      $dumpvars(0,tb_shift_reg);
    end
endmodule

