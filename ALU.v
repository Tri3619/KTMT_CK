module ALU (
    input [31:0] a, b,
    input [3:0] op,
    output reg [31:0] res
);
    wire [31:0] sum = (op[0] ? a - b : a + b);
    
    always @(*) begin
        case (op)
            4'b0000, 4'b0001: res = sum; // ADD/SUB
            4'b0010: res = a & b; // AND
            4'b0011: res = a | b; // OR
            4'b0100: res = a ^ b; // XOR
            4'b0101: res = a << b[4:0]; // SLL
            4'b0110: res = a >> b[4:0]; // SRL
            4'b0111: res = $signed(a) >>> b[4:0]; // SRA
            4'b1000: res = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT
            4'b1001: res = (a < b) ? 32'b1 : 32'b0; // SLTU
            4'b1010: res = a * b; // MUL
            default: res = 32'b0;
        endcase
    end
endmodule