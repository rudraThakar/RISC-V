`include "ALU_Control_Unit.v"
`include "Main_Control_Unit.v"

module Control_Unit(
    input [6:0]Op,funct7,
    input [2:0]funct3,

    output RegWrite, MemWrite, MemToReg, ALUSrc, Branch, Jump, JumpReg, 
    //output [1:0]ImmSrc,
    output [3:0]ALUControl
);

    wire [1:0]ALUOp;

    Main_Control_Unit Main_Controller(
                .opcode(Op),
                
                .RegWrite(RegWrite),
                //.RegDst(RegDst),
                //.ImmSrc(ImmSrc),
                //.MemRead(MemRead),
                .MemWrite(MemWrite),
                .MemToReg(MemToReg),
                .ALUSrc(ALUSrc),
                .Branch(Branch),
                .Jump(Jump),
                .JumpReg(JumpReg),
                .ALUOp(ALUOp)
    );

    ALU_Control_Unit ALU_Controller(
                            .ALUOp(ALUOp),
                            .funct3(funct3),
                            .funct7(funct7),
                            .op(Op),
                            .ALUControl(ALUControl)
    );


endmodule
