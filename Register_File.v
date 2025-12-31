// module Register_File(clk, rst, WE3, WD3, A1, A2, A3, RD1, RD2);

//     input clk, rst, WE3;           // WE3 = Write Enable
//     input [4:0] A1, A2, A3;        // Register addresses
//     input [31:0] WD3;              // Data to be written
//     output [31:0] RD1, RD2;        // Data read from registers

//     reg [31:0] Register [31:0];
//     integer i;

//     // Synchronous write, asynchronous reset
//     always @(posedge clk or posedge rst) begin
//         if (rst == 1'b1) begin
//             for (i = 0; i < 32; i = i + 1)
//                 Register[i] <= 32'b0;
//         end else begin
//             Register[0] <= 32'b0;   // Enforce $zero every cycle

//             // Normal write
//             if (WE3 && (A3 != 5'd0))
//                 Register[A3] <= WD3;
//                 //$display("Writing %h to Register %d. TIME = %0t. WE = %b", WD3, A3, $time, WE3);
//         end
//     end


//     // Combinational read
//     assign RD1 = (rst) ? 32'd0 : Register[A1];
//     assign RD2 = (rst) ? 32'd0 : Register[A2];


// endmodule


module Register_File(
    input clk,
    input rst,
    input WE3,
    input [31:0] WD3,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    output [31:0] RD1,
    output [31:0] RD2
);

    reg [31:0] Register [31:0];
    integer i;

    // Synchronous write, async reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                Register[i] <= 32'b0;
        end else begin
            Register[0] <= 32'b0;   // x0 always zero
            if (WE3 && (A3 != 5'd0))
                Register[A3] <= WD3;
        end
    end

    // WRITE-BEFORE-READ BYPASS LOGIC
    assign RD1 =
        (rst) ? 32'd0 :
        (WE3 && (A3 != 5'd0) && (A3 == A1)) ? WD3 :
        Register[A1];

    assign RD2 =
        (rst) ? 32'd0 :
        (WE3 && (A3 != 5'd0) && (A3 == A2)) ? WD3 :
        Register[A2];

endmodule

