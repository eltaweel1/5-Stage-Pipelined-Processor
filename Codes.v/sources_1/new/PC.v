//!add reset signal or not?
module PC(
    input wire clk,
    input wire PC_E, // PC Enable Active High 0 for stall
    input wire PC_F, // PC Flash Active High 
    input wire Reset,// Active high reset
    input wire [7:0] reset_interrupt_target,
    input wire [7:0] jump,     // jump target
    input wire [7:0] return,   // return target (old PC)
    input wire [2:0] PCSrc,
    input wire [2:0] jump_target_Scr,
    input wire       jump_now,
    output reg [7:0] PC_next,
    output wire[7:0] PC_plus1
    );
    
    reg [2:0] PC_selector;
    always@(*)
    begin
        case(jump_now)
            1'b0 : PC_selector = PCSrc;
            1'b1 : PC_selector = jump_target_Scr;
        endcase
    end
    reg [7:0] PC_current;
    
    assign PC_plus1 = PC_next + 1;
    always@(posedge clk) begin 
            PC_next <= PC_current; 
    end

    always@(*) begin

	if(PC_F)  PC_current = 8'h00;    // Highest Priority 
	else if(Reset) PC_current = reset_interrupt_target;
	else if(PC_E) begin
        case(PC_selector)
            3'b000: PC_current = reset_interrupt_target; // PC <== M[0] or PC <== M[1] (from instruction port of memory)
            3'b001: PC_current = PC_next + 1;
            3'b010: PC_current = PC_next + 2; 
            3'b011: PC_current = jump;          //PC <== R[rb]   (jump and loop and call)
            3'b100: PC_current = return;        //PC <== X[++SP] (RET and RTI)
            default:PC_current = PC_next + 1;
        endcase
	end
	else PC_current = PC_next;
	
    end
	
endmodule