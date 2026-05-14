module IF_ID (
    input  wire       clk,
    input  wire       enable,
    input  wire       flush,

    input  wire       isTwoByteInstr,   // from decode

    input  wire [7:0] PC_plus1_IF_ID,
    input  wire [7:0] inst_mem_in,

    output reg  [7:0] PC_plus1_out_IF_ID,
    output reg  [7:0] inst_mem_out,
    output reg  [7:0] ifIdImm,
    output reg        ifIdHasImm,
    output reg Flush_DEX
);

reg waitingForImm;
    
wire isTwoByteInstr_local;

    assign isTwoByteInstr_local =
           (inst_mem_in[7:4] == 12);
           
always @(posedge clk) begin
    if (flush) begin
        PC_plus1_out_IF_ID <= 8'h00;
        inst_mem_out       <= 8'h00;
        ifIdImm            <= 8'h00;
        ifIdHasImm         <= 1'b0;
        waitingForImm      <= 1'b0;
        Flush_DEX <= 1'b0;
    end
     else begin

            // =========================
            // IMM must ALWAYS be captured
            // =========================
            if (waitingForImm) begin
                ifIdImm       <= inst_mem_in;
                ifIdHasImm    <= 1'b1;
                waitingForImm <= 1'b0;
                Flush_DEX <= 1'b0;
                
            end

            // =========================
            // Normal instruction (stallable)
            // =========================
            else if (enable) begin
                PC_plus1_out_IF_ID <= PC_plus1_IF_ID;
                inst_mem_out       <= inst_mem_in;
                ifIdHasImm         <= 1'b0;

                if (isTwoByteInstr_local) begin
                    waitingForImm <= 1'b1;
                    Flush_DEX <= 1'b1;
                    end
            end
            // else: full stall ? freeze
        end
    end


endmodule
