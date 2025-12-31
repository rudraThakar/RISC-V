module execute_cycle(
    // Declaration I/Os
    input clk, rst, RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, BranchE, JumpE, JumpRegE,
    input [2:0] funct3E,
    input [3:0] ALUControlE,
    input [31:0] RD1_E, RD2_E, Imm_Ext_E,
    input [4:0] RD_E, RS1_E, RS2_E,
    input [31:0] InstrE, PCE, PCPlus4E,
    input [31:0] ResultW, ALU_Memvalue,
    input [1:0] ForwardA_E, ForwardB_E,

    output PCSrcE, RegWriteM, MemtoRegM, MemWriteM, JumpM,
    output FlushF, FlushD2,
    output [4:0] WriteReg_M,
    output [31:0] InstrM, PCPlus4M, WriteDataM, ALU_ResultM,
    output [31:0] PCTargetE
);
    // Declaration of Interim Wires
    wire [31:0] Src_A, Src_B_interim, Src_B;
    wire [31:0] ResultE;
    wire ZeroE;

    reg BranchTakenE;
    wire JumpTakenE;
    

    // Declaration of Pipeline Registers
    reg RegWriteE_r, MemtoRegE_r, MemWriteE_r, PCSrcE_r, JumpE_r;
    reg [4:0] WriteReg_E_r;
    reg [31:0] InstrE_r, PCPlus4E_r, RD2_E_r, ResultE_r;

    // Declaration of Modules
    // 3 by 1 Mux for Source A

    //This mux is to achieve forwarding for Source A. We forward the data from MEM or WB stage if needed.
    //Thus, the inputs to this mux are RD1_E (original source A), ResultW (data from WB stage) and ALU_ResultM (data from MEM stage).
    Mux_3_by_1 srca_mux (
                        .a(RD1_E),
                        .b(ResultW),
                        .c(ALU_Memvalue),
                        .s(ForwardA_E),
                        .d(Src_A)
                        );

    // 3 by 1 Mux for Source B
    //This mux is to achieve forwarding for Source B.
    Mux_3_by_1 srcb_mux (
                        .a(RD2_E),
                        .b(ResultW),
                        .c(ALU_Memvalue),
                        .s(ForwardB_E),
                        .d(Src_B_interim)
                        );

    // ALU Src Mux
    //Do we take the 2nd ALU operand from the register file (Src_B_interim) [eighter from the reigster file or the forwarded value]
    //or from the immediate extender (Imm_Ext_E)?    

    // Mux alu_src_mux (
    //         .a(Src_B_interim),
    //         .b(Imm_Ext_E),
    //         .sel(ALUSrcE),
    //         .c(Src_B)
    //         );

//We replace the above mux with the following conditional assignment to accomodate branch instructions
    
    assign Src_B = (BranchE) ? Src_B_interim :
                (ALUSrcE) ? Imm_Ext_E :
                            Src_B_interim;

//Compute Jalr Target

wire [31:0] JalrTargetE;
assign JalrTargetE = (Src_A + Imm_Ext_E) & 32'hFFFFFFFE;


assign PCTargetE =
    JumpRegE ? (JalrTargetE) :
               (PCE + Imm_Ext_E);



    // ALU Unit
    ALU alu (
            .A(Src_A),
            .B(Src_B),
            .ALUControl(ALUControlE),
            .Result(ResultE),
            .Zero(ZeroE)
            );

    // // Adder : PCTragetE = PCE + (Imm_Ext_E << 1)
    // PC_Adder branch_adder (
    //         .a(PCE),
    //         .b(Imm_Ext_E << 1),
    //         .c(PCTargetE)
    //         );


// Branch Decision Logic (Combinational)
    always @(*) begin
        BranchTakenE = 1'b0; // Default
        if (BranchE) begin
            case (funct3E)
                3'b000: BranchTakenE = ZeroE;        // beq
                3'b001: BranchTakenE = ~ZeroE;       // bne
                3'b100: BranchTakenE = ResultE[0];   // blt  (Assuming ALU result[0] is Set-Less-Than)
                3'b101: BranchTakenE = ~ResultE[0];  // bge
                3'b110: BranchTakenE = ResultE[0];   // bltu
                3'b111: BranchTakenE = ~ResultE[0];  // bgeu
                default: BranchTakenE = 1'b0;
            endcase
        end
    end

    // Register Logic
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            RegWriteE_r <= 1'b0; 
            MemWriteE_r <= 1'b0; 
            MemtoRegE_r <= 1'b0;
            PCSrcE_r <= 1'b0;
            JumpE_r <= 1'b0;    
            WriteReg_E_r <= 5'h00;
            PCPlus4E_r <= 32'h00000000; 
            RD2_E_r <= 32'h00000000; 
            ResultE_r <= 32'h00000000;
            InstrE_r <= 32'h00000000;
        end
        else begin
            RegWriteE_r <= RegWriteE; 
            MemWriteE_r <= MemWriteE; 
            MemtoRegE_r <= MemtoRegE;
            PCSrcE_r <= (BranchE & BranchTakenE) | JumpTakenE;
            JumpE_r <= JumpE;
            WriteReg_E_r <= RD_E;
            PCPlus4E_r <= PCPlus4E; 
            RD2_E_r <= Src_B_interim; 
            ResultE_r <= ResultE;
            InstrE_r <= InstrE;
        end
    end



    // Output Assignments
    assign JumpTakenE = JumpE | JumpRegE;
     
    assign PCSrcE = (BranchE & BranchTakenE) | JumpTakenE;

    assign FlushF = PCSrcE;
    assign FlushD2 = PCSrcE;
    assign RegWriteM = RegWriteE_r;
    assign MemWriteM = MemWriteE_r;
    assign MemtoRegM = MemtoRegE_r;
    assign WriteReg_M = WriteReg_E_r;
    assign JumpM = JumpE_r;
    assign PCPlus4M = PCPlus4E_r;
    assign WriteDataM = RD2_E_r;
    assign ALU_ResultM = ResultE_r;
    assign InstrM = InstrE_r;

// always@(negedge clk) begin
//         $display("EX STAGE: InstrE = %h, ForwardA_E = %b, ForwardB_E = %b, PCSrcE=%b, PCE = %d, FlushF=%b, FlushD2=%b, time= %0t", InstrE, ForwardA_E, ForwardB_E, PCSrcE, PCE, FlushF, FlushD2, $time);
//     end


endmodule




































// module execute_cycle(
//     // Declaration I/Os
//     input clk, rst, RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, BranchE, JumpE, JumpRegE,
//     input [2:0] funct3E,
//     input [3:0] ALUControlE,
//     input [31:0] RD1_E, RD2_E, Imm_Ext_E,
//     input [4:0] RD_E, RS1_E, RS2_E,
//     input [31:0] PCE, PCPlus4E,
//     input [31:0] ResultW, ALU_Memvalue,
//     input [1:0] ForwardA_E, ForwardB_E,

//     output PCSrcE, RegWriteM, MemtoRegM, MemWriteM, JumpM,
//     output FlushF, FlushD2,
//     output [4:0] WriteReg_M,
//     output [31:0] PCPlus4M, WriteDataM, ALU_ResultM,
//     output [31:0] PCTargetE
// );
//     // Declaration of Interim Wires
//     wire [31:0] Src_A, Src_B_interim, Src_B;
//     wire [31:0] ResultE;
//     wire ZeroE;

//     reg BranchTakenE;
//     wire JumpTakenE;
//     wire PCSrcE_comb;  // Combinational PC source signal
    

//     // Declaration of Pipeline Registers
//     reg RegWriteE_r, MemtoRegE_r, MemWriteE_r, JumpE_r;
//     reg [4:0] WriteReg_E_r;
//     reg [31:0] PCPlus4E_r, RD2_E_r, ResultE_r;

//     // Declaration of Modules
//     // 3 by 1 Mux for Source A
//     // This mux is to achieve forwarding for Source A. We forward the data from MEM or WB stage if needed.
//     // Thus, the inputs to this mux are RD1_E (original source A), ResultW (data from WB stage) and ALU_Memvalue (data from MEM stage).
//     Mux_3_by_1 srca_mux (
//                         .a(RD1_E),
//                         .b(ResultW),
//                         .c(ALU_Memvalue),
//                         .s(ForwardA_E),
//                         .d(Src_A)
//                         );

//     // 3 by 1 Mux for Source B
//     // This mux is to achieve forwarding for Source B.
//     Mux_3_by_1 srcb_mux (
//                         .a(RD2_E),
//                         .b(ResultW),
//                         .c(ALU_Memvalue),
//                         .s(ForwardB_E),
//                         .d(Src_B_interim)
//                         );

//     // ALU Src Mux
//     // Do we take the 2nd ALU operand from the register file (Src_B_interim) [either from the register file or the forwarded value]
//     // or from the immediate extender (Imm_Ext_E)?    
//     assign Src_B = (BranchE) ? Src_B_interim :
//                    (ALUSrcE) ? Imm_Ext_E :
//                                Src_B_interim;

//     // Compute PC Target
//     // For JALR: (Src_A + Imm_Ext_E) & ~1
//     // For JAL and branches: PCE + Imm_Ext_E
//     assign PCTargetE = JumpRegE ? ((Src_A + Imm_Ext_E) & 32'hFFFFFFFE) :
//                                   (PCE + Imm_Ext_E);

//     // ALU Unit
//     ALU alu (
//             .A(Src_A),
//             .B(Src_B),
//             .ALUControl(ALUControlE),
//             .Result(ResultE),
//             .Zero(ZeroE)
//             );

//     // Branch Decision Logic (Combinational)
//     always @(*) begin
//         BranchTakenE = 1'b0;

//         if (BranchE) begin
//             case (funct3E)
//                 3'b000: BranchTakenE <= ZeroE;        // beq
//                 3'b001: BranchTakenE <= ~ZeroE;       // bne
//                 3'b100: BranchTakenE <= ResultE[0];   // blt  (SLT)
//                 3'b101: BranchTakenE <= ~ResultE[0];  // bge
//                 3'b110: BranchTakenE <= ResultE[0];   // bltu (SLTU)
//                 3'b111: BranchTakenE <= ~ResultE[0];  // bgeu
//                 default: BranchTakenE <= 1'b0;
//             endcase
//         end
//     end

//     // Jump Taken Logic
//     assign JumpTakenE = JumpE | JumpRegE;

//     // Combinational PCSrc (for immediate flushing)
//     // This signal is available BEFORE the clock edge to all stages
//     assign PCSrcE_comb = (BranchE & BranchTakenE) | JumpTakenE;

//     // Pipeline Register Logic
//     // NOTE: We don't register PCSrcE anymore - it's purely combinational
//     always @(posedge clk or posedge rst) begin
//         if(rst == 1'b1) begin
//             RegWriteE_r <= 1'b0; 
//             MemWriteE_r <= 1'b0; 
//             MemtoRegE_r <= 1'b0;
//             JumpE_r <= 1'b0;    
//             WriteReg_E_r <= 5'h00;
//             PCPlus4E_r <= 32'h00000000; 
//             RD2_E_r <= 32'h00000000; 
//             ResultE_r <= 32'h00000000;
//         end
//         else begin
//             RegWriteE_r <= RegWriteE; 
//             MemWriteE_r <= MemWriteE; 
//             MemtoRegE_r <= MemtoRegE;
//             JumpE_r <= JumpE;
//             WriteReg_E_r <= RD_E;
//             PCPlus4E_r <= PCPlus4E; 
//             RD2_E_r <= Src_B_interim; 
//             ResultE_r <= ResultE;
//         end
//     end

//     // Output Assignments
//     // ALL flush signals are purely combinational - available BEFORE the clock edge
//     assign PCSrcE = PCSrcE_comb;      
//     assign FlushF = PCSrcE_comb;      // Flush Fetch stage immediately
//     assign FlushD2 = PCSrcE_comb;      // Flush Decode stage immediately
    
//     assign RegWriteM = RegWriteE_r;
//     assign MemWriteM = MemWriteE_r;
//     assign MemtoRegM = MemtoRegE_r;
//     assign WriteReg_M = WriteReg_E_r;
//     assign JumpM = JumpE_r;
//     assign PCPlus4M = PCPlus4E_r;
//     assign WriteDataM = RD2_E_r;
//     assign ALU_ResultM = ResultE_r;

//     // Debug Display
//     // always @(*) begin
//     //     $display("~~EX CYCLE: BranchE=%b, BranchTakenE=%b, JumpTakenE=%b, PCSrcE=%b, FlushD2=%b, time=%0t", 
//     //              BranchE, BranchTakenE, JumpTakenE, PCSrcE, FlushD2, $time);
//     // end

// endmodule




// module execute_cycle(
//     // Declaration I/Os
//     input clk, rst, RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, BranchE, JumpE, JumpRegE,
//     input [2:0] funct3E,
//     input [3:0] ALUControlE,
//     input [31:0] RD1_E, RD2_E, Imm_Ext_E,
//     input [4:0] RD_E, RS1_E, RS2_E,
//     input [31:0] PCE, PCPlus4E,
//     input [31:0] ResultW, ALU_Memvalue,
//     input [1:0] ForwardA_E, ForwardB_E,

//     output PCSrcE, RegWriteM, MemtoRegM, MemWriteM, JumpM,
//     output FlushF, FlushD2,
//     output [4:0] WriteReg_M,
//     output [31:0] PCPlus4M, WriteDataM, ALU_ResultM,
//     output [31:0] PCTargetE
// );
//     // Declaration of Interim Wires
//     wire [31:0] Src_A, Src_B_interim, Src_B;
//     wire [31:0] ResultE;
//     wire ZeroE;

//     reg BranchTakenE;
//     wire JumpTakenE;
//     wire PCSrcE_comb;
    

//     // Declaration of Pipeline Registers
//     reg RegWriteE_r, MemtoRegE_r, MemWriteE_r, PCSrcE_r, JumpE_r;
//     reg [4:0] WriteReg_E_r;
//     reg [31:0] PCPlus4E_r, RD2_E_r, ResultE_r;

//     // Declaration of Modules
//     // 3 by 1 Mux for Source A
//     Mux_3_by_1 srca_mux (
//                         .a(RD1_E),
//                         .b(ResultW),
//                         .c(ALU_Memvalue),
//                         .s(ForwardA_E),
//                         .d(Src_A)
//                         );

//     // 3 by 1 Mux for Source B
//     Mux_3_by_1 srcb_mux (
//                         .a(RD2_E),
//                         .b(ResultW),
//                         .c(ALU_Memvalue),
//                         .s(ForwardB_E),
//                         .d(Src_B_interim)
//                         );

//     // ALU Src Mux
//     assign Src_B = (BranchE) ? Src_B_interim :
//                    (ALUSrcE) ? Imm_Ext_E :
//                                Src_B_interim;

//     // Compute PC Target
//     assign PCTargetE = JumpRegE ? ((Src_A + Imm_Ext_E) & 32'hFFFFFFFE) :
//                                   (PCE + Imm_Ext_E);

//     // ALU Unit
//     ALU alu (
//             .A(Src_A),
//             .B(Src_B),
//             .ALUControl(ALUControlE),
//             .Result(ResultE),
//             .Zero(ZeroE)
//             );

//     // Branch Decision Logic (Combinational)
//     always @(*) begin
//         BranchTakenE = 1'b0;

//         if (BranchE) begin
//             case (funct3E)
//                 3'b000: BranchTakenE = ZeroE;        // beq
//                 3'b001: BranchTakenE = ~ZeroE;       // bne
//                 3'b100: BranchTakenE = ResultE[0];   // blt  (SLT)
//                 3'b101: BranchTakenE = ~ResultE[0];  // bge
//                 3'b110: BranchTakenE = ResultE[0];   // bltu (SLTU)
//                 3'b111: BranchTakenE = ~ResultE[0];  // bgeu
//                 default: BranchTakenE = 1'b0;
//             endcase
//         end
//     end

//     // Jump Taken Logic
//     assign JumpTakenE = JumpE | JumpRegE;

//     // Combinational PCSrc signal
//     assign PCSrcE_comb = (BranchE & BranchTakenE) | JumpTakenE;

//     // Pipeline Register Logic
//     always @(posedge clk or posedge rst) begin
//         if(rst == 1'b1) begin
//             RegWriteE_r <= 1'b0; 
//             MemWriteE_r <= 1'b0; 
//             MemtoRegE_r <= 1'b0;
//             PCSrcE_r <= 1'b0;
//             JumpE_r <= 1'b0;    
//             WriteReg_E_r <= 5'h00;
//             PCPlus4E_r <= 32'h00000000; 
//             RD2_E_r <= 32'h00000000; 
//             ResultE_r <= 32'h00000000;
//         end
//         else begin
//             // Normal pipeline advancement - don't squash here
//             RegWriteE_r <= RegWriteE; 
//             MemWriteE_r <= MemWriteE; 
//             MemtoRegE_r <= MemtoRegE;
//             PCSrcE_r <= PCSrcE_comb;
//             JumpE_r <= JumpE;
//             WriteReg_E_r <= RD_E;
//             PCPlus4E_r <= PCPlus4E; 
//             RD2_E_r <= Src_B_interim; 
//             ResultE_r <= ResultE;
//         end
//     end

//     // Output Assignments
//     // The current instruction in Execute (branch/jump) executes normally
//     // We only flush the instructions AFTER it
//     assign RegWriteM = RegWriteE_r;
//     assign MemWriteM = MemWriteE_r;
//     assign MemtoRegM = MemtoRegE_r;
    
//     // Use COMBINATIONAL PCSrc for immediate flushing
//     assign PCSrcE = PCSrcE_comb;
//     assign FlushF = PCSrcE_comb;    // Flush Fetch stage immediately
//     assign FlushD2 = PCSrcE_comb;   // Flush Decode stage immediately
    
//     assign WriteReg_M = WriteReg_E_r;
//     assign JumpM = JumpE_r;
//     assign PCPlus4M = PCPlus4E_r;
//     assign WriteDataM = RD2_E_r;
//     assign ALU_ResultM = ResultE_r;

//     // Debug Display
//     always @(*) begin
//         $display("~~EX CYCLE: BranchE=%b, BranchTakenE=%b, JumpTakenE=%b, PCSrcE_comb=%b, FlushD2=%b, time=%0t", 
//                  BranchE, BranchTakenE, JumpTakenE, PCSrcE_comb, FlushD2, $time);
//     end

// endmodule




// module execute_cycle(
//     // Declaration I/Os
//     input clk, rst, RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, BranchE, JumpE, JumpRegE,
//     input [2:0] funct3E,
//     input [3:0] ALUControlE,
//     input [31:0] RD1_E, RD2_E, Imm_Ext_E,
//     input [4:0] RD_E, RS1_E, RS2_E,
//     input [31:0] PCE, PCPlus4E,
//     input [31:0] ResultW, ALU_Memvalue,
//     input [1:0] ForwardA_E, ForwardB_E,

//     output PCSrcE, RegWriteM, MemtoRegM, MemWriteM, JumpM,
//     output FlushF, FlushD2,
//     output [4:0] WriteReg_M,
//     output [31:0] PCPlus4M, WriteDataM, ALU_ResultM,
//     output [31:0] PCTargetE
// );
//     // Declaration of Interim Wires
//     wire [31:0] Src_A, Src_B_interim, Src_B;
//     wire [31:0] ResultE;
//     wire ZeroE;

//     reg BranchTakenE;
//     wire JumpTakenE;
//     wire PCSrcE_comb;  // Combinational PC source signal
    

//     // Declaration of Pipeline Registers
//     reg RegWriteE_r, MemtoRegE_r, MemWriteE_r, PCSrcE_r, JumpE_r;
//     reg [4:0] WriteReg_E_r;
//     reg [31:0] PCPlus4E_r, RD2_E_r, ResultE_r;

//     // Declaration of Modules
//     // 3 by 1 Mux for Source A
//     // This mux is to achieve forwarding for Source A. We forward the data from MEM or WB stage if needed.
//     // Thus, the inputs to this mux are RD1_E (original source A), ResultW (data from WB stage) and ALU_Memvalue (data from MEM stage).
//     Mux_3_by_1 srca_mux (
//                         .a(RD1_E),
//                         .b(ResultW),
//                         .c(ALU_Memvalue),
//                         .s(ForwardA_E),
//                         .d(Src_A)
//                         );

//     // 3 by 1 Mux for Source B
//     // This mux is to achieve forwarding for Source B.
//     Mux_3_by_1 srcb_mux (
//                         .a(RD2_E),
//                         .b(ResultW),
//                         .c(ALU_Memvalue),
//                         .s(ForwardB_E),
//                         .d(Src_B_interim)
//                         );

//     // ALU Src Mux
//     // Do we take the 2nd ALU operand from the register file (Src_B_interim) [either from the register file or the forwarded value]
//     // or from the immediate extender (Imm_Ext_E)?    
//     assign Src_B = (BranchE) ? Src_B_interim :
//                    (ALUSrcE) ? Imm_Ext_E :
//                                Src_B_interim;

//     // Compute PC Target
//     // For JALR: (Src_A + Imm_Ext_E) & ~1
//     // For JAL and branches: PCE + Imm_Ext_E
//     assign PCTargetE = JumpRegE ? ((Src_A + Imm_Ext_E) & 32'hFFFFFFFE) :
//                                   (PCE + Imm_Ext_E);

//     // ALU Unit
//     ALU alu (
//             .A(Src_A),
//             .B(Src_B),
//             .ALUControl(ALUControlE),
//             .Result(ResultE),
//             .Zero(ZeroE)
//             );

//     // Branch Decision Logic (Combinational)
//     always @(*) begin
//         BranchTakenE = 1'b0;

//         if (BranchE) begin
//             case (funct3E)
//                 3'b000: BranchTakenE = ZeroE;        // beq
//                 3'b001: BranchTakenE = ~ZeroE;       // bne
//                 3'b100: BranchTakenE = ResultE[0];   // blt  (SLT)
//                 3'b101: BranchTakenE = ~ResultE[0];  // bge
//                 3'b110: BranchTakenE = ResultE[0];   // bltu (SLTU)
//                 3'b111: BranchTakenE = ~ResultE[0];  // bgeu
//                 default: BranchTakenE = 1'b0;
//             endcase
//         end
//     end

//     // Jump Taken Logic
//     assign JumpTakenE = JumpE | JumpRegE;

//     // Combinational PCSrc (for immediate flushing)
//     // Must handle the case when signals are not yet initialized
//     assign PCSrcE_comb = ((BranchE & BranchTakenE) | JumpTakenE);

//     // Pipeline Register Logic
//     always @(posedge clk or posedge rst) begin
//         if(rst == 1'b1) begin
//             RegWriteE_r <= 1'b0; 
//             MemWriteE_r <= 1'b0; 
//             MemtoRegE_r <= 1'b0;
//             PCSrcE_r <= 1'b0;
//             JumpE_r <= 1'b0;    
//             WriteReg_E_r <= 5'h00;
//             PCPlus4E_r <= 32'h00000000; 
//             RD2_E_r <= 32'h00000000; 
//             ResultE_r <= 32'h00000000;
//         end
//         else begin
//             RegWriteE_r <= RegWriteE; 
//             MemWriteE_r <= MemWriteE; 
//             MemtoRegE_r <= MemtoRegE;
//             PCSrcE_r <= PCSrcE_comb;  // Register the PC source for next stage
//             JumpE_r <= JumpE;
//             WriteReg_E_r <= RD_E;
//             PCPlus4E_r <= PCPlus4E; 
//             RD2_E_r <= Src_B_interim; 
//             ResultE_r <= ResultE;
//         end
//     end

//     // Output Assignments
//     // Use combinational signal for immediate response with proper initialization
//     assign PCSrcE = (rst) ? 1'b0 : PCSrcE_comb;
//     assign FlushF = (rst) ? 1'b0 : PCSrcE_comb;
//     assign FlushD2 = (rst) ? 1'b0 : PCSrcE_comb;
    
//     assign RegWriteM = RegWriteE_r;
//     assign MemWriteM = MemWriteE_r;
//     assign MemtoRegM = MemtoRegE_r;
//     assign WriteReg_M = WriteReg_E_r;
//     assign JumpM = JumpE_r;
//     assign PCPlus4M = PCPlus4E_r;
//     assign WriteDataM = RD2_E_r;
//     assign ALU_ResultM = ResultE_r;

//     // Debug Display
//     always @(*) begin
//         $display("~~EX CYCLE: BranchE=%b, BranchTakenE=%b, JumpTakenE=%b, PCSrcE=%b, FlushD2=%b, time=%0t", 
//                  BranchE, BranchTakenE, JumpTakenE, PCSrcE, FlushD2, $time);
//     end

// endmodule