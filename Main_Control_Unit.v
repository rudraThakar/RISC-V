module Main_Control_Unit (
    input  wire [6:0] opcode,

    output reg  RegWrite,
    output reg  MemWrite,
    output reg  MemToReg,
    output reg  ALUSrc,
    output reg  Branch,
    output reg  Jump,
    output reg  JumpReg,
    output reg  [1:0] ALUOp
);

always @(*) begin
    RegWrite = 0;
    MemWrite = 0;
    MemToReg = 0;
    ALUSrc   = 0;
    Branch   = 0;
    Jump     = 0;
    JumpReg  = 0;
    ALUOp    = 2'b00;

    case (opcode)

        7'b0110011: begin
            RegWrite = 1;
            ALUSrc   = 0;
            ALUOp    = 2'b10;
        end

        7'b0010011: begin
            RegWrite = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b10;
        end

        7'b0000011: begin
            RegWrite = 1;
            ALUSrc   = 1;
            MemToReg = 1;
            ALUOp    = 2'b00;
        end

        7'b0100011: begin
            MemWrite = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b00;
        end

        7'b1100011: begin
            Branch = 1;
            ALUSrc = 0;
            ALUOp  = 2'b01;
        end

        7'b1101111: begin
            RegWrite = 1;
            Jump     = 1;
        end

        7'b1100111: begin
            RegWrite = 1;
            Jump     = 1;
            JumpReg  = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b00;
        end

        default: begin
        end

    endcase
end

endmodule
