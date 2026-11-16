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
    wire [4:0]  rotate_amount = {rotate_imm,1'b0};

    wire [4:0] shift_imm = shift_op[11:7];
    wire [1:0] shift = shift_op[6:5];

    always @(*) begin
        if (MEM_RorW_EN) begin
        
            val2 = {{20{shift_op[11]}}, shift_op};
        end 
        else if (imm) begin
        
            val2 = (rotate_amount) ? base_val : (base_val >> rotate_amount) | (base_val << (32 - rotate_amount));
        end 
        else begin
            case (shift)
                2'b00: val2 = val_Rm  << shift_imm;
                2'b01: val2 = val_Rm >> shift_imm;
                2'b10: val2= $signed(val_Rm) >>> shift_imm;
                2'b11: val2= (shift_imm==5'b0) ? val_Rm :
                            ((val_Rm >> shift_imm) | (val_Rm << (32 - shift_imm)));
                default: val2 = val_Rm;
            endcase
        end
    end

endmodule