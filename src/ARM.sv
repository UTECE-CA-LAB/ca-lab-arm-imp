module ARM (
    input clk,
    input rst
);

    wire        freeze;
    wire        Branch_taken;
    wire [31:0] BranchAddr;
    wire        flush;

    wire [31:0] inst_if_out;
    wire [31:0] inst_id_in;

    wire [31:0] pc_if;
    wire [31:0] pc_id;
    wire [31:0] pc_exe;
    wire [31:0] pc_mem;
    wire [31:0] pc_wb;

    assign freeze       = 1'b0;
    // assign Branch_taken = 1'b0;
    // assign BranchAddr   = 32'b0;
    assign flush        = 1'b0;

    IF fetch (
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .Branch_taken(Branch_taken),
        .BranchAddr(BranchAddr),
        .PC(pc_if),
        .Instruction(inst_if_out)
    );

    IF_Reg fetch_reg (
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .flush(flush),
        .PC_in(pc_if),
        .Instruction_in(inst_if_out),
        .PC(pc_id),
        .Instruction(inst_id_in)
    );

    wire        WB_EN;
    wire [3:0]  Rf_address;
    wire        MEM_R_EN, MEM_W_EN;
    wire        S, B, SS2, imm;
    wire [3:0]  EXE_CMD;
    wire [31:0] Val_Rn, Val_Rm;
    wire [23:0] Signed_imm_24;
    wire [11:0] Shift_operand;

    ID instruction_decode (
        .clk(clk), 
        .rst(rst), 
        .instruction(inst_id_in),
        .WB_Rf_address(4'b0),
        .WB_data(32'b0),
        .WB_EN_feedback(1'b0),
        .WB_EN(WB_EN), 
        .Rf_address(Rf_address),
        .hazard(1'b0),
        .SR(4'b0),
        .MEM_R_EN(MEM_R_EN), 
        .MEM_W_EN(MEM_W_EN), 
        .S(S), 
        .B(B), 
        .SS2(SS2),
        .EXE_CMD(EXE_CMD),
        .Val_Rn(Val_Rn),
        .Val_Rm(Val_Rm),
        .imm(imm),
        .Signed_imm_24(Signed_imm_24),
        .Shift_operand(Shift_operand)   
    );

    wire        WB_EN_exe;
    wire        MEM_R_EN_exe, MEM_W_EN_exe;
    wire        S_exe, imm_exe;
    wire [3:0]  EXE_CMD_exe;
    wire [31:0] Val_Rn_exe, Val_Rm_exe;
    wire [11:0] Shift_operand_exe;
    wire [23:0] Signed_imm_24_exe;
    wire [3:0]  Dest_exe;

    ID_Reg decode_reg (
        .clk(clk),
        .rst(rst),
        .flush(flush),
        .WB_EN_in(WB_EN),
        .MEM_R_EN_in(MEM_R_EN),
        .MEM_W_EN_in(MEM_W_EN),
        .B_in(B),
        .S_in(S),
        .C_in(status_reg[2]),
        .imm_in(imm),
        .EXE_CMD_in(EXE_CMD),
        .PC_in(pc_id),
        .Val_Rn_in(Val_Rn),
        .Val_Rm_in(Val_Rm),
        .shift_operand_in(Shift_operand),
        .Signed_imm_24_in(Signed_imm_24),
        .Dest_in(Rf_address),

        .WB_EN(WB_EN_exe),
        .MEM_R_EN(MEM_R_EN_exe),
        .MEM_W_EN(MEM_W_EN_exe),
        .B(Branch_taken),
        .S(S_exe),
        .C(c_id_reg_out),
        .imm(imm_exe),
        .EXE_CMD(EXE_CMD_exe),
        .PC(pc_exe),
        .Val_Rn(Val_Rn_exe),
        .Val_Rm(Val_Rm_exe),
        .shift_operand(Shift_operand_exe),
        .Signed_imm_24(Signed_imm_24_exe),
        .Dest(Dest_exe)
    );

    reg [3:0] status_reg;
    wire c_id_reg_out;
    wire [31:0] ALU_res_exe, ALU_res_mem;

    EXE execute(
        .clk(clk), .rst(rst),
        .PC_in(pc_exe),
        .MEM_R_EN(MEM_R_EN_exe), .MEM_W_EN(MEM_W_EN_exe), .C(c_id_reg_out), .S(S_exe),
        .EXE_CMD(EXE_CMD_exe),
        .Val_Rn(Val_Rn_exe), .Val_Rm(Val_Rm_exe),
        .shift_operand(Shift_operand_exe),
        .Signed_imm_24(Signed_imm_24_exe),
        .imm(imm_exe),
        .PC(pc_mem),
        .sr(status_reg),
        .ALU_res(ALU_res_exe),
        .branch_addr(BranchAddr)
    );

    wire WB_EN_mem, MEM_R_EN_mem, MEM_W_EN_mem;
    wire [31:0] Val_Rm_mem;
    wire [3:0] Dest_mem;

    EXE_Reg exe_reg(
        .clk(clk), .rst(rst),
        .WB_EN_in(WB_EN_exe), .MEM_R_EN_in(MEM_R_EN_exe), .MEM_W_EN_in(MEM_W_EN_exe),
        .ALU_res_in(ALU_res_exe), .Val_Rm_in(Val_Rm_exe),
        .Dest_in(Dest_exe),

        .WB_EN(WB_EN_mem), .MEM_R_EN(MEM_R_EN_mem), .MEM_W_EN(MEM_W_EN_mem),
        .ALU_res(ALU_res_mem), .Val_Rm(Val_Rm_mem),
        .Dest(Dest_mem)
    );

    MEM_Reg memory_access_reg (
        .clk(clk),
        .rst(rst),
        .PC_in(pc_mem),
        .PC(pc_wb)
    );

endmodule
