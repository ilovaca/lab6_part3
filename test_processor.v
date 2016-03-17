module test_processor (Resetn, PClock, MClock, Run, proc_done, BusOutput, MEM_, cycle);
	input Resetn, PClock, MClock, Run;
	output proc_done;
	output [15 : 0] BusOutput;

	wire [4 : 0] addr;
	wire [15 : 0] mem_out;
	output [15 : 0] MEM_;
	output [1 : 0] cycle;
	reg proc_run;
	assign MEM_ = mem_out;
	wire incr_PC;
	// assign incr_PC = ;
	/************************* CPU *******************************/
	proc processor (mem_out, Resetn, PClock, Run, proc_done, BusOutput, cycle);
	/************************* MEMory ****************************/
	mem MEM (addr, MClock, mem_out);
	/********************** Program Counter **********************/
	counter PC (Resetn, incr_PC, MClock, addr);

	/*************************************************************/
	/*
	So dumb we don't need clock synchronization here
	*/
endmodule
