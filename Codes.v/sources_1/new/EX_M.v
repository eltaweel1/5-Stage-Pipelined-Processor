
module EX_MEM (
    input  wire       clk,
    input  wire       enable,
    input  wire       flush,
    
    input  wire [1:0] ra,
    input  wire [1:0] rb,
    input  wire [7:0] RF1,
    input  wire [7:0] RF2,
    input  wire [7:0] PC_plus1,
    
    input  wire [2:0] writePortSel,       // Write port selection
    input  wire       writeAddressSel,    // 0: Ra , 1: Rb
    input  wire       spWriteEnable,
    input  wire       ALU_result_out_DEX,
    
    input  wire       valid_out_DEX,
    
      
    input wire       RFwrite,
    input wire       DMwrite,
    
    input  wire [7:0] ALU_result,
    input  wire [7:0] DataMem,    
    input  wire [7:0] idExImm,    

    input wire [2:0] SAdd, 
    input wire       SData,
    
    input wire [1:0] sourceRegister1_DEX,
    input wire [1:0] sourceRegister2_DEX,
    
    input wire [1:0] destinationRegister,
    input wire       IsLoadInstruction_DEX,

    output reg [1:0] ra_out,
    output reg [1:0] rb_out,
    output reg [7:0] RF1_out,
    output reg [7:0] RF2_out,
    output reg [7:0] PC_plus1_out,
    
    output reg [2:0] writePortSel_out,       // Write port selection
    output reg       writeAddressSel_out,    // 0: Ra , 1: Rb
    output reg       spWriteEnable_out,
    
    output reg       ALU_result_out_EXM,
      
    output reg       RFwrite_out, // exMemRegisterWriteEnable
    output reg       DMwrite_out,
    
    output reg       valid_out_EXM,
    
    output reg  [7:0] imm,
    
    output reg [7:0] ALU_result_out,
    output reg [7:0] DataMem_out ,   
    output reg [2:0] SAdd_out,
    output reg       SData_out,

    output reg [1:0] sourceRegister1_EXM,
    output reg [1:0] sourceRegister2_EXM,
    
    output reg [1:0] destinationRegister_EXM,
    output reg       IsLoadInstruction_EXM
);

always @(posedge clk) begin
    if (flush) begin
        ra_out <= 0;
        rb_out <= 0;
        RF1_out         <= 8'h00;
        RF2_out         <= 8'h00;
        PC_plus1_out    <= 8'h00;
        writePortSel_out <= 0;       // Write port selection
        writeAddressSel_out <= 0 ;    // 0: Ra , 1: Rb
        spWriteEnable_out <= 0;
        ALU_result_out  <= 8'h00;
        DataMem_out     <= 8'h00;
        RFwrite_out <= 0;
        DMwrite_out <= 0;
	    SAdd_out <= 0;
	    SData_out <= 0;
	    destinationRegister_EXM <= 0;
	    IsLoadInstruction_EXM <= 0;
	    sourceRegister1_EXM <= 0;
	    sourceRegister2_EXM <= 0;
	    ALU_result_out_EXM <= 0;
        valid_out_EXM <= 0;
	    imm <= 0;
    end
    else if (enable) begin
        ra_out <= ra;
        rb_out <= rb;
        RF1_out         <= RF1;
        RF2_out         <= RF2;
        PC_plus1_out    <= PC_plus1;
        writePortSel_out <= writePortSel;       // Write port selection
        writeAddressSel_out <= writeAddressSel ;    // 0: Ra , 1: Rb
        spWriteEnable_out <= spWriteEnable;
        ALU_result_out  <= ALU_result;
        DataMem_out     <= DataMem;
        RFwrite_out <= RFwrite;
        DMwrite_out <= DMwrite;
	    SAdd_out <= SAdd;
	    SData_out <= SData;
	    destinationRegister_EXM <= destinationRegister;
	    IsLoadInstruction_EXM <= IsLoadInstruction_DEX;
	    sourceRegister1_EXM <= sourceRegister1_DEX;
	    sourceRegister2_EXM <= sourceRegister2_DEX;
	    ALU_result_out_EXM <= ALU_result_out_DEX;
	    valid_out_EXM <= valid_out_DEX;
	    imm <= idExImm;
    end
end

endmodule
