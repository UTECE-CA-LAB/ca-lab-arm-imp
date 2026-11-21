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

    reg [3:0]   status_reg;
    wire        c_id_reg_out;
    wire [31:0] ALU_res_exe, ALU_res_mem;

    wire        WB_EN_wb;
    wire [3:0]  Dest_wb;
    wire [31:0] WB_Value;

    wire        hazard_detected;
    wire [3:0]  src1_id, src2_id;

    wire        WB_EN_exe;
    wire [3:0]  Dest_exe;
    wire        WB_EN_mem;
    wire [3:0]  Dest_mem;

    assign freeze = hazard_detected;
    assign flush  = Branch_taken;

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
        .WB_Rf_address(Dest_wb),
        .WB_data(WB_Value),
        .WB_EN_feedback(WB_EN_wb),
        .hazard(hazard_detected),
        .SR(status_reg),

        .WB_EN(WB_EN),
        .Rf_address(Rf_address),
        .MEM_R_EN(MEM_R_EN), 
        .MEM_W_EN(MEM_W_EN), 
        .S(S), 
        .B(B), 
        .SS2(SS2),
        .src1(src1_id),
        .src2(src2_id),
        .EXE_CMD(EXE_CMD),
        .Val_Rn(Val_Rn),
        .Val_Rm(Val_Rm),
        .imm(imm),
        .Signed_imm_24(Signed_imm_24),
        .Shift_operand(Shift_operand)   
    );

    Hazard_Detection_Unit hazard_unit (
        .src1(src1_id),
        .src2(src2_id),
        .Two_src(SS2),
        .EXE_Dest(Dest_exe),
        .EXE_WB_EN(WB_EN_exe),
        .MEM_Dest(Dest_mem),
        .MEM_WB_EN(WB_EN_mem),
        .Hazard_Detected(hazard_detected)
    );

    wire        MEM_R_EN_exe, MEM_W_EN_exe;
    wire        S_exe, imm_exe;
    wire [3:0]  EXE_CMD_exe;
    wire [31:0] Val_Rn_exe, Val_Rm_exe;
    wire [11:0] Shift_operand_exe;
    wire [23:0] Signed_imm_24_exe;

    ID_Reg decode_reg (
        .clk(clk),
        .rst(rst),
        .flush(flush),
        .WB_EN_in(WB_EN),
        .MEM_R_EN_in(MEM_R_EN),
        .MEM_W_EN_in(MEM_W_EN),
        .B_in(B),
        .S_in(S),
        .C_in(status_reg[1]),
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

    wire MEM_R_EN_mem, MEM_W_EN_mem;
    wire [31:0] Val_Rm_mem;

    EXE_Reg exe_reg(
        .clk(clk), .rst(rst),
        .WB_EN_in(WB_EN_exe), .MEM_R_EN_in(MEM_R_EN_exe), .MEM_W_EN_in(MEM_W_EN_exe),
        .ALU_res_in(ALU_res_exe), .Val_Rm_in(Val_Rm_exe),
        .Dest_in(Dest_exe),

        .WB_EN(WB_EN_mem), .MEM_R_EN(MEM_R_EN_mem), .MEM_W_EN(MEM_W_EN_mem),
        .ALU_res(ALU_res_mem), .Val_Rm(Val_Rm_mem),
        .Dest(Dest_mem)
    );

    wire [31:0] Mem_read_value_mem;

    MEM memory_stage (
        .clk(clk),
        .rst(rst),
        .MEM_W_EN(MEM_W_EN_mem),
        .MEM_R_EN(MEM_R_EN_mem),
        .ALU_res(ALU_res_mem),
        .Val_Rm(Val_Rm_mem),
        .Mem_read_value(Mem_read_value_mem)
    );

    wire        MEM_R_EN_wb;
    wire [31:0] ALU_res_wb, Mem_read_value_wb;

    MEM_Reg memory_access_reg (
        .clk(clk),
        .rst(rst),
        .PC_in(pc_mem),
        .PC(pc_wb),

        .WB_EN_in(WB_EN_mem),
        .MEM_R_EN_in(MEM_R_EN_mem),
        .ALU_res_in(ALU_res_mem),
        .Mem_read_value_in(Mem_read_value_mem),
        .Dest_in(Dest_mem),

        .WB_EN(WB_EN_wb),
        .MEM_R_EN(MEM_R_EN_wb),
        .ALU_res(ALU_res_wb),
        .Mem_read_value(Mem_read_value_wb),
        .Dest(Dest_wb)
    );

    WB write_back_stage (
        .ALU_res(ALU_res_wb),
        .Mem_read_value(Mem_read_value_wb),
        .MEM_R_EN(MEM_R_EN_wb),
        .WB_Value(WB_Value)
    );

endmodule
