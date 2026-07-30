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

//Instruction Memory

module InstructionMemory(clk, rst, read_address, instruction_out);

    input clk, rst;
    input [31:0] read_address;
    output reg [31:0] instruction_out;
    integer k;

    reg [31:0] instruction_memory [63:0];

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            for (k = 0; k < 64; k = k + 1) begin
                instruction_memory[k] <= 32'b0;
            end
        end
        else
        instruction_out <= instruction_memory[read_address];
    end
endmodule

//Register File

module RegisterFile(clk, rst, RegWrite, Reg1, Reg2, destination_reg, write_data, read_data1, read_data2);

    input clk, rst, RegWrite;
    input [4:0] Reg1, Reg2, destination_reg;
    input [31:0] write_data;
    output reg [31:0] read_data1, read_data2;
    integer k;

    reg [31:0] Registers[31:0];

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            for (k = 0; k < 32; k = k + 1) begin
                Registers[k] <= 32'b0;
            end
        end
        else if (RegWrite)
        begin
            Registers[destination_reg] <= write_data;
        end
    end

    assign read_data1 = Registers[Reg1];
    assign read_data2 = Registers[Reg2];
    
endmodule