module EXE (
    input clk, rst,
    input [31:0] PC_in,
    input MEM_R_EN, MEM_W_EN, C, S,
    input [3:0]  EXE_CMD,
    input [31:0] Val_Rn, Val_Rm,
    input [11:0] shift_operand,
    input [23:0] Signed_imm_24,
    input imm,
    output logic [31:0] PC,
    output reg [3:0] sr,
    output logic [31:0] ALU_res,
    output [31:0] branch_addr
);

    assign PC = PC_in;

    wire [31:0] val2, Signed_imm_24_extended;
    reg [3:0] status_reg;
    wire MEM_RorW_EN;

    assign MEM_RorW_EN = MEM_R_EN | MEM_W_EN;
    assign Signed_imm_24_extended = Signed_imm_24[23] ? {8'b11111111,Signed_imm_24} : {8'b00000000,Signed_imm_24};
    assign branch_addr = PC_in + Signed_imm_24_extended;

    always @(negedge clk or posedge rst) begin
        if (rst)
            sr <= 4'b0;
        else if (S)
            sr <= status_reg;
    end

    VAL2_GENERATOR val2_gen(
    .val_Rm(Val_Rm),
    .shift_op(shift_operand),
    .imm(imm),
    .MEM_RorW_EN(MEM_RorW_EN),
    .val2(val2)
    );

    ALU alu (
    .EXE_CMD(EXE_CMD),
    .Val1(Val_Rn), 
    .Val2(val2),
    .c_in(C),
    .Satus_bits(status_reg),
    .out(ALU_res)
    );


endmodule


module EXE_Reg (
    input clk, rst,
    // input [31:0] PC_in,
    // output logic [31:0] PC
    input WB_EN_in, MEM_R_EN_in, MEM_W_EN_in,
    input [31:0] ALU_res_in, Val_Rm_in,
    input [3:0] Dest_in,

    output logic WB_EN, MEM_R_EN, MEM_W_EN,
    output logic [31:0] ALU_res, Val_Rm,
    output logic [3:0] Dest
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            //PC <= 32'b0;
            WB_EN <= 1'b0;
            MEM_R_EN <= 1'b0;
            MEM_W_EN <= 1'b0;
            ALU_res <= 32'b0;
            Val_Rm <= 32'b0;
            Dest <= 4'b0;
        end
        else begin
            //PC <= PC_in;
            WB_EN <= WB_EN_in;
            MEM_R_EN <= MEM_R_EN_in;
            MEM_W_EN <= MEM_W_EN_in;
            ALU_res <= ALU_res_in;
            Val_Rm <= Val_Rm_in;
            Dest <= Dest_in;
        end
    end

endmodule
