module HazzardDetection(
	ID_EX_MemWrite_i,
	ID_EX_MemRead_i,
	ID_EX_RegisterRd_i,
	IF_ID_RS_i,
	IF_ID_RT_i,
	mux8_o,
	IF_ID_write_o,
	PC_write_o
);

input	ID_EX_MemRead_i;
input	[4:0]	ID_EX_RegisterRd_i;
input	[4:0]	IF_ID_RS_i;
input	[4:0]	IF_ID_RT_i;

output reg 	mux8_o;
output reg 	PC_write_o;
output reg  IF_ID_write_o;

always @( * ) begin
	//lw stall
	if (ID_EX_MemRead_i and ((ID_EX_RegisterRd_i == IF_ID_RS_i) or (ID_EX_RegisterRd_i == IF_ID_RT_i))) begin
		//stall the pipeline, mux choose 0 rather than control
		mux8_o = 1'b0
		IF_ID_write_o = 1'b0
		PC_write_o = 1'b0
	end
	else begin
		mux8_o = 1'b1
		IF_ID_write_o = 1'b1
		PC_write_o = 1'b1	
	end
end

endmodule