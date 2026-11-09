module condition_check
(
    input  [3:0] condition,
    input  [3:0] SR,
    output reg inst_valid
);

    wire N = SR[3];
    wire Z = SR[2];
    wire C = SR[1];
    wire V = SR[0];

    always_comb begin
        case (condition)
            4'b0000: inst_valid = Z;    // Zero set (equal)                 
            4'b0001: inst_valid = ~Z;   // Zero clear (!equal)                

            4'b0010: inst_valid = C;    // Carry set    
            4'b0011: inst_valid = ~C;   // Carry clear     

            4'b0100: inst_valid = N;    // Negative set
            4'b0101: inst_valid = ~N;   // pozitive or zero set

            4'b0110: inst_valid = V;   // overflow
            4'b0111: inst_valid = ~V;  // !overflow

            4'b1000: inst_valid = C && ~Z; // a > b (unsigned)          
            4'b1001: inst_valid = ~C && Z; // a =< b (unsigned)

            4'b1010: inst_valid = (N==V); // a >= b (signed) 
            4'b1011: inst_valid = (N!=V); // a < b (signed)

            4'b1100: inst_valid = ~Z && (N==V); // a > b (signed)
            4'b1101: inst_valid = Z || (N!=V);  // a =< b (signed)

            4'b1110: inst_valid = 1'b1; // uncondition instruction (always execute it)
            4'b1111: inst_valid = 1'b0; // ?

            default: inst_valid = 1'b0;

        endcase
    end

endmodule
