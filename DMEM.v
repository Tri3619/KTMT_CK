module DMEM (
    input clk, 
    input MemWrite, 
    input MemRead,
    input [31:0] address,
    input [31:0] write_data,
    input [2:0] funct3,
    output reg [31:0] read_data
);
    // Word-addressable memory (4KB: 1024 words)
    reg [31:0] memory [0:1023];
    wire [9:0] word_address = address[11:2]; // Use 10 bits for word addressing

    // Read operation
    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b000: // lb
                    read_data = {{24{memory[word_address][7]}}, memory[word_address][7:0]};
                3'b001: // lh
                    read_data = {{16{memory[word_address][15]}}, memory[word_address][15:0]};
                3'b010: // lw
                    read_data = memory[word_address];
                3'b100: // lbu
                    read_data = {24'b0, memory[word_address][7:0]};
                3'b101: // lhu
                    read_data = {16'b0, memory[word_address][15:0]};
                default: 
                    read_data = 32'b0;
            endcase
        end
        else begin
            read_data = 32'b0;
        end
    end

    // Write operation
    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: // sb
                    memory[word_address][7:0] <= write_data[7:0];
                3'b001: // sh
                    memory[word_address][15:0] <= write_data[15:0];
                3'b010: // sw
                    memory[word_address] <= write_data;
                default: ; // Do nothing
            endcase
        end
    end
endmodule