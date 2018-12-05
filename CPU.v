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

IF_ID IF_ID(
    .clk_i      (clk_i),
    .pc_i       (instruction_addr),
    .instr_i    (instruction),
    .pc_o       (),
    .instr_o    (IF_ID_instruction)
);

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

    .pc_i       (),
    .pc_o       (),
    .RSdata_i   (),
    .RTdata_i   (),
    .imm_i      (),
    .funct_i    (),
    .RDaddr_i   (IF_ID_instruction[11:7]),
    .RSdata_o   (),
    .RTdata_o   (),
    .imm_o      (),
    .funct_o    (),
    .RDaddr_o   (),

	.RSaddr_i   (),
	.RTaddr_i	(),
	.RSaddr_o   (),
    .RTaddr_o   (),
);

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

	.AddResult_i(),
    .Zero_i     (),
    .ALU_data_i (),
    .writeData_i(),
    .RDaddr_i   (),
    .AddResult_o(),
    .Zero_o     (),
    .ALU_data_o (),
    .writeData_o(),
    .RDaddr_o   (),
);

MEM_WB MEM_WB(
    .clk_i      (clk_i),
    .RegWrite_i (EX_MEM_RegWrite_o),
    .Mem2Reg_i  (EX_MEM_Mem2Reg_o),
    .RegWrite_o (MEM_WB_RegWrite_o),
    .Mem2Reg_o  (MEM_WB_Mem2Reg_o),

	.ReadData_i (),
    .ALU_data_i (),
    .ReadData_o (),
    .ALU_data_o (),
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
    .data_i     (Registers_RTdata_o),
    .MemWr_i    (Control_MemWrite_o),
    .MemRe_i    (Control_MemRead_o),
    .Adr_i      (ALU_data_o),
    .data_o     (MUX_RegDst.data2_i)
);

Forwarding_Unit Forwarding_Unit(
    .EX_MEM_RegisterRd_i (EX_MEM.RDaddr_o)
    .EX_MEM_RegWrite_i   (EX_MEM.EX_MEM_RegWrite_o)
    .MEM_WB_RegisterRd_i (MEM_WB.RDaddr_o)
    .MEM_WB_RegWrite_i   (MEM_WB.MEM_WB_RegWrite_o)
    .ID_EX_RS_i          ()
    .ID_EX_RT_i          ()
    .ForwardA_o          ()
    .ForwardB_o          ()
);

HazzardDetection HazzardDetection(
    .ID_EX_MemWrite_i	(),
    .ID_EX_MemRead_i	(),
    .ID_EX_RegisterRd_i	(),
    .IF_ID_RS_i	(),
    .IF_ID_RT_i	(),
    .mux8_o     (),
    .IF_ID_write_o	(),
    .PC_write_o    ()
);

MUX8 MUX8(
    .data2_i	(),
    .setect_i	(),
    .data_o	()
);

endmodule

