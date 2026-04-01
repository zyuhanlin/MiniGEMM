module mac_pipe #(
  parameter AW   = 8,
  parameter ACCW = 32
)(
  input  wire                    clk,
  input  wire                    rst,
  input  wire                    clear,
  input  wire                    valid,
  input  wire signed [AW-1:0]    a,
  input  wire signed [AW-1:0]    b,
  output reg  signed [ACCW-1:0]  acc
);

  // Stage 1 pipeline registers
  reg  signed [2*AW-1:0] prod_r;
  reg                    valid_r;

  // current combinational product
  wire signed [2*AW-1:0] prod_w = $signed(a) * $signed(b);

  always @(posedge clk) begin
    if (rst) begin
      acc     <= '0;
      prod_r  <= '0;
      valid_r <= 1'b0;
    end else if (clear) begin
      acc     <= '0;
      prod_r  <= '0;
      valid_r <= 1'b0;
    end else begin
      // Stage 1: capture product + valid
      prod_r  <= prod_w;
      valid_r <= valid;

      // Stage 2: use previous cycle's registered product
      if (valid_r) begin
        acc <= acc + prod_r;
      end
    end
  end

endmodule
