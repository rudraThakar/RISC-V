`timescale 1ns/1ps

module pipeline_tb;

  // Clock & Reset
  reg clk;
  reg rst;

  // Instantiate DUT
  Pipeline_Top dut (
    .clk(clk),
    .rst(rst)
  );

  // Clock generation (100 MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset sequence
  initial begin
    rst = 1;
    #20;
    rst = 0;
  end

  // Simulation control
  initial begin
    $display("=== Starting RISC-V CPU Testbench ===");

    // wait for reset deassertion
    @(negedge rst);

    // let pipeline run
    repeat (20) @(posedge clk);

    // R-type instruction checks
    
    //check_reg(1, 32'd20);   
    check_reg(2, 32'd120);    
    //check_reg(4, 32'd50);       
    //check_reg(5, 32'd8);        
    //check_reg(6, 32'd24);       


    $display("=== JAL/JALR tests PASSED ===");
    $finish;
  end

  // Task: check register value

    task check_reg(input integer regnum, input [31:0] expected);
    begin
        if (dut.Decode.rf.Register[regnum] !== expected) begin
        // $display("ERROR: x%0d = %h, expected %h",
        //         regnum,
        //         dut.Decode.rf.Register[regnum],
        //         expected);
        $display("t=%0t: ForwardAE=%b ForwardBE=%b ALU_ResultM=%h ALU_ResultW=%h ResultW=%h",
            $time, dut.ForwardAE, dut.ForwardBE, dut.ALU_ResultM, dut.ALU_ResultW, dut.ResultW);
        $display("      regs: x1=%0h x2=%0h x3=%0h x4=%0h, x5=%0h, x6=%0h",
           dut.Decode.rf.Register[1], dut.Decode.rf.Register[2],
           dut.Decode.rf.Register[3], dut.Decode.rf.Register[4], dut.Decode.rf.Register[5], dut.Decode.rf.Register[6]);
        $fatal;
        end else begin
        $display("OK: x%0d = %h",
                regnum,
                expected);
        end
    end
    endtask


endmodule


