module upcount_3bit (Clear, Clock, Q);
	input Clear, Clock;
	output reg [2 : 0] Q;
	
	always @(posedge Clock)
		if (Clear)
			Q <= 3'b0;
		else 
			Q <= Q + 1'b1; 
endmodule 
