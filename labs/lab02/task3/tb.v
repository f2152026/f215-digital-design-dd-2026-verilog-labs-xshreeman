module tb;

  reg  [1:0] t_a, t_b;
  wire       t_gt, t_lt, t_eq;

  integer errors;
  integer i, j;

  // Expected values, computed independently of the DUT
  reg exp_gt, exp_lt, exp_eq;

  comp2 DUT (
    .A  (t_a),
    .B  (t_b),
    .GT (t_gt),
    .LT (t_lt),
    .EQ (t_eq)
  );

  // Waveform dump configuration (DO NOT CHANGE)
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  // One check: compare DUT outputs against the reference model
  task check;
    begin
      exp_gt = (t_a >  t_b);
      exp_lt = (t_a <  t_b);
      exp_eq = (t_a == t_b);

      if ({t_gt, t_lt, t_eq} !== {exp_gt, exp_lt, exp_eq}) begin
        errors = errors + 1;
        $display("%0t ERROR A=%b B=%b | got GT=%b LT=%b EQ=%b, expected GT=%b LT=%b EQ=%b",
                 $time, t_a, t_b, t_gt, t_lt, t_eq, exp_gt, exp_lt, exp_eq);
      end

      // Invariant: exactly one output must be high
      if ((t_gt + t_lt + t_eq) !== 1) begin
        errors = errors + 1;
        $display("%0t ERROR A=%b B=%b | one-hot violated: GT=%b LT=%b EQ=%b",
                 $time, t_a, t_b, t_gt, t_lt, t_eq);
      end
    end
  endtask

  initial begin
    errors = 0;

    // Exhaustive: all 16 combinations of A and B
    for (i = 0; i < 4; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        t_a = i[1:0];
        t_b = j[1:0];
        #5 check;
      end
    end

    #5;
    if (errors == 0)
      $display("TEST PASSED: all 16 combinations correct");
    else
      $display("TEST FAILED: %0d error(s)", errors);
    $finish;
  end

  initial
    $monitor($time, " A=%b B=%b | GT=%b LT=%b EQ=%b", t_a, t_b, t_gt, t_lt, t_eq);

endmodule