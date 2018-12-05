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
wire Control_ALU_Src_o, Control_RegWrite_o, Control_MemWrite_o, Control_MemRead_o, Control_Mem2Reg_o, Control_Branch_o;
wire ID_EX_ALU_Src_o, ID_EX_RegWrite_o, ID_EX_MemWrite_o, ID_EX_MemRead_o, ID_EX_Mem2Reg_o, ID_EX_Branch_o;
wire EX_MEM_RegWrite_o, EX_MEM_MemWrite_o, EX_MEM_MemRead_o, EX_MEM_Mem2Reg_o, EX_MEM_Branch_o;
wire MEM_WB_MemWrite_o, MEM_WB_MemRead_o;
wire [1:0] Control_ALUOp_o;
wire [1:0] ID_EX_ALUOp_o;
wire [31:0] Registers_RTdata_o, Registers_RSdata_o;
wire ALU_zero_o;
wire [31:0] MUX_ALUSrcA_data_o, MUX_ALUSrcB_data_o, ALU_data_o;
wire [1:0] FU_ForwardA_o, FU_ForwardB_o


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

wire [31:0] IF_ID_instruction;
IF_ID IF_ID(
    .clk_i      (clk_i),
    .pc_i       (instruction_addr),
    .instr_i    (instruction),
    .pc_o       (ID_EX.pc_i),
    .instr_o    (IF_ID_instruction)
);

wire [31:0] Sign_Extend_data_o;
wire [31:0] ID_EX_RSdata_o, ID_EX_RTdata_o, ID_EX_imm_o;
ID_EX ID_EX(
    .clk_i      (clk_i),
    .ALUOp_i    (Control_ALUOp_o),
    .ALUSrc_i   (Control_ALU_Src_o),
    .RegWrite_i (Control_RegWrite_o),
    .MemWrite_i (Control_MemWrite_o),
    .MemRead_i  (Control_MemRead_o),
    .Mem2Reg_i  (Control_Mem2Reg_o),
	.Branch_i   (Control_Branch_o),
    .ALUOp_o    (ID_EX_ALUOp_o),
    .ALUSrc_o   (ID_EX_ALU_Src_o),
    .RegWrite_o (ID_EX_RegWrite_o),
    .MemWrite_o (ID_EX_MemWrite_o),
    .MemRead_o  (ID_EX_MemRead_o),
    .Mem2Reg_o  (ID_EX_Mem2Reg_o),
	.Branch_o   (ID_EX_Branch_o),

    .pc_i       (IF_ID.pc_o),
    .pc_o       (ID_EX.pc_o),
    .RSdata_i   (Registers_RSdata_o),
    .RTdata_i   (Registers_RTdata_o),
    .imm_i      (Sign_Extend_data_o),
    .funct_i    ({IF_ID_instruction[31:25], IF_ID_instruction[14:12]}),
    .RDaddr_i   (IF_ID_instruction[11:7]),
    .RSdata_o   (ID_EX_RSdata_o),
    .RTdata_o   (ID_EX_RTdata_o),
    .imm_o      (ID_EX_imm_o),
    .funct_o    (ALU_Control.funct_i),
    .RDaddr_o   (EX_MEM.RDaddr_i),

    .RSaddr_i   (IF_ID_instruction[19:15]),
    .RTaddr_i   (IF_ID_instruction[24:20]),
    .RSaddr_o   (),
    .RTaddr_o   (),
);

wire [31:0] EX_MEM_ALU_data_o;
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

	.AddResult_i(Add_imm.data_o),
    .Zero_i     (ALU_zero_o),
    .ALU_data_i (ALU_data_o),
    .writeData_i(ID_EX_RTdata_o),
    .RDaddr_i   (ID_EX.RDaddr_o),
    .AddResult_o(),
    .Zero_o     (Branch.data2_i),
    .ALU_data_o (EX_MEM_ALU_data_o;),
    .writeData_o(Data_Memory.data_i),
    .RDaddr_o   (MEM_WB.RDaddr_i),
);

MEM_WB MEM_WB(
    .clk_i      (clk_i),
    .RegWrite_i (EX_MEM_RegWrite_o),
    .Mem2Reg_i  (EX_MEM_Mem2Reg_o),
    .RegWrite_o (MEM_WB_RegWrite_o),
    .Mem2Reg_o  (MEM_WB_Mem2Reg_o),

	.ReadData_i (Data_Memory.data_o),
    .ALU_data_i (EX_MEM_ALU_data_o),
    .RDaddr_i   (EX_MEM.RDaddr_o),
    .ReadData_o (MUX_RegDst.data2_i),
    .ALU_data_o (MUX_RegDst.data1_i),
    .RDaddr_o   (Registers.RDaddr_i),
);

Adder Add_PC(
    .data1_in   (instruction_addr),
    .data2_in   (32'b100),
    .data_o     (pc_i)
);

Adder Add_imm(
   .data1_in	(MUX_ALUSrc.data2_i << 1),
   .data2_in	(IF_ID_instruction)
   .data_o	(MUX_PCSrc.data2_i)
);

Branch Branch(
    .data1_in	(EX_MEM_zero_o),
    .data2_in	(EX_MEM_Branch_o),
    .data_o	(MUX_PCSrc.select_i)
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
    .RSaddr_i   (IF_ID_instruction[19:15]),
    .RTaddr_i   (IF_ID_instruction[24:20]),
    .RDaddr_i   (MEM_WB.RDaddr_o), 
    .RDdata_i   (MUX_RegDst.data_o),
    .RegWrite_i (MEM_WB_RegWrite_o), 
	.RSdata_o   (Registers_RSdata_o), 
    .RTdata_o   (Registers_RTdata_o) 
);

MUX5 MUX_RegDst(
    .data1_i    (MEM_WB.ALU_data_o),
    .data2_i    (MEM_WB.ReadData_O),
	.select_i   (MEM_WB_Mem2Reg_o),
    .data_o     (Registers.RDdata_i)
);

MUX5 MUX_PCSrc(
    .data1_i    (Add_imm.data_o),
    .data2_i    (Add_PC.data_o),
    .select_i   (Branch.data_o),
    .data_o     ()
);

MUX32 MUX_ALUSrcA(
    .data1_i    (ID_EX_RSdata_o),
    .data2_i    (MUX_RegDst_data_o),
    .data3_i    (MEM_WB_ALU_data_o),
    .select_i   (FU_ForwardA_o),
    .data_o     (MUX_ALUSrcA_data_o)
);

MUX32 MUX_ALUSrcB(
    .data1_i    (ID_EX_RTdata_o),
    .data2_i    (MUX_RegDst_data_o),
    .data3_i    (MEM_WB_ALU_data_o),
    .select_i   (FU_ForwardB_o),
    .data_o     (MUX_ALUSrcB_data_o)
);

Sign_Extend Sign_Extend(
    .data_i     (IF_ID_instruction[31:20]),
    .data_o     (MUX_ALUSrc.data2_i)
);

ALU ALU(
    .data1_i    (MUX_ALUSrcA_data_o),
    .data2_i    (MUX_ALUSrcB_data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (ALU_data_o),
    .Zero_o     (ALU_zero_o)
);

ALU_Control ALU_Control(
    .funct_i    (ID_EX.funct_o),
    .ALUOp_i    (ID_EX_ALUOp_o),
    .ALUCtrl_o  (ALU.ALUCtrl_i)
);

Data_Memory Data_Memory(
	.data_i     (EX_MEM.writeData_o),
    .MemWr_i    (EX_MEM_MemWrite_o),
    .MemRe_i    (EX_MEM_MemRead_o),
    .Adr_i      (EX_MEM_ALU_data_o),
    .data_o     (MEM_WB.ReadData_i)
);

Forwarding_Unit Forwarding_Unit(
    .EX_MEM_RegisterRd_i (EX_MEM.RDaddr_o)
    .EX_MEM_RegWrite_i   (EX_MEM_RegWrite_o)
    .MEM_WB_RegisterRd_i (MEM_WB.RDaddr_o)
    .MEM_WB_RegWrite_i   (MEM_WB_RegWrite_o)
    .ID_EX_RS_i          (ID_EX_RSaddr_o)
    .ID_EX_RT_i          (ID_EX_RTaddr_o)
    .ForwardA_o          (FU_ForwardA_o)
    .ForwardB_o          (FU_ForwardB_o)
);

HazzardDetection HazzardDetection(
    .ID_EX_MemWrite_i	(ID_EX_MemWrite_i),
    .ID_EX_MemRead_i	(ID_EX_MemRead_i),
    .ID_EX_RegisterRd_i	(ID_EX_RegisterRd_i),
    .IF_ID_RS_i	(IF_ID_RS_i),
    .IF_ID_RT_i	(IF_ID_RT_i),
    .mux8_o     (MUX8.select_i),
    .IF_ID_write_o	(),
    .PC_write_o    ()
);

MUX8 MUX8(
    .data2_i	({Control_ALUOp_o, Control_ALU_Src_o, Control_RegWrite_o, Control_MemWrite_o, Control_MemRead_o, Control_Mem2Reg_o}),
    .select_i	(HazzardDetection.mux8_o),
    .data_o	()
);

endmodule

