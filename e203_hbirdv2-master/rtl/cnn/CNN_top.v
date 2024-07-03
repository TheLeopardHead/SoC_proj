module cnn_top(
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
	output 					cfg_icb_rsp_valid,
	input 					cfg_icb_rsp_ready,
	output		[31:0]		cfg_icb_rsp_rdata,
//	output					cfg_icb_rsp_err,
	
	//cnn icb command channel
	output 					cnn_icb_cmd_valid,
	input 					cnn_icb_cmd_ready,
	output		[31:0]		cnn_icb_cmd_addr,
	output					cnn_icb_cmd_read,
	output 		[31:0]		cnn_icb_cmd_wdata,
	output 		[3:0]		cnn_icb_cmd_wmask,
	//cnn icb response channel
	input 					cnn_icb_rsp_valid,
	output 					cnn_icb_rsp_ready,
	input 		[31:0]		cnn_icb_rsp_rdata//,
//	input					cnn_icb_rsp_err,
	
);	

wire				enable;
wire				done;

cnn_control cnn_control(
	.clk(clk),
	.rst_n(rst_n),
	
	.cfg_icb_cmd_valid(cfg_icb_cmd_valid),
	.cfg_icb_cmd_ready(cfg_icb_cmd_ready),
	.cfg_icb_cmd_addr(cfg_icb_cmd_addr),
	.cfg_icb_cmd_read(cfg_icb_cmd_read),
	.cfg_icb_cmd_wdata(cfg_icb_cmd_wdata),
	.cfg_icb_cmd_wmask(cfg_icb_cmd_wmask),
	
	.cfg_icb_rsp_valid(cfg_icb_rsp_valid),
	.cfg_icb_rsp_ready(cfg_icb_rsp_ready),
	.cfg_icb_rsp_rdata(cfg_icb_rsp_rdata),
	
	.enable(enable),
	//.stop(stop),
	
	.done(done)
);

cnn_core cnn_core(
	.clk(clk),
	.rst_n(rst_n),
	
	.cnn_icb_cmd_valid(cnn_icb_cmd_valid),
	.cnn_icb_cmd_ready(cnn_icb_cmd_ready),
	.cnn_icb_cmd_addr(cnn_icb_cmd_addr),
	.cnn_icb_cmd_read(cnn_icb_cmd_read),
	.cnn_icb_cmd_wdata(cnn_icb_cmd_wdata),
	.cnn_icb_cmd_wmask(cnn_icb_cmd_wmask),
	
	.cnn_icb_rsp_valid(cnn_icb_rsp_valid),
	.cnn_icb_rsp_ready(cnn_icb_rsp_ready),
	.cnn_icb_rsp_rdata(cnn_icb_rsp_rdata),
	
	.enable(enable),
	.done(done)
);
endmodule
	
