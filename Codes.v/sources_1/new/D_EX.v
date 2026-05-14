module D_EX (
    input  wire       clk, 
    input  wire       enable,
    input  wire       flush,
    

    input wire  [7:0] op_code,
    input  wire [1:0] ra,
    input  wire [1:0] rb,
    input  wire [7:0] RF1,
    input  wire [7:0] RF2,
    input  wire [7:0] PC_plus1,
    input  wire [3:0] alu_op,  // ADDED
    input  wire [2:0] writePortSel,       // Write port selection
    input  wire       writeAddressSel,    // 0: Ra , 1: Rb
    input  wire       spWriteEnable,
    input  wire       valid_out,
    
    input wire       ALUSrc,     // wait for real size  
    input wire       RFwrite,
    input wire       DMwrite,

    input wire [2:0] SAdd, 
    input wire       SData,

    input wire       CCR_WE,
    
    input wire       IsLoadInstruction,
    
    //input wire       registerWriteEnable,// -> RFwrite
    input wire [1:0] sourceRegister1,
    input wire [1:0] sourceRegister2,
    input wire       useSourceRegister1,
    input wire       useSourceRegister2,
    input wire [1:0] destinationRegister,
    
    input wire [7:0] ifIdImm,
    input wire       ifIdHasImm,
    
    output reg  [3:0] op_code_out,
    output reg  [1:0] ra_out,
    output reg  [1:0] rb_out,
    output reg  [7:0] RF1_out, 
    output reg  [7:0] RF2_out, 
    output reg  [7:0] PC_plus1_out,
    output reg  [3:0] alu_op_out,  // ADDED
    
    output reg  [2:0]  writePortSel_out,       // Write port selection
    output reg         writeAddressSel_out,    // 0: Ra , 1: Rb
    output reg         spWriteEnable_out,
    
    output reg       ALUSrc_out,     // wait for real size  
    output reg       RFwrite_out,
    output reg       DMwrite_out,
    output reg [2:0] SAdd_out,
    output reg       SData_out,
    
    output reg       CCR_WE_out,
    output reg       valid_out_DEX,
    
    output reg       IsLoadInstruction_DEX,
    
    //output reg       registerWriteEnable_out,// -> RFwrite
    output reg [1:0] sourceRegister1_out,
    output reg [1:0] sourceRegister2_out,
    output reg       useSourceRegister1_out,
    output reg       useSourceRegister2_out,
    output reg [1:0] destinationRegister_out,
    output reg  [7:0] idExImm,
    output reg        idExHasImm

);
    always @(posedge clk) begin
        if (flush) begin
            idExImm <= 0;
            idExHasImm <= 0;
            op_code_out <= 0;
            ra_out <= 2'b00;
            rb_out <= 2'b00;
            RF1_out <= 8'h00; 
            RF2_out <= 8'h00; 
            PC_plus1_out <= 8'h00; 
            alu_op_out <= 4'd0;
            writePortSel_out <= 3'b000;
            writeAddressSel_out <= 0;
            spWriteEnable_out <= 0;
            ALUSrc_out <= 0;
            RFwrite_out <= 0; //registerWriteEnable_out
            DMwrite_out <= 0;
            SAdd_out <= 0;
            SData_out <= 0;
            CCR_WE_out <= 0;
            valid_out_DEX <= 0;
            
            sourceRegister1_out <= 0;
            sourceRegister2_out <= 0;
            useSourceRegister1_out <= 0;
            useSourceRegister2_out <= 0;
            destinationRegister_out <= 0;
            
            IsLoadInstruction_DEX <= 0;
        end 
        else if (enable) begin
            idExImm <= ifIdImm;
            idExHasImm <= ifIdHasImm;
            
            op_code_out <= op_code;
            ra_out <= ra;
            rb_out <= rb;
            RF1_out <= RF1; 
            RF2_out <= RF2; 
            PC_plus1_out <= PC_plus1;
            alu_op_out <= alu_op;
            writePortSel_out <= writePortSel;
            writeAddressSel_out <= writeAddressSel;
            spWriteEnable_out <= spWriteEnable;
            ALUSrc_out <= ALUSrc;
            RFwrite_out <= RFwrite;
            DMwrite_out <= DMwrite;
            SAdd_out <= SAdd;
            SData_out <= SData;
            CCR_WE_out <= CCR_WE;
            valid_out_DEX <= valid_out;
            sourceRegister1_out <= sourceRegister1;
            sourceRegister2_out <= sourceRegister2;
            useSourceRegister1_out <= useSourceRegister1;
            useSourceRegister2_out <= useSourceRegister2;
            destinationRegister_out <= destinationRegister;
            
            IsLoadInstruction_DEX <= IsLoadInstruction;
        end
    end
endmodule
