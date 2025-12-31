
module writeback_cycle(
// Declaration of IOs
input clk, rst, RegWriteW, MemtoRegW, JumpW,
input [4:0] WriteReg_W,
input [31:0] PCPlus4W, ALU_ResultW, ReadDataW,

output [31:0] ResultW
);

// Declaration of Module
// Mux result_mux (    
//                 .a(ALU_ResultW),
//                 .b(ReadDataW),
//                 .sel(MemtoRegW),
//                 .c(ResultW)
//                 );


assign ResultW =
    JumpW     ? PCPlus4W :
    MemtoRegW ? ReadDataW :
                ALU_ResultW;

endmodule