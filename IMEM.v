module IMEM (
    input [29:0] addr,
    output [31:0] inst
);
    reg [31:0] mem [0:1023];
    initial $readmemh("memory.dat", mem);
    assign inst = mem[addr];
endmodule