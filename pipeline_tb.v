module pipeline_tb;

    reg clk = 0;
    reg rst;

    // Clock generation: 100 time-unit period (50 high + 50 low)
    always #50 clk = ~clk;

    // Reset logic
    initial begin
        rst = 1'b0;      // start with reset low (inactive)
        #200;
        rst = 1'b1;      // assert reset after 200 time units
        #1000;
        $finish;         // end simulation
    end

    // Dump waveform
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, pipeline_tb);
    end

    // Instantiate DUT (Device Under Test)
    Pipeline_Top dut (
        .clk(clk),
        .rst(rst)
    );

endmodule

