module ALU_Control_Unit (
    input wire [6:0] op,
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    always @(*) begin
        case (ALUOp)

            2'b00: begin
                ALUControl = ALU_ADD;
            end

            2'b01: begin
                case (funct3)
                    3'b000: ALUControl = ALU_SUB;   // beq
                    3'b001: ALUControl = ALU_SUB;   // bne
                    3'b100: ALUControl = ALU_SLT;   // blt
                    3'b101: ALUControl = ALU_SLT;   // bge
                    3'b110: ALUControl = ALU_SLTU;  // bltu
                    3'b111: ALUControl = ALU_SLTU;  // bgeu
                    default: ALUControl = ALU_ADD; // safe default
                endcase
            end

            2'b10: begin
                case (funct3)
                    3'b000: begin
                        // add / addi / sub
                        if (op == 7'b0110011 && funct7[5])
                            ALUControl = ALU_SUB; // sub
                        else
                            ALUControl = ALU_ADD; // add / addi
                    end

                    3'b001: ALUControl = ALU_SLL;   // sll / slli
                    3'b010: ALUControl = ALU_SLT;   // slt / slti
                    3'b011: ALUControl = ALU_SLTU;  // sltu / sltiu
                    3'b100: ALUControl = ALU_XOR;   // xor / xori
                    3'b110: ALUControl = ALU_OR;    // or / ori
                    3'b111: ALUControl = ALU_AND;   // and / andi

                    3'b101: begin
                        // srl / srli / sra / srai
                        if (funct7[5])
                            ALUControl = ALU_SRA; // arithmetic shift
                        else
                            ALUControl = ALU_SRL; // logical shift
                    end

                    default: ALUControl = ALU_ADD;
                endcase
            end

            default: begin
                ALUControl = ALU_ADD;
            end

        endcase

        // $display("ALUCtrl: opcode=%b funct3=%b funct7=%b ALUControl=%b",
        //  ALUOp, funct3, funct7, ALUControl);

    end

endmodule
