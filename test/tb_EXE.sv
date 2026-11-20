`timescale 1ns / 1ns

module tb_EXE ();

    reg clk;
    reg rst;
    integer cycle;
    integer pass_count;
    integer fail_count;

    // ------------------------------------------------
    // Signal aliases - matching Figure 2 of 04-EXE.pdf
    // ------------------------------------------------

    wire        EXE_S_i;
    wire [3:0]  SR_status_bits_o;
    wire [3:0]  EXE_status_bits_o;

    wire        EXE_WB_i;
    wire        EXE_MEM_W_EN_i;
    wire        EXE_MEM_R_EN_i;

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
    assign SR_status_bits_o    = uut.execute.sr;          // Registered status flags (updated on negedge clk when S=1)
    assign EXE_status_bits_o   = uut.execute.status_reg;  // Immediate combinational ALU status flags {N, Z, C, V}

    assign EXE_WB_i            = uut.WB_EN_exe;
    assign EXE_MEM_W_EN_i      = uut.MEM_W_EN_exe;
    assign EXE_MEM_R_EN_i      = uut.MEM_R_EN_exe;

    assign EXE_ALU_Result_o    = uut.ALU_res_exe;

    // ------------------------------------------------
    // Clock generation (10ns period)
    // ------------------------------------------------

    always #5 clk = ~clk;

    always @(posedge clk) begin
        cycle = cycle + 1;
    end

    // ------------------------------------------------
    // Check helper task
    // ------------------------------------------------
    task check_cycle(
        input string desc,
        input [31:0] exp_alu,
        input exp_wb,
        input exp_mem_w,
        input exp_mem_r,
        input exp_s
    );
        bit ok;
        begin
            ok = 1'b1;
            if (EXE_ALU_Result_o !== exp_alu) begin
                $display("  [FAIL] %s - ALU_Result mismatch: got 0x%08h, expected 0x%08h", desc, EXE_ALU_Result_o, exp_alu);
                ok = 1'b0;
            end
            if (EXE_WB_i !== exp_wb) begin
                $display("  [FAIL] %s - WB_EN mismatch: got %b, expected %b", desc, EXE_WB_i, exp_wb);
                ok = 1'b0;
            end
            if (EXE_MEM_W_EN_i !== exp_mem_w) begin
                $display("  [FAIL] %s - MEM_W_EN mismatch: got %b, expected %b", desc, EXE_MEM_W_EN_i, exp_mem_w);
                ok = 1'b0;
            end
            if (EXE_MEM_R_EN_i !== exp_mem_r) begin
                $display("  [FAIL] %s - MEM_R_EN mismatch: got %b, expected %b", desc, EXE_MEM_R_EN_i, exp_mem_r);
                ok = 1'b0;
            end
            if (EXE_S_i !== exp_s) begin
                $display("  [FAIL] %s - S mismatch: got %b, expected %b", desc, EXE_S_i, exp_s);
                ok = 1'b0;
            end

            if (ok) begin
                $display("  [PASS] %-30s | ALU=0x%08h | WB=%b | MW=%b | MR=%b | S=%b",
                         desc, EXE_ALU_Result_o, EXE_WB_i, EXE_MEM_W_EN_i, EXE_MEM_R_EN_i, EXE_S_i);
                pass_count = pass_count + 1;
            end else begin
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ------------------------------------------------
    // Main simulation and automated verification
    // ------------------------------------------------
    initial begin
        clk = 0;
        rst = 1;
        cycle = 0;
        pass_count = 0;
        fail_count = 0;

        #20;
        rst = 0;

        #300;

        $display("\n========================================================");
        $display("                   SIMULATION SUMMARY                   ");
        $display("========================================================");
        $display("  Total Tests Passed: %0d", pass_count);
        $display("  Total Tests Failed: %0d", fail_count);
        if (fail_count == 0) begin
            $display("  >>> SUCCESS: ALL EXE STAGE CHECKS PASSED! <<<");
        end else begin
            $display("  >>> FAILURE: SOME CHECKS FAILED! PLEASE REVIEW. <<<");
        end
        $display("========================================================\n");

        $finish;
    end

    // ------------------------------------------------
    // Automated Cycle-by-Cycle Checks & Console Logging
    // ------------------------------------------------
    initial begin
        $display("\n==========================================================================================");
        $display("Cycle | rst | EXE_S | SR_status{NZCV} | EXE_status{NZCV} | WB | MEM_W | MEM_R | ALU_Result");
        $display("==========================================================================================");

        forever @(posedge clk) begin
            #1; // Sample shortly after posedge

            $display(
                "%5d |  %b  |   %b   |      %b       |       %b       | %b  |   %b   |   %b   |  %08h",
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

            // Automated assertions based on the lab benchmark program
            case (cycle)
                4:  check_cycle("Inst 1: MOV R0, #20",              32'h00000014, 1'b1, 1'b0, 1'b0, 1'b0);
                5:  check_cycle("Inst 2: MOV R1, #4096",            32'h00001000, 1'b1, 1'b0, 1'b0, 1'b0);
                6:  check_cycle("Inst 3: MOV R2, #0xC0000000",      32'hC0000000, 1'b1, 1'b0, 1'b0, 1'b0);
                7:  check_cycle("Inst 4: ADDS R3, R2, R2",          32'h00000004, 1'b1, 1'b0, 1'b0, 1'b1);
                8:  check_cycle("Inst 5: ADC R4, R0, R0",           32'h00000000, 1'b1, 1'b0, 1'b0, 1'b0);
                9:  check_cycle("Inst 6: SUB R5, R4, R4, LSL #2",   32'hFFFFFFF4, 1'b1, 1'b0, 1'b0, 1'b0);
                10: check_cycle("Inst 7: SBC R6, R0, R0, LSR #1",   32'hFFFFFFFF, 1'b1, 1'b0, 1'b0, 1'b0);
                11: check_cycle("Inst 8: ORR R7, R5, R2, ASR #2",   32'h00000005, 1'b1, 1'b0, 1'b0, 1'b0);
                12: check_cycle("Inst 9: AND R8, R7, R3",           32'h00000003, 1'b1, 1'b0, 1'b0, 1'b0);
                13: check_cycle("Inst 10: MVN R9, R6",              32'hFFFFFFF9, 1'b1, 1'b0, 1'b0, 1'b0);
                14: check_cycle("Inst 11: EOR R10, R4, R5",         32'h00000001, 1'b1, 1'b0, 1'b0, 1'b0);
                15: begin
                    check_cycle("Inst 12: CMP R8, R6",              32'h00000002, 1'b0, 1'b0, 1'b0, 1'b1);
                    if (EXE_status_bits_o[1] === 1'b1) begin
                        $display("  [PASS] Inst 12: Carry Flag (C=1) verified on EXE_status_bits_o");
                        pass_count = pass_count + 1;
                    end else begin
                        $display("  [FAIL] Inst 12: Expected C=1 on EXE_status_bits_o, got %b", EXE_status_bits_o);
                        fail_count = fail_count + 1;
                    end
                end
                16: begin
                    check_cycle("Inst 13: ADDNE R1, R1, R1",        32'h00000002, 1'b1, 1'b0, 1'b0, 1'b0);
                    if (SR_status_bits_o[1] === 1'b1) begin
                        $display("  [PASS] Inst 13: Carry Flag (C=1) verified in Status Register (SR_status_bits_o)");
                        pass_count = pass_count + 1;
                    end else begin
                        $display("  [FAIL] Inst 13: Expected SR C=1, got %b", SR_status_bits_o);
                        fail_count = fail_count + 1;
                    end
                end
                17: check_cycle("Inst 14: TST R9, R8",              32'h00000008, 1'b0, 1'b0, 1'b0, 1'b1);
                18: begin
                    // Inst 15: ADDEQ R2, R2, R2 -> Since Z=0, EQ is false. Must be squashed (WB_EN=0)
                    if (EXE_WB_i === 1'b0 && EXE_MEM_W_EN_i === 1'b0) begin
                        $display("  [PASS] Inst 15: ADDEQ correctly SQUASHED (WB_EN=0) because Z=0");
                        pass_count = pass_count + 1;
                    end else begin
                        $display("  [FAIL] Inst 15: ADDEQ should be squashed, got WB_EN=%b", EXE_WB_i);
                        fail_count = fail_count + 1;
                    end
                end
                19: check_cycle("Inst 16: MOV R0, #1024",           32'h00000400, 1'b1, 1'b0, 1'b0, 1'b0);
                20: check_cycle("Inst 17: STR R1, [R0], #0",        32'h00000000, 1'b0, 1'b1, 1'b0, 1'b0);
                21: check_cycle("Inst 18: LDR R11, [R0], #0",       32'h00000000, 1'b1, 1'b0, 1'b1, 1'b0);
                default: ;
            endcase
        end
    end

endmodule
