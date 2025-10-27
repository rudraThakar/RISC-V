module Instruction_Memory(rst, A, RD);
  input rst;
  input [31:0] A;
  output [31:0] RD;

  // 4 KB of instruction memory (1024 words × 4 bytes)
  reg [31:0] inst_mem [1023:0];

  integer i;  // Declare here, outside procedural blocks ✅

  // A is the Program Counter
  // A = 0x0000 -> inst_mem[0]
  // A = 0x0004 -> inst_mem[1]
  // A = 0x0008 -> inst_mem[2]
  assign RD = (rst == 1'b1) ? {32{1'b1}} : inst_mem[A >> 2];

  // Initialize memory contents directly
  initial begin
    inst_mem[0] = 32'h20080005;  // addi $t0, $zero, 5
    inst_mem[1] = 32'h20090003;  // addi $t1, $zero, 3
    inst_mem[2] = 32'h01095020;  // add  $t2, $t0, $t1
    inst_mem[3] = 32'hAC0A0000;  // sw   $t2, 0($zero)
    inst_mem[4] = 32'h8C0B0000;  // lw   $t3, 0($zero)
    inst_mem[5] = 32'h012A5822;  // sub  $t3, $t1, $t2
    for (i = 6; i < 1024; i = i + 1)
      inst_mem[i] = 32'h00000000; // nop
  end

endmodule

