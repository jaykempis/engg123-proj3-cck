
// *******************************************************
// File Name:		ram_sync_read_d0.v
// Edited by: Iris Carson, Antonio Castro, Joshua Kempis
// *******************************************************


module ram_sync_read_d0(clock, addr, din, we, dout);

// Configuration Parameters
parameter AWIDTH = 3;		// Address Width Parameter, also used to calculate depth
parameter DWIDTH = 32;		// Data width parameter
localparam DEPTH  = 1 << AWIDTH;
// Memory Array Decaration

				input 	clock;			//Input signal for clock
				input 	[AWIDTH-1:0] addr;	//Parameterized Address bus input
				input 	[DWIDTH-1:0] din;	//Parameterized Data bus input
				input 	we;			//Write Enable (input HIGH = write, LOW = read)
				output  	[DWIDTH-1:0] dout;	//Parameterized Data bus output

reg [DWIDTH-1:0] mem_array [0:DEPTH-1];

// Memory initialization
initial
begin
	$readmemb("dram0.txt", mem_array);
end

// Internal Register to latch address for synchronous read operation
reg [AWIDTH-1:0] rd_addr;

// Sequential Block to write data in memory as well as latch read address
// depending on 'we' write enable signal
always@(posedge clock)
begin
	if(we)
		mem_array[addr] <= din;	

rd_addr <= addr;		
end

// Data out during read operation with latched address to keep output stable
assign dout = mem_array[rd_addr];

endmodule


module ram_sync_read_d1(clock, addr, din, we, dout);
// Configuration Parameters

parameter AWIDTH = 3;		// Address Width Parameter, also used to calculate depth
parameter DWIDTH = 32;		// Data width parameter
localparam DEPTH  = 1 << AWIDTH;

				input 	clock;			//Input signal for clock
				input 	[AWIDTH-1:0] addr;	//Parameterized Address bus input
				input 	[DWIDTH-1:0] din;	//Parameterized Data bus input
				input 	we;			//Write Enable (input HIGH = write, LOW = read)
				output  	[DWIDTH-1:0] dout;	//Parameterized Data bus output

// Memory Array Decaration

reg [DWIDTH-1:0] mem_array [0:DEPTH-1];

// Memory initialization
initial
begin
	$readmemb("dram1.txt", mem_array);
end

reg [AWIDTH-1:0] rd_addr;

always@(posedge clock)
begin
	if(we)
		mem_array[addr] <= din;	

rd_addr <= addr;		
end

assign dout = mem_array[rd_addr];
endmodule


module ram_sync_read_t0(clock, addr, din, we, dout);
// Configuration Parameters

parameter AWIDTH = 3;		// Address Width Parameter, also used to calculate depth
parameter DWIDTH = 14;		// Data width parameter
localparam DEPTH  = 1 << AWIDTH;

				input 	clock;			//Input signal for clock
				input 	[AWIDTH-1:0] addr;	//Parameterized Address bus input
				input 	[DWIDTH-1:0] din;	//Parameterized Data bus input
				input 	we;			//Write Enable (input HIGH = write, LOW = read)
				output  	[DWIDTH-1:0] dout;	//Parameterized Data bus output

// Memory Array Decaration

reg [DWIDTH-1:0] mem_array [0:DEPTH-1];

// Memory initialization
initial
begin
	$readmemb("tagRam0.txt", mem_array);
end

// Internal Register to latch address for synchronous read operation
reg [AWIDTH-1:0] rd_addr;

always@(posedge clock)
begin
	if(we)
		mem_array[addr] <= din;	

rd_addr <= addr;		
end

assign dout = mem_array[rd_addr];
endmodule

module ram_sync_read_t1(clock, addr, din, we, dout);
// Configuration Parameters

parameter AWIDTH = 3;		// Address Width Parameter, also used to calculate depth
parameter DWIDTH = 14;		// Data width parameter
localparam DEPTH  = 1 << AWIDTH;

				input 	clock;	//Input signal for clock
				input 	[AWIDTH-1:0] addr;	//Parameterized Address bus input
				input 	[DWIDTH-1:0] din;	//Parameterized Data bus input
				input 	we;			//Write Enable (input HIGH = write, LOW = read)
				output  	[DWIDTH-1:0] dout;	//Parameterized Data bus output

// Memory Array Decaration

reg [DWIDTH-1:0] mem_array [0:DEPTH-1];

// Memory initialization
initial
begin
	$readmemb("tagRam1.txt", mem_array);
end
// Internal Register to latch address for synchronous read operation
reg [AWIDTH-1:0] rd_addr;

// Sequential Block to write data in memory as well as latch read address
// depending on 'we' write enable signal
always@(posedge clock)
begin
	if(we)
		mem_array[addr] <= din;	

rd_addr <= addr;		
end

// Data out during read operation with latched address to keep output stable
assign dout = mem_array[rd_addr];

endmodule
