module VAL2_GENERATOR (
    input [31:0] val_Rm,
    input [11:0] shift_op,
    input imm,
    input MEM_RorW_EN,
    output reg [31:0] val2
);

  
    wire [3:0] rotate_imm = shift_op[11:8];
    wire [7:0] immed_8     = shift_op[7:0];

    wire [31:0] base_val      = {24'b0, immed_8};
    wire [4:0]  rotate_amount = rotate_imm * 2;

    always @(*) begin
        if (MEM_RorW_EN) begin
        
            val2 = {{20{shift_op[11]}}, shift_op};
        end 
        else if (imm) begin
        
            val2 = (base_val >> rotate_amount) | (base_val << (32 - rotate_amount));
        end 
        else begin
        
            val2 = val_Rm;
        end
    end

endmodule