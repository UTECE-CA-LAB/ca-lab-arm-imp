module WB (
    input [31:0] ALU_res,
    input [31:0] Mem_read_value,
    input MEM_R_EN,
    output [31:0] WB_Value
);

    assign WB_Value = MEM_R_EN ? Mem_read_value : ALU_res;

endmodule
