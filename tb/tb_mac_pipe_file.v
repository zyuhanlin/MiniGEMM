`timescale 1ns/1ps

module tb_mac_pipe_file;
  reg clk = 0;
  reg rst = 1;

  reg clear = 0;
  reg valid = 0;
  reg signed [7:0] a = 0;
  reg signed [7:0] b = 0;

  wire signed [31:0] acc;

  // DUT: pipelined MAC
  mac_pipe dut(
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

  // delayed expected value (1-cycle latency alignment)
  integer exp_d1;
  reg     exp_valid_d1;

  task drive_one(input integer in_a, input integer in_b, input integer in_exp);
    begin
      // drive current input before rising edge
      a = in_a[7:0];
      b = in_b[7:0];
      valid = 1'b1;

      // wait one clock edge
      @(posedge clk);
      #1;

      // check previous expected value (aligned with pipeline delay)
      if (exp_valid_d1) begin
        if (acc !== exp_d1) begin
          $display("FAIL line=%0d  acc=%0d expected=%0d", line, acc, exp_d1);
          $fatal;
        end
      end

      // shift current expected into delayed register
      exp_d1 = in_exp;
      exp_valid_d1 = 1'b1;

      valid = 1'b0;
    end
  endtask

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_mac_pipe_file);

    exp_d1 = 0;
    exp_valid_d1 = 1'b0;

    // release reset
    #12 rst = 0;

    // clear DUT and pipeline state
    @(posedge clk);
    clear = 1;
    @(posedge clk);
    clear = 0;
    valid = 0;

    // open vectors file
    fd = $fopen("vectors.txt", "r");
    if (fd == 0) begin
      $display("FAIL: cannot open vectors.txt");
      $fatal;
    end

    line = 0;

    while (!$feof(fd)) begin
      r = $fscanf(fd, "%d %d %d\n", aa, bb, exp_acc);
      if (r == 3) begin
        line = line + 1;
        drive_one(aa, bb, exp_acc);
      end
    end

    $fclose(fd);

    // flush final delayed expected value
    @(posedge clk);
    #1;
    if (exp_valid_d1) begin
      if (acc !== exp_d1) begin
        $display("FAIL final flush  acc=%0d expected=%0d", acc, exp_d1);
        $fatal;
      end
    end

    $display("PASS: pipelined file-driven test passed. lines=%0d final acc=%0d", line, acc);
    #20;
    $finish;
  end
endmodule
