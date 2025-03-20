`timescale 1ns / 1ps

module tb_regsiter;
  reg clk;
  reg [31:0] d;
  wire [31:0] q;
  
  register dut(
    .clk(clk),
    .d(d),
    .q(q)
  );
  
  always #5 clk = ~clk;
  
  initial begin
    clk = 0;
    d = 32'h0000_000;
    
    #10
    d = 32'h0123_abcd;
    
    @(posedge clk)
    if (d == q) begin
      $display("pass");
    end else begin
      $display("fail");
    end
    
    @(posedge clk)
    $stop;
  end
endmodule