module MUX #(
    parameter INPUTS = 2
) (
    input [31:0] in0, in1, in2,
    input [$clog2(INPUTS)-1:0] select,
    output reg [31:0] out
);
    always @(*) begin
        if (INPUTS == 2) begin
            case (select)
                1'b0: out = in0;
                1'b1: out = in1;
                default: out = in0;
            endcase
        end
        else if (INPUTS == 3) begin
            case (select)
                2'b00: out = in0;
                2'b01: out = in1;
                2'b10: out = in2;
                default: out = in0;
            endcase
        end
    end
endmodule