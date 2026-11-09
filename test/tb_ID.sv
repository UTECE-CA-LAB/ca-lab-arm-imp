`timescale 1ns / 1ns

module tb_ID ();

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

        #20;
        rst = 0;

        #300;

        $display("\n================================================================================");
        $display("ID & ID_Reg Stage Simulation complete.");
        $display("================================================================================\n");
        $finish;
    end

    initial begin
        $display("========================================================================================================================================================");
        $display(" Cyc | PC | Inst       | WB_EN MEM_R MEM_W EXE_CMD  B  S | Dest | ValRn  ValRm | Shift_imm24 | Disassembly / Notes");
        $display("========================================================================================================================================================");
        
        forever @(posedge clk) begin
            #1; // Sample just after clock edge
            if (!rst && (uut.inst_id_in !== 32'bx)) begin
                $display(" %3d | %2d | 0x%8h |   %b     %b     %b     %4b     %b  %b |  %2d  |  %4d   %4d | %11d |",
                    cycle,
                    uut.pc_id,
                    uut.inst_id_in,
                    uut.WB_EN,
                    uut.MEM_R_EN,
                    uut.MEM_W_EN,
                    uut.EXE_CMD,
                    uut.B,
                    uut.S,
                    uut.Rf_address,
                    uut.Val_Rn,
                    uut.Val_Rm,
                    $signed(uut.Signed_imm_24)
                );
            end
        end
    end

endmodule
