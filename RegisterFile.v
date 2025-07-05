module RegFile (
    input clk, rst_n,
    input [4:0] rs1, rs2, rd,
    input [31:0] wr_data,
    input wr_en,
    output [31:0] rs1_data, rs2_data,
    output reg [31:0] regs [0:31]
);
    // Initialize registers
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end
    
    // Read operations (asynchronous)
    assign rs1_data = (rs1 != 0) ? regs[rs1] : 0;
    assign rs2_data = (rs2 != 0) ? regs[rs2] : 0;
    
    // Write operation (synchronous)
    always @(posedge clk) begin
        if (wr_en && rd != 0)
            regs[rd] <= wr_data;
    end
endmodule