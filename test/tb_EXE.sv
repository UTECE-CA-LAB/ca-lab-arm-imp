
`timescale 1ns / 1ns

module tb_EXE ();

    reg clk;
    reg rst;
    integer cycle;

    // ------------------------------------------------
    // Signal aliases - matching the requested waveform
    // ------------------------------------------------

    wire EXE_S_i;
    wire [3:0] SR_status_bits_o;
    wire [3:0] EXE_status_bits_o;

    wire EXE_WB_i;
    wire EXE_MEM_W_EN_i;
    wire EXE_MEM_R_EN_i;

    wire [31:0] EXE_ALU_Result_o;

    // ------------------------------------------------
    // ARM instance
    // ------------------------------------------------

    ARM uut (
        .clk(clk),
        .rst(rst)
    );

    // ------------------------------------------------
    // Connect internal ARM signals
    // ------------------------------------------------

    assign EXE_S_i             = uut.S_exe;

    assign SR_status_bits_o    = uut.status_reg;
    assign EXE_status_bits_o   = uut.execute.sr;

    assign EXE_WB_i            = uut.WB_EN_exe;
    assign EXE_MEM_W_EN_i      = uut.MEM_W_EN_exe;
    assign EXE_MEM_R_EN_i      = uut.MEM_R_EN_exe;

    assign EXE_ALU_Result_o    = uut.ALU_res_exe;

    // ------------------------------------------------
    // Clock generation
    // ------------------------------------------------

    always #5 clk = ~clk;

    always @(posedge clk) begin
        cycle = cycle + 1;
    end

    // ------------------------------------------------
    // Reset and simulation control
    // ------------------------------------------------

    initial begin
        clk = 0;
        rst = 1;
        cycle = 0;

        #20;
        rst = 0;

        #300;

        $display("\n============================================");
        $display("ARM Simulation complete.");
        $display("============================================\n");

        $finish;
    end

    // ------------------------------------------------
    // Signal sampling
    // ------------------------------------------------

    initial begin

        $display("==========================================================================");
        $display("Cycle | rst | EXE_S | SR_status | EXE_status | WB | MEM_W | MEM_R | ALU_Result");
        $display("==========================================================================");

        forever @(posedge clk) begin
            #1;

            $display(
                "%5d |  %b  |   %b   |    %b    |     %b     | %b  |   %b   |   %b   |  %h",
                cycle,
                rst,
                EXE_S_i,
                SR_status_bits_o,
                EXE_status_bits_o,
                EXE_WB_i,
                EXE_MEM_W_EN_i,
                EXE_MEM_R_EN_i,
                EXE_ALU_Result_o
            );

        end
    end

endmodule
