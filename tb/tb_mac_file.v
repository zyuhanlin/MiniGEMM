`timescale 1ns/1ps

module tb_mac_file;
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

  integer fd;
  integer r;
  integer line;
  integer aa, bb;
  integer exp_acc;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_mac_file);

    // release reset
    #12 rst = 0;

    // clear accumulator once
    @(posedge clk);
    clear = 1;
    @(posedge clk);
    clear = 0;
    valid = 0;

    // open vectors file
    fd = $fopen("vectors.txt", "r");
    if (fd == 0) begin
      $display("FAIL: cannot open vectors.txt (run python3 scripts/gen_vectors.py first)");
      $fatal;
    end

    line = 0;

    // read until EOF
    while (!$feof(fd)) begin
      r = $fscanf(fd, "%d %d %d\n", aa, bb, exp_acc);
      if (r != 3) begin
        // skip malformed line
        disable read_loop;
      end

      // drive inputs before rising edge
      a = aa[7:0];
      b = bb[7:0];
      valid = 1'b1;

      @(posedge clk);
      #1;

      line = line + 1;
      if (acc !== exp_acc) begin
        $display("FAIL line=%0d  a=%0d b=%0d  acc=%0d  expected=%0d",
                 line, $signed(a), $signed(b), acc, exp_acc);
        $fatal;
      end

      valid = 1'b0;
    end

    $fclose(fd);
    $display("PASS: file-driven test passed. lines=%0d final acc=%0d", line, acc);
    #20;
    $finish;
  end

  // label for disable (avoid syntax issues if r!=3)
  // Some simulators require named block; iverilog is ok with this pattern.
  initial begin : read_loop end

endmodule
