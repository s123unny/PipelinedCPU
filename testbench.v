`define CYCLE_TIME 50            

module TestBench;

reg                Clk;
reg                Reset;
reg                Start;
integer            i, outfile, counter;
integer            stall, flush;

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU CPU(
    .clk_i  (Clk),
    .rst_i  (Reset),
    .start_i(Start)
);
  
initial begin
    counter = 0;
    stall = 0;
    flush = 0;
    
    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        CPU.Instruction_Memory.memory[i] = 32'b0;
    end
    
    // initialize data memory
    for(i=0; i<32; i=i+1) begin
        CPU.Data_Memory.memory[i] = 8'b0;
    end    
        
    // initialize Register File
    for(i=0; i<32; i=i+1) begin
        CPU.Registers.register[i] = 32'b0;
    end
    
    // Load instructions into instruction memory
    $readmemb("instruction.txt", CPU.Instruction_Memory.memory);
    
    // Open output file
    outfile = $fopen("output.txt") | 1;
    
    // Set Input n into data memory at 0x00
    CPU.Data_Memory.memory[0] = 8'h5;       // n = 5 for example
    
    Clk = 1;
    Reset = 0;
    Start = 0;
    
    #(`CYCLE_TIME/4) 
    Reset = 1;
    Start = 1;
        
    
end
  
always@(posedge Clk) begin
    if(counter == 30)    // stop after 30 cycles
        $stop;

    // put in your own signal to count stall and flush
    if(CPU.HazzardDetection.mux8_o == 1 && CPU.Control.Branch_o == 0)stall = stall + 1;
    if(CPU.HazzardDetection.flush_o == 1)flush = flush + 1;  

    // print PC
    $fdisplay(outfile, "cycle = %d, Start = %d, Stall = %d, Flush = %d\nPC = %d", counter, Start, stall, flush, CPU.PC.pc_o);
    
    // print Registers
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "R0(r0) = %d, R8 (t0) = %d, R16(s0) = %d, R24(t8) = %d", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
    $fdisplay(outfile, "R1(at) = %d, R9 (t1) = %d, R17(s1) = %d, R25(t9) = %d", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
    $fdisplay(outfile, "R2(v0) = %d, R10(t2) = %d, R18(s2) = %d, R26(k0) = %d", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
    $fdisplay(outfile, "R3(v1) = %d, R11(t3) = %d, R19(s3) = %d, R27(k1) = %d", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
    $fdisplay(outfile, "R4(a0) = %d, R12(t4) = %d, R20(s4) = %d, R28(gp) = %d", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
    $fdisplay(outfile, "R5(a1) = %d, R13(t5) = %d, R21(s5) = %d, R29(sp) = %d", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
    $fdisplay(outfile, "R6(a2) = %d, R14(t6) = %d, R22(s6) = %d, R30(s8) = %d", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
    $fdisplay(outfile, "R7(a3) = %d, R15(t7) = %d, R23(s7) = %d, R31(ra) = %d", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);

    // print Data Memory
    $fdisplay(outfile, "Data Memory: 0x00 = %d", {CPU.Data_Memory.memory[3] , CPU.Data_Memory.memory[2] , CPU.Data_Memory.memory[1] , CPU.Data_Memory.memory[0] });
    $fdisplay(outfile, "Data Memory: 0x04 = %d", {CPU.Data_Memory.memory[7] , CPU.Data_Memory.memory[6] , CPU.Data_Memory.memory[5] , CPU.Data_Memory.memory[4] });
    $fdisplay(outfile, "Data Memory: 0x08 = %d", {CPU.Data_Memory.memory[11], CPU.Data_Memory.memory[10], CPU.Data_Memory.memory[9] , CPU.Data_Memory.memory[8] });
    $fdisplay(outfile, "Data Memory: 0x0c = %d", {CPU.Data_Memory.memory[15], CPU.Data_Memory.memory[14], CPU.Data_Memory.memory[13], CPU.Data_Memory.memory[12]});
    $fdisplay(outfile, "Data Memory: 0x10 = %d", {CPU.Data_Memory.memory[19], CPU.Data_Memory.memory[18], CPU.Data_Memory.memory[17], CPU.Data_Memory.memory[16]});
    $fdisplay(outfile, "Data Memory: 0x14 = %d", {CPU.Data_Memory.memory[23], CPU.Data_Memory.memory[22], CPU.Data_Memory.memory[21], CPU.Data_Memory.memory[20]});
    $fdisplay(outfile, "Data Memory: 0x18 = %d", {CPU.Data_Memory.memory[27], CPU.Data_Memory.memory[26], CPU.Data_Memory.memory[25], CPU.Data_Memory.memory[24]});
    $fdisplay(outfile, "Data Memory: 0x1c = %d", {CPU.Data_Memory.memory[31], CPU.Data_Memory.memory[30], CPU.Data_Memory.memory[29], CPU.Data_Memory.memory[28]});

	$fdisplay(outfile, "ID/EX: RSdata_o=%d, RTdata_o=%d, RDaddr_o=%d", CPU.ID_EX.RSdata_o, CPU.ID_EX.RTdata_o, CPU.ID_EX.RDaddr_o);
	$fdisplay(outfile, "mux8: %h", CPU.MUX8.data_o);
	$fdisplay(outfile, "ALUOp_o=%d, ALUSrc_o=%d, RegWrite_o=%d, MemWrite_o=%d, MemRead_o=%d, Mem2Reg_o=%d, Branch_o=%d", CPU.Control.ALUOp_o, CPU.Control.ALUSrc_o, CPU.Control.RegWrite_o, CPU.Control.MemWrite_o, CPU.Control.MemRead_o, CPU.Control.Mem2Reg_o, CPU.Control.Branch_o);
	
    $fdisplay(outfile, "\n");

	$display("cycle %d", counter);
    $display("[IF_ID]: pc_i=%d, instr_i=%b, flush_i=%d", CPU.IF_ID.pc_i, CPU.IF_ID.instr_i, CPU.IF_ID.flush_i);
	$display("[IF_ID]: pc_o=%d, instr_o=%b", CPU.IF_ID.pc_o, CPU.IF_ID.instr_o);
    $display("[Registers]: RSaddr_i=%d, RTaddr_i=%d, RDaddr_i=%d, RDdata_i=%d, RegWrite_i=%d, RSdata_o=%d, RTdata_o=%d",CPU.Registers.RSaddr_i, CPU.Registers.RTaddr_i, CPU.Registers.RDaddr_i, CPU.Registers.RDdata_i, CPU.Registers.RegWrite_i, CPU.Registers.RSdata_o, CPU.Registers.RTdata_o);
    $display("[ALU_Control]: funct_i=%b, ALUOp_i=%b, ALUCtrl_o=%b", CPU.ALU_Control.funct_i, CPU.ALU_Control.ALUOp_i, CPU.ALU_Control.ALUCtrl_o);
	$display("[Sign_Extend]: data_o=%b", CPU.Sign_Extend.data_o);
	 $display("[Add imm]: data1_in=%b, data_o=%b", CPU.Add_imm.data1_in, CPU.Add_imm.data_o);
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
	$display("\n");
	counter = counter + 1;
    
      
end

  
endmodule
