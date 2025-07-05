module ImmGen (
    input [31:0] instruction,    // Đầu vào 32 bit: Lệnh RISC-V chứa trường immediate
    input [2:0] imm_sel,         // Đầu vào 3 bit: Tín hiệu điều khiển chọn loại immediate
    output reg [31:0] imm_ext    // Đầu ra 32 bit: Giá trị immediate đã được mở rộng dấu
);
    // Khối always để xử lý mở rộng immediate dựa trên imm_sel
    always @(*) begin
        case (imm_sel)
            3'b001: // I-type (LOAD, I-type arithmetic, JALR)
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};
                // Lấy 12 bit từ [31:20], mở rộng dấu bằng cách sao chép bit dấu (instruction[31]) vào 20 bit cao
            
            3'b010: // S-type (STORE)
                imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                // Lấy 12 bit từ [31:25] và [11:7], mở rộng dấu bằng bit instruction[31]
            
            3'b011: // B-type (BRANCH)
                imm_ext = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                // Lấy các bit [31], [7], [30:25], [11:8], thêm bit 0 ở cuối để tạo immediate 13 bit (chia hết cho 2), mở rộng dấu
            
            3'b100: // U-type (LUI, AUIPC)
                imm_ext = {instruction[31:12], 12'b0};
                // Lấy 20 bit từ [31:12], thêm 12 bit 0 ở cuối, không cần mở rộng dấu (đã đúng 32 bit)
            
            3'b101: // J-type (JAL)
                imm_ext = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                // Lấy các bit [31], [19:12], [20], [30:21], thêm bit 0 ở cuối để tạo immediate 21 bit (chia hết cho 2), mở rộng dấu
            
            default: // Trường hợp không hợp lệ
                imm_ext = 32'b0;
                // Trả về 0 nếu imm_sel không hợp lệ
        endcase
    end
endmodule