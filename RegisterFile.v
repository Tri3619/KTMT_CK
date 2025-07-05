module RegisterFile (
    input clk,                    // Đầu vào: Tín hiệu xung nhịp
    input rst_n,                  // Đầu vào: Tín hiệu reset (active-low)
    input [4:0] addA, addB,       // Đầu vào 5 bit: Địa chỉ thanh ghi nguồn rs1 và rs2
    input [4:0] addD,             // Đầu vào 5 bit: Địa chỉ thanh ghi đích rd
    input [31:0] WB_out,          // Đầu vào 32 bit: Dữ liệu cần ghi vào thanh ghi đích
    input RegWrite,               // Đầu vào 1 bit: Tín hiệu điều khiển cho phép ghi vào thanh ghi
    output [31:0] dataA, dataB,   // Đầu ra 32 bit: Dữ liệu đọc từ thanh ghi rs1 và rs2
    output reg [31:0] registers [0:31] // Đầu ra: Mảng 32 thanh ghi, mỗi thanh ghi 32 bit
);
    // Khối always xử lý ghi thanh ghi tại cạnh lên của xung nhịp hoặc khi reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin         // Nếu rst_n = 0 (reset được kích hoạt)
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0; // Đặt tất cả 32 thanh ghi về 0
            end
        end
        else if (RegWrite && addD != 0) begin // Nếu RegWrite = 1 và địa chỉ đích không phải x0
            registers[addD] <= WB_out; // Ghi dữ liệu WB_out vào thanh ghi đích addD
        end
    end

    // Gán dữ liệu đọc từ thanh ghi rs1 và rs2 vào đầu ra
    assign dataA = registers[addA]; // Đọc dữ liệu từ thanh ghi tại địa chỉ addA
    assign dataB = registers[addB]; // Đọc dữ liệu từ thanh ghi tại địa chỉ addB
endmodule