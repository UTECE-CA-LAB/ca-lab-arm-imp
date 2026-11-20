module WB (
    input clk, rst,
    input [31:0] PC_in,
    output logic [31:0] PC
);

    assign PC = PC_in;

endmodule
