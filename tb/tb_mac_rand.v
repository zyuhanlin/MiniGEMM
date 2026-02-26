`timescale 1ns/1ps

module tb_mac_rand;
  reg clk = 0;
  reg rst = 1;

  reg clear = 0;
  reg valid = 0;
  reg signed [7:0] a = 0;
  reg signed [7:0] b = 0;

  wire signed [31:0] acc;

  mac dut(
    .clk(clk), .rst(rst),
    .clear(clear), .valid(valid),
    .a(a), .b(b),
    .acc(acc)
  );

  always #5 clk = ~clk;

  integer i;
  integer seed;
  integer gold;
  integer ai, bi;

  task do_one(input integer aa, input integer bb);
    integer prod;
    begin
      // drive inputs BEFORE rising edge
      a = aa[7:0];
      b = bb[7:0];
      valid = 1'b1;

      // golden uses EXACTLY what DUT sees (signed 8-bit)
      prod = $signed(a) * $signed(b);
      gold = gold + prod;

      @(posedge clk);
      #1;

      if (acc !== gold) begin
        $display("FAIL at iter=%0d  a=%0d b=%0d  acc=%0d  gold=%0d",
                 i, $signed(a), $signed(b), acc, gold);
        $fatal;
      end

      valid = 1'b0;
    end
  endtask

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_mac_rand);

    seed = 32'h1234_5678;
    gold = 0;

    #12 rst = 0;

    // synchronous clear
    @(posedge clk);
    clear = 1;
    gold  = 0;
    @(posedge clk);
    clear = 0;
    #1;
    if (acc !== 0) begin
      $display("FAIL: acc not zero after clear, acc=%0d", acc);
      $fatal;
    end

    for (i = 0; i < 200; i = i + 1) begin
      // FIX: force into 0..255 then map to -128..127
      ai = (($random(seed) & 8'hFF) - 128);
      bi = (($random(seed) & 8'hFF) - 128);
      do_one(ai, bi);
    end

    $display("PASS: randomized MAC test passed. final acc=%0d", acc);
    #20;
    $finish;
  end
endmodule
