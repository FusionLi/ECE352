/*****************************************************************************
 *                                                                           *
 * Module:       Peripheral_on_External_Bus                                  *
 * Description:                                                              *
 *      This module is used for the registers for part I of the bus          *
 *   communication exercise in Altera's computer organization lab set.       *
 *                                                                           *
 *****************************************************************************/

module Peripheral_on_External_Bus (
	// Inputs
	clk,
	reset_n,
	
	address,
	bus_enable,
	byte_enable,
	rw,
	write_data,
	
	// Bidirectionals
	
	// Outputs
	acknowledge,
	read_data,
	
	register_0,
	register_1,
	register_2,
	register_3
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				clk;
input				reset_n;

input		[31:0]	address;
input				bus_enable;
input		[1:0]	byte_enable;
input				rw;
input		[15:0]	write_data;

// Bidirectionals

// Outputs
output				acknowledge;
output		[15:0]	read_data;

output	reg	[15:0]	register_0;
output	reg	[15:0]	register_1;
output	reg	[15:0]	register_2;
output	reg	[15:0]	register_3;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
	wire detector;
	wire [1:0]reg_index;
	assign reg_index = address[1:0]	// which register to operate
	assign detector = (address[20:1] == 0x00000)
// Internal Registers

// State Machine Registers
	// A: initial state to judge whether it is a read or write
	// B: read
	// C: write
	// D: final state to finsh transaction and go back to initial state
	parameter [1:0] A = 0, B = 1, C = 2, D = 3;
	reg [1:0] current_state, next_state;
	reg [15:0] current_data;
/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
	always @ (current_state) 
	begin
		case (current_data)
			A:
			begin
			if (rw)	// write state
				next_state = C;
			else	// read state
				next_state = B;
			end
			B: next_state = D;
			C: next_state = D;
			D: next_state = A;
			default: next_state = A;
		endcase
	end
	
assign acknowledge	= (current_state == D);	// notify cpu to finish transaction 

assign read_data	= current_data;

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge clk)
begin
	if (reset_n == 0)
	begin
		register_0 <= 16'h0000;
		register_1 <= 16'h0000;
		register_2 <= 16'h0000;
		register_3 <= 16'h0000;
	end
	case (current_data)
		B:	// read
		begin
			case (reg_index)
				0: current_data <= register_0;
				1: current_data <= register_1;
				2: current_data <= register_2;
				3: current_data <= register_3;
			endcase
		end
		C:	// write
			case (reg_index)
				0: register_0 <= current_data;
				1: register_1 <= current_data;
				2: register_2 <= current_data;
				3: register_3 <= current_data;
			endcase
	endcase
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule
