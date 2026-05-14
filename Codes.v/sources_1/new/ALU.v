module ALU(
    input  [7:0] RFout1,
    input  [7:0] RFout2,
    input  [7:0] exMemAluResult,
    input  [7:0] memWbWriteBackData_ALU,
    input  [7:0] memWbWriteBackData,
    
    input  [7:0] B_DEX,
    input        A_sel,
    input  [3:0] alu_op,
    input  [3:0] FLAGS_in,    
    
    input wire [1:0] aluInputASelect, // Select signal for ALU input A source
    input wire [1:0] aluInputBSelect,  // Select signal for ALU input B source
    
    output reg [7:0] result,
    output wire [3:0] flags_out // V,C,N,Z
);
    reg [7:0] A;
    reg [7:0] B;
   // assign A = (A_sel) ? RFout2 : RFout1;
    reg [8:0] temp9;
    reg z_reg, n_reg, c_reg, v_reg; // Internal regs for Z and N and C and V 
    // Assign flags based on result and internal registers
    assign flags_out = {v_reg, c_reg, n_reg, z_reg};

    always @(*) begin
    // ALU input A
    case (aluInputASelect)
        2'b00: A = (A_sel) ? RFout2 : RFout1;
        2'b10: A = exMemAluResult;       
        2'b01: A = memWbWriteBackData_ALU;  
        2'b11: A = memWbWriteBackData;  
        default: A = (A_sel) ? RFout2 : RFout1;
    endcase

    // ALU input B
    case (aluInputBSelect)
        2'b00: B = B_DEX;
        2'b10: B = exMemAluResult;
        2'b01: B = memWbWriteBackData_ALU;
        2'b11: B = memWbWriteBackData;
        default: B = B_DEX;
    endcase
end

    always @(*) begin
        // defaults
        result = 8'h00;
        temp9  = 9'd0;
        z_reg = FLAGS_in[0];            // Default Z
        n_reg = FLAGS_in[1];            // Default N
        c_reg = FLAGS_in[2];            // Default C
        v_reg = FLAGS_in[3];            // Default V
        case (alu_op)
            4'd0: begin // NOP
                result = result;  // C and V , assigned by default
                //z_reg  = (result == 8'h00);
                //n_reg  = result[7];
            end
            4'd1: begin // ADD
                temp9  = {1'b0, A} + {1'b0, B};
                result = temp9[7:0];
                c_reg  = temp9[8];
                v_reg  = (~A[7] & ~B[7] &  result[7]) | ( A[7] &  B[7] & ~result[7]);
                z_reg  = (result == 8'h00);
                n_reg  = result[7];

            end
            4'd2: begin // SUB 
                temp9  = {1'b0, A} - {1'b0, B};
                result = temp9[7:0];
                c_reg  = temp9[8];
                v_reg  = (A[7] & ~B[7] & ~result[7]) | (~A[7] & B[7] &  result[7]);
                z_reg  = (result == 8'h00);
                n_reg  = result[7];

            end
            4'd3: begin // AND
                result = A & B;  // C and V , assigned by default
                z_reg  = (result == 8'h00);
                n_reg  = result[7];
            end
            4'd4: begin // OR
                result = A | B; // C and V , assigned by default
                z_reg  = (result == 8'h00);
                n_reg  = result[7];
            end
            4'd5: begin // RLC (rotate-through-carry)
                c_reg  = B[7];
                result = {B[6:0], FLAGS_in[2]};   // V , assigned by default  
                z_reg  = (result == 8'h00);
                n_reg  = result[7];
            end
            4'd6: begin // RRC (rotate-through-carry)
                c_reg  = B[0];
                result = {FLAGS_in[2], B[7:1]};  // V , assigned by default
                z_reg  = (result == 8'h00);
                n_reg  = result[7];
            end
            4'd7: begin // NOT
                result = ~B; // C, V , assigned by default
                z_reg  = (result == 8'h00);
                n_reg  = result[7];
            end
            4'd8: begin // NEG
                temp9  = {1'b0, (~B)} + 9'b1;
                result = temp9[7:0];
                c_reg  = temp9[8];
                v_reg  = (B == 8'h80);
                z_reg  = (result == 8'h00);
                n_reg  = result[7];
            end
            4'd9: begin // INC
                temp9  = {1'b0, B} + 9'b1;
                result = temp9[7:0];
                c_reg  = temp9[8];
                v_reg  = (~B[7] & result[7]);
                z_reg  = (result == 8'h00);
                n_reg  = result[7];
            end
            4'd10: begin // DEC
                temp9  = {1'b0, B} - 9'b1;
                result = temp9[7:0];
                c_reg  = temp9[8];
                v_reg  = (B[7] & ~result[7]);
                z_reg  = (result == 8'h00);
                n_reg  = result[7];
            end
            4'd11: begin // SETC
                c_reg  = 1'b1;    // V and Z and N , assigned by default 
            end
            4'd12: begin // CLRC
                c_reg  = 1'b0;    // V and Z and N , assigned by default 
            end
            default: begin // default NOP
                result = A;  // C and V , assigned by default
                z_reg = FLAGS_in[0];            // Default Z
                n_reg = FLAGS_in[1];            // Default N
                c_reg = FLAGS_in[2];            // Default C
                v_reg = FLAGS_in[3];            // Default V
            end
        endcase
    end 
endmodule
