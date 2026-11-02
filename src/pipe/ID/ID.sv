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
    input clk, rst,
    input [31:0] PC_in,
    output logic [31:0] PC
);

RegisterFile (
    input clk, rst,
    input writeBackEN,
    input   [4:0] src_1, src_2, Dest_WB,
    input  [31:0] Result_WB,
    output [31:0] reg_out_1, reg_out_2
);



    assign PC = PC_in;

endmodule