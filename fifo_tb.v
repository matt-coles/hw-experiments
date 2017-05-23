`timescale 100ps/1ps
module fifo_tb;

reg reset_n;
reg [15:0] data_in;
wire [15:0] data_out;
wire full, empty;
reg fifo_push, fifo_pop, clk;

simple_fifo dut (
  .clk(clk),
  .reset_n(reset_n),
  .push(fifo_push),
  .pop(fifo_pop),

  .data_in(data_in),
  .data_out(data_out),

  .full(full),
  .empty(empty)
);

initial begin
  clk = 1'b0;
  reset_n = 1'b0;
  repeat(4) #10 clk = ~clk;
  reset_n = 1'b1;
  forever #10 clk = ~clk; // generate a clock
end

reg [15:0] tmp;
initial begin
  data_in = 16'h0; // initial value
  fifo_push = 1'b0;
  fifo_pop = 1'b0;
  @(posedge reset_n); // wait for reset
  data_in = 16'hffff;
  repeat (8) begin
    @(posedge clk);
    fifo_push = 1'b1;
    @(negedge clk);
    fifo_push = 1'b0;
    data_in = ~data_in;
  end
  if (full != 1 && empty != 0) begin
    $display("Test failed!");
  end
  tmp = 16'hffff;
  repeat (8) begin
    @(posedge clk);
    fifo_pop = 1'b1;
    @(negedge clk);
    fifo_pop = 1'b0;
    if (data_out !== tmp) begin
      $display("Test failed!");
    end
    tmp = ~tmp;
  end
  if (full != 0 && empty != 1) begin
    $display("Test failed!");
  end
  repeat(5) @(posedge clk); //if this delay is odd it fails wtf?
  data_in = 16'h1234;
  repeat (8) begin
    @(posedge clk);
    fifo_push = 1'b1;
    @(negedge clk);
    fifo_push = 1'b0;
    data_in = ~data_in;
  end
  if (full != 1 && empty != 0) begin
    $display("Test failed!");
  end
  tmp = 16'h1234;
  repeat (8) begin
    @(posedge clk);
    fifo_pop = 1'b1;
    @(negedge clk);
    fifo_pop = 1'b0;
    if (data_out !== tmp) begin
      $display("Test failed!");
    end
    tmp = ~tmp;
  end
  if (full != 0 && empty != 1) begin
    $display("Test failed!");
  end
  $finish;
end

initial begin
  if ($test$plusargs("waves=1") != 0) begin
    $dumpfile("out/waves.vcd");
    $dumpvars(0, fifo_tb);
    if ($test$plusargs("dump_fifo=1") != 0) begin
      $dumpvars(0, dut.data[0]);
      $dumpvars(0, dut.data[1]);
      $dumpvars(0, dut.data[2]);
      $dumpvars(0, dut.data[3]);
      $dumpvars(0, dut.data[4]);
      $dumpvars(0, dut.data[5]);
      $dumpvars(0, dut.data[6]);
      $dumpvars(0, dut.data[7]);
    end
  end
end
endmodule
