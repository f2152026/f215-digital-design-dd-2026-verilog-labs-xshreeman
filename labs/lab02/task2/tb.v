// tb.v
// Starter testbench template -- YOU complete this file.

module tb;

  // TODO: declare the inputs and outputs
  localparam WIDTH = 8;
  localparam DEPTH = 8;

  reg  [$clog2(DEPTH)-1:0] t_sel;    // driven procedurally -> reg
  wire [WIDTH-1:0]         t_dout;
  // TODO: instantiate DUT here
  lut #(
    .WIDTH (WIDTH),
    .DEPTH (DEPTH)
  ) DUT (
    .sel  (t_sel),
    .dout (t_dout)
  );
  // Waveform dump configuration (DO NOT CHANGE)
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  integer k;
  initial begin
    // TODO: apply different input combinations
    t_sel = 0;
    for (k = 0; k < DEPTH; k = k + 1) begin
      t_sel = k[$clog2(DEPTH)-1:0];
      #5;
    end
    $finish;
  end

  initial
    $monitor($time, " sel=%0d | dout=%0d (0x%02h)", t_sel, t_dout, t_dout);
endmodule