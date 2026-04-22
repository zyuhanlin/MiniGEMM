`timescale 1ns/1ps

module tb_tile4x4_pipe_struct;
  reg clk = 0;
  reg rst = 1;
  reg clear = 0;
  reg valid = 0;

  reg signed [7:0] a0 = 0;
  reg signed [7:0] a1 = 0;
  reg signed [7:0] a2 = 0;
  reg signed [7:0] a3 = 0;

  reg signed [7:0] b0 = 0;
  reg signed [7:0] b1 = 0;
  reg signed [7:0] b2 = 0;
  reg signed [7:0] b3 = 0;

  wire signed [31:0] c00, c01, c02, c03;
  wire signed [31:0] c10, c11, c12, c13;
  wire signed [31:0] c20, c21, c22, c23;
  wire signed [31:0] c30, c31, c32, c33;

  integer active_cycles;
  integer total_cycles;
  integer mac_count;

  // 1-cycle delayed expected 4x4 tile
  integer exp00_d1, exp01_d1, exp02_d1, exp03_d1;
  integer exp10_d1, exp11_d1, exp12_d1, exp13_d1;
  integer exp20_d1, exp21_d1, exp22_d1, exp23_d1;
  integer exp30_d1, exp31_d1, exp32_d1, exp33_d1;
  reg     exp_valid_d1;

  tile4x4_pipe_struct dut(
    .clk(clk), .rst(rst), .clear(clear), .valid(valid),
    .a0(a0), .a1(a1), .a2(a2), .a3(a3),
    .b0(b0), .b1(b1), .b2(b2), .b3(b3),
    .c00(c00), .c01(c01), .c02(c02), .c03(c03),
    .c10(c10), .c11(c11), .c12(c12), .c13(c13),
    .c20(c20), .c21(c21), .c22(c22), .c23(c23),
    .c30(c30), .c31(c31), .c32(c32), .c33(c33)
  );

  always #5 clk = ~clk;

  task drive_one(
    input integer in_a0, input integer in_a1, input integer in_a2, input integer in_a3,
    input integer in_b0, input integer in_b1, input integer in_b2, input integer in_b3,

    input integer e00, input integer e01, input integer e02, input integer e03,
    input integer e10, input integer e11, input integer e12, input integer e13,
    input integer e20, input integer e21, input integer e22, input integer e23,
    input integer e30, input integer e31, input integer e32, input integer e33
  );
    begin
      a0 = in_a0[7:0];
      a1 = in_a1[7:0];
      a2 = in_a2[7:0];
      a3 = in_a3[7:0];

      b0 = in_b0[7:0];
      b1 = in_b1[7:0];
      b2 = in_b2[7:0];
      b3 = in_b3[7:0];

      valid = 1'b1;

      @(posedge clk);
      #1;

      total_cycles  = total_cycles + 1;
      active_cycles = active_cycles + 1;
      mac_count     = mac_count + 16;   // 4x4 tile = 16 MACs per active cycle

      // check delayed expected from previous cycle
      if (exp_valid_d1) begin
        if (c00 !== exp00_d1 || c01 !== exp01_d1 || c02 !== exp02_d1 || c03 !== exp03_d1 ||
            c10 !== exp10_d1 || c11 !== exp11_d1 || c12 !== exp12_d1 || c13 !== exp13_d1 ||
            c20 !== exp20_d1 || c21 !== exp21_d1 || c22 !== exp22_d1 || c23 !== exp23_d1 ||
            c30 !== exp30_d1 || c31 !== exp31_d1 || c32 !== exp32_d1 || c33 !== exp33_d1) begin

          $display("FAIL:");
          $display("Row0 got=%0d %0d %0d %0d  exp=%0d %0d %0d %0d",
                   c00, c01, c02, c03, exp00_d1, exp01_d1, exp02_d1, exp03_d1);
          $display("Row1 got=%0d %0d %0d %0d  exp=%0d %0d %0d %0d",
                   c10, c11, c12, c13, exp10_d1, exp11_d1, exp12_d1, exp13_d1);
          $display("Row2 got=%0d %0d %0d %0d  exp=%0d %0d %0d %0d",
                   c20, c21, c22, c23, exp20_d1, exp21_d1, exp22_d1, exp23_d1);
          $display("Row3 got=%0d %0d %0d %0d  exp=%0d %0d %0d %0d",
                   c30, c31, c32, c33, exp30_d1, exp31_d1, exp32_d1, exp33_d1);
          $fatal;
        end
      end

      // save current expected for next cycle
      exp00_d1 = e00; exp01_d1 = e01; exp02_d1 = e02; exp03_d1 = e03;
      exp10_d1 = e10; exp11_d1 = e11; exp12_d1 = e12; exp13_d1 = e13;
      exp20_d1 = e20; exp21_d1 = e21; exp22_d1 = e22; exp23_d1 = e23;
      exp30_d1 = e30; exp31_d1 = e31; exp32_d1 = e32; exp33_d1 = e33;
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
        if (c00 !== exp00_d1 || c01 !== exp01_d1 || c02 !== exp02_d1 || c03 !== exp03_d1 ||
            c10 !== exp10_d1 || c11 !== exp11_d1 || c12 !== exp12_d1 || c13 !== exp13_d1 ||
            c20 !== exp20_d1 || c21 !== exp21_d1 || c22 !== exp22_d1 || c23 !== exp23_d1 ||
            c30 !== exp30_d1 || c31 !== exp31_d1 || c32 !== exp32_d1 || c33 !== exp33_d1) begin

          $display("FAIL (flush):");
          $display("Row0 got=%0d %0d %0d %0d  exp=%0d %0d %0d %0d",
                   c00, c01, c02, c03, exp00_d1, exp01_d1, exp02_d1, exp03_d1);
          $display("Row1 got=%0d %0d %0d %0d  exp=%0d %0d %0d %0d",
                   c10, c11, c12, c13, exp10_d1, exp11_d1, exp12_d1, exp13_d1);
          $display("Row2 got=%0d %0d %0d %0d  exp=%0d %0d %0d %0d",
                   c20, c21, c22, c23, exp20_d1, exp21_d1, exp22_d1, exp23_d1);
          $display("Row3 got=%0d %0d %0d %0d  exp=%0d %0d %0d %0d",
                   c30, c31, c32, c33, exp30_d1, exp31_d1, exp32_d1, exp33_d1);
          $fatal;
        end
      end
    end
  endtask

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_tile4x4_pipe_struct);

    active_cycles = 0;
    total_cycles  = 0;
    mac_count     = 0;

    exp00_d1 = 0; exp01_d1 = 0; exp02_d1 = 0; exp03_d1 = 0;
    exp10_d1 = 0; exp11_d1 = 0; exp12_d1 = 0; exp13_d1 = 0;
    exp20_d1 = 0; exp21_d1 = 0; exp22_d1 = 0; exp23_d1 = 0;
    exp30_d1 = 0; exp31_d1 = 0; exp32_d1 = 0; exp33_d1 = 0;
    exp_valid_d1 = 1'b0;

    // release reset
    #12 rst = 0;

    // clear DUT state
    @(posedge clk);
    clear = 1;
    @(posedge clk);
    clear = 0;

    // step 0: b = [1,1,1,1]
    drive_one(
      1, 2, 3, 4,
      1, 1, 1, 1,

      1, 1, 1, 1,
      2, 2, 2, 2,
      3, 3, 3, 3,
      4, 4, 4, 4
    );

    // step 1: b = [2,2,2,2]
    drive_one(
      1, 2, 3, 4,
      2, 2, 2, 2,

      3, 3, 3, 3,
      6, 6, 6, 6,
      9, 9, 9, 9,
      12,12,12,12
    );

    // step 2: b = [3,3,3,3]
    drive_one(
      1, 2, 3, 4,
      3, 3, 3, 3,

      6, 6, 6, 6,
      12,12,12,12,
      18,18,18,18,
      24,24,24,24
    );

    // step 3: b = [4,4,4,4]
    drive_one(
      1, 2, 3, 4,
      4, 4, 4, 4,

      10,10,10,10,
      20,20,20,20,
      30,30,30,30,
      40,40,40,40
    );

    // pipeline flush
    flush_one();

    $display("PASS: tile4x4_pipe_struct 4-step test passed.");

    $display("PERF(active): active_cycles=%0d total_macs=%0d macs_per_active_cycle=%0f",
             active_cycles, mac_count, mac_count * 1.0 / active_cycles);

    $display("PERF(end_to_end): total_cycles=%0d total_macs=%0d macs_per_total_cycle=%0f",
             total_cycles, mac_count, mac_count * 1.0 / total_cycles);

    #20;
    $finish;
  end
endmodule
