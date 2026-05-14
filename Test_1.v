`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////


module tb_Top_Module;

    reg clk;
    reg reset;
    reg interrupt;
    reg [7:0] IN_PORT;
    wire [7:0] OUT_PORT;

    // Instantiate DUT
    Top_Module DUT (
        .clk(clk),
        .reset(reset),
        .interrupt(interrupt),
        .IN_PORT(IN_PORT),
        .OUT_PORT(OUT_PORT)
    );

    // Clock generation
    always #5 clk = ~clk;   // 100 MHz

    initial begin
        // =====================
        // Initial values
        // =====================
        clk = 0;
        reset = 1;
        interrupt = 0;
        IN_PORT = 8'd100;
    
        DUT.Memory.M[0] = 8'b0000_0100; 
        DUT.Memory.M[1] = 8'b0000_0101;         
        DUT.Memory.M[2] = 8'b0110_0000; 
        DUT.Memory.M[3] = 8'b0011_0100; 
        DUT.Memory.M[4] = 8'b0001_1000;    // reset start
        //DUT.Memory.M[5] = 8'b1011_0100;  // interrupt start        
        //DUT.Memory.M[6] = 8'b0000_1010;         
        //DUT.Memory.M[7] = 8'b0000_1010;         
        //DUT.Memory.M[8] = 8'b0000_1010;         
        //DUT.Memory.M[9] = 8'b0110_1100;         
        //DUT.Memory.M[10] = 8'b1011_1110;         
        //DUT.Memory.M[11] = 8'b0000_0000; 
        //DUT.Memory.M[12] = 8'b0000_0000; 
        //DUT.Memory.M[13] = 8'b0000_0000;

        // =====================
        // Apply reset
        // =====================
        #7;
        reset = 0;

        DUT.Memory.M[255] = 8'b0000_1101;
        // =====================
        // Initialize Register File
        // R0 = 5 , R1 = 3
        // =====================
        DUT.RF.R[0] = 8'd9;
        DUT.RF.R[1] = 8'd1;
        DUT.RF.R[2] = 8'd0;
        
        
        // =====================
        // Run simulation
        // =====================
        #100;

        $stop;
    end

endmodule
