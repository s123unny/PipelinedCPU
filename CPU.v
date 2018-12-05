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
wire Control_ALU_Src_o, Control_RegWrite_o, Control_MemWrite_o, Control_MemRead_o, Control_Mem2Reg_o, Control_Branch_o;
wire ID_EX_RegWrite_o, ID_EX_MemWrite_o, ID_EX_MemRead_o, ID_EX_Mem2Reg_o, ID_EX_Branch_o;
wire EX_MEM_RegWrite_o, EX_MEM_MemWrite_o, EX_MEM_MemRead_o, EX_MEM_Mem2Reg_o, EX_MEM_Branch_o;
wire MEM_WB_MemWrite_o, MEM_WB_MemRead_o;
wire [1:0] Control_ALUOp_o;
wire [1:0] ID_EX_ALUOp_o;
wire [31:0] Registers_RTdata_o, Registers_RSdata_o;
wire ALU_zero_o;
wire [31:0] MUX_ALUSrcA_data_o, MUX_ALUSrcB_data_o, ALU_data_o;
wire [1:0] FU_ForwardA_o, FU_ForwardB_o
wire [31:0] IF_ID_instruction;
wire [7:0]  MUX8_data_o;

Control Control(
    .clk_i      (clk_i),
    .Op_i       (IF_ID_instruction[6:0]),
    .ALUOp_o    (Control_ALUOp_o),
    .ALUSrc_o   (Control_ALU_Src_o),
    .RegWrite_o (Control_RegWrite_o),
    .MemWrite_o (Control_MemWrite_o),
    .MemRead_o  (Control_MemRead_o),
    .Mem2Reg_o  (Control_Mem2Reg_o)
);

wire [31:0]  IF_ID_pc_o;
IF_ID IF_ID(
    .clk_i      (clk_i),
    .pc_i       (instruction_addr),
    .instr_i    (instruction),
    .pc_o       (IF_ID_pc_o),
    .instr_o    (IF_ID_instruction)
);

wire [31:0] Sign_Extend_data_o;
wire [31:0] ID_EX_RSdata_o, ID_EX_RTdata_o, ID_EX_imm_o;
wire [4:0]  ID_EX_RSaddr_o, ID_EX_RTaddr_o;
wire [9:0]  ID_EX_funct_o;
wire [4:0]  ID_EX_RDaddr_o;
ID_EX ID_EX(
    .clk_i      (clk_i),
    .ALUOp_i    (MUX8_data_o[7:6]),
    .ALUSrc_i   (MUX8_data_o[5]),
    .RegWrite_i (MUX8_data_o[4]),
    .MemWrite_i (MUX8_data_o[3]),
    .MemRead_i  (MUX8_data_o[2]),
    .Mem2Reg_i  (MUX8_data_o[1]),
	.Branch_i   (MUX8_data_o[0]),
    .ALUOp_o    (ID_EX_ALUOp_o),
    .RegWrite_o (ID_EX_RegWrite_o),
    .MemWrite_o (ID_EX_MemWrite_o),
    .MemRead_o  (ID_EX_MemRead_o),
    .Mem2Reg_o  (ID_EX_Mem2Reg_o),
	.Branch_o   (ID_EX_Branch_o),

    .RSdata_i   (Registers_RSdata_o),
    .RTdata_i   (Registers_RTdata_o),
    .imm_i      (Sign_Extend_data_o),
    .funct_i    ({IF_ID_instruction[31:25], IF_ID_instruction[14:12]}),
    .RDaddr_i   (IF_ID_instruction[11:7]),
    .RSdata_o   (ID_EX_RSdata_o),
    .RTdata_o   (ID_EX_RTdata_o),
    .funct_o    (ID_EX_funct_o),
    .RDaddr_o   (ID_EX_RDaddr_o),

    .RSaddr_i   (IF_ID_instruction[19:15]),
    .RTaddr_i   (IF_ID_instruction[24:20]),
    .RSaddr_o   (ID_EX_RSaddr_o),
    .RTaddr_o   (ID_EX_RTaddr_o),
);

wire [31:0] EX_MEM_ALU_data_o;
wire EX_MEM_Zero_o;
wire [31:0] EX_MEM_writeData_o;
wire EX_MEM_RDaddr_o;
EX_MEM EX_MEM(
    .clk_i      (clk_i),
    .RegWrite_i (ID_EX_RegWrite_o),
    .MemWrite_i (ID_EX_MemWrite_o),
    .MemRead_i  (ID_EX_MemRead_o),
    .Mem2Reg_i  (ID_EX_Mem2Reg_o),
	.Branch_i   (ID_EX_Branch_o),
    .RegWrite_o (EX_MEM_RegWrite_o),
    .MemWrite_o (EX_MEM_MemWrite_o),
    .MemRead_o  (EX_MEM_MemRead_o),
    .Mem2Reg_o  (EX_MEM_Mem2Reg_o),
	.Branch_o   (EX_MEM_Branch_o),

    .Zero_i     (ALU_zero_o),
    .ALU_data_i (ALU_data_o),
    .writeData_i(MUX_ALUSrcB_data_o),
    .RDaddr_i   (ID_EX_RDaddr_o),
    .Zero_o     (EX_MEM_Zero_o),
    .ALU_data_o (EX_MEM_ALU_data_o),
    .writeData_o(EX_MEM_writeData_o),
    .RDaddr_o   (EX_MEM_RDaddr_o),
);

wire [31:0] Data_Memory_data_o;
wire [31:0] MEM_WB_ReadData_o;
wire [31:0] MEM_WB_ALU_data_o;
wire [4:0]  MEM_WB_RDaddr_o;
MEM_WB MEM_WB(
    .clk_i      (clk_i),
    .RegWrite_i (EX_MEM_RegWrite_o),
    .Mem2Reg_i  (EX_MEM_Mem2Reg_o),
    .RegWrite_o (MEM_WB_RegWrite_o),
    .Mem2Reg_o  (MEM_WB_Mem2Reg_o),

	.ReadData_i (Data_Memory_data_o),
    .ALU_data_i (EX_MEM_ALU_data_o),
    .RDaddr_i   (EX_MEM_RDaddr_o),
    .ReadData_o (MEM_WB_ReadData_o),
    .ALU_data_o (MEM_WB_ALU_data_o),
    .RDaddr_o   (MEM_WB_RDaddr_o),
);

wire [31:0] Add_PC_data_o;
Adder Add_PC(
    .data1_in   (instruction_addr),
    .data2_in   (32'b100),
    .data_o     (Add_PC_data_o)
);

wire [31:0] Add_imm_data_o;
Adder Add_imm(
   .data1_in	(Sign_Extend_data_o << 1),
   .data2_in	(IF_ID_instruction),
   .data_o	    (Add_imm_data_o)
);

wire Branch_data_o;
Branch Branch(
    .data1_in	(EX_MEM_Zero_o),
    .data2_in	(EX_MEM_Branch_o),
    .data_o	    (Branch_data_o)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (MUX_PCSrc_data_o),
    .pc_o       (instruction_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (instruction_addr), 
    .instr_o    (instruction)
);

Registers Registers(
    .RSaddr_i   (IF_ID_instruction[19:15]),
    .RTaddr_i   (IF_ID_instruction[24:20]),
    .RDaddr_i   (MEM_WB_RDaddr_o), 
    .RDdata_i   (MUX_RegDst_data_o),
    .RegWrite_i (MEM_WB_RegWrite_o), 
	.RSdata_o   (Registers_RSdata_o), 
    .RTdata_o   (Registers_RTdata_o) 
);

wire [31:0] MUX_RegDst_data_o;
MUX5 MUX_RegDst(
    .data1_i    (MEM_WB_ALU_data_o),
    .data2_i    (MEM_WB_ReadData_o),
	.select_i   (MEM_WB_Mem2Reg_o),
    .data_o     (MUX_RegDst_data_o)
);

wire [31:0] MUX_PCSrc_data_o;
MUX5 MUX_PCSrc(
    .data1_i    (Add_imm_data_o),
    .data2_i    (Add_PC_data_o),
    .select_i   (Branch_data_o),
    .data_o     (MUX_PCSrc_data_o)
);

MUX32 MUX_ALUSrcA(
    .data1_i    (ID_EX_RSdata_o),
    .data2_i    (MUX_RegDst_data_o),
    .data3_i    (EX_MEM_ALU_data_o),
    .select_i   (FU_ForwardA_o),
    .data_o     (MUX_ALUSrcA_data_o)
);

MUX32 MUX_ALUSrcB(
    .data1_i    (ID_EX_RTdata_o),
    .data2_i    (MUX_RegDst_data_o),
    .data3_i    (EX_MEM_ALU_data_o),
    .select_i   (FU_ForwardB_o),
    .data_o     (MUX_ALUSrcB_data_o)
);

wire [31:0] Sign_Extend_data_o;
Sign_Extend Sign_Extend(
    .data_i     (IF_ID_instruction[31:20]),
    .data_o     (Sign_Extend_data_o)
);

wire [2:0] ALU_Control_ALUCtrl_o;
ALU ALU(
    .data1_i    (MUX_ALUSrcA_data_o),
    .data2_i    (MUX_ALUSrcB_data_o),
    .ALUCtrl_i  (ALU_Control_ALUCtrl_o),
    .data_o     (ALU_data_o),
    .Zero_o     (ALU_zero_o)
);

ALU_Control ALU_Control(
    .funct_i    (ID_EX_funct_o),
    .ALUOp_i    (ID_EX_ALUOp_o),
    .ALUCtrl_o  (ALU_Control_ALUCtrl_o)
);

Data_Memory Data_Memory(
	.data_i     (EX_MEM_writeData_o),
    .MemWr_i    (EX_MEM_MemWrite_o),
    .MemRe_i    (EX_MEM_MemRead_o),
    .Adr_i      (EX_MEM_ALU_data_o),
    .data_o     (Data_Memory_data_o)
);

Forwarding_Unit Forwarding_Unit(
    .EX_MEM_RegisterRd_i (EX_MEM_RDaddr_o)
    .EX_MEM_RegWrite_i   (EX_MEM_RegWrite_o)
    .MEM_WB_RegisterRd_i (MEM_WB_RDaddr_o)
    .MEM_WB_RegWrite_i   (MEM_WB_RegWrite_o)
    .ID_EX_RS_i          (ID_EX_RSaddr_o)
    .ID_EX_RT_i          (ID_EX_RTaddr_o)
    .ForwardA_o          (FU_ForwardA_o)
    .ForwardB_o          (FU_ForwardB_o)
);

wire HazzardDetection_mux8_o;
wire HazzardDetection_IF_ID_write_o;
wire HazzardDetection_PC_write_o;
HazzardDetection HazzardDetection(
    .ID_EX_MemWrite_i	(ID_EX_MemWrite_o),
    .ID_EX_MemRead_i	(ID_EX_MemRead_o),
    .ID_EX_RegisterRd_i	(ID_EX_RegisterRd_o),
    .IF_ID_RS_i	(IF_ID_instruction[19:15]),
    .IF_ID_RT_i	(IF_ID_instruction[24:20]),
    .mux8_o     (HazzardDetection_mux8_o),
    .IF_ID_write_o	(HazzardDetection_IF_ID_write_o),
    .PC_write_o    (HazzardDetection_PC_write_o)
);

MUX8 MUX8(
    .data2_i	({Control_ALUOp_o, Control_ALU_Src_o, Control_RegWrite_o, Control_MemWrite_o, Control_MemRead_o, Control_Mem2Reg_o}),
    .select_i	(HazzardDetection_mux8_o),
    .data_o	    (MUX8_data_o)
);

endmodule

