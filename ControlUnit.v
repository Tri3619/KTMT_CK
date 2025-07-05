module ControlUnit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input [11:0] imm,
    output reg RegWrite,
    output reg ALUSrc,
    output reg ALUSrc_pc,
    output reg MemWrite,
    output reg MemRead,
    output reg [1:0] ResultSrc,
    output reg Branch,
    output reg Jump,
    output reg Halt,
    output reg [1:0] ALUOp,
    output reg [3:0] ALUControl
);
    // Main control logic
    always @(*) begin
        // Default values
        RegWrite = 0;
        ALUSrc = 0;
        ALUSrc_pc = 0;
        MemWrite = 0;
        MemRead = 0;
        ResultSrc = 2'b00;
        Branch = 0;
        Jump = 0;
        Halt = 0;
        ALUOp = 2'b00;
        ALUControl = 4'b0000;
        
        case (opcode)
            // R-type instructions
            7'b0110011: begin
                RegWrite = 1;
                ALUOp = 2'b10;
                case (funct3)
                    3'b000: ALUControl = funct7[5] ? 4'b0001 : 4'b0000; // SUB/ADD
                    3'b001: ALUControl = 4'b0101; // SLL
                    3'b010: ALUControl = 4'b1000; // SLT
                    3'b011: ALUControl = 4'b1001; // SLTU
                    3'b100: ALUControl = 4'b0100; // XOR
                    3'b101: ALUControl = funct7[5] ? 4'b0111 : 4'b0110; // SRA/SRL
                    3'b110: ALUControl = 4'b0011; // OR
                    3'b111: ALUControl = 4'b0010; // AND
                endcase
            end
            
            // I-type instructions
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUOp = 2'b10;
                case (funct3)
                    3'b000: ALUControl = 4'b0000; // ADDI
                    3'b010: ALUControl = 4'b1000; // SLTI
                    3'b011: ALUControl = 4'b1001; // SLTIU
                    3'b100: ALUControl = 4'b0100; // XORI
                    3'b110: ALUControl = 4'b0011; // ORI
                    3'b111: ALUControl = 4'b0010; // ANDI
                    3'b001: ALUControl = 4'b0101; // SLLI
                    3'b101: ALUControl = funct7[5] ? 4'b0111 : 4'b0110; // SRAI/SRLI
                endcase
            end
            
            // Load instructions
            7'b0000011: begin
                RegWrite = 1;
                ALUSrc = 1;
                MemRead = 1;
                ResultSrc = 2'b01;
                ALUControl = 4'b0000; // ADD
            end
            
            // Store instructions
            7'b0100011: begin
                ALUSrc = 1;
                MemWrite = 1;
                ALUControl = 4'b0000; // ADD
            end
            
            // Branch instructions
            7'b1100011: begin
                Branch = 1;
                ALUOp = 2'b01;
                ALUControl = 4'b0001; // SUB
            end
            
            // JAL
            7'b1101111: begin
                RegWrite = 1;
                Jump = 1;
                ALUSrc_pc = 1;
                ResultSrc = 2'b10;
                ALUControl = 4'b0000; // ADD
            end
            
            // JALR
            7'b1100111: begin
                RegWrite = 1;
                Jump = 1;
                ALUSrc = 1;
                ResultSrc = 2'b10;
                ALUControl = 4'b0000; // ADD
            end
            
            // LUI
            7'b0110111: begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUControl = 4'b0000; // ADD (result = imm)
            end
            
            // AUIPC
            7'b0010111: begin
                RegWrite = 1;
                ALUSrc_pc = 1;
                ALUSrc = 1;
                ALUControl = 4'b0000; // ADD
            end
            
            // System instructions
            7'b1110011: begin
                Halt = (funct3 == 3'b000 && (imm == 12'h000 || imm == 12'h001));
            end
            
            default: begin
                // Handle undefined opcodes
                RegWrite = 0;
                ALUSrc = 0;
                ALUSrc_pc = 0;
                MemWrite = 0;
                MemRead = 0;
                ResultSrc = 2'b00;
                Branch = 0;
                Jump = 0;
                Halt = 0;
                ALUOp = 2'b00;
                ALUControl = 4'b0000;
            end
        endcase
    end
endmodule