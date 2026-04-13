module tile2x2 #(
  parameter AW   = 8,
  parameter ACCW = 32
)(
  input  wire                   clk,
  input  wire                   rst,
  input  wire                   clear,
  input  wire                   valid,

  input  wire signed [AW-1:0]   a0,
  input  wire signed [AW-1:0]   a1,
  input  wire signed [AW-1:0]   b0,
  input  wire signed [AW-1:0]   b1,

  output reg signed [ACCW-1:0]  c00,
  output reg signed [ACCW-1:0]  c01,
  output reg signed [ACCW-1:0]  c10,
  output reg signed [ACCW-1:0]  c11
);

  // 当前拍的四个乘积（组合逻辑）
  wire signed [2*AW-1:0] p00 = $signed(a0) * $signed(b0);
  wire signed [2*AW-1:0] p01 = $signed(a0) * $signed(b1);
  wire signed [2*AW-1:0] p10 = $signed(a1) * $signed(b0);
  wire signed [2*AW-1:0] p11 = $signed(a1) * $signed(b1);

  always @(posedge clk) begin
    if (rst) begin
      c00 <= '0;
      c01 <= '0;
      c10 <= '0;
      c11 <= '0;
    end else if (clear) begin
      c00 <= '0;
      c01 <= '0;
      c10 <= '0;
      c11 <= '0;
    end else if (valid) begin
      c00 <= c00 + p00;
      c01 <= c01 + p01;
      c10 <= c10 + p10;
      c11 <= c11 + p11;
    end
  end

endmodule
