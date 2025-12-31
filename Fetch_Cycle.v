
module Fetch_Cycle(

    // Declare input & outputs
    input clk, rst, StallD, StallF, FlushF,
    input PCSrcE,   
    input [31:0] PCTargetE,
    output [31:0] InstrD,
    output [31:0] PCD, PCPlus4D
);

    // Declaring interim wires
    wire [31:0] Next_PC_F, PCF, PCPlus4F;
    wire [31:0] InstrF;

    // Declaration of Pipeline Register
    reg [31:0] InstrF_r;
    reg [31:0] PCF_r, PCPlus4F_r;

    // Initiation of Modules
    // Declare PC Mux
    Mux PC_MUX (.a(PCPlus4F),
                .b(PCTargetE),
                .sel(PCSrcE),
                .c(Next_PC_F)
                );

    // Declare PC Counter
    PC Program_Counter (
                .clk(clk),
                .rst(rst),
                .PC_Next(Next_PC_F),
                .StallF(StallF),
                .PC(PCF)
                );

    // Declare Instruction Memory
    Instruction_Memory IMEM (
                .rst(rst),
                .A(PCF),
                .RD(InstrF)
                );

    // Declare PC adder
    PC_Adder PC_adder (
                .a(PCF),
                .b(32'h00000004),
                .c(PCPlus4F)
                );

always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        InstrF_r    <= 32'h00000000;
        PCF_r       <= 32'h00000000;
        PCPlus4F_r  <= 32'h00000000;
    end

        //  FLUSH DECODE STAGE (branch taken)
    else if (FlushF) begin
        InstrF_r    <= 32'h00000000;   // NOP
        PCF_r       <= 32'h00000000;
        PCPlus4F_r  <= 32'h00000000;
    end

    // STALL DECODE STAGE
    else if (!StallD) begin
        InstrF_r    <= InstrF;
        PCF_r       <= PCF;
        PCPlus4F_r  <= PCPlus4F;
    end
    // else: hold previous values (stall)
end

    assign  InstrD = InstrF_r;
    assign  PCD = PCF_r;
    assign  PCPlus4D = PCPlus4F_r;

// always@(negedge clk) begin
//         $display("FETCH STAGE: InstrD = %h,StallF=%b, FlushF=%b, time=%0t",
//             InstrD, StallF,FlushF, $time);
//     end


endmodule


