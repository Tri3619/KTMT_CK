module BranchComp (
    input [31:0] a, b,
    input [2:0] funct3,
    output take
);
    assign take = (funct3 == 3'b000) ? (a == b) : // BEQ
                 (funct3 == 3'b001) ? (a != b) : // BNE
                 (funct3 == 3'b100) ? ($signed(a) < $signed(b)) : // BLT
                 (funct3 == 3'b101) ? ($signed(a) >= $signed(b)) : // BGE
                 (funct3 == 3'b110) ? (a < b) : // BLTU
                 (funct3 == 3'b111) ? (a >= b) : // BGEU
                 1'b0;
endmodule