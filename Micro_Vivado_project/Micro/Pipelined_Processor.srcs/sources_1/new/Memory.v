module Von_Neumann_Mem(

    input wire clk,       // input Clock signal 
    input wire reset,
    input wire interrupt,
	
	input wire       SData,     // Write Data MUX select
    input wire       DMwrite,   // Data port Write enable
	input wire [2:0] SAdd, // Address MUX select
            
	input  wire [7:0] PC,           // instruction Address Bus (only 128 byte)
	input  wire [7:0] PC_plus1_E_M, // PC + 1  From the Fetch to memory reg
    input  wire [7:0] ALU_out,
    input  wire [7:0] RF_out1,
    input  wire [7:0] RF_out2,
    input  wire [7:0] imm,
    input  wire [7:0] ALU_SP_Direct,
    
    input  wire waitingForPCFromMem,
    input  wire return_inst,
    
    input wire [1:0] storeAddressSelect,
    input wire [1:0] storeDataSelect,
    
    input [7:0] memWbAluResult,
    input [7:0] memWbMemoryData,
    
    output reg pcFromMemValid,
	
    output wire  [7:0] Data_Memory_Out, // Output Data Bus
    output wire  [7:0] inst_Out      // Output instruction Bus
);

    reg [7:0] data;
    reg [7:0] add;
    
    reg [7:0] M_Address_Bus;  // Data Address Bus
    reg [7:0] Data_Bus;  // Input Data Bus
    
    
    
    reg [7:0] M[0:255];      // Memry width is 8 and memory height is 256
    
    
    integer i;
    
    reg [7:0] inst_add;
    always@(*)
    begin
        if(reset) inst_add = 0;
        else if(interrupt) inst_add = 1;
        else inst_add = PC;
    end
    
    assign inst_Out = M[inst_add];
    assign Data_Memory_Out = M[add];
    
    always@(*)
    begin
    case(storeAddressSelect)
        2'b00:  add = M_Address_Bus;
        2'b01:  add = memWbAluResult;
        default: add = M_Address_Bus;
    endcase
    end
    
	always@(*)
    begin
    case(storeDataSelect)
        2'b00:  data = Data_Bus;
        2'b01:  data = memWbAluResult;
        2'b10:  data = memWbMemoryData;
        default: data = Data_Bus;
    endcase
    end
    
	// select for Address Bus
	always @(*) begin
	if(return_inst) M_Address_Bus = ALU_SP_Direct; // RTI , RET
	else begin
        case (SAdd)
            3'b000: M_Address_Bus = PC_plus1_E_M;
            3'b001: M_Address_Bus = ALU_out;
            3'b010: M_Address_Bus = RF_out1;
            3'b011: M_Address_Bus = RF_out2;
            3'b100: M_Address_Bus = imm;
            3'b101: M_Address_Bus = ALU_SP_Direct; // RTI , RET
            default: M_Address_Bus = PC_plus1_E_M;
        endcase
    end
	end
	// Select for Data Bus
	always @(*) begin
        case (SData)
            2'b00: Data_Bus = RF_out1;
            2'b01: Data_Bus = PC_plus1_E_M;
     
        endcase
    end

    
    
    always@(*) begin
     if(waitingForPCFromMem) 
        pcFromMemValid = 1;     
     else 
        pcFromMemValid = 0; 
     end
    
    
    
    always @(posedge clk) begin
    if (reset) begin
        //inst_Out <= M[0];
        for (i = 128; i < 256; i = i + 1) begin // reset for data part only
            M[i] <= 8'd0;
        end
    end
    else if (interrupt) begin
        //inst_Out <= M[1];
    end
    else begin
        if(DMwrite) M[add] <= data;
    end
    end



endmodule

