`timescale 1ns / 1ns

module hazard ();

    reg clk;
    reg rst;
    integer cycle;
    integer hazard_count;
    integer bubble_count;
    integer pass_count;
    integer fail_count;

    // ----------------------------------------------------------------
    // ARM Instance with Integrated Hazard Detection Unit
    // ----------------------------------------------------------------
    ARM uut (
        .clk(clk),
        .rst(rst)
    );

    // ----------------------------------------------------------------
    // Pipeline Probe Aliases
    // ----------------------------------------------------------------
    wire [31:0] if_pc           = uut.pc_if;
    wire [31:0] if_inst         = uut.inst_if_out;
    wire [31:0] id_pc           = uut.pc_id;
    wire [31:0] id_inst         = uut.inst_id_in;

    wire        hazard_det      = uut.hazard_detected;
    wire        freeze_sig      = uut.freeze;
    wire [3:0]  src1_id         = uut.src1_id;
    wire [3:0]  src2_id         = uut.src2_id;
    wire        two_src_id      = uut.SS2;

    wire [31:0] exe_pc          = uut.pc_exe;
    wire [31:0] exe_alu_res     = uut.ALU_res_exe;
    wire [3:0]  exe_dest        = uut.Dest_exe;
    wire        exe_wb_en       = uut.WB_EN_exe;
    wire        exe_mem_w       = uut.MEM_W_EN_exe;
    wire        exe_mem_r       = uut.MEM_R_EN_exe;

    wire [31:0] mem_pc          = uut.pc_mem;
    wire [31:0] mem_alu_res     = uut.ALU_res_mem;
    wire [3:0]  mem_dest        = uut.Dest_mem;
    wire        mem_wb_en       = uut.WB_EN_mem;
    wire        mem_mem_w       = uut.MEM_W_EN_mem;
    wire        mem_mem_r       = uut.MEM_R_EN_mem;
    wire [31:0] mem_rdata       = uut.Mem_read_value_mem;

    wire [31:0] wb_pc           = uut.pc_wb;
    wire [31:0] wb_val          = uut.WB_Value;
    wire [3:0]  wb_dest         = uut.Dest_wb;
    wire        wb_en           = uut.WB_EN_wb;

    // ----------------------------------------------------------------
    // Clock Generator (10ns Period -> 100MHz)
    // ----------------------------------------------------------------
    always #5 clk = ~clk;

    always @(posedge clk) begin
        cycle = cycle + 1;
    end

    // ----------------------------------------------------------------
    // Verification Helper Task
    // ----------------------------------------------------------------
    task check_condition(input string test_name, input bit cond, input string details);
        begin
            if (cond) begin
                $display("  [PASS] %-40s | %s", test_name, details);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] %-40s | %s", test_name, details);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ----------------------------------------------------------------
    // Main Test Sequence
    // ----------------------------------------------------------------
    initial begin
        clk = 0;
        rst = 1;
        cycle = 0;
        hazard_count = 0;
        bubble_count = 0;
        pass_count = 0;
        fail_count = 0;

        $display("\n============================================================================================================================");
        $display("                                   ARM HAZARD UNIT SIMULATION START                                                        ");
        $display("============================================================================================================================");
        $display("Cycle | IF:PC | ID:Inst  | Hazard | Freeze | Src1 | Src2 | 2Src | EXE:ALU_Res | EXE:Dst | EXE_WB | MEM:Addr | MEM_W | MEM_R | WB:Val     | WB:Dst | WB_EN");
        $display("----------------------------------------------------------------------------------------------------------------------------");

        #20;
        rst = 0;

        // Run until end of benchmark (PC loops at 0x0000002e) or timeout
        fork : sim_run
            begin
                wait (cycle > 50 && if_pc == 32'h0000002e);
                #200; // Allow tail instructions to write back
                disable sim_run;
            end
            begin
                #50000; // 50 us safety timeout
                $display("\n  [TIMEOUT] Reached max simulation time limit!");
                disable sim_run;
            end
        join

        $display("\n==========================================================================");
        $display("                          HAZARD SIMULATION SUMMARY                       ");
        $display("==========================================================================");
        $display("  Total Simulation Cycles      : %0d", cycle);
        $display("  Total Hazard Events Detected : %0d", hazard_count);
        $display("  Total Bubbles Injected       : %0d", bubble_count);
        $display("  Passed Condition Checks      : %0d", pass_count);
        $display("  Failed Condition Checks      : %0d", fail_count);
        $display("--------------------------------------------------------------------------");
        $display("  Final Register File State (Benchmark Result R0 - R6):");
        for (int r = 0; r <= 6; r = r + 1) begin
            $display("    R%0d = 0x%08h (%0d)", r, uut.instruction_decode.reg_file.regs[r], $signed(uut.instruction_decode.reg_file.regs[r]));
        end
        $display("==========================================================================");

        if (hazard_count > 0 && fail_count == 0) begin
            $display("  >>> SUCCESS: HAZARD DETECTION & STALL MECHANISM OPERATING CORRECTLY! <<<");
        end else if (hazard_count == 0) begin
            $display("  >>> WARNING: NO HAZARDS DETECTED DURING SIMULATION! <<<");
        end else begin
            $display("  >>> FAILURE: SOME CHECKS FAILED! PLEASE REVIEW LOGS. <<<");
        end
        $display("==========================================================================\n");

        $finish;
    end

    // ----------------------------------------------------------------
    // Cycle Monitor and Hazard Assertion Checks
    // ----------------------------------------------------------------
    always @(posedge clk) begin
        #1; // Sample immediately after posedge
        if (!rst) begin
            $display(
                "%5d |  %04h | %08h |    %b   |    %b   |  R%02d |  R%02d |   %b  |  %08h   |   R%02d   |    %b   |   %04h   |   %b   |   %b   |  %08h  |   R%02d  |   %b",
                cycle,
                if_pc,
                id_inst,
                hazard_det,
                freeze_sig,
                src1_id,
                src2_id,
                two_src_id,
                exe_alu_res,
                exe_dest,
                exe_wb_en,
                mem_alu_res[10:0],
                mem_mem_w,
                mem_mem_r,
                wb_val,
                wb_dest,
                wb_en
            );

            // Track hazard events
            if (hazard_det) begin
                hazard_count = hazard_count + 1;
                $display("  >>> [HAZARD DETECTED] Cycle %0d: ID stalls! Src1=R%0d, Src2=R%0d against (EXE_Dest=R%0d, WB=%b) | (MEM_Dest=R%0d, WB=%b)",
                         cycle, src1_id, src2_id, exe_dest, exe_wb_en, mem_dest, mem_wb_en);

                // Check that freeze signal is strictly asserted when hazard is detected
                check_condition(
                    "Hazard: Freeze asserted",
                    (freeze_sig === 1'b1),
                    $sformatf("freeze=%b on hazard=1", freeze_sig)
                );
            end

            // Track bubble (NOP) injection into EXE stage
            if (uut.decode_reg.WB_EN === 1'b0 && uut.decode_reg.MEM_R_EN === 1'b0 && uut.decode_reg.MEM_W_EN === 1'b0 && uut.decode_reg.B === 1'b0) begin
                bubble_count = bubble_count + 1;
            end
        end
    end

    // ----------------------------------------------------------------
    // Monitor Register File Writebacks on negedge clk
    // ----------------------------------------------------------------
    always @(negedge clk) begin
        if (!rst && wb_en) begin
            #1; // Short delay after negedge write
            if (uut.instruction_decode.reg_file.regs[wb_dest] === wb_val) begin
                $display("      [RF-UPDATE] negedge clk: Register R%0d <= 0x%08h", wb_dest, wb_val);
            end
        end
    end

endmodule
