module counter (Resetn, pin, p_ld, increment, Clock, Q);
	input Resetn, Clock, p_ld, increment;
	input [15 : 0] pin;
	output reg [15 : 0] Q;

	always @(posedge Clock) begin
		if (Clear)
			Q <= 16'b0;
		else if (increment)
			Q <= Q + 1'b1; 
		else if (p_ld)
			Q <= pin;
 	end
endmodule
