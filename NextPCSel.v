module NextPCSel (
    input [31:0] PC_plus4,      // Đầu vào 32 bit: Giá trị PC + 4 (địa chỉ lệnh tiếp theo thông thường)
    input [31:0] PC_branch,     // Đầu vào 32 bit: Địa chỉ nhánh (branch) hoặc nhảy (jump) được tính toán
    input [31:0] JALR_target,   // Đầu vào 32 bit: Địa chỉ đích cho lệnh JALR
    input Branch,               // Đầu vào 1 bit: Tín hiệu điều khiển cho lệnh nhánh có điều kiện
    input Jump,                 // Đầu vào 1 bit: Tín hiệu điều khiển cho lệnh nhảy (JAL, JALR)
    input branch_taken,         // Đầu vào 1 bit: Tín hiệu xác định nhánh được thực hiện (từ BranchComp)
    input [6:0] op,             // Đầu vào 7 bit: Mã opcode, dùng để phân biệt JALR
    output [31:0] next_PC       // Đầu ra 32 bit: Giá trị PC tiếp theo cho lệnh kế tiếp
);
    // Gán giá trị PC tiếp theo dựa trên các điều kiện nhánh và nhảy
    assign next_PC = (Jump && (op == 7'b1100111)) ? JALR_target : // JALR: Chọn JALR_target
                     (Jump || (Branch && branch_taken)) ? PC_branch : // JAL hoặc nhánh thỏa mãn: Chọn PC_branch
                     PC_plus4; // Mặc định: Chọn PC + 4
endmodule