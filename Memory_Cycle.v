
module memory_cycle(
    
    // Declaration of I/Os
    input clk, rst, RegWriteM, MemtoRegM, MemWriteM, JumpM,
    input [4:0] WriteReg_M,
    input [31:0] InstrM, PCPlus4M, WriteDataM, ALU_ResultM,

    output RegWriteW, MemtoRegW, JumpW, 
    output [4:0] WriteReg_W,
    output [31:0] PCPlus4W, ALU_ResultW, ReadDataW
);

    // Declaration of Interim Wires
    wire [31:0] ReadDataM;

    // Declaration of Interim Registers
    reg RegWriteM_r, MemtoRegM_r, JumpM_r;
    reg [4:0] WriteReg_M_r;
    reg [31:0] PCPlus4M_r, ALU_ResultM_r, ReadDataM_r;

    // Declaration of Module Initiation

    Data_Memory dmem (
                        .clk(clk),
                        .rst(rst),
                        .WE(MemWriteM),
                        .WD(WriteDataM),
                        .A(ALU_ResultM),
                        .RD(ReadDataM)
                    );

    // Memory Stage Register Logic
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            RegWriteM_r <= 1'b0; 
            MemtoRegM_r <= 1'b0;
            WriteReg_M_r <= 5'h00;
            JumpM_r <= 1'b0;
            PCPlus4M_r <= 32'h00000000; 
            ALU_ResultM_r <= 32'h00000000; 
            ReadDataM_r <= 32'h00000000;
        end
        else begin
            RegWriteM_r <= RegWriteM; 
            MemtoRegM_r <= MemtoRegM;
            WriteReg_M_r <= WriteReg_M;
            PCPlus4M_r <= PCPlus4M; 
            JumpM_r <= JumpM;
            ALU_ResultM_r <= ALU_ResultM; 
            ReadDataM_r <= ReadDataM;
        end
    end 

// always@(*) begin
//         $display("~~MEM CYCLE: InstrM = %h, Time = %0t", InstrM, $time);
//     end

    // Declaration of output assignments
    assign RegWriteW = RegWriteM_r;
    assign MemtoRegW = MemtoRegM_r;
    assign WriteReg_W = WriteReg_M_r;
    assign JumpW = JumpM_r;
    assign PCPlus4W = PCPlus4M_r;
    assign ALU_ResultW = ALU_ResultM_r;
    assign ReadDataW = ReadDataM_r;

endmodule
