module proc (DIN, Resetn, Clock, Run, Done_out, BusOutput, ADDR_out, DOUT_out);
	input [15 : 0] DIN;
	input Resetn, Clock, Run;
	output Done_out;
	output [15 : 0] BusOutput;
	output [15 : 0] ADDR_out, DOUT_out;
	parameter MV = 3'b000, MVI = 3'b001, ADD = 3'b010, SUB = 3'b011; 
	reg Done;
	reg Clear;
	assign Done_out = Done;
	reg ld_A, ld_IR, ld_G, ld_EN, bus_reg_sel, 
		bus_Gout_sel, bus_DIN_sel, p_ld, incr_PC, ld_ADDR, ld_DOUT;
	wire [2 : 0] Tstep_Q;
	wire [2 : 0] Opcode, Rx, Ry;
	reg  [7 : 0] ld_R;
	wire [8 : 0] IR;
	wire [15 : 0] Aout, ALU_out, G_out;
	reg  [15 : 0] BusWires;
	reg  [7 : 0] R_sel, ld_sel;
	wire [15 : 0] R0, R1, R2, R3, R4, R5, R6, PC;
	wire AddSub;
	output [1 : 0] cycle;
	assign cycle = Tstep_Q;
	assign AddSub = (Opcode == ADD);
	/********************** Counter for Counting Cycles *****************/
	upcount_3bit Tstep (Clear, Clock, Tstep_Q);
	/********************** Instruction Decoding ************************/
	assign Opcode = IR[8 : 6];
	dec3to8 decX (IR[5:3], 1'b1, Rx);
	dec3to8 decY (IR[2:0], 1'b1, Ry);

	/********************** Control logic *******************************/
	always @(Tstep_Q or Opcode or Rx or Ry or Run or Resetn)	
	begin
		// . . . specify initial values
		if (!Resetn) begin
			Clear = 1;
			ld_IR = 0;
			ld_EN = 0;
			ld_A = 0;
			ld_G = 0;
			R_sel = 8'bxxxx_xxxx;
			ld_sel = 8'bxxxx_xxxx;
			bus_reg_sel = 0;
			bus_Gout_sel = 0;
			bus_DIN_sel = 0;
			Done = 0;
		end
		else if(Run) begin
			case (Tstep_Q)
				2'b00: // store DIN in IR in time step 0
					begin
						Clear = 0;
						ld_IR = 1;
						ld_EN = 0;
						ld_A = 0;
						ld_G = 0;
						R_sel = 8'bxxxx_xxxx;
						ld_sel = 8'bxxxx_xxxx;
						bus_reg_sel = 0;
						bus_Gout_sel = 0;
						bus_DIN_sel = 1;
						Done = 0;
					end
				2'b01: // time step 1
					case (Opcode)
						MV: begin
							Clear = 1;
							ld_IR = 0;
							ld_EN = 1;
							ld_A = 0;
							ld_G = 0;
							R_sel = Ry;
							ld_sel = Rx;
							bus_reg_sel = 1;
							bus_Gout_sel = 0;
							bus_DIN_sel = 0;
							Done = 1;
						end
						MVI: begin
							Clear = 1;
							ld_IR = 0;
							ld_EN = 1;
							ld_A = 0;
							ld_G = 0;
							R_sel = 8'bxxxx_xxxx;
							ld_sel = Rx;
							bus_reg_sel = 0;
							bus_Gout_sel = 0;
							bus_DIN_sel = 1;
							Done = 1;
						end
						ADD: begin
							Clear = 0;
							ld_IR = 0;
							ld_EN = 0;
							ld_A = 1;
							ld_G = 0;
							R_sel = Rx;
							ld_sel = 8'bxxxx_xxxx;
							bus_reg_sel = 1;
							bus_DIN_sel = 0;
							bus_Gout_sel = 0;
							Done = 0;
						end
						SUB: begin
							Clear = 0;
							ld_IR = 0;
							ld_EN = 0;
							ld_A = 1;
							ld_G = 0;
							R_sel = Rx;
							ld_sel = 8'bxxxx_xxxx;
							bus_reg_sel = 1;
							bus_DIN_sel = 0;
							bus_Gout_sel = 0;
							Done = 0;
						end
						default: begin
							Clear = 1;
							ld_IR = 0;
							ld_EN = 0;
							ld_A = 0;
							ld_G = 0;
							R_sel = 8'bxxxx_xxxx;
							ld_sel = 8'bxxxx_xxxx;
							bus_reg_sel = 0;
							bus_DIN_sel = 0;
							bus_Gout_sel = 0;
							Done = 0;
						end
					endcase
				2'b10: //define signals in time step 2
					case (Opcode)
						ADD: begin
							Clear = 0;
							ld_IR = 0;
							ld_EN = 0;
							ld_A = 0;
							ld_G = 1;
							R_sel = Ry;
							ld_sel = 8'bxxxx_xxxx;
							bus_reg_sel = 1;
							bus_DIN_sel = 0;
							bus_Gout_sel = 0;
							Done = 0;
						end
						SUB: begin
							Clear = 0;
							ld_IR = 0;
							ld_EN = 0;
							ld_A = 0;
							ld_G = 1;
							R_sel = Ry;
							ld_sel = 8'bxxxx_xxxx;
							bus_reg_sel = 1;
							bus_DIN_sel = 0;
							bus_Gout_sel = 0;
							Done = 0;
						end
						default: begin
							Clear = 1;
							ld_IR = 0;
							ld_EN = 0;
							ld_A = 0;
							ld_G = 0;
							R_sel = 8'bxxxx_xxxx;
							ld_sel = 8'bxxxx_xxxx;
							bus_reg_sel = 0;
							bus_DIN_sel = 0;
							bus_Gout_sel = 0;
							Done = 0;
						end
					endcase
				2'b11: //define signals in time step 3
					case (Opcode)
						ADD: begin
							Clear = 1;
							ld_IR = 0;
							ld_EN = 1;
							ld_A = 0;
							ld_G = 0;
							R_sel = 8'bxxxx_xxxx;
							ld_sel = Rx;
							bus_reg_sel = 0;
							bus_DIN_sel = 0;
							bus_Gout_sel = 1;
							Done = 1;
						end
						SUB: begin
							Clear = 1;
							ld_IR = 0;
							ld_EN = 1;
							ld_A = 0;
							ld_G = 0;
							R_sel = 8'bxxxx_xxxx;
							ld_sel = Rx;
							bus_reg_sel = 0;
							bus_DIN_sel = 0;
							bus_Gout_sel = 1;
							Done = 1;
						end
						default: begin
							Clear = 1;
							ld_IR = 0;
							ld_EN = 0;
							ld_A = 0;
							ld_G = 0;
							R_sel = 8'bxxxx_xxxx;
							ld_sel = 8'bxxxx_xxxx;
							bus_reg_sel = 0;
							bus_DIN_sel = 0;
							bus_Gout_sel = 0;
							Done = 0;
						end
					endcase
			endcase
		end
		else begin
				Clear = 1;
				ld_IR = 0;
				ld_EN = 0;
				ld_A = 0;
				ld_G = 0;
				R_sel = 8'bxxxx_xxxx;
				ld_sel = 8'bxxxx_xxxx;
				bus_reg_sel = 0;
				bus_DIN_sel = 0;
				bus_Gout_sel = 0;
				Done = 0;			
		end
	end

	/************************** BUS mux ********************************/
	always @ (*) begin
		if (bus_reg_sel) begin
			case(R_sel) 
				8'b0000_0001: BusWires = R0;
				8'b0000_0010: BusWires = R1; 
				8'b0000_0100: BusWires = R2;
				8'b0000_1000: BusWires = R3;
				8'b0001_0000: BusWires = R4;
				8'b0010_0000: BusWires = R5;
				8'b0100_0000: BusWires = R6;
				8'b1000_0000: BusWires = PC;
				default: BusWires = 8'bxxxx_xxxx;
			endcase
		end
		else if (bus_Gout_sel) begin
				BusWires = G_out;
		end
		else if (bus_DIN_sel) begin
				BusWires = DIN;
		end
		else 	// should not happen
				BusWires = 16'bxxxx_xxxx_xxxx_xxxx;
	end	

	/************************* Register Load Enable ********************/
	always @ (*) begin
		if (ld_EN) ld_R = ld_sel;
		else ld_R = 8'b0000_0000;
	end

	/**************************** Registers ***************************/
	regn R_0 (BusWires, ld_R[0], Clock, R0);
	regn R_1 (BusWires, ld_R[1], Clock, R1);
	regn R_2 (BusWires, ld_R[2], Clock, R2);
	regn R_3 (BusWires, ld_R[3], Clock, R3);
	regn R_4 (BusWires, ld_R[4], Clock, R4);
	regn R_5 (BusWires, ld_R[5], Clock, R5);
	regn R_6 (BusWires, ld_R[6], Clock, R6);
	regn A   (BusWires, ld_A,    Clock, Aout);
	regn #(.n(9)) R_IR (DIN[15 : 7], ld_IR, Clock, IR);
	regn G   (ALU_out,  ld_G, Clock, G_out);
	regn ADDR (BusWires, ld_ADDR, Clock, ADDR_out);
	regn DOUT (BusWires, ld_DOUT, Clock, DOUT_out);
	regn #(.n(1)) W    (Wr, 1'b1, Clock, W_out);
	/**************************** ALU ***************************/
	ALU  alu (Aout, BusWires, AddSub, ALU_out);
	/**************************** PC ****************************/
	assign p_ld = ld_R[7];
	counter ProgCnter (Resetn, BusWires, p_ld, incr_PC, Clock, PC);
	assign BusOutput = BusWires;
endmodule
