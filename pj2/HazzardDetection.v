module HazzardDetection(
	ID_EX_MemWrite_i,
	ID_EX_MemRead_i,
	ID_EX_RegisterRd_i,
	IF_ID_RS_i,
	IF_ID_RT_i,
	Registers_RSdata_i ,
    Registers_RTdata_i ,
    branch_i,
	mux8_o,
	flush_o
);

input	ID_EX_MemWrite_i, ID_EX_MemRead_i;
input	[4:0]	ID_EX_RegisterRd_i;
input	[4:0]	IF_ID_RS_i;
input	[4:0]	IF_ID_RT_i;
input	[31:0]	Registers_RSdata_i, Registers_RTdata_i;
input	branch_i;

output reg 	mux8_o;
output reg 	flush_o;

always @( * ) begin
	//lw stall
	if (ID_EX_MemRead_i && ((ID_EX_RegisterRd_i == IF_ID_RS_i) || (ID_EX_RegisterRd_i == IF_ID_RT_i))) begin
		//stall the pipeline, mux choose 0 rather than control
		mux8_o <= 1'b1;
	end
	else begin
		mux8_o <= 1'b0;
	end

	//flush
	if (branch_i && Registers_RSdata_i == Registers_RTdata_i) begin
		flush_o <= 1'b1;
	end
	else begin
		flush_o <= 1'b0;
	end
end

endmodule
