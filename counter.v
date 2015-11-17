module counter (clock, reset, stopCounter, counter);

input stopCounter,reset,clock;

output reg [15:0] counter;

always @(posedge clock or posedge reset or stopCounter)
begin
	if (reset)
		counter = 0;
	else if(!stopCounter)
		counter = counter + 1;
end

endmodule
