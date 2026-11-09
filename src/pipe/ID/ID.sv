module ID_Reg(
    input clk, rst,
    input flush, WB_EN_in, MEM_R_EN_in, MEM_W_EN_in, B_in, S_in,
    input [3:0]  EXE_CMD_in,
    input [31:0] PC_in, Val_Rn_in, Val_Rm_in,
    input [11:0] shift_operand_in, 
    input [23:0] Signed_imm_24_in, 
    input [3:0] Dest_in,          
    
    output reg WB_EN, MEM_R_EN, MEM_W_EN, B, S,
    output reg [3:0]  EXE_CMD,
    output reg [31:0] PC, Val_Rn, Val_Rm,
    output reg [11:0] shift_operand,
    output reg [23:0] Signed_imm_24,
    output reg [3:0]  Dest
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            WB_EN <= 1'b0;
            MEM_R_EN <= 1'b0;
            MEM_W_EN <= 1'b0;
            EXE_CMD <= 4'b0;
            B <= 1'b0;
            S <= 1'b0;
            PC <= 32'b0;
            Val_Rn <= 32'b0;
            Val_Rm <= 32'b0;
            shift_operand <= 12'b0;
            Signed_imm_24 <= 24'b0;
            Dest <= 4'b0;
        end
        else if (flush) begin
            WB_EN <= 1'b0;
            MEM_R_EN <= 1'b0;
            MEM_W_EN <= 1'b0;
            EXE_CMD <= 4'b0;
            B <= 1'b0;
            S <= 1'b0;
            PC <= 32'b0;
            Val_Rn <= 32'b0;
            Val_Rm <= 32'b0;
            shift_operand <= 12'b0;
            Signed_imm_24 <= 24'b0;
            Dest <= 4'b0;
        end
        else begin
            WB_EN <= WB_EN_in;
            MEM_R_EN <= MEM_R_EN_in;
            MEM_W_EN <= MEM_W_EN_in;
            EXE_CMD <= EXE_CMD_in;
            B <= B_in;
            S <= S_in;
            PC <= PC_in;
            Val_Rn <= Val_Rn_in;
            Val_Rm <= Val_Rm_in;
            shift_operand <= shift_operand_in;
            Signed_imm_24 <= Signed_imm_24_in;
            Dest <= Dest_in;
        end
    end
    
endmodule



module ID(

    input  clk, rst, 
    input [31:0] instruction,
    
    input [3:0] WB_Rf_address,
    input [31:0] WB_data,
    input WB_EN_feedback,
    output WB_EN, 
    output [3:0] Rf_address,
    
    input  hazard,
    input [3:0] SR,
    
    
    output MEM_R_EN, MEM_W_EN, 
    output S, B, SS2,
    // SS2 = stall_src2 = tow_src : it's for hazrd unit which check arm need to stall or not (on src2)  
    
    
    output [3:0] EXE_CMD,
    output [31:0] Val_Rn,
    output [31:0] Val_Rm,
    
    output imm,
    output [23:0] Signed_imm_24,
    output [11:0] Shift_operand   

);

// exe outputs

assign Shift_operand = instruction[11:0];
assign Rf_address = instruction[15:12];

assign imm = instruction[25];
assign Signed_imm_24 = instruction[23:0];


// RF
wire [3:0] Rn, Rm;
assign Rn = instruction[19:16];
assign Rm = instruction[3:0];

wire [3:0] Src1, Src2;
assign Src1 = Rn;
assign Src2 = uncond_MEM_W_EN ? Rf_address : Rm;

RegisterFile reg_file(
    .clk(clk), 
    .rst(rst),
    .writeBackEN(WB_EN_feedback),
    .src_1(Src1),
    .src_2(Src2),
    .Dest_WB(WB_Rf_address),
    .Result_WB(WB_data),
    .reg_out_1(Val_Rn),
    .reg_out_2(Val_Rm)
);

// condition check

wire [3:0] cond; 
assign cond = instruction[31:28];

wire inst_valid;
condition_check cond_check(
  .condition(cond),
  .SR(SR),
  .inst_valid(inst_valid)
);

wire cond_sel;
assign cond_sel = hazard || ~inst_valid;

assign SS2 = ~(imm || uncond_MEM_R_EN);


// control unit

wire [3:0] opcode;
wire [1:0] Mode;
wire inst_S;

assign Mode   = instruction[27:26];
assign opcode = instruction[24:21];
assign inst_S = instruction[20];


wire [3:0] uncond_EXE_COM;
wire uncond_WB_EN, uncond_MEM_R_EN, uncond_MEM_W_EN, uncond_S, uncond_B;

control_unit cont_unit(
  .opcode(opcode),
  .Mode(Mode),
  .S(inst_S),
  .out({uncond_WB_EN, 
        uncond_MEM_R_EN, 
        uncond_MEM_W_EN, 
        uncond_EXE_COM, 
        uncond_S, 
        uncond_B })
);

assign { WB_EN,
         MEM_R_EN, 
         MEM_W_EN, 
         EXE_CMD, 
         S, 
         B } = cond_sel ? 9'd0 : {  uncond_WB_EN, 
                                    uncond_MEM_R_EN, 
                                    uncond_MEM_W_EN, 
                                    uncond_EXE_COM, 
                                    uncond_S, 
                                    uncond_B };



endmodule
