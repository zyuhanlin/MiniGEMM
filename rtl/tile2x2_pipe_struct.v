module tile2x2_pipe_struct #(
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

  output wire signed [ACCW-1:0] c00,
  output wire signed [ACCW-1:0] c01,
  output wire signed [ACCW-1:0] c10,
  output wire signed [ACCW-1:0] c11
);

  // 4 个并行的流水线 MAC 实例
  mac_pipe #(.AW(AW), .ACCW(ACCW)) u_mac00 (
    .clk(clk),
    .rst(rst),
    .clear(clear),
    .valid(valid),
    .a(a0),
    .b(b0),
    .acc(c00)
  );

  mac_pipe #(.AW(AW), .ACCW(ACCW)) u_mac01 (
    .clk(clk),
    .rst(rst),
    .clear(clear),
    .valid(valid),
    .a(a0),
    .b(b1),
    .acc(c01)
  );

  mac_pipe #(.AW(AW), .ACCW(ACCW)) u_mac10 (
    .clk(clk),
    .rst(rst),
    .clear(clear),
    .valid(valid),
    .a(a1),
    .b(b0),
    .acc(c10)
  );

  mac_pipe #(.AW(AW), .ACCW(ACCW)) u_mac11 (
    .clk(clk),
    .rst(rst),
    .clear(clear),
    .valid(valid),
    .a(a1),
    .b(b1),
    .acc(c11)
  );

endmodule
