module mac #(
  parameter AW   = 8,   // a,b width
  parameter ACCW = 32   // accumulator width
)(
  input  wire                   clk,
  input  wire                   rst,    // synchronous reset (highest priority)
  input  wire                   clear,  // clear accumulator
  input  wire                   valid,  // when 1, do acc += a*b
  input  wire signed [AW-1:0]   a,
  input  wire signed [AW-1:0]   b,
  output reg  signed [ACCW-1:0] acc
);

  // signed multiply, width = 2*AW
  wire signed [2*AW-1:0] prod = $signed(a) * $signed(b);

  always @(posedge clk) begin
    if (rst) begin
      acc <= '0;
    end else if (clear) begin
      acc <= '0;
    end else if (valid) begin
      acc <= acc + prod; // prod will be sign-extended when added to acc
    end
  end

endmodule
