
module Data_Memory(clk,rst,WE,WD,A,RD);
    input clk, rst, WE;
    input [31:0] A, WD;
    output [31:0] RD;

    reg [31:0] data_mem [1023 : 0];

//Logic for right shift is similar to that as in Instructuon memory

    always @(posedge clk)
        begin
            if (WE)
                data_mem[A>>2] <= WD;
        end

    assign RD = (rst == 1'b1) ? {32{1'b0}} : data_mem[A>>2]

    integer i;
    inital begin
        for(i=0; i<1024; i=i+1)
            data_mem[i] = 32'b0;
    end

endmodule

