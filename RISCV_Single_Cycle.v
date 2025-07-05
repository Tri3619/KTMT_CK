module RISCV_Single_Cycle (
    input clk, rst_n,
    output [31:0] inst_out,
    output [31:0] pc_out,
    output [31:0] regs [0:31]
);
    // Internal signals
    wire [31:0] pc_next, pc_curr, pc_plus4, pc_target;
    wire [31:0] inst;
    wire [4:0] rs1 = inst[19:15];
    wire [4:0] rs2 = inst[24:20];
    wire [4:0] rd  = inst[11:7];
    wire [31:0] imm;
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] alu_op1, alu_op2;
    wire [31:0] alu_result;
    wire [31:0] mem_data;
    wire [31:0] wb_data;
    wire [3:0]  alu_ctrl;
    wire        reg_wr;
    wire        alu_src;
    wire        pc_src;
    wire        mem_wr;
    wire        mem_rd;
    wire [1:0]  wb_sel;
    wire        branch;
    wire        branch_take;
    wire        is_jal;
    wire        is_jalr;
    wire        halt;

    // Program Counter with integrated adders
    PC pc_unit (
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(pc_next),
        .imm_ext(imm),
        .branch(branch),
        .jump(is_jal || is_jalr),
        .branch_take(branch_take),
        .pc(pc_curr),
        .pc_plus4(pc_plus4),
        .pc_target(pc_target)
    );

    // Instruction Memory
    InstMem imem (
        .addr(pc_curr[31:2]),
        .inst(inst)
    );

    // Control Unit with integrated ALU Control
    ControlUnit ctrl (
        .opcode(inst[6:0]),
        .funct3(inst[14:12]),
        .funct7(inst[31:25]),
        .imm(inst[31:20]),
        .reg_wr(reg_wr),
        .alu_src(alu_src),
        .pc_src(pc_src),
        .mem_wr(mem_wr),
        .mem_rd(mem_rd),
        .wb_sel(wb_sel),
        .branch(branch),
        .jal(is_jal),
        .jalr(is_jalr),
        .halt(halt),
        .alu_ctrl(alu_ctrl)
    );

    // Register File
    RegFile regs_unit (
        .clk(clk),
        .rst_n(rst_n),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wr_data(wb_data),
        .wr_en(reg_wr),
        .rs1_data(reg_data1),
        .rs2_data(reg_data2),
        .regs(regs)
    );

    // Immediate Generator
    ImmGen imm_gen (
        .inst(inst),
        .imm(imm)
    );

    // ALU Operand Selection
    assign alu_op1 = pc_src ? pc_curr : reg_data1;
    assign alu_op2 = alu_src ? imm : reg_data2;

    // Arithmetic Logic Unit
    ALU alu (
        .a(alu_op1),
        .b(alu_op2),
        .op(alu_ctrl),
        .res(alu_result)
    );

    // Branch Comparator
    BranchComp branch_comp (
        .a(reg_data1),
        .b(reg_data2),
        .funct3(inst[14:12]),
        .take(branch_take)
    );

    // Data Memory
    DataMem dmem (
        .clk(clk),
        .wr_en(mem_wr),
        .rd_en(mem_rd),
        .addr(alu_result),
        .wr_data(reg_data2),
        .funct3(inst[14:12]),
        .rd_data(mem_data)
    );

    // Writeback Data Selection
    assign wb_data = (wb_sel == 2'b00) ? alu_result :
                    (wb_sel == 2'b01) ? mem_data :
                    (wb_sel == 2'b10) ? pc_plus4 : 0;

    // Next PC Selection
    assign pc_next = halt ? pc_curr :
                    is_jalr ? {alu_result[31:1], 1'b0} : // Clear LSB for alignment
                    (branch && branch_take) || is_jal ? pc_target : 
                    pc_plus4;

    // Output assignments
    assign inst_out = halt ? 32'hxxxxxxxx : inst;
    assign pc_out = pc_curr;
endmodule