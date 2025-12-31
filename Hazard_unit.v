// The hazard detection unit receives the two source registers
// from the instruction in the Execute stage (RS1_E and RS2_E) and the destination registers
// from the instructions in the Memory and Writeback stages (RD_M, RD_W). It also
// receives the RegWrite signals from the Memory and Writeback stages to
// know whether the destination register will actually be written



module hazard_unit(
    input  rst,
    input  RegWriteM,
    input  RegWriteW,
    input  [4:0] RD_M,
    input  [4:0] RD_W,
    input  [4:0] Rs1_E,
    input  [4:0] Rs2_E,
    input PCSrcE,

    input  [4:0] RD_E,    //for stalling purpose
    input  [4:0] RS1_D,
    input  [4:0] RS2_D,
    input MemtoRegE,

    output [1:0] ForwardAE,
    output [1:0] ForwardBE,

    output StallF,    //for stalling the Program counter
    output StallD,    //for stalling the Fetch-Decode pipeline register
    output FlushD1     //Flush the Decode-Execute pipeline register

//NOTE: The Decode-Execute pipeline registers are flushed due to 2 main reasons:
// 1. Load-use hazard (inserting a bubble)  ----> FlushD1
// 2. Branch/jump taken (clearing the mispredicted instruction)  -----> FlushD2
);

    wire lw_stall;


    // The lw_stall is true when we need to wait for memory data
    assign lw_stall = MemtoRegE && (RD_E != 5'd0) && ((RD_E == RS1_D) || (RD_E == RS2_D));

    // STALLS: Freeze PC and IF/ID if we have a load-use hazard
    // UNLESS we are flushing due to a branch (Branch takes priority)
    assign StallF  = lw_stall && !PCSrcE;
    assign StallD  = lw_stall && !PCSrcE;

    // FLUSHES:
    // We flush the Execute stage (ID/EX register) if:
    // 1. We have a load-use hazard (insert a bubble)
    // 2. OR we have a branch/jump taken (clear the mispredicted instruction)
    assign FlushD1 = lw_stall || PCSrcE;


    // Forward A (rs1)
    assign ForwardAE =
        (RegWriteM && (RD_M != 5'd0) && (RD_M == Rs1_E)) ? 2'b10 :
        (RegWriteW && (RD_W != 5'd0) && (RD_W == Rs1_E)) ? 2'b01 :
        2'b00;

    // Forward B (rs2)
    assign ForwardBE =
        (RegWriteM && (RD_M != 5'd0) && (RD_M == Rs2_E)) ? 2'b10 :
        (RegWriteW && (RD_W != 5'd0) && (RD_W == Rs2_E)) ? 2'b01 :
        2'b00;

// always@(negedge clk) begin
//         $display("HAZARD UNIT: lw_stall=%b, StallF=%b, StallD=%b, FlushD1=%b, time=%0t",
//             lw_stall,StallF,StallD,FlushD1, $time);
//     end


endmodule
