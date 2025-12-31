
module PC(
    input clk,rst,
    input [31:0]PC_Next,
    input StallF,
    output reg [31:0]PC
);

    always @(posedge clk or posedge rst)
    begin
        if(rst == 1'b1)
            PC <= {32{1'b0}};
        else if(!StallF)
            PC <= PC_Next;
    end
endmodule
