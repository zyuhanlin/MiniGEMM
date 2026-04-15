module tile4x4_pipe_struct #(
  parameter AW   = 8,
  parameter ACCW = 32
)(
  input  wire                    clk,
  input  wire                    rst,
  input  wire                    clear,
  input  wire                    valid,

  input  wire signed [AW-1:0]    a0,
  input  wire signed [AW-1:0]    a1,
  input  wire signed [AW-1:0]    a2,
  input  wire signed [AW-1:0]    a3,

  input  wire signed [AW-1:0]    b0,
  input  wire signed [AW-1:0]    b1,
  input  wire signed [AW-1:0]    b2,
  input  wire signed [AW-1:0]    b3,

  output wire signed [ACCW-1:0]  c00, c01, c02, c03,
  output wire signed [ACCW-1:0]  c10, c11, c12, c13,
  output wire signed [ACCW-1:0]  c20, c21, c22, c23,
  output wire signed [ACCW-1:0]  c30, c31, c32, c33
);

  // Top-left 2x2 tile
  tile2x2_pipe_struct #(.AW(AW), .ACCW(ACCW)) u_tl (
    .clk(clk), .rst(rst), .clear(clear), .valid(valid),
    .a0(a0), .a1(a1),
    .b0(b0), .b1(b1),
    .c00(c00), .c01(c01),
    .c10(c10), .c11(c11)
  );

  // Top-right 2x2 tile
  tile2x2_pipe_struct #(.AW(AW), .ACCW(ACCW)) u_tr (
    .clk(clk), .rst(rst), .clear(clear), .valid(valid),
    .a0(a0), .a1(a1),
    .b0(b2), .b1(b3),
    .c00(c02), .c01(c03),
    .c10(c12), .c11(c13)
  );

  // Bottom-left 2x2 tile
  tile2x2_pipe_struct #(.AW(AW), .ACCW(ACCW)) u_bl (
    .clk(clk), .rst(rst), .clear(clear), .valid(valid),
    .a0(a2), .a1(a3),
    .b0(b0), .b1(b1),
    .c00(c20), .c01(c21),
    .c10(c30), .c11(c31)
  );

  // Bottom-right 2x2 tile
  tile2x2_pipe_struct #(.AW(AW), .ACCW(ACCW)) u_br (
    .clk(clk), .rst(rst), .clear(clear), .valid(valid),
    .a0(a2), .a1(a3),
    .b0(b2), .b1(b3),
    .c00(c22), .c01(c23),
    .c10(c32), .c11(c33)
  );

endmodule
