module Hazard_Detection_Unit (
    input [3:0] src1,
    input [3:0] src2,
    input       Two_src,
    input [3:0] EXE_Dest,
    input       EXE_WB_EN,
    input [3:0] MEM_Dest,
    input       MEM_WB_EN,
    output reg  Hazard_Detected
);
    always @(*) begin
        Hazard_Detected = 1'b0;

        
        if (EXE_WB_EN) begin
            if ((src1 == EXE_Dest) || (Two_src && (src2 == EXE_Dest))) begin
                Hazard_Detected = 1'b1;
            end
        end

       
        if (MEM_WB_EN) begin
            if ((src1 == MEM_Dest) || (Two_src && (src2 == MEM_Dest))) begin
                Hazard_Detected = 1'b1;
            end
        end
    end
endmodule
