module MEM (
    input clk, rst,
    input MEM_W_EN, MEM_R_EN,
    input [31:0] ALU_res,
    input [31:0] Val_Rm,
    output [31:0] Mem_read_value
);
   
    wire [31:0] mem_addr = ALU_res - 32'd1024;

    
    data_mem d_mem (
        .a(mem_addr[10:0]),  
        .d(Val_Rm),           
        .clk(clk),
        .we(MEM_W_EN),       
        .spo(Mem_read_value)  
    );

endmodule


module MEM_Reg (
    input clk, rst,
    input WB_EN_in, MEM_R_EN_in,
    input [31:0] ALU_res_in, Mem_read_value_in,
    input [3:0] Dest_in,
    
    output reg WB_EN, MEM_R_EN,
    output reg [31:0] ALU_res, Mem_read_value,
    output reg [3:0] Dest
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            WB_EN          <= 1'b0;
            MEM_R_EN       <= 1'b0;
            ALU_res        <= 32'b0;
            Mem_read_value <= 32'b0;
            Dest           <= 4'b0;
        end
        else begin
            WB_EN          <= WB_EN_in;
            MEM_R_EN       <= MEM_R_EN_in;
            ALU_res        <= ALU_res_in;
            Mem_read_value <= Mem_read_value_in;
            Dest           <= Dest_in;
        end
    end

endmodule