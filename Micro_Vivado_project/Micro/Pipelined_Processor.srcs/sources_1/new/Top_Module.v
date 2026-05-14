
module Top_Module(
    input wire clk,
    input wire reset,
    input wire interrupt,
    input wire [7:0] IN_PORT,
    output reg [7:0] OUT_PORT
    );

        
    wire pcEnable;
    wire pcFlush;
    wire ifIdEnable;
    wire ifIdFlush;
    wire idExEnable;
    wire idExFlush;
    
    wire [7:0] ALU_result;
    wire [3:0] ALU_flags_out;
    wire [3:0] CCR_flags_out; 
    wire       DMwrite_out_EXM;
    wire [2:0] SAdd_CU, SAdd_DEX, SAdd_EXM;
    wire       SData_CU, SData_DEX, SData_EXM;
    wire [7:0] RF1_out_EXM;
    wire [7:0] RF2_out_EXM;
    wire [7:0] ALU_result_out_EXM;
    wire [7:0] reset_interrupt_target;
    wire [7:0] RF1_out_DEX; // from DEX to jump
    wire [7:0] return;
    wire [2:0] PCSrc;
    wire [7:0] PC;
    wire [7:0] PC_plus1;
    
    wire [2:0] jump_target_Scr; // from jump unit
    wire       jump_now; // from jump unit
    
    wire [1:0] storeAddressSelect;
    wire [1:0] storeDataSelect;
    
    wire [7:0] PC_plus1_out_EXM;
    wire waitingForPCFromMem;
    wire pcFromMemValid;
    
    wire [7:0]  imm_MWB;
    
    wire  [7:0] inst_Out;
    
    wire valid_out;
    wire  [7:0] Data_Memory_Out;
    
    PC PC_unit (
    .clk(clk),
    .PC_E(pcEnable),                        // PC Enable Active High 0 for stall
    .PC_F(pcFlush),                        // PC Flash Active High 
    .Reset(reset),                   // Active high reset
    .reset_interrupt_target(inst_Out),
    .jump(RF1_out_DEX),                      // jump target
    .return(Data_Memory_Out),                  // return target (old PC)
    .PCSrc(PCSrc),
    .PC_next(PC),
    .PC_plus1(PC_plus1),
    
    .jump_target_Scr(jump_target_Scr),
    .jump_now(jump_now)
    );
    //////////////////////////////////////////////////////////////////////////////
    
    
    
    wire  [7:0] ALU_result_out_MWB;      // from M_WB reg
    wire  [7:0] DataMem_out_MWB;         // from M_WB reg
    
    wire  [7:0] idExImm;
    wire        return_inst;
    wire [7:0] imm;
    
    Von_Neumann_Mem Memory (
    .clk(clk),      // input Clock signal 
    .reset(reset),
    .interrupt(interrupt),
	
	.pcFromMemValid(pcFromMemValid),
	.waitingForPCFromMem(waitingForPCFromMem),
	
	.SData(SData_EXM),     // Write Data MUX select
    .DMwrite(DMwrite_out_EXM),   // Data port Write enable
	.SAdd(SAdd_EXM), // Address MUX select
            
	.PC(PC),                 // instruction Address Bus (only 128 byte)
	.PC_plus1_E_M(PC_plus1_out_EXM), // PC + 1  From EXM
    .ALU_out(ALU_result_out_EXM),  
    .RF_out1(RF1_out_EXM),         
    .RF_out2(RF2_out_EXM),
    .imm(imm), // Could be changed
    
    .return_inst(return_inst),
    .ALU_SP_Direct(ALU_result),
    
    .storeAddressSelect(storeAddressSelect),  
    .storeDataSelect(storeDataSelect),
    
    .memWbAluResult(ALU_result_out_MWB),
    .memWbMemoryData(DataMem_out_MWB),
	
    .Data_Memory_Out(Data_Memory_Out), // Output Data Bus
    .inst_Out(inst_Out)         // Output instruction Bus
    );
    ///////////////////////////////////////////////////////////////////////
    wire  [7:0] PC_plus1_out_IF_ID;
    wire  [7:0] inst_mem_out;
    wire       isTwoByteInstr;
    wire  [7:0] ifIdImm;
    wire        ifIdHasImm;
    wire        Flush_DEX;
    
    IF_ID FD (
    .clk(clk),
    .enable(ifIdEnable),
    .flush(ifIdFlush),
    .Flush_DEX(Flush_DEX),
    .isTwoByteInstr(isTwoByteInstr),
    
    .PC_plus1_IF_ID(PC_plus1),
    .inst_mem_in(inst_Out),
    
    .PC_plus1_out_IF_ID(PC_plus1_out_IF_ID),
    .inst_mem_out(inst_mem_out),
    
    .ifIdImm(ifIdImm),
    .ifIdHasImm(ifIdHasImm)
    );
    /////////////////////////////////////////////////////////////////////////////////////
    wire ZF;
    wire NF;
    wire VF;
    wire CF;
    wire  [2:0]  writePortSel;       // Write port selection
    wire         writeAddressSel;    // 0: Ra , 1: Rb
    wire  [1:0]  readAddressASel;    // 0: Ra , 1: Rb  , 11:SP
    wire  [1:0]  readAddressBSel;    // 0: Ra , 1: Rb  , 11:SP
    wire         spWriteEnable;    
    
    wire [3:0] ALUControl; // wait for real size
    wire       ALUSrc;     // wait for real size   
    wire       RFwrite;
    wire       DMwrite;
    
    wire       CCR_WE;
    
    wire [1:0] sourceRegister1;
    wire [1:0] sourceRegister2;
    wire       useSourceRegister1;
    wire       useSourceRegister2;
    wire [1:0] destinationRegister;
    wire       IsLoadInstruction;
    wire       restore_int;
    
    
    
    Control_Unit CU (
    .op_code(inst_mem_out[7:4]),
    .ra(inst_mem_out[3:2]),
    .rb(inst_mem_out[1:0]),
    .reset(reset),
    .interrupt(interrupt),
    .ZF(CCR_flags_out[0]), // zero flag
    .NF(CCR_flags_out[1]), // negative flag
    .CF(CCR_flags_out[2]), // carry flag
    .VF(CCR_flags_out[3]), // overflow flag
    .restore_int(restore_int),
    .isTwoByteInstr(isTwoByteInstr),
    
    .valid_out(valid_out),
    
    .writePortSel(writePortSel),       // Write port selection
    .readAddressASel(readAddressASel),    // 0: Ra , 1: Rb
    .writeAddressSel(writeAddressSel),    // 0: Ra , 1: Rb
    .readAddressBSel(readAddressBSel),    // 0: Ra , 1: Rb  , 11:SP
    .spWriteEnable(spWriteEnable),  
   
    .ALUControl(ALUControl), // wait for real size
    .ALUSrc(ALUSrc),   // wait for real size
    .PCSrc(PCSrc),   
    .RFwrite(RFwrite),
    .DMwrite(DMwrite),
    .SAdd(SAdd_CU),
    .SData(SData_CU),
    .CCR_WE(CCR_WE),
    
    .IsLoadInstruction(IsLoadInstruction),
    
    .sourceRegister1(sourceRegister1),
    .sourceRegister2(sourceRegister2),
    .useSourceRegister1(useSourceRegister1),
    .useSourceRegister2(useSourceRegister2),
    .destinationRegister(destinationRegister)
    );
    /////////////////////////////////////////////////////////////////////////////////
    wire        RFwrite_out_MWB;         // from M_WB reg
    wire  [2:0] writePortSel_out_MWB;    // from M_WB reg
    wire        writeAddressSel_out_MWB; // from M_WB reg
    wire        spWriteEnable_out_MWB;   // from M_WB reg
    
    wire        IsLoadInstruction_DEX;  
    
    
    wire  [7:0] RF1_out_MWB;             // from M_WB reg
    wire  [7:0] RF2_out_MWB;             // from M_WB reg
    
    wire  [1:0] Ra_MWB;
    wire  [1:0] Rb_MWB;
    
    wire [7:0]  readDataA;   // A operand
    wire [7:0]  readDataB;   // B operand
      
    RegisterFile RF (
    .clk(clk),
    .rst(reset),         // optional reset
    .writeEnable(RFwrite_out_MWB),
    .writePortSel(writePortSel_out_MWB),        // Write port selection
    .writeAddressSel(writeAddressSel_out_MWB),    // 0: Ra , 1: Rb
    
    .imm(imm_MWB),
    
    .readAddressASel(readAddressASel),    // 0: Ra , 1: Rb
    .readAddressBSel(readAddressBSel),    // 0: Ra , 1: Rb  , 11:SP

    .spWriteEnable(spWriteEnable_out_MWB),    
    .spWriteData(ALU_result_out_MWB),     // Data to write(in R3 only)

    // -------- Address sources --------
    .Ra(inst_mem_out[3:2]),
    .Rb(inst_mem_out[1:0]),
    .Ra_MWB(Ra_MWB),
    .Rb_MWB(Rb_MWB),

    // -------- Write sources --------
    .ALU_out(ALU_result_out_MWB),
    .IN_port(IN_PORT),
    .DataMemory_out(DataMem_out_MWB),
    .RFout1(RF1_out_MWB),

    .readDataA(readDataA),   // A operand
    .readDataB(readDataB)    // B operand
    );
    //////////////////////////////////////////////////////////////////////////////////////////////////
    wire  [1:0] ra_out_DEX;
    wire  [1:0] rb_out_DEX;
    
    wire  [7:0] RF2_out_DEX; 
    wire  [7:0] PC_plus1_out_DEX;
    wire  [3:0] alu_op_out_DEX;  // ADDED
    
    wire  [2:0]  writePortSel_out_DEX;       // Write port selection
    wire         writeAddressSel_out_DEX;    // 0: Ra , 1: Rb
    wire         spWriteEnable_out_DEX;
    
    wire       ALUSrc_out_DEX;     // wait for real size  
    wire       RFwrite_out_DEX;
    wire       DMwrite_out_DEX;
    wire       CCR_WE_out;
    
    wire [3:0] op_code_out;
    
    wire [1:0] sourceRegister1_out;
    wire [1:0] sourceRegister2_out;
    wire       useSourceRegister1_out;
    wire       useSourceRegister2_out;
    wire [1:0] destinationRegister_out;
    
    wire [1:0] destinationRegister_EXM;
    wire [1:0] destinationRegister_MWB;
    
    wire [1:0] aluInputASelect;
    wire [1:0] aluInputBSelect;
    
    wire       RFwrite_out_EXM;
   // wire       RFwrite_out_MWB; (above)
   
    wire       IsLoadInstruction_MWB;
    
    wire [1:0] sourceRegister1_EXM;  
    wire [1:0] sourceRegister2_EXM;  
    
    
    wire        idExHasImm;
    wire        valid_out_DEX;
    
    
    
    D_EX DEX (
    .clk(clk), 
    .enable(idExEnable), 
    .flush(idExFlush),
    .op_code(inst_mem_out[7:4]),
    
    .valid_out(valid_out),
    .valid_out_DEX(valid_out_DEX),
    
    .ra(inst_mem_out[3:2]),
    .rb(inst_mem_out[1:0]),
    .RF1(readDataA),
    .RF2(readDataB),
    .PC_plus1(PC_plus1_out_IF_ID),
    .alu_op(ALUControl),  // ADDED
    .writePortSel(writePortSel),       // Write port selection
    .writeAddressSel(writeAddressSel),    // 0: Ra , 1: Rb
    .spWriteEnable(spWriteEnable),
    
    .ALUSrc(ALUSrc),     
    .RFwrite(RFwrite),
    .DMwrite(DMwrite),
    .CCR_WE(CCR_WE),
    .IsLoadInstruction(IsLoadInstruction),
    
    .ifIdImm(ifIdImm),
    .ifIdHasImm(ifIdHasImm),
    
    .idExImm(idExImm),
    .idExHasImm(idExHasImm),
    
    .sourceRegister1(sourceRegister1),
    .sourceRegister2(sourceRegister2),
    .useSourceRegister1(useSourceRegister1),
    .useSourceRegister2(useSourceRegister2),
    .destinationRegister(destinationRegister),
    
    .op_code_out(op_code_out),
    .ra_out(ra_out_DEX),
    .rb_out(rb_out_DEX),
    .RF1_out(RF1_out_DEX), 
    .RF2_out(RF2_out_DEX), 
    .PC_plus1_out(PC_plus1_out_DEX),
    .alu_op_out(alu_op_out_DEX),  // ADDED
    
    .IsLoadInstruction_DEX(IsLoadInstruction_DEX),
    
    .writePortSel_out(writePortSel_out_DEX),       // Write port selection
    .writeAddressSel_out(writeAddressSel_out_DEX),    // 0: Ra , 1: Rb
    .spWriteEnable_out(spWriteEnable_out_DEX),
    .CCR_WE_out(CCR_WE_out),
    
    .ALUSrc_out(ALUSrc_out_DEX),     // wait for real size  
    .RFwrite_out(RFwrite_out_DEX),
    .DMwrite_out(DMwrite_out_DEX),
    .SAdd(SAdd_CU), .SData(SData_CU),         // Inputs
    .SAdd_out(SAdd_DEX), .SData_out(SData_DEX), // Outputs

    .sourceRegister1_out(sourceRegister1_out),
    .sourceRegister2_out(sourceRegister2_out),
    .useSourceRegister1_out(useSourceRegister1_out),
    .useSourceRegister2_out(useSourceRegister2_out),
    .destinationRegister_out(destinationRegister_out)
    );
    ///////////////////////////////////////////////////////////////////////////////////////////////
    Jump_Unit JU(
        .op_code_DEX(op_code_out),
        .ra_DEX(ra_out_DEX),
        .ZF_ALU(ALU_flags_out[0]), // zero flag from ALU
        
        .ZF(CCR_flags_out[0]), // zero flag
        .NF(CCR_flags_out[1]), // negative flag
        .CF(CCR_flags_out[2]), // carry flag
        .VF(CCR_flags_out[3]), // overflow flag
    
        .jump_now(jump_now),
        .jump_target_Scr(jump_target_Scr),
        .return_inst(return_inst)
    );
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    Forward_Unit FU (
    // Inputs from D/EX pipeline register (current instruction)
        .idExSourceRegister1(sourceRegister1_out),   // Index of first source register (rs1)
        .idExSourceRegister2(sourceRegister2_out),   // Index of second source register (rs2)
        .idExUseSourceRegister1(useSourceRegister1_out), // Indicates if the current instruction uses rs1
        .idExUseSourceRegister2(useSourceRegister2_out), // Indicates if the current instruction uses rs2
    // Inputs from EX/MEM pipeline register (previous instruction)
        .exMemRegisterWriteEnable(RFwrite_out_EXM), // High if previous instruction writes to a register (have a destination)
        .exMemDestinationRegister(destinationRegister_EXM), // Destination register index (rd) of EX/MEM stage
        //.exMemAluResult(ALU_result_out_EXM),           // ALU result from EX/MEM stage (available for forwarding)
    // Inputs from MEM/WB pipeline register (two instructions earlier)
        .memWbRegisterWriteEnable(RFwrite_out_MWB), // High if instruction in WB stage writes to a register (have a destination)
        .memWbDestinationRegister(destinationRegister_MWB), // Destination register index (rd) of MEM/WB stage
        .memWbWriteBackData(DataMem_out_MWB),        // Data that will be written back to the register file
        .IsLoadInstruction_MWB(IsLoadInstruction_MWB),
    // Outputs to ALU input multiplexers
        .aluInputASelect(aluInputASelect), // Select signal for ALU input A source
        .aluInputBSelect(aluInputBSelect), // Select signal for ALU input B source
        
        .isStoreInstruction_EXMEM(DMwrite_out_EXM),
        
        .exMemAddressRegister(sourceRegister1_EXM),
        .exMemDataRegister(sourceRegister2_EXM),
        .storeAddressSelect(storeAddressSelect),
        .storeDataSelect(storeDataSelect)
    );
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ALU ALU_unit (
    .RFout1(RF1_out_DEX),
    .RFout2(RF2_out_DEX),
    .A_sel(ALUSrc_out_DEX),
    .B_DEX(RF2_out_DEX),
    
    .exMemAluResult(ALU_result_out_EXM),
    .memWbWriteBackData_ALU(ALU_result_out_MWB),
    .memWbWriteBackData(DataMem_out_MWB),
    .alu_op(alu_op_out_DEX),
    .FLAGS_in(CCR_flags_out),
    
    .aluInputASelect(aluInputASelect),  // Select signal for ALU input A source
    .aluInputBSelect(aluInputBSelect),  // Select signal for ALU input B source
        
    .result(ALU_result),
    .flags_out(ALU_flags_out) // V,C,N,Z
    );
    
    
    CCR CCR_unit (
    .clk(clk),
    .rst(reset),           // Active high reset
    .we(CCR_WE_out),            // write from ALU
    .save_int(0),      // interrupt entry
    .restore_int(restore_int),   // return from interrupt
    .flags_in(ALU_flags_out),      // flags from ALU {V,C,N,Z}
    
    .flags_out(CCR_flags_out)
    );
    ////////////////////////////////////////////////////////////////////////
    wire [1:0] ra_out_EXM;
    wire [1:0] rb_out_EXM;
    
    
    wire [2:0] writePortSel_out_EXM;       // Write port selection
    wire       writeAddressSel_out_EXM;    // 0: Ra , 1: Rb
    wire       spWriteEnable_out_EXM;
    wire       IsLoadInstruction_EXM;
    
    wire       valid_out_EXM;
    
    
    
 // wire       DMwrite_out_EXM; Defined above

    wire [7:0] DataMem_out_EXM;    
    
    
    EX_MEM EXM (
    .clk(clk),
    .enable(1),
    .flush(0),
    
    .IsLoadInstruction_DEX(IsLoadInstruction_DEX),
    
    .valid_out_DEX(valid_out_DEX),
    .valid_out_EXM(valid_out_EXM),
    .ra(ra_out_DEX),
    .rb(rb_out_DEX),
    .RF1(RF1_out_DEX),
    .RF2(RF2_out_DEX),
    .PC_plus1(PC_plus1_out_DEX),
    
    .writePortSel(writePortSel_out_DEX),
    .writeAddressSel(writeAddressSel_out_DEX),
    .spWriteEnable(spWriteEnable_out_DEX),
    
    .sourceRegister1_DEX(sourceRegister1_out),
    .sourceRegister2_DEX(sourceRegister2_out),
    
    .sourceRegister1_EXM(sourceRegister1_EXM),
    .sourceRegister2_EXM(sourceRegister2_EXM),
    
    .RFwrite(RFwrite_out_DEX),
    .destinationRegister(destinationRegister_out),
    .DMwrite(DMwrite_out_DEX),
    .idExImm(idExImm),
    .ALU_result(ALU_result),
    .DataMem(Data_Memory_Out),     // 2 byte instruction case
    
    .IsLoadInstruction_EXM(IsLoadInstruction_EXM),
    
    .imm(imm),
    .ra_out(ra_out_EXM),
    .rb_out(rb_out_EXM),        
    .RF1_out(RF1_out_EXM),
    .RF2_out(RF2_out_EXM),
    .PC_plus1_out(PC_plus1_out_EXM),
    .writePortSel_out(writePortSel_out_EXM),       // Write port selection
    .writeAddressSel_out(writeAddressSel_out_EXM),    // 0: Ra , 1: Rb
    .spWriteEnable_out(spWriteEnable_out_EXM),
    .ALU_result_out(ALU_result_out_EXM),
    .DataMem_out(DataMem_out_EXM),
    .RFwrite_out(RFwrite_out_EXM),
    .DMwrite_out(DMwrite_out_EXM),
    .SAdd(SAdd_DEX), .SData(SData_DEX),        // Inputs
    .SAdd_out(SAdd_EXM), .SData_out(SData_EXM),// Outputs

    .destinationRegister_EXM(destinationRegister_EXM)
    );
    ////////////////////////////////////////////////////////////////////////////////
    
    
    MEM_WB MWB (
    .clk(clk),
    .enable(1),
    .flush(0),

    .ALU_result(ALU_result_out_EXM),
    .DataMem(Data_Memory_Out),
    
    .ra(ra_out_EXM),
    .rb(rb_out_EXM),
    .RF1(RF1_out_EXM),
    .RF2(RF2_out_EXM),
    .writePortSel(writePortSel_out_EXM),       // Write port selection
    .writeAddressSel(writeAddressSel_out_EXM),    // 0: Ra , 1: Rb
    .spWriteEnable(spWriteEnable_out_EXM),
    .RFwrite(RFwrite_out_EXM),
    .destinationRegister(destinationRegister_EXM),
    .IsLoadInstruction_EXM(IsLoadInstruction_EXM),
    
    .ra_out(Ra_MWB),
    .rb_out(Rb_MWB),
    .RF1_out(RF1_out_MWB),
    .RF2_out(RF2_out_MWB),
    .writePortSel_out(writePortSel_out_MWB),       // Write port selection
    .writeAddressSel_out(writeAddressSel_out_MWB),    // 0: Ra , 1: Rb
    .spWriteEnable_out(spWriteEnable_out_MWB),
    .RFwrite_out(RFwrite_out_MWB),
    .IsLoadInstruction_MWB(IsLoadInstruction_MWB),
    .destinationRegister_MWB(destinationRegister_MWB),
    
    .imm(imm),
    .imm_MWB(imm_MWB),
    .ALU_result_out(ALU_result_out_MWB),
    .DataMem_out(DataMem_out_MWB)
    );
    

    Hazard_Unit HU(
        .reset(reset),   
        .interrupt(interrupt), 
        .idExMemReadEnable(IsLoadInstruction_DEX),   // EX stage instruction is LOAD
        .idExDestinationReg(destinationRegister_out),  // Destination register of LOAD

        .ifIdSourceReg1(sourceRegister1),      // Source register 1 in ID stage
        .ifIdSourceReg2(sourceRegister2),      // Source register 2 in ID stage
        .ifIdUseSourceReg1(useSourceRegister1),    // Does ID instruction use rs1?
        .ifIdUseSourceReg2(useSourceRegister2),    // Does ID instruction use rs2?
        //.isTwoByteInstr(isTwoByteInstr),
        //.ifIdHasImm(ifIdHasImm),
        .Flush_DEX(Flush_DEX),
        // Control hazard
        .branchTaken(jump_now),          // Branch or jump is taken
    
        // ============================
        // Outputs
        // ============================
    
        .pcEnable(pcEnable),
        .pcFlush(pcFlush),
    
        .ifIdEnable(ifIdEnable),
        .ifIdFlush(ifIdFlush),
    
        .idExEnable(idExEnable),
        .idExFlush(idExFlush)
    );

    ////////////////////////////////////////////////////////////////////////////////////////////
   // Use a sequential block to "hold" the value 
       always @(posedge clk) begin
           if (reset) begin
               OUT_PORT <= 8'h00; // Clear output on reset
           end 
           else if (valid_out_EXM == 1) begin
               OUT_PORT <= ALU_result_out_EXM; 
           end
       end
    
  
endmodule
