
module Control_Unit(
    input wire [3:0] op_code,
    input wire [1:0] ra,
    input wire [1:0] rb,
    input wire       reset,
    input wire       interrupt,
    
    input wire       ZF, // zero flag
    input wire       NF, // negative flag
    input wire       VF, // overflow flag
    input wire       CF, // carry flag
    
    output reg  [2:0]  writePortSel,       // Write port selection
    output reg         writeAddressSel,    // 0: Ra , 1: Rb
    output reg  [1:0]  readAddressASel,    // 0: Ra , 1: Rb  , 11:SP
    output reg  [1:0]  readAddressBSel,    // 0: Ra , 1: Rb  , 11:SP
    output reg         spWriteEnable,    
    output reg         IsLoadInstruction,    
    
    output reg [3:0] ALUControl, 
    output reg       ALUSrc,     
    
    output reg       isTwoByteInstr,
    
    output reg       CCR_WE, // CCR write enable
    output reg [2:0] PCSrc,   
    output reg       RFwrite,
    output reg       DMwrite,
    output reg [2:0] SAdd,
    output reg 	     SData,
    output reg 	     valid_out,
    
    output reg restore_int,
    
    // Forward
    //output       registerWriteEnable, -> RFwrite
    output reg [1:0] sourceRegister1,
    output reg [1:0] sourceRegister2,
    output reg       useSourceRegister1,
    output reg       useSourceRegister2,
    output reg [1:0] destinationRegister
    );
    
    always@(*)
    begin
        // DEFAULT VALUES
        ALUControl = 4'd0;
        ALUSrc     = 3'd0;
        PCSrc      = 2'd1;   // default PC + 1
        RFwrite    = 1'b0;
        DMwrite    = 1'b0;
        
        valid_out = 0;
        
        isTwoByteInstr=0;
        
        readAddressASel = 1'b0;
        writeAddressSel = 1'b0;
        readAddressBSel = 2'b00;
        spWriteEnable   = 1'b0;
        IsLoadInstruction = 1'b0;
        
        SAdd = 2'b00;
        SData = 1'b0;
        
        CCR_WE = 1'b0;
        restore_int = 1'b0;
        
        sourceRegister1 = 2'b00;
        sourceRegister2 = 2'b00;
        
        useSourceRegister1 = 1'b0;
        useSourceRegister2 = 1'b0;
        
        destinationRegister = 2'b00;
        
        writePortSel = 0;
         
        if(reset) PCSrc = 0;
        else if(interrupt) begin 
            PCSrc = 0;
            
        end
        else
        begin
            case(op_code)
            4'b0000: begin           //NOP
                ALUControl = 4'd0;   // NOP
                PCSrc = 1;           // PCSrc choose PC+1
                ALUSrc = 1'b0;       //! R[ra], R[rb] (Arbitrary for NOP)
                RFwrite    = 1'b0;
                DMwrite    = 1'b0;
            end
            4'b0001: begin //MOV
                PCSrc = 1;        // PCSrc choose PC+1
                ALUControl = 4'd0;   // NOP
                
                RFwrite = 1;      //write in RF
                writeAddressSel = 0;     // ra
                readAddressASel = 1;     // rb
                readAddressBSel = 1;     // rb
                writePortSel = 3;
                ALUSrc = 1'b0;       
                DMwrite    = 1'b0;
                ALUControl = 4'd0;
                
                // Forward
                sourceRegister1 = rb;
                sourceRegister2 = rb;
        
                useSourceRegister1 = 1'b1;
                useSourceRegister2 = 1'b1;
        
                destinationRegister = ra;
            end
            4'b0010: begin //ADD
                ALUControl = 4'd1;   // ADD
                PCSrc = 1; // PCSrc choose PC+1
                RFwrite = 1; //write in RF
                ALUSrc = 0; 
                DMwrite    = 1'b0;
                writeAddressSel = 0;     // ra
                readAddressASel = 0;     // ra
                readAddressBSel = 1;     // rb
                writePortSel = 0;
                CCR_WE = 1;
                
                // Forward
                sourceRegister1 = ra;
                sourceRegister2 = rb;
        
                useSourceRegister1 = 1'b1;
                useSourceRegister2 = 1'b1;
        
                destinationRegister = ra;
            end
            4'b0011: begin //SUB
                ALUControl = 4'd2;
                PCSrc = 1; // PCSrc choose PC+1
                RFwrite = 1; //write in RF
                ALUSrc = 0; 
                DMwrite    = 1'b0;
                writeAddressSel = 0;     // ra
                readAddressASel = 0;     // ra
                readAddressBSel = 1;     // rb
                writePortSel = 0;
                CCR_WE = 1;
                
                // Forward
                sourceRegister1 = ra;
                sourceRegister2 = rb;
        
                useSourceRegister1 = 1'b1;
                useSourceRegister2 = 1'b1;
        
                destinationRegister = ra;
            end
            4'b0100: begin //AND
                ALUControl = 4'd3;
                PCSrc = 1; // PCSrc choose PC+1
                RFwrite = 1; //write in RF
                ALUSrc = 0; 
                DMwrite    = 1'b0;
                writeAddressSel = 0;     // ra
                readAddressASel = 0;     // ra
                readAddressBSel = 1;     // rb
                writePortSel = 0;
                CCR_WE = 1;
                
                // Forward
                sourceRegister1 = ra;
                sourceRegister2 = rb;
        
                useSourceRegister1 = 1'b1;
                useSourceRegister2 = 1'b1;
        
                destinationRegister = ra;
            end
            4'b0101: begin //OR
                ALUControl = 4'd4;
                PCSrc = 1; // PCSrc choose PC+1
                RFwrite = 1; //write in RF
                ALUSrc = 0; 
                DMwrite    = 1'b0;
                writeAddressSel = 0;     // ra
                readAddressASel = 0;     // ra
                readAddressBSel = 1;     // rb
                writePortSel = 0;
                CCR_WE = 1;
                
                // Forward
                sourceRegister1 = ra;
                sourceRegister2 = rb;
        
                useSourceRegister1 = 1'b1;
                useSourceRegister2 = 1'b1;
        
                destinationRegister = ra;
            end
            4'b0110: begin //RLC . RRC . SETC . CLRC
                case(ra)
                    2'b00: begin 
                        ALUControl = 4'd5; // RLC
                        PCSrc = 1; // PCSrc choose PC+1
                        RFwrite = 1; //write in RF
                        ALUSrc = 0; 
                        DMwrite    = 1'b0;
                        writeAddressSel = 1;     // rb
                        readAddressASel = 1;     // rb
                        readAddressBSel = 1;     // rb
                        writePortSel = 3'b000; //
                        CCR_WE = 1;
                        
                        // Forward
                        sourceRegister1 = rb;
                        sourceRegister2 = rb;
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = rb;
                    end 
                    2'b01: begin 
                        ALUControl = 4'd6; // RRC
                        PCSrc = 1; // PCSrc choose PC+1
                        RFwrite = 1; //write in RF
                        ALUSrc = 0; 
                        DMwrite    = 1'b0;
                        writeAddressSel = 1;     // rb
                        readAddressASel = 1;     // rb
                        readAddressBSel = 1;     // rb
                        writePortSel = 3'b000; //
                        CCR_WE = 1;
                        
                        // Forward
                        sourceRegister1 = rb;
                        sourceRegister2 = rb;
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = rb;
                    end
                    2'b10: begin 
                        //SETC 
                        ALUControl = 4'd11;
                        PCSrc = 1;
                        RFwrite = 0;
                        ALUSrc = 0;
                        DMwrite = 1'b0;
                        CCR_WE = 1;
                        
                        // Forward
                        useSourceRegister1 = 1'b0;
                        useSourceRegister2 = 1'b0;

                    end 
                    2'b11: begin 
                        // CLRC  
                        ALUControl = 4'd12;
                        PCSrc = 1;
                        RFwrite = 0;
                        ALUSrc = 0;
                        DMwrite = 1'b0;
                        CCR_WE = 1;
                        
                        // Forward
                        useSourceRegister1 = 1'b0;
                        useSourceRegister2 = 1'b0;
                    end 
                endcase
            end
            4'b0111: begin //PUSH . POP . OUT . IN
                case(ra)
                    2'b00:begin 

                        PCSrc = 1;
                        DMwrite = 1;
                        spWriteEnable = 1; // send to forward too
                        RFwrite = 0;
        
                        ALUControl = 4'd10; // DEC operation (B - 1)
                        ALUSrc = 1'b1;      // Select RF2 (Port B) for ALU input B
        
                        readAddressASel = 2'b01; // 01 = Rb
                        readAddressBSel = 2'b10; //  SP
        
                        SAdd  = 3'b011;     // Select RF_out2 (SP) as Address
                        SData = 1'b0;       // Select RF_out1 (Rb) as Data
                        
                        // Forward
                        sourceRegister1 = rb;
                        sourceRegister2 = 3;  // DEC SP
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = 3;
                    end 
                    2'b01: begin // POP 
                    
                       PCSrc = 1;
                       DMwrite = 0;      
                       spWriteEnable = 1;  
                       RFwrite = 1;       
                
                       ALUControl = 4'd9;  // INC 
                       ALUSrc = 1'b1;      // Select SP on Port B
                
                       readAddressBSel = 2'b10; // Read SP
                       writeAddressSel = 1'b1;
                       writePortSel    = 3'b010; 
        
                       SAdd  = 3'b001;     // Address = ALU_out
                       SData = 1'b0;
                       
                       // Forward
                        sourceRegister1 = 3;  // INC SP
                        sourceRegister2 = 3;  // INC SP
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = rb;
                    end 
                    2'b10: begin // OUT (ra = 2) 
                        PCSrc = 1;
                        RFwrite = 0;
                        ALUControl = 4'd3;
                        
                        readAddressASel = 2'b01; 
                        readAddressBSel = 2'b01; 
                        
                        valid_out = 1;
                        
                       // Forward
                        sourceRegister1 = rb;  
                        sourceRegister2 = rb;  
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                    end
                    2'b11: begin // IN (ra = 3) 
                        PCSrc = 1;
                        RFwrite = 1;
                        writeAddressSel = 1; // rb
                        writePortSel = 3'b001;
                    end
                endcase
            end
            4'b1000: begin // NOT, NEG, INC, DEC  
                PCSrc = 1;
                RFwrite = 1;
                writeAddressSel = 1;
                readAddressBSel = 1;
                writePortSel = 3'b000;
                ALUSrc = 0;
                
                // Forward
                        sourceRegister1 = rb;
                        sourceRegister2 = rb;
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = rb;
                case(ra)
                    2'b00: begin
                    ALUControl = 4'd7;  // NOT
                    CCR_WE = 1;
                    end
                    2'b01: begin 
                    ALUControl = 4'd8;  // NEG
                    CCR_WE = 1;
                    end
                    2'b10: begin
                    ALUControl = 4'd9;  // INC
                    CCR_WE = 1;

                    end
                    2'b11: begin
                    ALUControl = 4'd10; // DEC
                    CCR_WE = 1;

                    end
                endcase
            end
            4'b1001: begin //JZ . JN . JC . JV
                PCSrc = 1; // PCSrc choose PC+1 (static prediction)
                ALUControl = 4'd0; //! NOP
                readAddressASel = 1; // rb
                
                // Forward
                        sourceRegister1 = rb;
                        sourceRegister2 = rb;
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = rb;
                
            end
            4'b1010: begin //!LOOP
                PCSrc = 1;
                RFwrite = 1;
                writeAddressSel = 0; // ra
                readAddressASel = 1; // rb
                readAddressBSel = 0; // ra to DEC
                writePortSel = 3'b000;
                ALUSrc = 0;
                ALUControl = 4'd10; // DEC
                CCR_WE = 1;
                
                // Forward
                        sourceRegister1 = rb;
                        sourceRegister2 = ra;
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = ra; 
            end
            ////////////////////////////////////////////////////////////
            4'b1011: begin //JUMP . CALL . RET . RTI
            PCSrc = 1; // must be flushed 
                case(ra)
                    2'b00: begin
                        readAddressASel = 1; // rb
                        readAddressBSel = 1; // rb
                        
                        // Forward
                        sourceRegister1 = rb;
                        sourceRegister2 = rb;
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = rb; 
                    end
                    2'b01: begin // CALL
                        PCSrc = 1;          // The Jump_Unit will override this with the jump target
                        DMwrite = 1;        // MUST be 1 to write to memory
                        spWriteEnable = 1;  // Update SP (decrement)
                        RFwrite = 0;
                        ALUControl = 4'd10; // DEC (SP - 1)
                        ALUSrc = 1'b1;      // Select ALU B (SP)
                        readAddressASel = 2'b01; // R[rb]
                        readAddressBSel = 2'b10; // Read current SP
                        SAdd = 3'b011;      // Use current SP as the memory address
                        SData = 1'b1;      //  Select PC+1 as the data to write
                        
                        // Forward
                        sourceRegister1 = rb;
                        sourceRegister2 = 3;
                
                        useSourceRegister1 = rb;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = 3; 
                    end
                    2'b10: begin // RET
          	       readAddressASel = 2'b10;   // Select SP (R3) as ALU Input A
          	       readAddressBSel = 2'b10;   // Select SP (R3) as ALU Input B
  		           ALUSrc          = 3'b000;  
   		           ALUControl      = 4'd9;   // ALU Operation: iNC 
  		           spWriteEnable   = 1'b1;    
        	       writePortSel    = 3'b000;   // Write source is ALU_out (SP + 1)
      		       RFwrite         = 1'b0;    // Don't write to general registers 
     		       DMwrite         = 1'b0;    
     		       SAdd            = 3'b101;  // Mem Address = ALU_out (which is SP - 1)
     		       
     		       // Forward
                        sourceRegister1 = 3;
                        sourceRegister2 = 3;
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = 3;
                        
		           PCSrc = 4; // if jump unit didnot give the pcsrc
		           end
                    2'b11: begin // RTI
          	       readAddressASel = 2'b10;   // Select SP (R3) as ALU Input A
          	       readAddressBSel = 2'b10;   // Select SP (R3) as ALU Input B
  		           ALUSrc          = 3'b000;  
   		           ALUControl      = 4'd9;   // ALU Operation: iNC 
  		           spWriteEnable   = 1'b1;    
        	       writePortSel    = 3'b000;   // Write source is ALU_out (SP + 1)
      		       RFwrite         = 1'b0;    // Don't write to general registers 
     		       DMwrite         = 1'b0;    
     		       SAdd            = 3'b101;  // Mem Address = ALU_out (which is SP - 1)
	               restore_int     = 1'b1;    // ENABLE RESTORE
		           CCR_WE = 1;
		           // Forward
                        sourceRegister1 = 3;
                        sourceRegister2 = 3;
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = 3;
		           
                   PCSrc = 4; // if jump unit didnot give the pcsrc
		    end
                endcase  
            end
            4'b1100: begin //LDM . LDD . STD
                PCSrc = 1; //PCSrc choose PC+2
                isTwoByteInstr = 1;
                ALUControl = 4'd1; //! ADD: R[rb] + Immediate
                ALUSrc = 3'b100;   //! ALU A = R[rb], ALU B = Immediate
                case(ra)
                    2'b00: begin 
                    RFwrite = 1; //write in RF //! LDM
                    IsLoadInstruction = 1;
                   // SData = 1; // add = PC + 1
                    //SAdd = 4; // imm
                    
                    writePortSel = 4;
                    writeAddressSel = 1; // rb
                    
                    // Forward
                        sourceRegister1 = ra;
                        sourceRegister2 = rb;
                
                        useSourceRegister1 = 1'b0;
                        useSourceRegister2 = 1'b0;
                
                        destinationRegister = rb;
                    end
                    2'b01: begin 
                    RFwrite = 1; //write in RF // LDD
                    IsLoadInstruction = 1;
                    SAdd = 4;
                    writePortSel = 2;
                    writeAddressSel = 1; // rb
                    // Forward
                        sourceRegister1 = ra;
                        sourceRegister2 = rb;
                
                        useSourceRegister1 = 1'b0;
                        useSourceRegister2 = 1'b0;
                
                        destinationRegister = rb;
                    end
                    
                    2'b10: begin 
                    DMwrite = 1; //write in DM // STD
                    RFwrite = 0;  
                       
                        SData = 0; // add = PC + 1
                        SAdd = 4; // imm
                        readAddressASel = 1; // rb
                        readAddressBSel = 1; // rb
                    // Forward
                        sourceRegister1 = rb;
                        sourceRegister2 = rb;
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = rb;
                    end
                    default: begin
                        
                    end
                endcase 
            end
            4'b1101: begin // LDI: R[rb] = Memory[R[ra]]
                PCSrc           = 3'd1;    // PC = PC + 1
                RFwrite         = 1'b1;    // Enable writing to Register File
                writeAddressSel = 1'b1;    // Select Rb as the destination register
                writePortSel    = 3'b010;   // Select Data_Memory_Out as the write source
                SAdd            = 3'b010;  // Select RF_out1 (R[ra]) as the Memory Address
                SData           = 1'b0;    // (Default) Not writing to memory
                DMwrite         = 1'b0;    // (Default) Ensure Data Memory write is disabled
                
                IsLoadInstruction = 1;
                
                // Forward
                        sourceRegister1 = ra;
                        sourceRegister2 = rb;
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b0;
                
                        destinationRegister = rb;
            end
            4'b1110: begin // STI: M[R[ra]] = R[rb]
                PCSrc           = 1;
                DMwrite         = 1;
                RFwrite         = 0;
                
                readAddressASel = 2'b01;  // R[rb]
                readAddressBSel = 2'b00;  // Put Ra on the output bus
                SAdd            = 3'b011; // Use Ra as the memory address
                SData           = 2'b00;  // Use Rb as the memory data
                
                ALUControl      = 4'd0;   
                ALUSrc          = 3'b000;
                
                // Forward
                        sourceRegister1 = ra; // Address
                        sourceRegister2 = rb; // Dara
                
                        useSourceRegister1 = 1'b1;
                        useSourceRegister2 = 1'b1;
                
                        destinationRegister = rb; // any thing 
            end
            default: begin
                ALUControl = 4'd0;   // NOP
                PCSrc = 1; // PCSrc choose PC+1
                ALUSrc = 3'b000; // R[ra], R[rb] (Arbitrary for NOP)
            end
        endcase
        end
        
    end
endmodule