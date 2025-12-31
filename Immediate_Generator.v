module Immediate_Generator (
    input  [31:0] In,      // instruction
    output reg [31:0] Imm_Ext
);

always @(*) begin
    case (In[6:0])

        7'b0010011, 
        7'b0000011, 
        7'b1100111, 
        7'b1110011: begin   // I-type
            Imm_Ext = {{20{In[31]}}, In[31:20]};
        end

        7'b0100011: begin   // S-type
            Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]};
        end

        7'b1100011: begin   // B-type
            Imm_Ext = {{19{In[31]}}, In[31], In[7], In[30:25], In[11:8], 1'b0};
        end

        7'b0010111, 
        7'b0110111: begin   // U-type (AUIPC/LUI)
            Imm_Ext = {In[31:12], 12'b0};
        end

        7'b1101111: begin   // J-type
            Imm_Ext = {{11{In[31]}}, In[31], In[19:12], In[20], In[30:21], 1'b0};
        end

        default: begin
            Imm_Ext = 32'b0;
        end

    endcase
end

endmodule
