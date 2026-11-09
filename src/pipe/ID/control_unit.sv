module control_unit (
    input [3:0] opcode,
    input [1:0] Mode,
    input S,
    output [8:0] out
);

    reg WB_EN, MEM_R_EN, MEM_W_EN, B;
    reg [3:0] ALU_COM;
    reg S_out;

    always @(*) begin
        
        WB_EN = 1'b0;
        MEM_R_EN = 1'b0;
        MEM_W_EN = 1'b0;
        B = 1'b0;
        ALU_COM = 4'b0000;
        S_out = 1'b0;

        if (Mode == 2'b10) begin
            B = 1;
            WB_EN = 0;
            MEM_R_EN = 0;
            MEM_W_EN = 0;
            ALU_COM = 4'b0000;
            S_out = 1'b0;
        end 

        else begin
            case (opcode)

                4'b0000: begin // AND
                    WB_EN   = 1'b1;
                    ALU_COM = 4'b0110;
                    S_out   = (Mode == 2'b00) ? S : 1'b0;
                end

                4'b0001: begin // EOR
                    WB_EN   = 1'b1;
                    ALU_COM = 4'b1000;
                    S_out   = (Mode == 2'b00) ? S : 1'b0;
                end

                4'b0010: begin // SUB
                    WB_EN   = 1'b1;
                    ALU_COM = 4'b0100;
                    S_out   = (Mode == 2'b00) ? S : 1'b0;
                end

                4'b0100: begin // ADD / LDR / STR
                    if (Mode == 2'b00) begin
                        WB_EN   = 1'b1; 
                        ALU_COM = 4'b0010;
                        S_out   = S;
                    end else if (Mode == 2'b01) begin
                        ALU_COM = 4'b0010; 
                        S_out   = 1'b0; // Memory instructions do not update flags
                        if (S) begin
                            MEM_R_EN = 1'b1;
                            WB_EN    = 1'b1;
                        end
                        else begin
                            MEM_W_EN = 1'b1;
                        end 
                    end
                end

                4'b0101: begin // ADC
                    WB_EN   = 1'b1;
                    ALU_COM = 4'b0011;
                    S_out   = (Mode == 2'b00) ? S : 1'b0;
                end

                4'b0110: begin // SBC
                    WB_EN   = 1'b1;
                    ALU_COM = 4'b0101;
                    S_out   = (Mode == 2'b00) ? S : 1'b0;
                end

                4'b1100: begin // ORR
                    WB_EN   = 1'b1;
                    ALU_COM = 4'b0111;
                    S_out   = (Mode == 2'b00) ? S : 1'b0;
                end

                4'b1101: begin // MOV
                    WB_EN   = 1'b1;
                    ALU_COM = 4'b0001;
                    S_out   = (Mode == 2'b00) ? S : 1'b0;
                end

                4'b1111: begin // MVN
                    WB_EN   = 1'b1;
                    ALU_COM = 4'b1001;
                    S_out   = (Mode == 2'b00) ? S : 1'b0;
                end

                4'b1000: begin // TST
                    ALU_COM = 4'b0110;
                    S_out   = 1'b1; // TST always updates flags
                end

                4'b1010: begin // CMP
                    ALU_COM = 4'b0100;
                    S_out   = 1'b1; // CMP always updates flags
                end

                default: begin
                    ALU_COM = 4'b0000;
                    S_out   = 1'b0;
                end

            endcase
        end
    end

    assign out = {WB_EN, MEM_R_EN, MEM_W_EN, ALU_COM, S_out, B};

endmodule
