module ALU (
    input [31:0] A, B,           // Hai đầu vào A và B, mỗi đầu vào là 32 bit
    input [3:0] ALUControl,      // Đầu vào điều khiển ALU, 4 bit, xác định phép toán cần thực hiện
    output reg [31:0] alu_out    // Đầu ra của ALU, 32 bit, lưu kết quả của phép toán
);
    wire [31:0] sum;             // Biến trung gian lưu kết quả của phép cộng hoặc trừ

    // Phép toán cộng hoặc trừ được thực hiện dựa trên ALUControl[0]
    // Nếu ALUControl[0] = 0: thực hiện A + B (cộng)
    // Nếu ALUControl[0] = 1: thực hiện A + (~B + 1) (trừ, tương đương với A - B)
    assign sum = (!ALUControl[0]) ? A + B : (A + (~B + 1));

    // Khối always thực hiện các phép toán dựa trên giá trị của ALUControl
    always @(*) begin
        case (ALUControl)
            4'b0000, 4'b0001: alu_out = sum; // 0000: ADD (cộng), 0001: SUB (trừ)
            4'b0010: alu_out = A & B;        // 0010: AND (phép AND bit-wise)
            4'b0011: alu_out = A | B;        // 0011: OR (phép OR bit-wise)
            4'b0100: alu_out = A ^ B;        // 0100: XOR (phép XOR bit-wise)
            4'b0101: alu_out = A << B[4:0];  // 0101: SLL (dịch trái logic, sử dụng 5 bit thấp của B)
            4'b0110: alu_out = A >> B[4:0];  // 0110: SRL (dịch phải logic, sử dụng 5 bit thấp của B)
            4'b0111: alu_out = $signed(A) >>> B[4:0]; // 0111: SRA (dịch phải số học, giữ bit dấu)
            4'b1000: alu_out = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // 1000: SLT (so sánh có dấu, trả về 1 nếu A < B)
            4'b1001: alu_out = (A < B) ? 32'b1 : 32'b0; // 1001: SLTU (so sánh không dấu, trả về 1 nếu A < B)
            4'b1010: alu_out = A * B;        // 1010: MUL (phép nhân)
            default: alu_out = 32'b0;        // Trường hợp mặc định: đầu ra bằng 0 nếu ALUControl không hợp lệ
        endcase
    end
endmodule