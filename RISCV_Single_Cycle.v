module RISCV_Single_Cycle (
    input clk, rst_n,
    output [31:0] Instruction_out_top,
    output [31:0] PC_out_top,
    output [31:0] registers [0:31]
);
    // Internal signals
    reg [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4 = pc + 4;
    wire [31:0] pc_target;
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

    // PC update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            pc <= 32'b0;
        else 
            pc <= pc_next;
    end
    
    // Calculate PC target
    assign pc_target = pc + imm;

    // Instruction Memory (giữ tên instance IMEM_inst)
    IMEM IMEM_inst (
        .addr(pc[31:2]),
        .inst(inst)
    );

    // Control Unit
    ControlUnit ControlUnit_inst (
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
    RegFile RegFile_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wr_data(wb_data),
        .wr_en(reg_wr),
        .rs1_data(reg_data1),
        .rs2_data(reg_data2),
        .registers(registers)
    );

    // Immediate Generator
    ImmGen ImmGen_inst (
        .inst(inst),
        .imm_ext(imm)
    );

    // ALU Operand Selection
    assign alu_op1 = pc_src ? pc : reg_data1;
    assign alu_op2 = alu_src ? imm : reg_data2;

    // Arithmetic Logic Unit
    ALU ALU_inst (
        .a(alu_op1),
        .b(alu_op2),
        .ALUControl(alu_ctrl),
        .alu_out(alu_result)
    );

    // Branch Comparator
    BranchComp BranchComp_inst (
        .op(inst[6:0]),
        .funct3(inst[14:12]),
        .rs1_data(reg_data1),
        .rs2_data(reg_data2),
        .branch_taken(branch_take)
    );

    // Data Memory (giữ tên instance DMEM_inst)
    DMEM DMEM_inst (
        .clk(clk),
        .MemWrite(mem_wr),
        .MemRead(mem_rd),
        .address(alu_result),
        .write_data(reg_data2),
        .funct3(inst[14:12]),
        .read_data(mem_data)
    );

    // Writeback Data Selection
    assign wb_data = (wb_sel == 2'b00) ? alu_result : 
                    (wb_sel == 2'b01) ? mem_data : 
                    (wb_sel == 2'b10) ? pc_plus4 : 
                    32'b0;

    // Next PC Selection
    assign pc_next = halt ? pc : 
                    is_jalr ? alu_result : 
                    (branch && branch_take) || is_jal ? pc_target : 
                    pc_plus4;

    // Output assignments
    assign Instruction_out_top = halt ? 32'hxxxxxxxx : inst;
    assign PC_out_top = pc;
endmodule