module RegisterFile (
    input clk, rst,
    input writeBackEN,
    input   [4:0] src_1, src_2, Dest_WB,
    input  [31:0] Result_WB,
    output [31:0] reg_out_1, reg_out_2
);
    reg [31:0] regs [15:0];

    initial begin
    int q;
        for(q = 0; q < 16; q = q +1) begin
            regs[q] = 32'dq;
        end
    end

    // Read-Register from RF
    assign reg_out_1 = regs[src_1];
    assign reg_out_2 = regs[src_2];
    
    //Write-Data on Register 
    integer i;
    always @(posedge clk or posedge rst) begin
        
        if (rst) begin
            for (i = 0; i < 16; i = i + 1)
                regs[i] <= 32'b0;
        end

        else if (writeBackEN)
            if (Dest_WB != 15 )
                regs[Dest_WB] <= Result_WB;
            else 
                regs[Dest_WB] <= 32'b0; 
    end

endmodule
