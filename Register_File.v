module Register_File(clk, rst, WE3, WD3, A1, A2, A3, RD1, RD2);

    input clk, rst, WE3;           // WE3 = Write Enable
    input [4:0] A1, A2, A3;        // Register addresses
    input [31:0] WD3;              // Data to be written
    output [31:0] RD1, RD2;        // Data read from registers

    reg [31:0] Register [31:0];
    integer i;

    // Synchronous write, asynchronous reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                Register[i] <= 32'b0;
        end
        else if (WE3 && (A3 != 5'b00000)) begin
            Register[A3] <= WD3;   // Write only if not register 0
        end
    end

    // Combinational read
    assign RD1 = (rst) ? 32'd0 : Register[A1];
    assign RD2 = (rst) ? 32'd0 : Register[A2];

    // Ensure $zero register always stays zero
    initial begin
        Register[0] = 32'b0;
    end

endmodule

