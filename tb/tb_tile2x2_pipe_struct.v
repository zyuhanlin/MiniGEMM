`timescale 1ns/1ps

module tb_tile2x2_pipe_struct;
  reg clk = 0;
  reg rst = 1;
  reg clear = 0;
  reg valid = 0;

  reg signed [7:0] a0 = 0;
  reg signed [7:0] a1 = 0;
  reg signed [7:0] b0 = 0;
  reg signed [7:0] b1 = 0;

  wire signed [31:0] c00, c01, c10, c11;

  integer active_cycles;
  integer total_cycles;
  integer mac_count;

  // 1-cycle delayed expected tile
  integer exp_c00_d1, exp_c01_d1, exp_c10_d1, exp_c11_d1;
  reg     exp_valid_d1;

  tile2x2_pipe_struct dut(
    .clk(clk), .rst(rst), .clear(clear), .valid(valid),
    .a0(a0), .a1(a1), .b0(b0), .b1(b1),
    .c00(c00), .c01(c01), .c10(c10), .c11(c11)
  );

  always #5 clk = ~clk;

  task drive_one(
    input integer in_a0, input integer in_a1,
    input integer in_b0, input integer in_b1,
    input integer in_exp_c00, input integer in_exp_c01,
    input integer in_exp_c10, input integer in_exp_c11
  );
    begin
      a0 = in_a0[7:0];
      a1 = in_a1[7:0];
      b0 = in_b0[7:0];
      b1 = in_b1[7:0];
      valid = 1'b1;

      @(posedge clk);
      #1;

      total_cycles  = total_cycles + 1;
      active_cycles = active_cycles + 1;
      mac_count     = mac_count + 4;

      // 检查上一拍延迟对齐后的 expected
      if (exp_valid_d1) begin
        if (c00 !== exp_c00_d1 || c01 !== exp_c01_d1 ||
            c10 !== exp_c10_d1 || c11 !== exp_c11_d1) begin
          $display("FAIL: c00=%0d c01=%0d c10=%0d c11=%0d  expected=%0d,%0d,%0d,%0d",
                   c00, c01, c10, c11,
                   exp_c00_d1, exp_c01_d1, exp_c10_d1, exp_c11_d1);
          $fatal;
        end
      end

      // 当前这拍的 expected 留给下一拍检查
      exp_c00_d1 = in_exp_c00;
      exp_c01_d1 = in_exp_c01;
      exp_c10_d1 = in_exp_c10;
      exp_c11_d1 = in_exp_c11;
      exp_valid_d1 = 1'b1;

      valid = 1'b0;
    end
  endtask

  task flush_one;
    begin
      valid = 1'b0;

      @(posedge clk);
      #1;

      total_cycles = total_cycles + 1;

      if (exp_valid_d1) begin
        if (c00 !== exp_c00_d1 || c01 !== exp_c01_d1 ||
            c10 !== exp_c10_d1 || c11 !== exp_c11_d1) begin
          $display("FAIL (flush): c00=%0d c01=%0d c10=%0d c11=%0d  expected=%0d,%0d,%0d,%0d",
                   c00, c01, c10, c11,
                   exp_c00_d1, exp_c01_d1, exp_c10_d1, exp_c11_d1);
          $fatal;
        end
      end
    end
  endtask

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_tile2x2_pipe_struct);

    active_cycles = 0;
    total_cycles  = 0;
    mac_count     = 0;

    exp_c00_d1 = 0;
    exp_c01_d1 = 0;
    exp_c10_d1 = 0;
    exp_c11_d1 = 0;
    exp_valid_d1 = 1'b0;

    // release reset
    #12 rst = 0;

    // clear DUT state
    @(posedge clk);
    clear = 1;
    @(posedge clk);
    clear = 0;

    // k = 0 -> expected [7,8;28,32]
    drive_one(1, 4, 7, 8, 7, 8, 28, 32);

    // k = 1 -> expected [25,28;73,82]
    drive_one(2, 5, 9, 10, 25, 28, 73, 82);

    // k = 2 -> expected [58,64;139,154]
    drive_one(3, 6, 11, 12, 58, 64, 139, 154);

    // flush final result
    flush_one();

    $display("PASS: tile2x2_pipe_struct test passed. c00=%0d c01=%0d c10=%0d c11=%0d",
             c00, c01, c10, c11);

    $display("PERF(active): active_cycles=%0d total_macs=%0d macs_per_active_cycle=%0f",
             active_cycles, mac_count, mac_count * 1.0 / active_cycles);

    $display("PERF(end_to_end): total_cycles=%0d total_macs=%0d macs_per_total_cycle=%0f",
             total_cycles, mac_count, mac_count * 1.0 / total_cycles);

    #20;
    $finish;
  end
endmodule
