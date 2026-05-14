module RegisterFile (
    input  wire        clk,
    input  wire        rst,         // optional reset
    input  wire        writeEnable,
    input  wire  [2:0] writePortSel,        // Write port selection
    input  wire        writeAddressSel,     // 0: Ra , 1: Rb
    input  wire  [1:0] readAddressASel,     // 0: Ra , 1: Rb  , 11:SP
    input  wire  [1:0] readAddressBSel,     // 0: Ra , 1: Rb  , 11:SP

    input  wire        spWriteEnable,    
    input  wire [7:0]  spWriteData,     // Data to write(in R3 only)

    // -------- Address sources --------
    input  wire [1:0]  Ra,
    input  wire [1:0]  Rb,
    input  wire [1:0]  Ra_MWB,
    input  wire [1:0]  Rb_MWB,


    // -------- Write sources --------
    input  wire [7:0]  ALU_out,
    input  wire [7:0]  IN_port,
    input  wire [7:0]  DataMemory_out,
    input  wire [7:0]  RFout1,
    input  wire [7:0]  imm,

    output wire [7:0]  readDataA,   // A operand
    output wire [7:0]  readDataB    // B operand
);
    // 4 registers of 8 bits
    reg [7:0] R[0:3];
    reg [7:0] writeData;       // Data to write
  
    reg  [1:0]  readAddressA;          // Read port A address
    reg  [1:0]  readAddressB;          // Read port B address 
    wire [1:0]  writeAddress;    // Destination register
    
    assign writeAddress = (writeAddressSel)  ? Rb_MWB : Ra_MWB;

     always @(*) begin
        case (readAddressBSel)
            2'b00: readAddressB = Ra; // R[ra]
            2'b01: readAddressB = Rb; // R[rb]
            2'b10: readAddressB = 2'b11; // R3(sp)
            default: readAddressB = 2'b01;
        endcase
    end
     always @(*) begin
        case (readAddressASel)
            2'b00: readAddressA = Ra; // R[ra]
            2'b01: readAddressA = Rb; // R[rb]
            2'b10: readAddressA = 2'b11; // R3(sp)
            default: readAddressA = 2'b00;
        endcase
    end

    always @(*) begin
        case (writePortSel)
            3'b000: writeData = ALU_out;
            3'b001: writeData = IN_port;
            3'b010: writeData = DataMemory_out;
            3'b011: writeData = RFout1;
            3'b100: writeData = imm;
            default: writeData = 8'd0;
        endcase
    end

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 3; i = i + 1)
                R[i] <= 8'd0;
            R[3] <= 8'd255; 
        end
        else begin
             if (writeEnable && writeAddress != 2'b11) R[writeAddress] <= writeData;   // write only when enabled , the second check is for 
                                                                                       // give sp write higher priority if they come together
             if (spWriteEnable) R[3] <= spWriteData; 
        end  
  end
    assign readDataA = R[readAddressA];
    assign readDataB = R[readAddressB];
endmodule
