module ARM_WRAP (
    input clk,
    input key1
);

    wire deb_out, rst;

    debouncer deb_inst (
        .SIGNAL_I(key1),
        .CLK_I(clk),
        .SIGNAL_O(deb_out)
    );
    assign rst = ~deb_out;

    ARM ARM_inst (
        .clk(clk),
        .rst(rst)
    );

    ILA ila_inst (
        .clk(clk),

        .probe0(rst),                    // [0:0]
        .probe1(ARM_inst.pc_if),         // [31:0]
        .probe2(ARM_inst.pc_id),         // [31:0]
        .probe3(ARM_inst.pc_exe),        // [31:0]
        .probe4(ARM_inst.pc_mem),        // [31:0]
        .probe5(ARM_inst.pc_wb),         // [31:0]
        .probe6(ARM_inst.inst_id_in),     // [31:0] ID instruction (from IF/ID reg)
        .probe8(ARM_inst.instruction_decode.reg_file.regs[0]), // input wire [31:0]  probe8 
        .probe9(ARM_inst.instruction_decode.reg_file.regs[1]), // input wire [31:0]  probe9 
        .probe10(ARM_inst.instruction_decode.reg_file.regs[2]), // input wire [31:0]  probe10 
        .probe11(ARM_inst.instruction_decode.reg_file.regs[3]), // input wire [31:0]  probe11 
        .probe12(ARM_inst.instruction_decode.reg_file.regs[4]), // input wire [31:0]  probe12 
        .probe13(ARM_inst.instruction_decode.reg_file.regs[5]), // input wire [31:0]  probe13 
        .probe14(ARM_inst.instruction_decode.reg_file.regs[6]) // input wire [31:0]  probe14
    );

endmodule
