// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions:	Three modules included: HEX, HEXs, chooseHEXs
//
//					HEX:	decode a four-bit input value into
//							7-segment HEX display signals (0 to F)
//					HEXs:	decode four 8-bit inputs to eight 7-segment
//							HEX display signals (not compatible with DE1)
//					chooseHEXs:	decode four 8-bit inputs to a single
//								selected 7-segment HEX display singnals
//								(compatible with both DE1 and DE2)
//
// Input(s):		HEX
//						 in: 4-bit input (HEX: 0 to F)
//					HEXs
//						 in0 - in4: four 8-bit input (HEX: 00 to FF)
//					chooseHEXs
//						 in0-in4: four 8-bit input (HEX: 00 to FF)
//						 select: two-bit input controlling output decoded
//								 signals
//
// Output(s):		HEX/HEXs/chooseHEXs
//						 out: seven-segment display decoded value(s) 
//
// ---------------------------------------------------------------------

module chooseHEXs
(
in0, in1, in2, in3,
select, out1, out0
);
input 	[7:0] in0, in1, in2, in3;
input	[1:0] select;
output 	[6:0] out0, out1;

reg		[7:0] temp_in;

always@(*)
begin
	if( select == 0 )
		temp_in = in0;
	else if( select == 1 )
		temp_in = in1;
	else if( select == 2 )
		temp_in = in2;
	else if( select == 3 )
		temp_in = in3;
	else
		temp_in = in0;
end

HEX hex0 ( temp_in[7:4], out1 );
HEX hex1 ( temp_in[3:0], out0 );

endmodule

module HEXs
(
in0, in1, in2, in3,
counter, select,
out0, out1, out2, out3
//out4, out5, out6, out7
);
input 	[7:0] in0, in1, in2, in3;	// data for register
input 	[15:0] counter;	// data for counter
input select;
output 	[6:0] out0, out1, out2, out3;
//output 	[6:0] out4, out5, out6, out7;


//HEX hex0 ( in0[7:4], out3,select_n  );
//HEX hex1 ( in0[3:0], out2,select_n  );
//HEX hex2 ( in1[7:4], out1,select_n  );
//HEX hex3 ( in1[3:0], out0,select_n  );

wire [7:0] display0, display1, display2, display3;

assign display0 = select ? in0 : counter[15:8];
assign display1 = select ? in1 : counter[7:0];
assign display2 = select ? in2 : 8'b00000000;
assign display3 = select ? in3 : 8'b00000000;

// we do not have enough hex display to show the 4 registers at the same time
// but enough for counter to display

// it will only show first two registers or the counter depending on SW[2]

HEX hex0 ( display0[7:4], out0);
HEX hex1 ( display0[3:0], out1);
HEX hex2 ( display1[7:4], out2);
HEX hex3 ( display1[3:0], out3);


endmodule

module HEX (in, out);
input 	[3:0] in;
output reg [6:0] out;


always @(in)
begin
	case (in)
		0: out = 7'b1000000;
		1: out = 7'b1111001;
		2: out = 7'b0100100;
		3: out = 7'b0110000;
		4: out = 7'b0011001;
		5: out = 7'b0010010;
		6: out = 7'b0000010;
		7: out = 7'b1111000;
		8: out = 7'b0000000;
		9: out = 7'b0010000;
		10: out = 7'b0001000;
		11: out = 7'b0000011;
		12: out = 7'b1000110;
		13: out = 7'b0100001;
		14: out = 7'b0000110;
		15: out = 7'b0001110;
	 endcase
 end
endmodule
