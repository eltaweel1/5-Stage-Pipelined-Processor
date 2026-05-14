
module Jump_Unit(
    input wire [3:0] op_code_DEX,
    input wire [1:0] ra_DEX,
    input wire       ZF, // zero flag from CCR
    input wire       ZF_ALU, // zero flag from ALU
    input wire       NF, // negative flag
    input wire       VF, // overflow flag
    input wire       CF, // carry flag
    
    output reg       jump_now,
    output reg       return_inst,
    
    output reg [2:0] jump_target_Scr // 3 to choose R[rb] and 4 to choose Memory output
    );
    
    always@(*)
    begin
        jump_now = 1'b0;
        jump_target_Scr = 0;
        return_inst = 0;
        casez({op_code_DEX,ra_DEX})
            6'b1001_00: begin //JZ
                if(ZF == 1) begin 
                    jump_now = 1;
                    jump_target_Scr = 3;
                    end
                else jump_now = 0;
            end
            6'b1001_01: begin //JN
                if(NF == 1) begin 
                    jump_now = 1;
                    jump_target_Scr = 3;
                    end
                else jump_now = 0;
            end
            6'b1001_10: begin //JC
                if(CF == 1) begin 
                    jump_now = 1;
                    jump_target_Scr = 3;
                    end
                else jump_now = 0;
            end
            6'b1001_11: begin //JV
                if(VF == 1) begin 
                    jump_now = 1;
                    jump_target_Scr = 3;
                    end
                else jump_now = 0;
            end
            6'b1010_00: begin //LOOP
                if(ZF_ALU == 0) begin 
                    jump_now = 1;
                    jump_target_Scr = 3;
                    end
                else jump_now = 0;
            end 
            6'b1010_01: begin //LOOP
                if(ZF_ALU == 0) begin 
                    jump_now = 1;
                    jump_target_Scr = 3;
                    end
                else jump_now = 0;
            end 
            6'b1010_10: begin //LOOP
                if(ZF_ALU == 0) begin 
                    jump_now = 1;
                    jump_target_Scr = 3;
                    end
                else jump_now = 0;
            end 
            6'b1010_11: begin //LOOP
                if(ZF_ALU == 0) begin 
                    jump_now = 1;
                    jump_target_Scr = 3;
                    end
                else jump_now = 0;
            end 
            6'b1011_00: begin //JUMP
                jump_now = 1;
                jump_target_Scr = 3;
            end
            6'b1011_01: begin //CALL
                jump_now = 1;
                jump_target_Scr = 3;
            end
            6'b1011_10: begin //RET
                jump_now = 1;
                jump_target_Scr = 4;
                return_inst = 1 ;
            end
            6'b1011_11: begin //RTI
                jump_now = 1;
                jump_target_Scr = 4;
                return_inst = 1;
            end
            default: begin
                jump_now = 0;
                jump_target_Scr = 0;
                end
        endcase
    end
endmodule
