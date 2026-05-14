// [7:4] = Active flags  {V, C, N, Z}
// [3:0] = Saved flags   {V, C, N, Z}  (used during interrupt)
module CCR (
    input  wire        clk,
    input  wire        rst,           // Active high reset
    input  wire        we,            // write from ALU
    input  wire        save_int,      // interrupt entry
    input  wire        restore_int,   // return from interrupt
    input  wire [3:0]  flags_in,      // flags from ALU {V,C,N,Z}
    output wire [3:0]  flags_out
);
    reg  [7:0]  flags_out_temp;

    always @(posedge clk) begin
        if (rst) begin
            flags_out_temp[7:0] <= 8'd0;

        end else if (save_int) begin
            flags_out_temp[3:0] <= flags_out_temp[7:4]; // Save active flags into lower bits

        end else if (restore_int) begin
            flags_out_temp[7:4] <= flags_out[3:0]; // Restore saved flags back to active flags

        end else if (we) begin
            flags_out_temp[7:4] <= flags_in; // Normal ALU flag update
        end
    end
    assign flags_out = flags_out_temp[7:4];

endmodule
