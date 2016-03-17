module part_III (Resetn, Clock, Run, proc_done, proc_DOUT);
	input Resetn, Clock, Run;
	output proc_done;
	output  [15 : 0] proc_DOUT;
	wire ld_POUT;


	/***************************** Processor ***********************/
	proc Processor (Mem_out, Resetn, Clock, Run, proc_done, Bus_out, ADDR, DOUT);
	/***************************** Memory **************************/
	mem MEM (addr, MClock, mem_out);
	/***************************** Output Register *****************/
	assign ld_POUT = ;
	regn PROC_OUT (DOUT, ld_POUT, Clock, proc_DOUT);
endmodule
