module DataMem (
    input clk,
    input wr_en,
    input rd_en,
    input [31:0] addr,
    input [31:0] wr_data,
    input [2:0] funct3,
    output reg [31:0] rd_data
);
    // 4KB byte-addressable memory
    reg [7:0] mem [0:4095];
    
    // Read operation
    always @(*) begin
        rd_data = 32'b0;
        if (rd_en) begin
            case (funct3)
                3'b000: // LB
                    rd_data = {{24{mem[addr][7]}}, mem[addr]};
                3'b001: // LH
                    rd_data = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};
                3'b010: // LW
                    rd_data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                3'b100: // LBU
                    rd_data = {24'b0, mem[addr]};
                3'b101: // LHU
                    rd_data = {16'b0, mem[addr+1], mem[addr]};
            endcase
        end
    end
    
    // Write operation
    always @(posedge clk) begin
        if (wr_en) begin
            case (funct3)
                3'b000: // SB
                    mem[addr] <= wr_data[7:0];
                3'b001: begin // SH
                    mem[addr]   <= wr_data[7:0];
                    mem[addr+1] <= wr_data[15:8];
                end
                3'b010: begin // SW
                    mem[addr]   <= wr_data[7:0];
                    mem[addr+1] <= wr_data[15:8];
                    mem[addr+2] <= wr_data[23:16];
                    mem[addr+3] <= wr_data[31:24];
                end
            endcase
        end
    end
endmodule