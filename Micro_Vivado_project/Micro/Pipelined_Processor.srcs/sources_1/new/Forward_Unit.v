module Forward_Unit(
    // ============================
    // Inputs from ID/EX stage
    // ============================

    input [1:0] idExSourceRegister1,
    input [1:0] idExSourceRegister2,

    input       idExUseSourceRegister1,
    input       idExUseSourceRegister2,

    // ============================
    // Inputs from EX/MEM stage
    // ============================

    input       exMemRegisterWriteEnable,
    input [1:0] exMemDestinationRegister,
    input [7:0] exMemAluResult,          // (used outside by mux)
    
    // ============================
    // Inputs from MEM/WB stage
    // ============================

    input       memWbRegisterWriteEnable,
    input [1:0] memWbDestinationRegister,
    input [7:0] memWbWriteBackData,       // (used outside by mux)
    input       IsLoadInstruction_MWB,     // 1 if MEM/WB instruction is LOAD

    // ============================
    // Outputs
    // ============================

    output reg [1:0] aluInputASelect,
    output reg [1:0] aluInputBSelect,
    
    
    
    input       isStoreInstruction_EXMEM,   // STORE or STI

    input [1:0] exMemAddressRegister,       // Ra (source 1 for store)
    input [1:0] exMemDataRegister,          // Rb (source 2 for store)

    // ============================
    // MEM/WB stage
    // ============================

    //input       memWbRegisterWriteEnable,
    //input [1:0] memWbDestinationRegister,

    //input [7:0] memWbAluResult,
    //input [7:0] memWbMemoryData,
    //input       IsLoadInstruction_MWB,

    // ============================
    // Outputs
    // ============================

    output reg [1:0] storeAddressSelect,
    output reg [1:0] storeDataSelect
);

always @(*) begin
    // ============================
    // Default: no forwarding
    // ============================

    aluInputASelect = 2'b00;   // from register file
    aluInputBSelect = 2'b00;

     // =================================================
    // ALU input A (Source Register 1)
    // =================================================

    // -------- EX/MEM forwarding (ALU result only) --------
    if (idExUseSourceRegister1 &&
        exMemRegisterWriteEnable &&
        (exMemDestinationRegister == idExSourceRegister1)) begin

        aluInputASelect = 2'b10;
    end

    // -------- MEM/WB forwarding (ALU or LOAD result) -----
    else if (idExUseSourceRegister1 &&
             memWbRegisterWriteEnable &&
             (memWbDestinationRegister == idExSourceRegister1)) begin

        if (IsLoadInstruction_MWB)
            aluInputASelect = 2'b11;   // memory (LOAD)
        else
            aluInputASelect = 2'b01;   // ALU result
    end

    // =================================================
    // ALU input B (Source Register 2)
    // =================================================

    // -------- EX/MEM forwarding (ALU result only) --------
    if (idExUseSourceRegister2 &&
        exMemRegisterWriteEnable &&
        (exMemDestinationRegister == idExSourceRegister2)) begin

        aluInputBSelect = 2'b10;
    end

    // -------- MEM/WB forwarding (ALU or LOAD result) -----
    else if (idExUseSourceRegister2 &&
             memWbRegisterWriteEnable &&
             (memWbDestinationRegister == idExSourceRegister2)) begin

        if (IsLoadInstruction_MWB)
            aluInputBSelect = 2'b11;   // memory (LOAD)
        else
            aluInputBSelect = 2'b01;   // ALU result
    end
    
    
// store after load and after ALU

    // defaults
    storeAddressSelect = 2'b00; // old MUX
    storeDataSelect    = 2'b00; // old MUX

    if (isStoreInstruction_EXMEM &&
        memWbRegisterWriteEnable) begin

        // ---------- Address forwarding (Ra) ----------
        if (memWbDestinationRegister == exMemAddressRegister) begin
            storeAddressSelect = 2'b01; // MEM/WB_ALU
           // storeAddressSelect = 2'b10; // MEM/WB_memory_output
        end

        // ---------- Data forwarding (Rb) ----------
        if (memWbDestinationRegister == exMemDataRegister) begin
            if (IsLoadInstruction_MWB)
                storeDataSelect = 2'b10; // LOAD ? STORE (MEM/WB_memory_output)
            else
                storeDataSelect = 2'b01; // ADD ? STORE (MEM/WB_ALU)
        end
    end
end


endmodule
