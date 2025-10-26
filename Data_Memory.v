module Data_Memory(
    input clk,
    input rst,
    input WE,
    input [31:0] A,
    input [31:0] WD,
    output reg [31:0] RD
);

    reg [31:0] data_mem [0:1023];

    integer i;

    // Initialize memory to 0
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            data_mem[i] = 32'b0;
    end

    // Write operation on positive edge
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 1024; i = i + 1)
                data_mem[i] <= 32'b0;
        end
        else if (WE) begin
            data_mem[A >> 2] <= WD;   // A >> 2 because word addressing (32-bit aligned)
        end
    end

    // Read operation (combinational)
    always @(*) begin
        if (rst)
            RD = 32'b0;
        else
            RD = data_mem[A >> 2];
    end

endmodule
