//Note: RS2 = Rt (Source register 2)
module decode_cycle(
    // Declaring I/O
    input clk, rst, RegWriteW, FlushD1, FlushD2,
    input [4:0] WriteRegW,
    input [31:0] InstrD, PCD, PCPlus4D, ResultW,
//output of decode stage is used in the execute stage

    output RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, BranchE, JumpE, JumpRegE,
    output [2:0] funct3,   //funct3 field is pipelined to the execute stage, to perfomr branch instructions
    output [3:0] ALUControlE,
    output [31:0] RD1_E, RD2_E, Imm_Ext_E,
    output [4:0] RS1_E, RS2_E, RD_E,     //Source and destination registers for the instruction in Execute stage
    output [4:0] RS1_D, RS2_D,    //Source registers for the instruction in Decode stage
    output [31:0] InstrE, PCE, PCPlus4E
);

    // Declare Interim Wires
    wire RegWriteD, MemtoRegD, MemWriteD, ALUSrcD, BranchD, JumpD, JumpRegD;
    wire [3:0] ALUControlD;
    wire [31:0] RD1_D, RD2_D, Imm_Ext_D;

    //wire FlushD = FlushD1 | FlushD2;   //IMPORTANT

    // Declaration of pipeline Register (to hold values between clock cycles)
    reg RegWriteD_r, MemtoRegD_r, MemWriteD_r, ALUSrcD_r, BranchD_r, JumpD_r, JumpRegD_r;
    reg [2:0] funct3_r;
    reg [3:0] ALUControlD_r;
    reg [31:0] RD1_D_r, RD2_D_r, Imm_Ext_D_r;
    reg [4:0] RD_D_r, RS1_D_r, RS2_D_r;    //Source and destination registers for the instruction in Decode stage stored in the pipeline registers
    reg [31:0] InstrD_r, PCD_r, PCPlus4D_r;

    // Control Unit
    Control_Unit control (
                            .Op(InstrD[6:0]),
                            .funct3(InstrD[14:12]),
                            .funct7(InstrD[31:25]),

                            .RegWrite(RegWriteD),
                            .MemToReg(MemtoRegD),
                            .MemWrite(MemWriteD),
                            .ALUSrc(ALUSrcD), 
                            .Branch(BranchD),
                            .Jump(JumpD),
                            .JumpReg(JumpRegD),
                            //.ImmSrc(ImmSrcD),
                            .ALUControl(ALUControlD)
                            );

    // Register File
    Register_File rf (
                        .clk(clk),
                        .rst(rst),
                        .WE3(RegWriteW),
                        .WD3(ResultW),
                        .A1(InstrD[19:15]),
                        .A2(InstrD[24:20]),
                        .A3(WriteRegW),
                        .RD1(RD1_D),
                        .RD2(RD2_D)
                        );

    // Sign Extension
    Immediate_Generator extension (
                        .In(InstrD[31:0]),
                        .Imm_Ext(Imm_Ext_D)
                        );



    always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        // full reset → bubble
        RegWriteD_r   <= 1'b0;
        MemtoRegD_r   <= 1'b0;
        MemWriteD_r   <= 1'b0;
        ALUSrcD_r     <= 1'b0;
        BranchD_r     <= 1'b0;
        JumpD_r       <= 1'b0;
        JumpRegD_r    <= 1'b0;
        ALUControlD_r <= 4'b0000;
        InstrD_r      <= 32'b0;

        funct3_r      <= 3'b000;
        RD1_D_r       <= 32'b0;
        RD2_D_r       <= 32'b0;
        Imm_Ext_D_r   <= 32'b0;
        RD_D_r        <= 5'b0;
        RS1_D_r       <= 5'b0;
        RS2_D_r       <= 5'b0;
        PCD_r         <= 32'b0;
        PCPlus4D_r    <= 32'b0;
    end

    //FLUSH EXECUTE STAGE (insert bubble)

    else if (FlushD1 | FlushD2) begin
        RegWriteD_r   <= 1'b0;
        MemtoRegD_r   <= 1'b0;
        MemWriteD_r   <= 1'b0;
        ALUSrcD_r     <= 1'b0;
        BranchD_r     <= 1'b0;
        JumpD_r       <= 1'b0;
        JumpRegD_r    <= 1'b0;
        ALUControlD_r <= 4'b0000;
        InstrD_r      <= 32'b0;   //NOP instruction, actual

        // data can be anything, zero is safest
        funct3_r      <= 3'b000;
        RD1_D_r       <= 32'b0;
        RD2_D_r       <= 32'b0;
        Imm_Ext_D_r   <= 32'b0;
        RD_D_r        <= 5'b0;
        RS1_D_r       <= 5'b0;
        RS2_D_r       <= 5'b0;
        // PCD_r         <= 32'b0;
        // PCPlus4D_r    <= 32'b0;
    end

    // NORMAL OPERATION
    else begin
        RegWriteD_r   <= RegWriteD;
        MemtoRegD_r   <= MemtoRegD;
        MemWriteD_r   <= MemWriteD;
        ALUSrcD_r     <= ALUSrcD;
        BranchD_r     <= BranchD;
        JumpD_r       <= JumpD;
        JumpRegD_r    <= JumpRegD;
        ALUControlD_r <= ALUControlD;
        InstrD_r      <= InstrD;

        funct3_r      <= InstrD[14:12];
        RD1_D_r       <= RD1_D;
        RD2_D_r       <= RD2_D;
        Imm_Ext_D_r   <= Imm_Ext_D;
        RD_D_r        <= InstrD[11:7];
        RS1_D_r       <= InstrD[19:15];
        RS2_D_r       <= InstrD[24:20];
        PCD_r         <= PCD;
        PCPlus4D_r    <= PCPlus4D;
    end
end


    // Output asssign statements
    assign RegWriteE = RegWriteD_r;
    assign MemWriteE = MemWriteD_r;
    assign MemtoRegE = MemtoRegD_r;
    assign ALUSrcE = ALUSrcD_r;
    assign BranchE = BranchD_r;
    assign JumpE = JumpD_r;
    assign JumpRegE = JumpRegD_r;
    assign ALUControlE = ALUControlD_r;
    assign InstrE = InstrD_r;

    assign funct3 = funct3_r;
    assign RD1_E = RD1_D_r;
    assign RD2_E = RD2_D_r;
    assign Imm_Ext_E = Imm_Ext_D_r;
    assign RD_E = RD_D_r;
    assign RS1_E = RS1_D_r;
    assign RS2_E = RS2_D_r;

    assign RS1_D = InstrD[19:15];
    assign RS2_D = InstrD[24:20];
    assign PCE = PCD_r;
    assign PCPlus4E = PCPlus4D_r;


always @(negedge clk) begin
        $display("DECODE STAGE: InstrD = %h, FlushD1=%b, FlushD2=%b, FlushD=%b, PCE=%d, time=%0t", InstrD, FlushD1, FlushD2, FlushD1|FlushD2, PCE, $time);
    end

endmodule

