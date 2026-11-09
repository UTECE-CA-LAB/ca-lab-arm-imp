module alu (
    input [3:0] EXE_CMD,
    input [31:0] Val1, Val2,
    input c_in,
    output [3:0] Satus_bits,
    output [31:0] out
);

    reg [31:0] ALU_Res;
    reg n_flag, z_flag, c_flag, v_flag;

    always @(*) begin

        ALU_Res = 32'd0;
        n_flag = 1'b0;
        z_flag = 1'b0;
        c_flag = 1'b0;
        v_flag = 1'b0;

        case (EXE_CMD)

            4'b0001: begin // Pass Val2
                ALU_Res = Val2;
                n_flag = ALU_Res[31];
                z_flag = (ALU_Res == 32'd0);
            end

            4'b1001: begin // Pass ~Val2
                ALU_Res = ~Val2;
                n_flag = ALU_Res[31];
                z_flag = (ALU_Res == 32'd0);
            end

            4'b0010: begin // ADD
                {c_flag, ALU_Res} = {1'b0, Val1} + {1'b0, Val2};
                n_flag = ALU_Res[31];
                z_flag = (ALU_Res == 32'd0);
                v_flag = (Val1[31] == Val2[31]) && (ALU_Res[31] != Val1[31]);
            end

            4'b0011: begin // ADDC (Add with carry)
                {c_flag, ALU_Res} = {1'b0, Val1} + {1'b0, Val2} + c_in;
                n_flag = ALU_Res[31];
                z_flag = (ALU_Res == 32'd0);
                v_flag = (Val1[31] == Val2[31]) && (ALU_Res[31] != Val1[31]);
            end

            4'b0100: begin // SUB
                {c_flag, ALU_Res} = {1'b0, Val1} + {1'b0, ~Val2} + 33'b1;
                n_flag = ALU_Res[31];
                z_flag = (ALU_Res == 32'd0);
                v_flag = (Val1[31] != Val2[31]) && (ALU_Res[31] == Val2[31]);
            end

            4'b0101: begin // SUBC (Subtract with carry/borrow)
                {c_flag, ALU_Res} = {1'b0, Val1} + {1'b0, ~Val2} + {32'b0, c_in};
                n_flag = ALU_Res[31];
                z_flag = (ALU_Res == 32'd0);
                v_flag = (Val1[31] != Val2[31]) && (ALU_Res[31] == Val2[31]);
            end

            4'b0110: begin // AND
                ALU_Res = Val1 & Val2;
                n_flag = ALU_Res[31];
                z_flag = (ALU_Res == 32'd0);
            end

            4'b0111: begin // OR
                ALU_Res = Val1 | Val2;
                n_flag = ALU_Res[31];
                z_flag = (ALU_Res == 32'd0);
            end

            4'b1000: begin // XOR
                ALU_Res = Val1 ^ Val2;
                n_flag = ALU_Res[31];
                z_flag = (ALU_Res == 32'd0);
            end
            
            default: begin
                ALU_Res = 32'd0;
                n_flag = 1'b0;
                z_flag = 1'b1; 
                c_flag = 1'b0;
                v_flag = 1'b0;
            end
        endcase
    end

    assign out = ALU_Res;
    assign Satus_bits = {n_flag, z_flag, c_flag, v_flag};

endmodule