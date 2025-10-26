module ALU(
    input [31:0] A, B,
    input [2:0] ALUControl,
    output Carry, OverFlow, Zero, Negative,
    output reg [31:0] Result
);

    wire [31:0] B_in;
    wire [31:0] Sum;
    wire Cout;

    // It has Flags : Carry, OverFlow, Zero, Negative
    // ALUControl:
    // 000 -> A + B
    // 001 -> A - B
    // 010 -> A & B
    // 011 -> A | B
    // 101 -> SLT (set less than)

    // For subtraction or SLT, use two’s complement of B
    assign B_in = (ALUControl == 3'b001 || ALUControl == 3'b101) ? ~B + 1 : B;

    // Perform addition/subtraction
    assign {Cout, Sum} = A + B_in;

    // ALU main logic
    always @(*) begin
        case (ALUControl)
            3'b000: Result = Sum;               // A + B
            3'b001: Result = Sum;               // A - B
            3'b010: Result = A & B;             // AND
            3'b011: Result = A | B;             // OR
            3'b101: Result = {{31{1'b0}}, Sum[31]}; // SLT
            default: Result = 32'b0;
        endcase
    end

    // Overflow and flag logic
    wire add_overflow, sub_overflow;
    assign add_overflow = (~(A[31] ^ B[31])) && (Sum[31] ^ A[31]);
    assign sub_overflow = (A[31] ^ B[31]) && (Sum[31] ^ A[31]);

    assign OverFlow = (~ALUControl[1]) &&                  // only for arithmetic ops
                      ((~ALUControl[0] & add_overflow) |   // ADD
                       ( ALUControl[0] & sub_overflow));   // SUB

    assign Carry = ((~ALUControl[1]) & Cout);
    assign Zero = (Result == 32'b0);
    assign Negative = Result[31];

endmodule

