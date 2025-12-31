module ALU (
    input  wire [31:0] A,          
    input  wire [31:0] B,          
    input  wire [3:0]  ALUControl, 
    output reg  [31:0] Result,     
    output wire Zero        // Zero flag (for beq)
);

    assign Zero = (Result == 32'b0);

    always @(*) begin
        case (ALUControl)

            4'b0000: Result = A + B;                     // ADD
            4'b0001: Result = A - B;                     // SUB

            4'b0010: Result = A & B;                     // AND
            4'b0011: Result = A | B;                     // OR
            4'b0100: Result = A ^ B;                     // XOR

            // Shifts (RV32 → lower 5 bits)
            4'b0101: Result = A << B[4:0];               // SLL
            4'b0110: Result = A >> B[4:0];               // SRL
            4'b0111: Result = $signed(A) >>> B[4:0];     // SRA

            // Comparisons
            4'b1000: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
            4'b1001: Result = (A < B) ? 32'd1 : 32'd0;                   // SLTU

            // Default 
            default: Result = 32'b0;

        endcase
        //$display("ALU Operation: A=%h, B=%h, ALUControl=%b, Result=%h, time= %0t", A, B, ALUControl, Result, $time);


    end

endmodule
