`timescale 1ns / 1ns

module tb_ARM ();

    reg clk;
    reg rst;
    integer cycle;

    always #5 clk = ~clk;

    always @(posedge clk) begin
        cycle = cycle + 1;
    end

    ARM uut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        rst = 1;
        cycle = 0;

        // Reset
        #20;
        rst = 0;

        wait (uut.pc_if == 7);
        @(posedge clk);
        #2;

        $display("--------------------------------------------------------------------------------");
        $display(">>> Reset asserted at cycle %0d (PC_IF reached %0d) <<<", cycle, uut.pc_if);
        $display("--------------------------------------------------------------------------------");
        rst = 1;
        #20;
        rst = 0;
        $display("--------------------------------------------------------------------------------");
        $display(">>> Reset released, restarting from PC = 0 <<<");
        $display("--------------------------------------------------------------------------------");

        #150;

        $display("--------------------------------------------------------------------------------");
        $display("Simulation complete.");
        $finish;
    end

    initial begin
        $display("--------------------------------------------------------------------------------");
        $display("   Cycle   | rst |  PC_IF   |  PC_ID   |  PC_EXE  |  PC_MEM  |  PC_WB  ");
        $display("--------------------------------------------------------------------------------");
        $monitor("   %4d    |  %b  |   %3d    |   %3d    |   %3d    |   %3d    |   %3d   ",
            cycle, rst, uut.pc_if, uut.pc_id, uut.pc_exe, uut.pc_mem, uut.pc_wb);
    end

endmodule