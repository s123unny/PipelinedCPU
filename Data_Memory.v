module Data_Memory(
	clk_i,
	data_i,
	MemWr_i,
	MemRe_i,
	Adr_i,
	data_o
);

input       		clk_i;
input 	[31:0] 		data_i;
input 				MemWr_i, MemRe_i;
input	[31:0]		Adr_i;
output reg [31:0]	data_o;

reg 	[7:0]		memory 	[31:0];

always @(posedge clk_i) begin
	if (MemWr_i) begin
		//write data_i to Adr_i
		memory[Adr_i+3] = data_i[31:24];
		memory[Adr_i+2] = data_i[23:16];
		memory[Adr_i+1] = data_i[15:8];
		memory[Adr_i] = data_i[7:0];
	end
	else if (MemRe_i) begin
		data_o = {memory[Adr_i+3],memory[Adr_i+2],memory[Adr_i+1],memory[Adr_i]};
	end
end
endmodule