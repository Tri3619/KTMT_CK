module ALU (
    input [31:0] A, B,
    input [3:0] ALUControl,
    output reg [31:0] alu_out
);
    wire [31:0] sum = (ALUControl[0] ? A - B : A + B);
    
    always @(*) begin
        case (ALUControl)
            4'b0000, 4'b0001: alu_out = sum; // ADD/SUB
            4'b0010: alu_out = A & B; // AND
            4'b0011: alu_out = A | B; // OR
            4'b0100: alu_out = A ^ B; // XOR
            4'b0101: alu_out = A << B[4:0]; // SLL
            4'b0110: alu_out = A >> B[4:0]; // SRL
            4'b0111: alu_out = $signed(A) >>> B[4:0]; // SRA
            4'b1000: alu_out = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // SLT
            4'b1001: alu_out = (A < B) ? 32'b1 : 32'b0; // SLTU
            4'b1010: alu_out = A * B; // MUL
            default: alu_out = 32'b0;
        endcase
    end
endmodule