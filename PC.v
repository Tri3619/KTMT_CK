module PC (
    input clk, rst_n,
    input [31:0] next_pc,
    input [31:0] imm_ext,
    input branch, jump, branch_take,
    output reg [31:0] pc,
    output [31:0] pc_plus4,
    output [31:0] pc_target
);
    // Internal calculations
    assign pc_plus4 = pc + 4;
    assign pc_target = pc + imm_ext;
    
    // PC update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            pc <= 32'b0;
        else 
            pc <= next_pc;
    end
endmodule