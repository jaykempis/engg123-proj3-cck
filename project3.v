
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
output reg stall;

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
reg [adrWIDTH-1:0] adrlatch;


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

//active high flags for input/sample data
reg [3:0] i;  
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
    //default parameters
		state <= idle;
		
		adrMM <= 'b0;
		readMem <= 'b0;
		writeMem <= 'b0;
		stall <= 'b0;
		
		writedata <= 'b0;
		tag1 <= 'b0;
		tag2 <= 'b0;
		write1 <= 1'b0;
		write2 <= 1'b0;
		write3 <= 1'b0;
		write4 <= 1'b0;
		readwrite <= 1'b1;
		
		sdata1 <= 'b0;
		sdata2 <= 'b0;
		stag1 <= 'b0;
		stag2 <= 'b0;
		readdata <= 'b0;
		index <= 4'd0;
		flag <= 1'b0;
	end
	
	else
	begin
		case(state)
		
			idle: //default, wait for read/write 
			begin
				//set parameters
				write1 <= 1'b0;
		        write2 <= 1'b0;
				write3 <= 1'b0;
				write4 <= 1'b0;
				stall <= 1'b0;
				readMem <= 1'b0;
				writeMem <= 1'b0;
				writedata <= 'b0;
				writetag1 <= 'b0;
				writetag2 <= 'b0;
				
				flag <= 1'b0;
				index <= 4'd0;
				
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
				write1 <= 1'b0;
				write2 <= 1'b0;
				
				//case statement for hit/miss
				case(hit)
					1'b0: 
					begin
						stag1 <= tag1;
						stag2 <= tag2;
						sdata1 <= data1;
						sdata2 <= data2;
						stall <= 1'b1;
						write1 <= 1'b0;
						write2 <= 1'b0;
						if(ready_mem)
						begin
							if(valid & dirty) state <= updateMem;
							else state <= readMem;
						end
						else state <= state;
					end
						
					1'b1:
					begin
						state <= idle;
						write1 <= 1'b1;
						write2 <= 1'b1;
						stall <= 1'b0;
					    if(write_hit1)
						begin
							if(used1) writetag1 <= tag1;
							else writetag1 <= {tag1[13],1'b1,tag1[11:0]};
							if(used2) writetag2 <= tag2;
							else writetag2 <= {tag2[13],1'b1,tag2[11:0]};
						end
					end
				endcase	
			end
			
			
			write: //write hit or miss cache
			begin
				//case statement for hit/miss
				case(hit)
					1'b0:  
					begin
						stag1 <= tag1;
						stag2 <= tag2;
						sdata1 <= data1;
						sdata2 <= data2;
						stall <= 1'b1;
					  if(readyMem)
						if(valid & dirty) state <= updataMem;
						else state <= readMem;
					  else state <= write;
					end
					
					1'b1:
					begin
						state <= idle;
						write1 <= 1'b1;
						write2 <= 1'b1;
						stall <= 1'b0;
							if(write_hit1)
							begin
								write1 <= 1'b1;  
								if(used1) writetag1 <= {tag1[13:12],1'b1,tag1[10:0]};
								else writetag1 <= {tag2[13],1'b1,1'b1,tag1[10:0]};
								if(used2) writetag2 <= tag2;
								else writetag2 <= {tag3[13],1'b1,tag2[11:0]};
							end
							else
							begin
								write2 <= 1'b1;
								if(used2) writetag2 <= {tag2[13],1'b0,1'b1,tag2[10:0]};
								else writetag2 <= {tag2[13:12],1'b1,tag2[10:0]};
								if(used1) writetag1 <= {tag1[13],1'b0,tag1[11:0]};
								else writetag1 <= tag1;
							 end
					end
				endcase
			end
			
			
			readMem: //drive memory bus address
			begin
				flag <= 1'b0;
				adrMM <= {addrlatch[15:2],2'd0};
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
				else state <= waitMem;
				end
			end
			
			
			updateMem: //check LRU location
			begin
				flag <= 1'b1;
				//update
				if(used1) adrMM <= {stag2[10:0],adrlatch[4:2],2'd0};
				else adrMM <= {stag1[10:0],adrlatch[4:2],2'd0};
				//move state
				if(readyMem)
				begin
					writeMem <= 1'b1;
					state <= waitMem;
				end
				else
				begin
					writeMem <= 1'b0;
					state <= state;
				end
			end
			
			
			updateCache: //store read data to memory, update cache
			begin
				if(index!=4'b1111) index <= {1'b1,index[3:1]};
				else
				begin
					state <= idle;
					if(used1)
					begin
						writetag2 <= {1'b1,1'b0,1'b0,adrlatch[15:5]};
						writetag1 <= {stag1[13],1'b0,stag1[11:0]};
						write2 <= 1'b1;
						write1 <= 1'b0;
						write3 <= 1'b1;
						write4 <= 1'b1;
					end
					else
					begin
						writetag1 <= {1'b1,1'b1,1'b0,adrlatch[15:5]};
						writetag2 <= {stag2[13],1'b1,stag3[11:0]};
						write1 <= 1'd1;
						write2 <= 1'd0;
						write3 <= 1'd1;
						write4 <= 1'd1;
					end
				end
			end
		
			
			default: //default values
			begin
				//default parameters
				state <= idle;
				
				adrMM <= 'd0;
				readMem <= 'd0;
				writeMem <= 'd0;
				stall <= 'd0;
				
				writedata <= 'd0;
				tag1 <= 'd0;
				tag2 <= 'd0;
				write1 <= 1'd0;
				write2 <= 1'd0;
				write3 <= 1'd0;
				write4 <= 1'd0;
				readwrite <= 1'd1;
					
				sdata1 <= 'd0;
				sdata2 <= 'd0;
				stag1 <= 'd0;
				stag2 <= 'd0;
				readdata <= 'd0;
				index <= 4'd0;
				flag <= 1'd0;
			end
		endcase
	end
end


endmodule


//module to read cache data files
module readCacheData(CLK, ADR, IN, WRITE, OUT);
input CLK, WRITE;

parameter adrWIDTH = 3;
parameter dataWIDTH = 32;
localparam dep = 1 << adrWIDTH;

input [AWIDTH-1:0] ADR
input [DWIDTH-1:0] IN;
output [DWIDTH-1:0] OUT;

reg [dataWIDTH-1:0] memory [0:dep-1];

initial
begin
	$readmemb("cachedata.txt", memory);
end

reg [adrWIDTH-1:0] readAddress;

always@(posedge clock)
begin
  if(WRITE) memory[ADR] <= IN;	
  readAddress <= ADR;		
end

assign OUT = memory[readAddress];

endmodule


//module to read tag data files
module readTagData(CLK, ADR, IN, WRITE, OUT);
input CLK, WRITE;

parameter adrWIDTH = 3;
parameter dataWIDTH = 32;
localparam dep = 1 << adrWIDTH;

input [AWIDTH-1:0] ADR
input [DWIDTH-1:0] IN;
output [DWIDTH-1:0] OUT;

reg [dataWIDTH-1:0] memory [0:dep-1];

initial
begin
	$readmemb("tagdata.txt", memory);
end

reg [adrWIDTH-1:0] readAddress;

always@(posedge clock)
begin
	if(WRITE) memory[ADR] <= IN;	
	readAddress <= ADR;		
end

assign OUT = memory[readAddress];

endmodule



