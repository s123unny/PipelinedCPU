module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

wire [31:0] instruction;
wire [31:0] instruction_addr;
wire [31:0] pc_i;
wire Control_ALU_Src_o, Control_RegWrite_o, Control_MemWrite_o, Control_MemRead_o, Control_Mem2Reg_o;
wire [1:0] Control_ALUOp_o;
wire [31:0] Registers_RTdata_o, Registers_RSdata_o;
wire ALU_zero_o;
wire [31:0] MUX_ALUSrc_data_o, ALU_data_o;

Control Control(
    .clk_i      (clk_i),
    .Op_i       (instruction[6:0]),
    .ALUOp_o    (Control_ALUOp_o),
    .ALUSrc_o   (Control_ALU_Src_o),
    .RegWrite_o (Control_RegWrite_o),
    .MemWrite_o (Control_MemWrite_o),
    .MemRead_o  (Control_MemRead_o),
    .Mem2Reg_o  (Control_Mem2Reg_o)
);

Adder Add_PC(
    .data1_in   (instruction_addr),
    .data2_in   (32'b100),
    .data_o     (pc_i)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (pc_i),
    .pc_o       (instruction_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (instruction_addr), 
    .instr_o    (instruction)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (instruction[19:15]),
    .RTaddr_i   (instruction[24:20]),
    .RDaddr_i   (instruction[11:7]), 
    .RDdata_i   (MUX_RegDst.data_o),
    .RegWrite_i (Control_RegWrite_o), 
    .RSdata_o   (Registers_RSdata_o), 
    .RTdata_o   (Registers_RTdata_o) 
);

MUX5 MUX_RegDst(
    .data1_i    (ALU_data_o),
    .data2_i    (Data_Memory.data_o),
    .select_i   (Control_Mem2Reg_o),
    .data_o     (Registers.RDdata_i)
);

MUX32 MUX_ALUSrc(
    .data1_i    (Registers_RTdata_o),
    .data2_i    (Sign_Extend.data_o),
    .select_i   (Control_ALU_Src_o),
    .data_o     (MUX_ALUSrc_data_o)
);

Sign_Extend Sign_Extend(
    .data_i     (instruction[31:20]),
    .data_o     (MUX_ALUSrc.data2_i)
);

ALU ALU(
    .clk_i      (clk_i),
    .data1_i    (Registers_RSdata_o),
    .data2_i    (MUX_ALUSrc_data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (ALU_data_o),
    .Zero_o     (ALU_zero_o)
);

ALU_Control ALU_Control(
    .funct_i    ({instruction[31:25], instruction[14:12]}),
    .ALUOp_i    (Control_ALUOp_o),
    .ALUCtrl_o  (ALU.ALUCtrl_i)
);

Data_Memory Data_Memory(
    .clk_i      (clk_i),
    .data_i     (Registers_RTdata_o),
    .MemWr_i    (Control_MemWrite_o),
    .MemRe_i    (Control_MemRead_o),
    .Adr_i      (ALU_data_o),
    .data_o     (MUX_RegDst.data2_i)
);

// HazzardDetection HazzardDetection(
//     .mux8_o     (),
//     .Flush_o    ()
// );

endmodule

