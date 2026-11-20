module MEM (
    input clk, rst,
    input [31:0] PC_in,
    output logic [31:0] PC
);

    assign PC = PC_in;

endmodule


module MEM_Reg (
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
