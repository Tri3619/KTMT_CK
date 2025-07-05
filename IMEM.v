module IMEM (
    input [29:0] addr,
    output [31:0] inst,
    // Thêm port debug
    output reg [31:0] memory [0:1023]
);
    initial $readmemh("memory.dat", memory);
    assign inst = memory[addr];
endmodule