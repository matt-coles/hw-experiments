`timescale 100ps/1ps
/*
* DEPTH must be a power of 2
*/
module simple_fifo #(
  parameter DEPTH = 8,
  parameter WIDTH = 16
)(
  input wire clk,
  input wire reset_n,
  input wire push,
  input wire pop,

  input wire [WIDTH-1:0] data_in,
  output reg [WIDTH-1:0] data_out,

  output reg full,
  output reg empty
);

reg [$clog2(DEPTH)-1:0] rd_ptr;
reg [$clog2(DEPTH)-1:0] wr_ptr;
reg [WIDTH-1:0] data [DEPTH-1:0];

always @(posedge clk) begin
  if (~reset_n) begin
    rd_ptr <= 0;
    wr_ptr <= 0;
    full <= 0;
    empty <= 1;
  end
  else begin
    if (push & ~full) begin
      data[wr_ptr] <= data_in;
      wr_ptr = wr_ptr + 1;
      if (wr_ptr == rd_ptr) begin
        full <= 1'b1;
      end
      else begin
        empty <= 1'b0;
      end
    end
    if (pop & ~empty) begin
      data_out <= data[rd_ptr];
      rd_ptr = rd_ptr + 1;
      if (wr_ptr == rd_ptr) begin
        empty <= 1'b1;
      end
      else begin
        full <= 1'b0;
      end
    end
  end
end

endmodule
