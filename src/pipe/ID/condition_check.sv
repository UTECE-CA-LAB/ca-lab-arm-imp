module condition_check
(
    input  [3:0] Cond,
    input  [3:0] SR,
    output reg out
);

    wire N = SR[0];
    wire Z = SR[1];
    wire C = SR[2];
    wire V = SR[3];

    always @(*) begin
        case (Cond)
            4'b0000: out = Z;                 
            4'b0001: out = ~Z;                

            4'b0010: out = C;                  
            4'b0011: out = ~C;                

            4'b0100: out = N;                  
            4'b0101: out = ~N;               

            4'b0110: out = V;                 
            4'b0111: out = ~V;                 

            4'b1000: out = C && ~Z;          
            4'b1001: out = ~C && Z;           

            4'b1010: out = (N==V);             
            4'b1011: out = (N!=V);           

            4'b1100: out = ~Z && (N==V);      
            4'b1101: out = Z || (N!=V);      

            4'b1110: out = 1'b1;              
            4'b1111: out = 1'b0;              

            default: out = 1'b0;

        endcase
    end

endmodule
