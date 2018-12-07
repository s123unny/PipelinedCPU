module EX_MEM(
    clk_i      ,
    RegWrite_i ,
    MemWrite_i ,
    MemRead_i  ,
    Mem2Reg_i  ,
    RegWrite_o ,
    MemWrite_o ,
    MemRead_o  ,
    Mem2Reg_o  ,

    Zero_i     ,
    ALU_data_i ,
    writeData_i,
    RDaddr_i   ,
    Zero_o     ,
    ALU_data_o ,
    writeData_o,
    RDaddr_o   ,
);

input clk_i;
input RegWrite_i, MemWrite_i, MemRead_i, Mem2Reg_i;
output reg RegWrite_o, MemWrite_o, MemRead_o, Mem2Reg_o;

input                 Zero_i;
input       [31:0]    ALU_data_i, writeData_i;
input       [4:0]     RDaddr_i;

output reg            Zero_o;
output reg  [31:0]    ALU_data_o, writeData_o;
output reg  [4:0]     RDaddr_o;


always @(posedge clk_i) begin
    RegWrite_o <= RegWrite_i; 
    MemWrite_o <= MemWrite_i; 
    MemRead_o <= MemRead_i; 
    Mem2Reg_o <= Mem2Reg_i;
    Zero_o <= Zero_i;
    ALU_data_o <= ALU_data_i;
    writeData_o <= writeData_i;
    RDaddr_o <= RDaddr_i;
end
endmodule
