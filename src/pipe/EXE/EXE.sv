module EXE (
    input clk, rst,
    input [31:0] PC_in,
    input WB_EN, MEM_R_EN, MEM_W_EN, B, S,
    input [3:0]  EXE_CMD,
    input [31:0] PC, Val_Rn, Val_Rm,
    input [11:0] shift_operand,
    input [23:0] Signed_imm_24,
    input [3:0]  Dest,
    output logic [31:0] PC,
);

    assign PC = PC_in;

    wire [31:0] val2;

    reg [3:0] sr;
    always @(posedge clk or posedge rst) begin
        if (rst)
            sr <= 4'b0;
        else
            sr <= status_reg;
    end

    VAL2_GENERATOR val2_gen(
    input [31:0] val_Rm,
    input [11:0] shift_op,
    input imm,
    input MEM_RorW_EN,
    output [31:0] val2
    );

    ALU alu (
    .EXE_CMD(EXE_CMD),
    .Val1(Val_Rn), .Val2(),
    input c_in,
    .Satus_bits(status_reg),
    output [31:0] out
    );


endmodule


module EXE_Reg (
    input clk, rst,
    input [31:0] PC_in,
    output logic [31:0] PC
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'b0;
        end
        else begin
            PC <= PC_in;
        end
    end

endmodule
