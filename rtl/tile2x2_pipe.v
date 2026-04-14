module tile2x2_pipe #(
  parameter AW   = 8,
  parameter ACCW = 32
)(
  input  wire                   clk,
  input  wire                   rst,
  input  wire                   clear,
  input  wire                   valid,

  input  wire signed [AW-1:0]  a0,
  input  wire signed [AW-1:0]  a1,
  input  wire signed [AW-1:0]  b0,
  input  wire signed [AW-1:0]  b1,

  output reg signed [ACCW-1:0] c00,
  output reg signed [ACCW-1:0] c01,
  output reg signed [ACCW-1:0] c10,
  output reg signed [ACCW-1:0] c11
);

  // 当前拍组合乘积
  wire signed [2*AW-1:0] p00_w = $signed(a0) * $signed(b0);
  wire signed [2*AW-1:0] p01_w = $signed(a0) * $signed(b1);
  wire signed [2*AW-1:0] p10_w = $signed(a1) * $signed(b0);
  wire signed [2*AW-1:0] p11_w = $signed(a1) * $signed(b1);

  // 流水线寄存器：存上一拍的4个乘积 + valid
  reg signed [2*AW-1:0] p00_r, p01_r, p10_r, p11_r;
  reg                   valid_r;

  always @(posedge clk) begin
    if (rst) begin
      c00 <= '0;
      c01 <= '0;
      c10 <= '0;
      c11 <= '0;

      p00_r <= '0;
      p01_r <= '0;
      p10_r <= '0;
      p11_r <= '0;
      valid_r <= 1'b0;

    end else if (clear) begin
      c00 <= '0;
      c01 <= '0;
      c10 <= '0;
      c11 <= '0;

      p00_r <= '0;
      p01_r <= '0;
      p10_r <= '0;
      p11_r <= '0;
      valid_r <= 1'b0;

    end else begin
      // Stage 1: 先把当前拍乘积和 valid 存起来
      p00_r <= p00_w;
      p01_r <= p01_w;
      p10_r <= p10_w;
      p11_r <= p11_w;
      valid_r <= valid;

      // Stage 2: 用上一拍寄存下来的乘积更新输出 tile
      if (valid_r) begin
        c00 <= c00 + p00_r;
        c01 <= c01 + p01_r;
        c10 <= c10 + p10_r;
        c11 <= c11 + p11_r;
      end
    end
  end

endmodule
