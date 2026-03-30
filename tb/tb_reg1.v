`timescale 1ns/1ps

module tb_reg1;
  reg clk = 0;
  reg rst = 1;
  reg d   = 0;
  wire q;

  reg1 dut(.clk(clk), .rst(rst), .d(d), .q(q));

  // 10ns period clock
  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_reg1);

    #12 rst = 0;
    #10 d = 1;
    #10 d = 0;
    #10 d = 1;
    #20 $finish;
  end
endmodule
