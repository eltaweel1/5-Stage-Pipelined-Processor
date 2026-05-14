module MEM_WB (
    input  wire       clk,
    input  wire       enable,
    input  wire       flush,

    input  wire [7:0] ALU_result,
    input  wire [7:0] DataMem,
    
    
    input  wire [1:0] ra,
    input  wire [1:0] rb,
    input  wire [7:0] RF1,
    input  wire [7:0] RF2,
    input  wire [2:0] writePortSel,       // Write port selection
    input  wire       writeAddressSel,    // 0: Ra , 1: Rb
    input  wire       spWriteEnable,
    
    input wire  [7:0] imm,
    
    input wire       RFwrite,
    input wire       IsLoadInstruction_EXM,
    input wire [1:0] destinationRegister,
    
    output reg  [1:0] ra_out,
    output reg  [1:0] rb_out,
    output reg  [7:0] RF1_out,
    output reg  [7:0] RF2_out,
    output reg  [7:0] imm_MWB,
    output reg  [2:0] writePortSel_out,       // Write port selection
    output reg        writeAddressSel_out,    // 0: Ra , 1: Rb
    output reg        spWriteEnable_out,
    
    
    
    output reg        RFwrite_out,

    output reg  [7:0] ALU_result_out,
    output reg  [7:0] DataMem_out,
    
    output reg       IsLoadInstruction_MWB,
    output reg [1:0] destinationRegister_MWB
    
);

always @(posedge clk) begin
    if (flush) begin
        ra_out <= 0;
        rb_out <= 0;
        RF1_out <= 0;
        RF2_out <= 0;

        writePortSel_out <= 0;
        writeAddressSel_out <= 0;
        spWriteEnable_out <= 0;
        RFwrite_out <= 0;
        
        ALU_result_out <= 8'h00;
        DataMem_out    <= 8'h00;
        IsLoadInstruction_MWB <= 0;
	    destinationRegister_MWB <= 0;
	    imm_MWB <= 0;
    end
    else if (enable) begin
        ra_out <= ra;
        rb_out <= rb;
        RF1_out <= RF1;
        RF2_out <= RF2;

        writePortSel_out <= writePortSel;
        writeAddressSel_out <= writeAddressSel;
        spWriteEnable_out <= spWriteEnable;
        RFwrite_out <= RFwrite;    
                        
        ALU_result_out <= ALU_result;
        DataMem_out    <= DataMem;
        
        imm_MWB <= imm;
        
        IsLoadInstruction_MWB <= IsLoadInstruction_EXM;
	    destinationRegister_MWB <= destinationRegister;
    end
end

endmodule

