
`include "Fetch_Cycle.v"
`include "Decode_Cycle.v"
`include "Execute_Cycle.v"
`include "Memory_Cycle.v"
`include "Writeback_Cycle.v"    
`include "PC.v"
`include "PC_Adder.v"
`include "Mux.v"
`include "Instruction_Memory.v"
`include "Control_Unit.v"
`include "Register_File.v"
`include "Immediate_Generator.v"
`include "ALU.v"
`include "Data_Memory.v"
`include "Hazard_unit.v"
`include "Mux_3_by_1.v"


module Pipeline_Top(clk, rst);

    // Declaration of I/O
    input clk, rst;

    // Declaration of Interim Wires
    wire PCSrcE, RegWriteW, RegWriteE, MemtoRegE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, JumpE, JumpRegE, RegWriteM, MemtoRegM, MemWriteM, ResultSrcM, MemtoRegW;
    wire JumpM, JumpW;
    wire StallF, StallD, FlushD1, FlushD2, FlushF;
    wire [2:0] funct3;
    wire [3:0] ALUControlE;
    wire [4:0] WriteReg_M, WriteRegW;
    wire [31:0] PCTargetE, InstrD, InstrE, InstrM, PCD, PCPlus4D, ResultW, RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E, PCPlus4M, WriteDataM, ALU_ResultM;
    wire [31:0] PCPlus4W, ALU_ResultW, ALU_Memvalue, ReadDataW;
    wire [4:0] RS1_E, RS2_E, RD_E, RS1_D, RS2_D;
    wire [1:0] ForwardBE, ForwardAE;
    

    // Module Initiation
    // Fetch Stage
    Fetch_Cycle Fetch (
                        .clk(clk), 
                        .rst(rst), 
                        // .PCSrcD(PCSrcD), 
                        // .PCTargetD(PCTargetD),
                        .PCSrcE(PCSrcE),
                        .PCTargetE(PCTargetE), 
                        .StallF(StallF),
                        .StallD(StallD),
                        .FlushF(FlushF),
                        
                        .InstrD(InstrD), 
                        .PCD(PCD), 
                        .PCPlus4D(PCPlus4D)
                    );

    // Decode Stage
    decode_cycle Decode (
                        .clk(clk), 
                        .rst(rst), 
                        .RegWriteW(RegWriteW), 
                        .FlushD1(FlushD1),
                        .FlushD2(FlushD2),
                        .WriteRegW(WriteRegW), 
                        .InstrD(InstrD), 
                        .PCD(PCD), 
                        .PCPlus4D(PCPlus4D), 
                        .ResultW(ResultW),

                        .RegWriteE(RegWriteE), 
                        .MemtoRegE(MemtoRegE),
                        .MemWriteE(MemWriteE),
                        .ALUSrcE(ALUSrcE),  
                        //.ResultSrcE(ResultSrcE),
                        .BranchE(BranchE), 
                        .JumpE(JumpE),
                        .JumpRegE(JumpRegE), 
                        .funct3(funct3),
                        .ALUControlE(ALUControlE), 
                        .RD1_E(RD1_E), 
                        .RD2_E(RD2_E), 
                        .Imm_Ext_E(Imm_Ext_E), 
                        //.WriteReg_E(WriteReg_E), 
                        .InstrE(InstrE),
                        .PCE(PCE), 
                        .PCPlus4E(PCPlus4E),
                        .RS1_E(RS1_E),
                        .RS2_E(RS2_E),
                        .RD_E(RD_E),
                        .RS1_D(RS1_D),
                        .RS2_D(RS2_D)
                        // .PCTargetD(PCTargetD),
                        // .PCSrcD(PCSrcD)
                    );

    // Execute Stage
    execute_cycle Execute (
                        .clk(clk), 
                        .rst(rst), 
                        .InstrE(InstrE),
                        .RegWriteE(RegWriteE), 
                        .MemtoRegE(MemtoRegE),
                        .MemWriteE(MemWriteE),
                        .ALUSrcE(ALUSrcE),  
                        //.ResultSrcE(ResultSrcE),
                        .BranchE(BranchE), 
                        .JumpE(JumpE),
                        .JumpRegE(JumpRegE), 
                        .funct3E(funct3),   //funct3 from decode stage is pipelined to execute stage for branch operations
                        .ALUControlE(ALUControlE), 
                        .RD1_E(RD1_E), 
                        .RD2_E(RD2_E), 
                        .Imm_Ext_E(Imm_Ext_E), 
                        .RS1_E(RS1_E),
                        .RS2_E(RS2_E),
                        .RD_E(RD_E),
                        .PCE(PCE), 
                        .PCPlus4E(PCPlus4E), 
                        .ResultW(ResultW),
                        .ForwardA_E(ForwardAE),
                        .ForwardB_E(ForwardBE),
                        
                        .PCSrcE(PCSrcE), 
                        .PCTargetE(PCTargetE), 
                        .RegWriteM(RegWriteM), 
                        .MemtoRegM(MemtoRegM),
                        .MemWriteM(MemWriteM), 
                        .FlushF(FlushF),    
                        .FlushD2(FlushD2),
                        .JumpM(JumpM),
                        //.ResultSrcM(ResultSrcM), 
                        .WriteReg_M(WriteReg_M), 
                        .PCPlus4M(PCPlus4M), 
                        .WriteDataM(WriteDataM), 
                        .ALU_Memvalue(ALU_ResultM),
                        .ALU_ResultM(ALU_ResultM),
                        .InstrM(InstrM)
                    );
    
    // Memory Stage
    memory_cycle Memory (
                        .clk(clk), 
                        .rst(rst), 
                        .RegWriteM(RegWriteM), 
                        .MemtoRegM(MemtoRegM),
                        .MemWriteM(MemWriteM), 
                        .WriteReg_M(WriteReg_M), 
                        .PCPlus4M(PCPlus4M), 
                        .InstrM(InstrM),
                        .WriteDataM(WriteDataM), 
                        .ALU_ResultM(ALU_ResultM), 
                        .JumpM(JumpM),
                        //.ResultSrcM(ResultSrcM),
                        .RegWriteW(RegWriteW), 
                        .MemtoRegW(MemtoRegW),
                        .WriteReg_W(WriteRegW), 
                        .PCPlus4W(PCPlus4W),
                        .JumpW(JumpW), 
                        .ALU_ResultW(ALU_ResultW), 
                        .ReadDataW(ReadDataW)
                        
                    );

    // Write Back Stage
    writeback_cycle WriteBack (
                        .clk(clk), 
                        .rst(rst), 
                        .RegWriteW(RegWriteW), 
                        .MemtoRegW(MemtoRegW),
                        .WriteReg_W(WriteRegW),
                        .JumpW(JumpW),
                        .PCPlus4W(PCPlus4W), 
                        .ALU_ResultW(ALU_ResultW), 
                        .ReadDataW(ReadDataW), 
                        .ResultW(ResultW)
                    );

    hazard_unit Forwarding_block (
                        .rst(rst), 
                        .RegWriteM(RegWriteM), 
                        .RegWriteW(RegWriteW), 
                        .RD_M(WriteReg_M), 
                        .RD_W(WriteRegW), 
                        .Rs1_E(RS1_E), 
                        .Rs2_E(RS2_E), 
                        .RD_E(RD_E),
                        .RS1_D(RS1_D),  
                        .RS2_D(RS2_D),
                        .MemtoRegE(MemtoRegE),
                        .PCSrcE(PCSrcE),

                        .ForwardAE(ForwardAE), 
                        .ForwardBE(ForwardBE),
                        .StallF(StallF),
                        .StallD(StallD),    
                        .FlushD1(FlushD1)
                        );

// always @(negedge clk) begin
//         $display("STALL AND FLUSH: FlushF=%b, FlushD1 (Hazard Unit) =%b, FlushD2 (Execute Cycle) =%b, PCSrcE = %b, time= %0t", FlushF, FlushD1, FlushD2, PCSrcE, $time);
//     end

endmodule
    
