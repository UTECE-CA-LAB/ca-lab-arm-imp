module ID_Reg (
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


module ID (
    input  clk, rst, hazard,
    input [31:0] PC_in, instruction,
    input [3:0] SR,
    input [3:0] WB_Dest,
    input [31:0] WB_Value,
    input WB_WB_EN,
    output [31:0] PC,
    output WB_EN, MEM_R_EN, MEM_W_EN, S_out, B, Two_src, 
    output [3:0] EXE_CMD,
    output [31:0] Val_Rn,
    output [31:0] Val_Rm,
    output [23:0] Signed_imm_24,
    output imm,
    output [3:0] Dest,
    output [11:0] Shift_operand

);

wire [3:0] Cond, OPcode, Rn, Rm;
wire S;
wire [1:0] Mode;

wire uncond_WB_EN, uncond_MEM_R_EN, uncond_MEM_W_EN, uncond_S, uncond_B;
wire [3:0] uncond_EXE_COM;

assign PC = PC_in;

assign Cond = instruction[31:28];
assign Mode = instruction[27:26];
assign imm = instruction[25];
assign OPcode = instruction[24:21];
assign S = instruction[20];
assign Rn = instruction[19:16];
assign Dest = instruction[15:12];
assign Shift_operand = instruction[11:0];
assign Rm = instruction[3:0];
assign Signed_imm_24 = instruction[23:0];

wire cond_sel, cond_flag;
wire [3:0] Src1, Src2;
assign cond_sel = hazard || ~ cond_flag;
assign Two_src = ~(imm || uncond_MEM_R_EN);
assign {WB_EN, MEM_R_EN, MEM_W_EN, EXE_CMD, S_out, B} = cond_sel ? 9'd0 : {uncond_WB_EN, uncond_MEM_R_EN, uncond_MEM_W_EN, uncond_EXE_COM, uncond_S, uncond_B};
assign Src2 = uncond_MEM_W_EN ? Dest : Rm;

RegisterFile reg_file(
    .clk(clk), .rst(rst),
    .writeBackEN(WB_WB_EN),
    .src_1(Src1), .src_2(Src2), .Dest_WB(WB_Dest),
    .Result_WB(WB_Value),
    .reg_out_1(Val_Rn), .reg_out_2(Val_Rm)
);

control_unit cont_unit(
  .OPCode(OPcode),
  .Mode(Mode),
  .S(S),
  .out({uncond_WB_EN, uncond_MEM_R_EN, uncond_MEM_W_EN, uncond_EXE_COM, uncond_S, uncond_B})
);

condition_check cond_check(
  .Cond(Cond),
  .SR(SR),
  .out(cond_flag)
);
 

endmodule