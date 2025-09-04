
module Register_File(clk,rst,WE3,WD3,A1,A2,A3,RD1,RD2);

    input clk,rst,WE3;       //WE3 = Write Enable
    input [4:0]A1,A2,A3;     //Address of the register
    input [31:0]WD3;         //data to be written in the register
    output [31:0]RD1,RD2;    //data read from the register

    reg [31:0] Register [31:0];

//Register Write is Synchronous Sequential
//Register Read is combinational

    integer i;
    always @ (posedge clk or posedge rst)
    begin
        if(rst)
            for (i=0; i<32; i=i+1){
                Register[i] <= 0;
            }
        else
            if(WE3 & (A3!=5'b00000))    //notreg[0] & write_enabled
                Register[A3] <= WD3;
    end
    assign RD1 = (rst==1'b0) ? 32'd0 : Register[A1];
    assign RD2 = (rst==1'b0) ? 32'd0 : Register[A2];

    initial begin
        Register[0] = 32'h00000000;     //$zero register is constant
    end

endmodule
