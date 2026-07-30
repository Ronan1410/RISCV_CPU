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

// Immediate Generator
module Immediate_Generator(Opcode, instruction, Immediate_extent);
    input [6:0] Opcode;
    input [31:0] instruction;
    output reg [31:0] Immediate_extent;

    always @(*) begin
        case (Opcode)
            7'b0000011: Immediate_extent = {{20{instruction[31]}}, instruction[31:20]}; // I-type
            7'b0100011: Immediate_extent = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S-type
            7'b1100011: Immediate_extent = {{19{instruction[31]}}, instruction[31], instruction[30:25], instruction[11:0], 1'b0}; // B-type
            default: Immediate_extent = 32'b0;
        endcase
    end
endmodule


//Control Unit
module Control_Unit(instruction, Branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite);

    input [6:0] instruction;
    output reg Branch, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite;
    output reg [1:0] ALUOp;

    always @(*)
    begin
        case(instruction)
            7'b0110011: //R-type
            {
                ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp
            } <= 8'b001000_01;

            7'b0000011: //I-type
            {
                ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp
            } <= 8'b111100_00;

            7'b0100011: //S-type
            {
                ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp
            } <= 8'b100010_00;

            7'b1100011: //B-type
            {
                ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp
            } <= 8'b000001_01;
        endcase
    end
endmodule


//ALU

module ALU_unit(A, B, Control_in, ALU_Result, zero);

    input [31:0] A, B;
    input [3:0] Control_in;
    output reg [31:0] ALU_Result;
    output reg zero;

    always @(Control_in, A, B)
    begin
        case(Control_in)
            4'b0000: //AND
            begin
                zero <= 0;
                ALU_Result <= A & B;
            end
            4'b0001: //OR
            begin
                zero <= 0;
                ALU_Result <= A | B;
            end
            4'b0010: //ADD
            begin
                zero <= 0;
                ALU_Result <= A + B;
            end
            4'b0110: //SUB
            begin
                if (A == B)
                    zero <= 1;
                else
                    zero <= 0;

                ALU_Result <= A - B;
            end
        endcase
    end
endmodule


//ALU Control

module ALU_Control(ALUOp, fun7, fun3, Control_out);

    input [1:0] ALUOp;
    input fun7;
    input [2:0] fun3;

    output reg [3:0] Control_out;

    always @(*)
    begin
        case({ALUOp, fun7, fun3})
            6'b00_0_000: Control_out <= 4'b0010; //ADD
            6'b00_0_111: Control_out <= 4'b0000; //AND
            6'b00_0_110: Control_out <= 4'b0001; //OR
            6'b01_0_000: Control_out <= 4'b0110; //SUB
            6'b10_0_000: Control_out <= 4'b0010; //ADD
            6'b10_1_000: Control_out <= 4'b0110; //SUB
            6'b10_0_111: Control_out <= 4'b0000; //AND
            6'b10_0_110: Control_out <= 4'b0001; //OR
        endcase
    end
endmodule


//Data Memory

module Data_Memory(clk, rst, MemWrite, MemRead, read_address, Write_data, MemData_out);

    input clk, rst, MemWrite, MemRead;
    input [31:0] read_address, Write_data;
    output [31:0] MemData_out;

    reg [31:0] D_Memory [63:0];
    integer k;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            for(k = 0; k < 64; k = k + 1) begin
                D_Memory[k] <= 32'b0;
            end
        end
        else if (MemWrite)
        begin
            D_Memory[read_address] <= Write_data;
        end
    end

    assign MemData_out = (MemRead) ? D_Memory[read_address] : 32'b0;

endmodule


//Multiplexers
//MUX 1
module Mux1(sel1, A1, B1, Mux1_out);
    input sel1;
    input [31:0] A1, B1;
    output [31:0] Mux1_out;

    assign Mux1_out = (sel1 == 1'b0) ? A1 : B1; 
endmodule

//MUX 2
module Mux2(sel2, A2, B2, Mux2_out);
    input sel2;
    input [31:0] A2, B2;
    output [31:0] Mux2_out;

    assign Mux2_out = (sel2 == 1'b0) ? A2 : B2; 
endmodule

//MUX 3
module Mux3(sel3, A3, B3, Mux3_out);
    input sel3;
    input [31:0] A3, B3;
    output [31:0] Mux3_out;

    assign Mux3_out = (sel3 == 1'b0) ? A3 : B3; 
endmodule


//AND logic
module AND_logic(Branch, zero, and_out);
    input Branch, zero;
    output and_out;

    assign and_out = Branch & zero;
endmodule


//Adder
module Adder(in_1, in_2, Sum_out);

    input [31:0] in_1, in_2;
    output [31:0] Sum_out;

    assign Sum_out = in_1 + in_2;    
endmodule


//All modules instantiate
module top(clk, rst);
    input clk, rst;

    wire [31:0] PC_top;
    wire [31:0] instruction_top;
    wire RegWrite_top;
    wire [1:0] ALUOp_top;
    wire [31:0] Read_data1_top, Read_data2_top;
    wire [31:0] Immediate_extent_top;
    wire [31:0] MUX1_top;
    wire ALUSrc_top;
    wire [3:0] ALUCtrl_top;
    wire zero_top, branch_top;
    wire [31:0] Sum_out_top;
    wire [31:0] NextoPC_top;
    wire [31:0] PC_in_top;
    wire and_out_top;
    wire [31:0] address_top;
    wire [31:0] MemData_top;
    wire MemToReg_top;
    wire MemWrite_top;
    wire MemRead_top;
    wire [31:0] WriteBack_top;


    //Program Counter 
    Program_Counter PC (.clk(clk), .rst(rst), .PC_in(PC_in_top), .PC_out(PC_top));

    //PC Adder
    PCplus4 PC_Adder(.fromPC(PC_top), .NextoPC(NextoPC_top));

    //Instruction Memory
    InstructionMemory Inst_Memory(.clk(clk), .rst(rst), .read_address(PC_top), .instruction_out(instruction_top));

    //Register File
    RegisterFile Reg_File(.clk(clk), .rst(rst), .RegWrite(RegWrite_top), .Reg1(instruction_top[19:15]), .Reg2(instruction_top[24:20]), .destination_reg(instruction_top[11:7]), .write_data(WriteBack_top), .read_data1(Read_data1_top), .read_data2(Read_data2_top));

    //Immediate Generator
    Immediate_Generator ImmGen(.Opcode(instruction_top[6:0]), .instruction(instruction_top), .Immediate_extent(Immediate_extent_top));

    //Control Unit
    Control_Unit CtrlUnit(.instruction(instruction_top[6:0]), .Branch(branch_top), .MemRead(MemRead_top), .MemToReg(MemToReg_top), .ALUOp(ALUOp_top), .MemWrite(MemWrite_top), .ALUSrc(ALUSrc_top), .RegWrite(RegWrite_top));

    //ALU Control
    ALU_Control ALUCtrl(.ALUOp(ALUOp_top), .fun7(instruction_top[30]), .fun3(instruction_top[14:12]), .Control_out(ALUCtrl_top));

    //ALU
    ALU_unit ALUUnit(.A(Read_data1_top), .B(MUX1_top), .Control_in(ALUCtrl_top), .ALU_Result(address_top), .zero(zero_top));

    //ALU MUX
    Mux1 ALU_MUX(.sel1(ALUSrc_top), .A1(Read_data2_top), .B1(Immediate_extent_top), .Mux1_out(MUX1_top));

    //Adder
    Adder Adder(.in_1(PC_top), .in_2(Immediate_extent_top), .Sum_out(Sum_out_top));

    //AND gate
    AND_logic And_logic(.Branch(branch_top), .zero(zero_top), .and_out(and_out_top));

    //Adder MUX
    Mux2 Adder_MUX(.sel2(and_out_top), .A2(NextoPC_top), .B2(Sum_out_top), .Mux2_out(PC_in_top));

    //Data Memory
    Data_Memory Data_Memory(.clk(clk), .rst(rst), .MemWrite(MemWrite_top), .MemRead(MemRead_top), .read_address(address_top), .Write_data(Read_data2_top), .MemData_out(MemData_top));

    //MUX 3
    Mux3 MUX3(.sel3(MemToReg_top), .A3(address_top), .B3(MemData_top), .Mux3_out(WriteBack_top));
    
endmodule





//testbench
module tb_top;
    reg clk, rst;
    top uut(.clk(clk), .rst(rst));

    initial begin
        clk = 0;
        rst = 1;
        #5;
        rst = 0;
        #400;
    end

    always begin
        #5 clk = ~clk;
    end
    
    initial begin
        $monitor("Time=%0t PC=%h Instruction=%h", $time, uut.PC_top, uut.instruction_top);
    end

endmodule