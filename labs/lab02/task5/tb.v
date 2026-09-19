module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  reg  [3:0] expected;
  integer    errors;
  integer    i, j, k;

  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  task check;
    begin
      expected = t_op ? (t_a - t_b) : (t_a + t_b);   // 4-bit truncation
      if (t_result !== expected) begin
        errors = errors + 1;
        $display("%0t ERROR op=%b a=%0d b=%0d | got %0d, expected %0d",
                 $time, t_op, t_a, t_b, t_result, expected);
      end
    end
  endtask

  initial begin
    errors = 0;

    // --- Directed: change ONLY op, holding a and b constant ---
    // Exposes a sensitivity-list that ignores op.
    t_a = 9; t_b = 3; t_op = 0;
    #5 check;                 // expect 12
    t_op = 1;
    #5 check;                 // expect  6  <-- only op moved
    t_op = 0;
    #5 check;                 // expect 12

    // --- Directed: repeat the same op with a new b ---
    // Exposes a subtract path that carries stale intermediates.
    t_op = 1;
    t_a = 8; t_b = 1; #5 check;   // expect 7
    t_a = 8; t_b = 2; #5 check;   // expect 6
    t_a = 8; t_b = 4; #5 check;   // expect 4

    // --- Exhaustive: all 512 combinations ---
    for (k = 0; k < 2; k = k + 1)
      for (i = 0; i < 16; i = i + 1)
        for (j = 0; j < 16; j = j + 1) begin
          t_op = k[0];
          t_a  = i[3:0];
          t_b  = j[3:0];
          #5 check;
        end

    if (errors == 0)
      $display("TEST PASSED: all vectors correct");
    else
      $display("TEST FAILED: %0d error(s)", errors);
    $finish;
  end

endmodule