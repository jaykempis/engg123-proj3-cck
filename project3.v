
// *******************************************************
// File Name:		project3.v
// Two-Way Set-Associative Cache Controller
// Hardware Implementation Project 3
// Edited by: Iris Carson, Antonio Castro, Joshua Kempis
// *******************************************************

module project3(CLK, RST, adrCPU, adrMM, dataCPU, dataMM, readyMem, readCPU, writeCPI, readMem, writeMem, stallCPU);

input CLK,
input RST,
input readyMem;
input readCPU;
input writeCPU;
output reg readMem;
output reg writeMem;
output reg stallCPU;

//cache parameters in powers of 2
parameter cachesize = 22; //4MB
parameter cachelines = 12; 
parameter blocksize = 10; //1KB
parameter set_num = 11;

parameter valid_bit = 1;
parameter used_bit = 1;
parameter dirty_bit = 1;
parameter tagWIDITH = 11;

parameter adrWIDTH = 16;
parameter dataWIDTH	= 8;

input [adrWIDTH-1:0] adrCPU,	//Address bus from CPU
output reg [adrWIDTH-1:0] adrMM,	//Address bus to Main Memory
	
inout [dataWIDTH-1:0] dataCPU,	//Data Bus from CPU
inout [dataWIDTH-1:0] dataMM	//Data Bus to Main Memory


reg [2:0] state;
localparam idle = 3'b000, read = 3'b001, write = 3'b010, readMem = 3'b011, waitMem = 3'b100, updateMem = 3'b101, updateCache = 3'b110;

reg readwrite;
reg writeDataByte;

reg flag;

//tag and data parameters and setup
wire [(dataWIDTH*blocksize)-1:0] data1;  
wire [(dataWIDTH*blocksize)-1:0] data2;
reg [(dataWIDTH*blocksize)-1:0] readdata;
reg [(dataWIDTH*blocksize)-1:0] writedata;
reg [(dataWIDTH*blocksize)-1:0] sdata1;
reg [(dataWIDTH*blocksize)-1:0] sdata2;

wire [tagWIDTH-1:0] tagdata;
wire [(valid_bit+used_bit+dirty_bit+tagWIDTH-1):0]  tag1; 
wire [(valid_bit+used_bit+dirty_bit+tagWIDTH-1):0]  tag2;
reg [(valid_bit+used_bit+dirty_bit+tagWIDTH-1):0] writetag1;
reg [(valid_bit+used_bit+dirty_bit+tagWIDTH-1):0] writetag2;
reg [(valid_bit+used_bit+dirty_bit+tagWIDTH-1):0] stag1;
reg [(valid_bit+used_bit+dirty_bit+tagWIDTH-1):0] stag2;

wire  [dataWIDTH-1:0] bytew1;
wire  [dataWIDTH-1:0] bytew2;

//active high flags
reg [3:0] i;  
reg readwrite;
reg write1;
reg write2;
reg write3;
reg write4;

//hit parameters
wire hit, write_hit1, write_hit2, valid_flag, write_valid1, write_valid2, used1, used2, dirty_flag, write_dirty1, write_dirty2;

assign hit = write_hit1 | write_hit2;
assign write_hit1 = write_valid1 & (tagdata == tag1[10:0]);
assign write_hit2 = write_valid2 & (tagdata == tag2[10:0]);
assign valid = write_valid1 & write_valid2;
assign write_valid1 = tag1[13];
assign write_valid2 = tag2[13];
assign used1 = tag1[12];
assign used2 = tag2[12];
assign dirty = write_dirty1 | write_dirty2;
assign write_dirty1 = tag1[11];
assign write_dirty2 = tag2[11];


always@(posedge CLK or negedge RST)
begin
	if (!RST)
	begin
    //insert reset values
    
	end
	
	else
	begin
		case(state)
		
			idle: //default, wait for read/write 
			begin
			
				if(readCPU)
				begin
					state <= read;
					readwrite <= 1'b1;
				end
				else if(writeCPU)
				begin
					state <= write;
					readwrite <= 1'b0;
					writeDataByte <= dataCPU;
				end
				else state <= state;
				
			end
			
			
			read: //read hit or miss cache
			begin 
				//hit flag
				//wire parameters
			end
			
			
			write: //write hit or miss cache
			begin
				//hit flag
				//wire paramters
			end
			
			
			readMem: //drive memory bus address
			begin
				
				if(readyMem)
				begin
					readMem <= 1'b1;
					state <= waitMem;
				end
				else
				begin
					readMem <= 1'b0;
					state <= state;
				end
	
			end
			
			
			waitMem: //check/wait if memory bus is ready
			begin
			
				if(readyMem)
				begin
					if(flag)	state <= readMM;
					else state <= updateCache;
					readMem <= 1'b0;
					writeMem <= 1'b1;
				end
				else
				begin
					state <= state;
				end
	
			end
			
			
			updateMem: //check LRU location
			begin
	
				flag <= 1'b1;
				if(readyMem)
				begin
					state <= waitMem;
				end
				else
				begin
					state <= state;
				end
	
			end
			
			
			updateCache: //store read data to memory, update cache
			begin
	
			end
			
			
			default: //default values
			begin
	
			end
		endcase
	end


end


endmodule

