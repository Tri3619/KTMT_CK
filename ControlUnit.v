module ControlUnit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input [11:0] imm,
    output reg reg_wr,
    output reg alu_src,
    output reg pc_src,
    output reg mem_wr,
    output reg mem_rd,
    output reg [1:0] wb_sel,
    output reg branch,
    output reg jal,
    output reg jalr,
    output reg halt,
    output reg [3:0] alu_ctrl
);
    // Main control logic
    always @(*) begin
        // Default values
        reg_wr = 0;
        alu_src = 0;
        pc_src = 0;
        mem_wr = 0;
        mem_rd = 0;
        wb_sel = 2'b00;
        branch = 0;
        jal = 0;
        jalr = 0;
        halt = 0;
        alu_ctrl = 4'b0000; // ADD
        
        case (opcode)
            // R-type instructions
            7'b0110011: begin
                reg_wr = 1;
                case (funct3)
                    3'b000: alu_ctrl = funct7[5] ? 4'b0001 : 4'b0000; // SUB/ADD
                    3'b001: alu_ctrl = 4'b0101; // SLL
                    3'b010: alu_ctrl = 4'b1000; // SLT
                    3'b011: alu_ctrl = 4'b1001; // SLTU
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    3'b101: alu_ctrl = funct7[5] ? 4'b0111 : 4'b0110; // SRA/SRL
                    3'b110: alu_ctrl = 4'b0011; // OR
                    3'b111: alu_ctrl = 4'b0010; // AND
                endcase
            end
            
            // I-type instructions
            7'b0010011: begin
                reg_wr = 1;
                alu_src = 1;
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000; // ADDI
                    3'b010: alu_ctrl = 4'b1000; // SLTI
                    3'b011: alu_ctrl = 4'b1001; // SLTIU
                    3'b100: alu_ctrl = 4'b0100; // XORI
                    3'b110: alu_ctrl = 4'b0011; // ORI
                    3'b111: alu_ctrl = 4'b0010; // ANDI
                    3'b001: alu_ctrl = 4'b0101; // SLLI
                    3'b101: alu_ctrl = funct7[5] ? 4'b0111 : 4'b0110; // SRAI/SRLI
                endcase
            end
            
            // Load instructions
            7'b0000011: begin
                reg_wr = 1;
                alu_src = 1;
                mem_rd = 1;
                wb_sel = 2'b01;
                alu_ctrl = 4'b0000; // ADD
            end
            
            // Store instructions
            7'b0100011: begin
                alu_src = 1;
                mem_wr = 1;
                alu_ctrl = 4'b0000; // ADD
            end
            
            // Branch instructions
            7'b1100011: begin
                branch = 1;
                pc_src = 1;
                alu_ctrl = 4'b0001; // SUB
            end
            
            // JAL
            7'b1101111: begin
                reg_wr = 1;
                jal = 1;
                pc_src = 1;
                wb_sel = 2'b10;
                alu_ctrl = 4'b0000; // ADD
            end
            
            // JALR
            7'b1100111: begin
                reg_wr = 1;
                jalr = 1;
                alu_src = 1;
                wb_sel = 2'b10;
                alu_ctrl = 4'b0000; // ADD
            end
            
            // LUI
            7'b0110111: begin
                reg_wr = 1;
                alu_src = 1;
                alu_ctrl = 4'b0000; // ADD (result = imm)
            end
            
            // AUIPC
            7'b0010111: begin
                reg_wr = 1;
                pc_src = 1;
                alu_src = 1;
                alu_ctrl = 4'b0000; // ADD
            end
            
            // System instructions
            7'b1110011: begin
                halt = (funct3 == 3'b000 && (imm == 12'h000 || imm == 12'h001));
            end
        endcase
    end
endmodule