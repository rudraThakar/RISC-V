
module Mux (a,b,sel,c);    //2:1 MUX

    input [31:0]a,b;
    input sel;
    output [31:0]c;

    assign c = (~sel) ? a : b ;
    
endmodule

