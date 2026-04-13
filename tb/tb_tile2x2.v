`timescale 1ns/1ps

module tb_tile2x2;
  reg clk = 0;
  reg rst = 1;
  reg clear = 0;
  reg valid = 0;

  reg signed [7:0] a0 = 0;
  reg signed [7:0] a1 = 0;
  reg signed [7:0] b0 = 0;
  reg signed [7:0] b1 = 0;

  wire signed [31:0] c00, c01, c10, c11;

  integer cycle_count;
  integer mac_count;

  tile2x2 dut(
    .clk(clk), .rst(rst), .clear(clear), .valid(valid),
    .a0(a0), .a1(a1), .b0(b0), .b1(b1),
    .c00(c00), .c01(c01), .c10(c10), .c11(c11)
  );

  always #5 clk = ~clk;

  task drive_one(
    input integer in_a0, input integer in_a1,
    input integer in_b0, input integer in_b1
  );
    begin
      a0 = in_a0[7:0];
      a1 = in_a1[7:0];
      b0 = in_b0[7:0];
      b1 = in_b1[7:0];
      valid = 1'b1;

      @(posedge clk);
      #1;

      cycle_count = cycle_count + 1;
      mac_count   = mac_count + 4;

      valid = 1'b0;
    end
  endtask

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_tile2x2);

    cycle_count = 0;
    mac_count   = 0;

    // 解除复位
    #12 rst = 0;

    // 清零
    @(posedge clk);
    clear = 1;
    @(posedge clk);
    clear = 0;

    // k = 0
    drive_one(1, 4, 7, 8);

    // k = 1
    drive_one(2, 5, 9, 10);

    // k = 2
    drive_one(3, 6, 11, 12);

    if (c00 !== 58 || c01 !== 64 || c10 !== 139 || c11 !== 154) begin
      $display("FAIL: c00=%0d c01=%0d c10=%0d c11=%0d",
               c00, c01, c10, c11);
      $fatal;
    end

    $display("PASS: tile2x2 test passed. c00=%0d c01=%0d c10=%0d c11=%0d",
             c00, c01, c10, c11);

    $display("PERF: cycles=%0d total_macs=%0d macs_per_cycle=%0f",
             cycle_count, mac_count, mac_count * 1.0 / cycle_count);

    #20;
    $finish;
  end
endmodule

