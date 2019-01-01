`define CYCLE_TIME 50			

module TestBench;

reg				Clk;
reg				Reset;
reg				Start;
integer			i, outfile, outfile2, counter;
reg					flag;
reg		[26:0]		address;
reg		[23:0]		tag;
reg		[4:0]		index;

wire	[256-1:0]	mem_cpu_data; 
wire				mem_cpu_ack; 	
wire	[256-1:0]	cpu_mem_data; 
wire	[32-1:0]	cpu_mem_addr; 	
wire				cpu_mem_enable; 
wire				cpu_mem_write; 

always #(`CYCLE_TIME/2) Clk = ~Clk;	

CPU CPU(
	.clk_i  (Clk),
    .rst_i  (Reset),
	.start_i(Start),
	
	.mem_data_i(mem_cpu_data), 
	.mem_ack_i(mem_cpu_ack), 	
	.mem_data_o(cpu_mem_data), 
	.mem_addr_o(cpu_mem_addr), 	
	.mem_enable_o(cpu_mem_enable), 
	.mem_write_o(cpu_mem_write)
);

Data_Memory Data_Memory
(
	.clk_i    (Clk),
  .rst_i    (Reset),
	.addr_i   (cpu_mem_addr),
	.data_i   (cpu_mem_data),
	.enable_i (cpu_mem_enable),
	.write_i  (cpu_mem_write),
	.ack_o    (mem_cpu_ack),
	.data_o   (mem_cpu_data),
	.count		()
);
  
initial begin
	counter = 1;
	
	// initialize instruction memory (2KB)
	for(i=0; i<512; i=i+1) begin
		CPU.Instruction_Memory.memory[i] = 32'b0;
	end
	
	// initialize data memory	(16KB)
	for(i=0; i<512; i=i+1) begin
		Data_Memory.memory[i] = 256'b0;
	end
		
	// initialize cache memory	(1KB)
	for(i=0; i<32; i=i+1) begin
		CPU.dcache.dcache_tag_sram.memory[i] = 24'b0;
		CPU.dcache.dcache_data_sram.memory[i] = 256'b0;
	end
	
	// initialize Register File
	for(i=0; i<32; i=i+1) begin
		CPU.Registers.register[i] = 32'b0;
	end
	
	// Load instructions into instruction memory
	$readmemb("instruction.txt", CPU.Instruction_Memory.memory);
	
	// Open output file
	outfile = $fopen("output.txt") | 1;
	outfile2 = $fopen("cache.txt") | 1;
	
	
	// Set Input n into data memory at 0x00
	Data_Memory.memory[0] = 256'h5;		// n = 5 for example
	
    Clk = 0;
    Reset = 0;
    Start = 0;
    
    #(`CYCLE_TIME/4) 
    Reset = 1;
    Start = 1;

    
end
  
always@(posedge Clk) begin
	if(counter == 150) begin	// store cache to memory
		$fdisplay(outfile, "Flush Cache! \n");
		for(i=0; i<32; i=i+1) begin
			tag = CPU.dcache.dcache_tag_sram.memory[i];
			index = i;
			address = {tag[21:0], index};
			Data_Memory.memory[address] = CPU.dcache.dcache_data_sram.memory[i];
		end 
	end
	if(counter > 150) begin	// stop 
		$stop;
	end
		
	$fdisplay(outfile, "cycle = %d, Start = %b", counter, Start);
	// print PC 
	$fdisplay(outfile, "PC = %d", CPU.PC.pc_o);
	
	// print Registers
	$fdisplay(outfile, "Registers");
	$fdisplay(outfile, "R0(r0) = %h, R8 (t0) = %h, R16(s0) = %h, R24(t8) = %h", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
	$fdisplay(outfile, "R1(at) = %h, R9 (t1) = %h, R17(s1) = %h, R25(t9) = %h", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
	$fdisplay(outfile, "R2(v0) = %h, R10(t2) = %h, R18(s2) = %h, R26(k0) = %h", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
	$fdisplay(outfile, "R3(v1) = %h, R11(t3) = %h, R19(s3) = %h, R27(k1) = %h", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
	$fdisplay(outfile, "R4(a0) = %h, R12(t4) = %h, R20(s4) = %h, R28(gp) = %h", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
	$fdisplay(outfile, "R5(a1) = %h, R13(t5) = %h, R21(s5) = %h, R29(sp) = %h", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
	$fdisplay(outfile, "R6(a2) = %h, R14(t6) = %h, R22(s6) = %h, R30(s8) = %h", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
	$fdisplay(outfile, "R7(a3) = %h, R15(t7) = %h, R23(s7) = %h, R31(ra) = %h", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);

	// print Data Memory
	$fdisplay(outfile, "Data Memory: 0x0000 = %h", Data_Memory.memory[0]);
	$fdisplay(outfile, "Data Memory: 0x0020 = %h", Data_Memory.memory[1]);
	$fdisplay(outfile, "Data Memory: 0x0040 = %h", Data_Memory.memory[2]);
	$fdisplay(outfile, "Data Memory: 0x0060 = %h", Data_Memory.memory[3]);
	$fdisplay(outfile, "Data Memory: 0x0080 = %h", Data_Memory.memory[4]);
	$fdisplay(outfile, "Data Memory: 0x00A0 = %h", Data_Memory.memory[5]);
	$fdisplay(outfile, "Data Memory: 0x00C0 = %h", Data_Memory.memory[6]);
	$fdisplay(outfile, "Data Memory: 0x00E0 = %h", Data_Memory.memory[7]);
	$fdisplay(outfile, "Data Memory: 0x0400 = %h", Data_Memory.memory[32]);
	
	$fdisplay(outfile, "\n");
	
	// print Data Cache Status
	if(CPU.dcache.p1_stall_o && CPU.dcache.state==0) begin
		if(CPU.dcache.sram_dirty) begin
			if(CPU.dcache.p1_MemWrite_i) 
				$fdisplay(outfile2, "Cycle: %d, Write Miss, Address: %h, Write Data: %h (Write Back!)", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_i);
			else if(CPU.dcache.p1_MemRead_i) 
				$fdisplay(outfile2, "Cycle: %d, Read Miss , Address: %h, Read Data : %h (Write Back!)", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_o);
		end
		else begin
			if(CPU.dcache.p1_MemWrite_i) 
				$fdisplay(outfile2, "Cycle: %d, Write Miss, Address: %h, Write Data: %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_i);
			else if(CPU.dcache.p1_MemRead_i) 
				$fdisplay(outfile2, "Cycle: %d, Read Miss , Address: %h, Read Data : %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_o);
		end
		flag = 1'b1;
	end
	else if(!CPU.dcache.p1_stall_o) begin
		if(!flag) begin
			if(CPU.dcache.p1_MemWrite_i) 
				$fdisplay(outfile2, "Cycle: %d, Write Hit , Address: %h, Write Data: %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_i);
			else if(CPU.dcache.p1_MemRead_i) 
				$fdisplay(outfile2, "Cycle: %d, Read Hit  , Address: %h, Read Data : %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_o);
		end
		flag = 1'b0;
	end

	$display("cycle %d", counter);
	$display("[PC]: pc_i=%d, pc_o=%d, stall_i=%b, pcEnable_i=%b, start_i=%b, rst_i=%b", CPU.PC.pc_i, CPU.PC.pc_o, CPU.PC.stall_i, CPU.PC.pcEnable_i, CPU.PC.start_i, CPU.PC.rst_i);
    $display("[IF_ID]: pc_i=%d, instr_i=%b, flush_i=%b, stall_i=%b", CPU.IF_ID.pc_i, CPU.IF_ID.instr_i, CPU.IF_ID.flush_i, CPU.IF_ID.stall_i);
	$display("[IF_ID]: pc_o=%d, instr_o=%b", CPU.IF_ID.pc_o, CPU.IF_ID.instr_o);
	$display("[Control]: ALUOp_o=%d, ALUSrc_o=%d, RegWrite_o=%d, MemWrite_o=%d, MemRead_o=%d, Mem2Reg_o=%d, Branch_o=%d", CPU.Control.ALUOp_o, CPU.Control.ALUSrc_o, CPU.Control.RegWrite_o, CPU.Control.MemWrite_o, CPU.Control.MemRead_o, CPU.Control.Mem2Reg_o, CPU.Control.Branch_o);
    $display("[Registers]: RSaddr_i=%d, RTaddr_i=%d, RDaddr_i=%d, RDdata_i=%d, RegWrite_i=%d, RSdata_o=%d, RTdata_o=%d",CPU.Registers.RSaddr_i, CPU.Registers.RTaddr_i, CPU.Registers.RDaddr_i, CPU.Registers.RDdata_i, CPU.Registers.RegWrite_i, CPU.Registers.RSdata_o, CPU.Registers.RTdata_o);
    $display("[ALU_Control]: funct_i=%b, ALUOp_i=%b, ALUCtrl_o=%b", CPU.ALU_Control.funct_i, CPU.ALU_Control.ALUOp_i, CPU.ALU_Control.ALUCtrl_o);
	$display("[Sign_Extend]: data_o=%b", CPU.Sign_Extend.data_o);
	$display("[Add imm]: data1_in=%b, data_o=%b", CPU.Add_imm.data1_in, CPU.Add_imm.data_o);
	$display("[mux8]: %h", CPU.MUX8.data_o);
    $display("[ID_EX]: ALUOp_i=%b, ALUSrc_i=%d, RegWrite_i=%d, MemWrite_i=%d, MemRead_i=%d", CPU.ID_EX.ALUOp_i, CPU.ID_EX.ALUSrc_i, CPU.ID_EX.RegWrite_i, CPU.ID_EX.MemWrite_i, CPU.ID_EX.MemRead_i);
    $display("[ID_EX]: RSdata_i=%d, RTdata_i=%d, RSaddr_i=%d, RTaddr_i=%d, RDaddr_i=%d, imm_i=%d", CPU.ID_EX.RSdata_i, CPU.ID_EX.RTdata_i, CPU.ID_EX.RSaddr_i, CPU.ID_EX.RTaddr_i, CPU.ID_EX.RDaddr_i, CPU.ID_EX.imm_i);
    $display("[ID_EX]: ALUOp_o=%b, RegWrite_o=%d, MemWrite_o=%d, MemRead_o=%d", CPU.ID_EX.ALUOp_o, CPU.ID_EX.RegWrite_o, CPU.ID_EX.MemWrite_o, CPU.ID_EX.MemRead_o);
    $display("[ID_EX]: RSdata_o=%d, RTdata_o=%d, RSaddr_o=%d, RTaddr_o=%d, RDaddr_o=%d", CPU.ID_EX.RSdata_o, CPU.ID_EX.RTdata_o, CPU.ID_EX.RSaddr_o, CPU.ID_EX.RTaddr_o, CPU.ID_EX.RDaddr_o);
	$display("[MUX_ALUSrcA]: select_i=%d, data1_i=%d, data2_i=%d, data3_i=%d, data_o=%d", CPU.MUX_ALUSrcA.select_i, CPU.MUX_ALUSrcA.data1_i, CPU.MUX_ALUSrcA.data2_i, CPU.MUX_ALUSrcA.data3_i, CPU.MUX_ALUSrcA.data_o);
    $display("[MUX_ALUSrcB]: select_i=%d, data1_i=%d, data2_i=%d, data3_i=%d, data_o=%d", CPU.MUX_ALUSrcB.select_i, CPU.MUX_ALUSrcB.data1_i, CPU.MUX_ALUSrcB.data2_i, CPU.MUX_ALUSrcB.data3_i, CPU.MUX_ALUSrcB.data_o);
	$display("[Forwardind]: ForwardA_o=%d, ForwardB_o=%d", CPU.Forwarding_Unit.ForwardA_o, CPU.Forwarding_Unit.ForwardB_o);
	$display("[ALU]: data1_i=%d, data2_i=%d, ALUCtrl_i=%b, data_o=%d, Zero_o=%d", CPU.ALU.data1_i, CPU.ALU.data2_i, CPU.ALU.ALUCtrl_i, CPU.ALU.data_o, CPU.ALU.Zero_o);
	$display("[EX_MEM]: ALU_data_i=%d, writeData_i=%d, RDaddr_i=%d, RegWrite_i=%d, MemWrite_i=%d, MemRead_i=%d", CPU.EX_MEM.ALU_data_i, CPU.EX_MEM.writeData_i, CPU.EX_MEM.RDaddr_i, CPU.EX_MEM.RegWrite_i, CPU.EX_MEM.MemWrite_i, CPU.EX_MEM.MemRead_i);
    $display("[EX_MEM]: ALU_data_o=%d, writeData_o=%d, RDaddr_o=%d, RegWrite_o=%d, MemWrite_o=%d, MemRead_o=%d,", CPU.EX_MEM.ALU_data_o, CPU.EX_MEM.writeData_o, CPU.EX_MEM.RDaddr_o, CPU.EX_MEM.RegWrite_o, CPU.EX_MEM.MemWrite_o, CPU.EX_MEM.MemRead_o);
	$display("[MEM_WB]: RDaddr_i=%d, RegWrite_i=%d, ReadData_i=%d, ALU_data_o=%d", CPU.MEM_WB.RDaddr_i, CPU.MEM_WB.RegWrite_i, CPU.MEM_WB.ReadData_i, CPU.MEM_WB.ALU_data_i);
    $display("[MEM_WB]: RDaddr_o=%d, RegWrite_o=%d, ReadData_o=%d, ALU_data_o=%d", CPU.MEM_WB.RDaddr_o, CPU.MEM_WB.RegWrite_o, CPU.MEM_WB.ReadData_o, CPU.MEM_WB.ALU_data_o);
	$display("");
	$display("[Data_Memory]: addr_i=%d, enable_i=%b, write_i=%b, ack_o=%d, count=%d", Data_Memory.addr_i, Data_Memory.enable_i, Data_Memory.write_i, Data_Memory.ack_o, Data_Memory.count);
	$display("[dcache_top]: mem_ack_i=%d, p1_addr_i=%d, p1_MemRead_i=%b, p1_MemWrite_i=%b", CPU.dcache.mem_ack_i, CPU.dcache.p1_addr_i, CPU.dcache.p1_MemRead_i, CPU.dcache.p1_MemWrite_i);
	$display("[dcache_top]: mem_addr_o=%d, mem_enable_o=%b, mem_write_o=%b, p1_stall_o=%b", CPU.dcache.mem_addr_o, CPU.dcache.mem_enable_o, CPU.dcache.mem_write_o, CPU.dcache.p1_stall_o);
	$display("Data_Memory_i=%d", Data_Memory.data_i);
	$display("Data_Memory_o=%d", Data_Memory.data_o);
	$display("dcache_top: mem_data_i=%d", CPU.dcache.mem_data_i);
	$display("dcache_top: mem_data_o=%d", CPU.dcache.mem_data_o);
	$display("dcache_top: p1_data_i=%d", CPU.dcache.p1_data_i);
	$display("dcache_top: p1_data_o=%d", CPU.dcache.p1_data_o);
	$display("[dcache_data_sram]: enable_i=%b, data_o=%d", CPU.dcache.dcache_data_sram.enable_i, CPU.dcache.dcache_data_sram.data_o);
	$display("\n");
		
	
	counter = counter + 1;
end

  
endmodule
