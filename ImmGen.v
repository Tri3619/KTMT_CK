module ImmGen (
    input [31:0] instruction,
    output reg [31:0] imm_ext
);
    always @(*) begin
        case (instruction[6:0])
            // I-type, LOAD, JALR
            7'b0010011, 7'b0000011, 7'b1100111: 
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};
            // S-type
            7'b0100011: 
                imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            // B-type
            7'b1100011: 
                imm_ext = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            // U-type
            7'b0110111, 7'b0010111: 
                imm_ext = {instruction[31:12], 12'b0};
            // J-type
            7'b1101111: 
                imm_ext = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            default: 
                imm_ext = 32'b0;
        endcase
    end
endmodule