module Hazard_Unit(

    // ============================
    // Inputs
    // ============================

    // -------- Load-use hazard --------
    input        reset,   
    input        interrupt,   
    input        idExMemReadEnable,   // EX stage instruction is LOAD
    input [1:0]  idExDestinationReg,  // Destination register of LOAD

    input [1:0]  ifIdSourceReg1,      // Source register 1 in ID stage
    input [1:0]  ifIdSourceReg2,      // Source register 2 in ID stage
    input        ifIdUseSourceReg1,    // ID uses rs1?
    input        ifIdUseSourceReg2,    // ID uses rs2?

    // -------- Control hazards --------
    input        branchTaken,          // Jump/branch resolved in EX

    // -------- RET / jump-from-memory --------
    input        waitingForPCFromMem, // latched: jump taken & PC not ready yet

    // -------- Two-byte instruction (IMM) --------
    input        Flush_DEX,            // waiting for immediate byte

    // ============================
    // Outputs
    // ============================

    output reg pcEnable,
    output reg pcFlush,

    output reg ifIdEnable,
    output reg ifIdFlush,

    output reg idExEnable,
    output reg idExFlush
);

always @(*) begin
    // ============================
    // Default (no hazard)
    // ============================
    pcEnable   = 1'b1;
    pcFlush    = 1'b0;

    ifIdEnable = 1'b1;
    ifIdFlush  = 1'b0;

    idExEnable = 1'b1;
    idExFlush  = 1'b0;

    if(reset || interrupt) ifIdFlush  = 1'b1;
    // =====================================================
    // 1) Normal control hazard (branch / jump in EX)
    // =====================================================
    else if (branchTaken) begin
        ifIdFlush = 1'b1;
        idExFlush = 1'b1;
    end

    // =====================================================
    // 2) Jump needs PC from memory (RET / load-PC)
    // =====================================================
    else if (waitingForPCFromMem) begin
        pcEnable   = 1'b0;   // stop PC
        ifIdEnable = 1'b0;   // freeze IF/ID
        idExFlush  = 1'b1;   // bubble in EX
    end

    // =====================================================
    // 3) Load-use data hazard
    // =====================================================
    else if ( idExMemReadEnable &&
        ( (ifIdUseSourceReg1 && (idExDestinationReg == ifIdSourceReg1)) ||
          (ifIdUseSourceReg2 && (idExDestinationReg == ifIdSourceReg2)) )
       ) begin

        pcEnable   = 1'b0;
        ifIdEnable = 1'b0;
        idExFlush  = 1'b1;
    end

    // =====================================================
    // 4) Two-byte instruction (IMM fetch)
    // =====================================================
    if (Flush_DEX) begin
        idExFlush  = 1'b1;   // bubble while IMM is fetched
    end
end

endmodule
