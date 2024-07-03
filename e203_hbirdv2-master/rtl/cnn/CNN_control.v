`define		CNN_BASE_ADDR		32'h10042000
`define		CNN_CTR				3'h0
`define		CNN_STATUS			3'h4

module cnn_control(
	input					clk,
	input					rst_n,
	
	//cfg icb command channel
	input					cfg_icb_cmd_valid,
	output					cfg_icb_cmd_ready,
	input		[31:0]		cfg_icb_cmd_addr,
	input 					cfg_icb_cmd_read,
	input		[31:0]		cfg_icb_cmd_wdata,
	input 		[3:0]		cfg_icb_cmd_wmask,
	//cfg icb response channel
	output 	reg				cfg_icb_rsp_valid,
	input 					cfg_icb_rsp_ready,
	output	reg	[31:0]		cfg_icb_rsp_rdata,
//	output					cfg_icb_rsp_err,

	output					enable,
	
	input 					done
);

//handshake signal
wire 			cfg_icb_cmd_hsk;
wire 			cfg_icb_cmd_wr_hsk;
wire 			cfg_icb_cmd_rd_hsk;

//4 registers
//0bit control the core whether be enabled
reg 	[7:0]	CNNCTR;

//0bit indicates whether the work is done
wire 	[7:0]	CNNSTATUS;

//handshake succeed
assign cfg_icb_cmd_hsk		=	cfg_icb_cmd_valid & cfg_icb_cmd_ready;
//assign cfg_icb_cmd_hsk		=	cfg_icb_cmd_valid;
//write data handshake succeed
assign cfg_icb_cmd_wr_hsk	=	cfg_icb_cmd_hsk & (~cfg_icb_cmd_read);
//read data handshake succeed
assign cfg_icb_cmd_rd_hsk	=	cfg_icb_cmd_hsk	& cfg_icb_cmd_read;

//keep ready
assign cfg_icb_cmd_ready	=	1'b1;

//inform the core to start work
assign enable				=	CNNCTR[0];

//register CNNSTATUS configuration
assign CNNSTATUS	=	done ? 8'b1 : 8'b0;

//register CNNCTR configuration
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		CNNCTR	<=	8'h0;
	end
	else if(cfg_icb_cmd_wr_hsk && (cfg_icb_cmd_addr[2:0] == `CNN_CTR))begin
		CNNCTR	<=	cfg_icb_cmd_wdata[7:0] & {8{cfg_icb_cmd_wmask[0]}};
	end
	else begin
		CNNCTR	<=	CNNCTR;
	end
end

//cfg_icb_cmd_valid control
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		cfg_icb_rsp_valid	<=	1'b0;
	end
	else if(cfg_icb_cmd_hsk && (~cfg_icb_rsp_valid))begin
		cfg_icb_rsp_valid	<=	1'b1;
	end
	else if(cfg_icb_rsp_ready && cfg_icb_rsp_valid)begin
		cfg_icb_rsp_valid	<=	1'b0;
	end
	else begin
		cfg_icb_rsp_valid	<=	1'b0;
	end
end

//cfg_icb_rsp_rdata control
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		cfg_icb_rsp_rdata	<=	32'h0;	
	end
	else if(cfg_icb_cmd_rd_hsk && cfg_icb_cmd_addr[2:0] == (`CNN_CTR))begin
		cfg_icb_rsp_rdata	<=	{24'h0, CNNCTR};
	end
	else if(cfg_icb_cmd_rd_hsk && cfg_icb_cmd_addr[2:0] == (`CNN_STATUS))begin
		cfg_icb_rsp_rdata	<=	{24'h0, CNNSTATUS};
	end
	else begin
		cfg_icb_rsp_rdata	<=	32'h0;
	end
end

endmodule
