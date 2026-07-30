//Program Counter
module Program_Counter(clk, rst, PC_in, PC_out);
    input clk, rst;
    input [31:0] PC_in;
    output reg [31:0] PC_out;

    always @(posedge clk or posedge rst)
    begin
        if(rst)
            PC_out <= 32'b0;
        else
            PC_out <= PC_in;
    end
endmodule

//PC + 4

module PCplus4(fromPC, NextoPC);
    input [31:0] fromPC;
    output [31:0] NextoPC;

    assign NextoPC = fromPC + 4;

endmodule

