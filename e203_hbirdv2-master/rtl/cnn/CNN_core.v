module cnn_core(
	input					clk,
	input					rst_n,
	
	//cnn icb command channel
	output 	reg				cnn_icb_cmd_valid,
	input 					cnn_icb_cmd_ready,
	output	reg	[31:0]		cnn_icb_cmd_addr,
	output	reg				cnn_icb_cmd_read,
	output 	reg	[31:0]		cnn_icb_cmd_wdata,
	output 		[3:0]		cnn_icb_cmd_wmask,
	//cnn icb response channel
	input 					cnn_icb_rsp_valid,
	output 					cnn_icb_rsp_ready,
	input 		[31:0]		cnn_icb_rsp_rdata,
//	input					cnn_icb_rsp_err,

	input 					enable,
	//
	output	reg				done//,
);
//state
parameter		IDLE 			= 	3'b000;
parameter 		LOAD_WEIGHT		=	3'b001;
parameter		LOAD_IMAGE		=	3'b010;
parameter		COMPUTE			=	3'b011;
parameter		STORE			=	3'b100;
parameter		DONE			=	3'b101;
	
parameter		weight_addr 	=	32'h00002000;
parameter		image_addr		= 	32'h40000000;
parameter 		out_addr		=	32'h60000000;

//Systolic Array Mode
parameter		DISABLE 		= 	2'b00;
parameter		SINGLE 			= 	2'b01;
parameter		CLEAR			=	2'b10;

parameter		DELTA01			= 	16'h0e00;
parameter		DELTA02			= 	16'h1a00;
parameter		DELTA03			= 	16'h2200;
parameter		DELTA04			= 	16'h2700;
parameter		DELTA05			= 	16'h2b00;
parameter		DELTA06			= 	16'h2c00;
parameter		DELTA07			= 	16'h2b00;

parameter		DELTA10			= 	16'h2900;
parameter		DELTA11			= 	16'h2600;
parameter		DELTA12			= 	16'h2200;
parameter		DELTA13			= 	16'h1e00;
parameter		DELTA14			= 	16'h1a00;
parameter		DELTA15			= 	16'h1600;
parameter		DELTA16			= 	16'h1200;
parameter		DELTA17			= 	16'h0f00;

parameter		DELTA20			= 	16'h0c00;


//command channel handshake signals
wire 			cnn_icb_cmd_hsk;
wire 			cnn_icb_cmd_rd_hsk;
wire			cnn_icb_cmd_wr_hsk;
wire 			send_update_control;
//response channel handshake signals
wire 			cnn_icb_rsp_hsk;

reg		[2:0]	current_state;
reg 	[2:0]	next_state;
reg		[1:0]	mode;
reg 	[3:0]	compute_cnt;


reg 	[31:0]		weight_addr_next;
wire 				weight_addr_send_start;
reg 	[3:0]		weight_addr_send_cnt;
reg				weight_addr_send_done;

wire 				weight_data_rcpt_done;
reg 	[4:0]		weight_data_rcpt_cnt;
reg	[31:0]		cur_weight_00;
reg	[31:0]		cur_weight_01;
reg	[31:0]		cur_weight_02;
reg	[31:0]		cur_weight_03;
reg	[31:0]		cur_weight_10;
reg	[31:0]		cur_weight_11;
reg	[31:0]		cur_weight_12;
reg	[31:0]		cur_weight_13;
reg	[31:0]		cur_weight_20;
reg	[31:0]		cur_weight_21;
reg	[31:0]		cur_weight_22;
reg	[31:0]		cur_weight_23;
reg	[31:0]		cur_weight_30;
reg	[31:0]		cur_weight_31;
reg	[31:0]		cur_weight_32;
reg	[31:0]		cur_weight_33;

reg		[3:0]		image_addr_send_cnt;
wire 				image_addr_send_start;
reg 				image_addr_send_done;
reg 	[31:0]		image_addr_next;
wire 				image_data_rcpt_done;
reg 	[4:0]		image_data_rcpt_cnt;
reg 	[31:0]		image_data_00;
reg 	[31:0]		image_data_01;
reg 	[31:0]		image_data_02;
reg 	[31:0]		image_data_03;
reg 	[31:0]		image_data_10;
reg 	[31:0]		image_data_11;
reg 	[31:0]		image_data_12;
reg 	[31:0]		image_data_13;
reg 	[31:0]		image_data_20;
reg 	[31:0]		image_data_21;
reg 	[31:0]		image_data_22;
reg 	[31:0]		image_data_23;
reg 	[31:0]		image_data_30;
reg 	[31:0]		image_data_31;
reg 	[31:0]		image_data_32;
reg 	[31:0]		image_data_33;

reg [31:0]			in_weight_0;
reg [31:0]			in_weight_1;
reg [31:0]			in_weight_2;
reg [31:0]			in_weight_3;
reg [31:0]			in_data_0;
reg [31:0]			in_data_1;
reg [31:0]			in_data_2;
reg [31:0]			in_data_3;


wire		[31:0]		result_00;
wire		[31:0]		result_01;
wire		[31:0]		result_02;
wire		[31:0]		result_03;
wire		[31:0]		result_10;
wire		[31:0]		result_11;
wire		[31:0]		result_12;
wire		[31:0]		result_13;
wire		[31:0]		result_20;
wire		[31:0]		result_21;
wire		[31:0]		result_22;
wire		[31:0]		result_23;
wire		[31:0]		result_30;
wire		[31:0]		result_31;
wire		[31:0]		result_32;
wire		[31:0]		result_33;

reg		[31:0]		gelu_00;
reg		[31:0]		gelu_01;
reg		[31:0]		gelu_02;
reg		[31:0]		gelu_03;
reg		[31:0]		gelu_10;
reg		[31:0]		gelu_11;
reg		[31:0]		gelu_12;
reg		[31:0]		gelu_13;
reg		[31:0]		gelu_20;
reg		[31:0]		gelu_21;
reg		[31:0]		gelu_22;
reg		[31:0]		gelu_23;
reg		[31:0]		gelu_30;
reg		[31:0]		gelu_31;
reg		[31:0]		gelu_32;
reg		[31:0]		gelu_33;



wire 				store_data_send_start;
wire 				store_data_send_done;
reg		[4:0]		store_data_send_cnt;
reg 	[4:0]		store_rsp_rcpt_cnt;
wire 			 	store_done;
reg 	[31:0]		store_data_addr_next;
reg 	[31:0]		store_data_send_next;
reg [3:0] store_data_send_next_cnt;


assign cnn_icb_cmd_hsk 		=	cnn_icb_cmd_valid & cnn_icb_cmd_ready;
assign cnn_icb_cmd_rd_hsk	=	cnn_icb_cmd_hsk & cnn_icb_cmd_read;
assign cnn_icb_cmd_wr_hsk	=	cnn_icb_cmd_hsk & (~cnn_icb_cmd_read);
assign send_update_control	=	(~cnn_icb_cmd_valid) || cnn_icb_cmd_ready;
assign cnn_icb_rsp_hsk 		=	cnn_icb_rsp_valid & cnn_icb_rsp_ready;

pe_array u_pe_array(
	.clk(clk),
	.rst_n(rst_n),
	.weight0_in(in_weight_0),
	.weight1_in(in_weight_1),
	.weight2_in(in_weight_2),
	.weight3_in(in_weight_3),
	.data0_in(in_data_0),
	.data1_in(in_data_1),
	.data2_in(in_data_2),
	.data3_in(in_data_3),
	.result_00(result_00),
	.result_01(result_01),
	.result_02(result_02),
	.result_03(result_03),
	.result_10(result_10),
	.result_11(result_11),
	.result_12(result_12),
	.result_13(result_13),
	.result_20(result_20),
	.result_21(result_21),
	.result_22(result_22),
	.result_23(result_23),
	.result_30(result_30),
	.result_31(result_31),
	.result_32(result_32),
	.result_33(result_33),
	.mode(mode)
);


//状态更新逻辑
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		current_state <= IDLE;
	end
	else begin
		current_state <= next_state;
	end
end

//
always@(*)begin
	case(current_state)
	IDLE:begin
		if(enable)begin
			next_state <= LOAD_WEIGHT;
		end
		else begin
			next_state <= IDLE;
		end
	end	
	LOAD_WEIGHT:begin
		if(weight_data_rcpt_done)begin
			next_state <= LOAD_IMAGE;
		end
		else begin
			next_state <= LOAD_WEIGHT;
		end
	end
	LOAD_IMAGE:begin
		if(image_data_rcpt_done)begin
			next_state <= COMPUTE;
		end
		else begin
			next_state <= LOAD_IMAGE;
		end
	end
	COMPUTE:begin
		if(compute_cnt == 4'b0100)begin
			next_state <= STORE;
		end
		else begin
			next_state <= COMPUTE;
		end
	end
	STORE:begin
		if(store_done)begin
			next_state <= DONE;
		end
		else begin
			next_state <= STORE;
		end
	end
	DONE:begin
		if(enable)begin
			next_state <= DONE;
		end
		else begin
			next_state <= IDLE;
		end
	end
	default:begin
		next_state	<= IDLE;
	end
	endcase
end	

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		mode <= DISABLE;
	end
	else if(((current_state == LOAD_IMAGE) && (image_data_rcpt_done)) || (current_state == COMPUTE) || ((current_state == STORE) && (compute_cnt < 4'b1010) && (compute_cnt > 4'b0100))) begin
		mode <= SINGLE;
	end
	else if((current_state == STORE) && (compute_cnt == 4'b1010)) begin
		mode <= DISABLE;
	end
	else if(store_done) begin
		mode <= CLEAR;
	end
	else begin
		mode <= DISABLE;
	end
end

///////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////*ICB control*///////////////////////////////////////////////////
assign cnn_icb_cmd_wmask	= 	4'b1111;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnn_icb_cmd_valid <= 1'b0;
	end
	else if(weight_addr_send_start || image_addr_send_start || store_data_send_start)begin
		cnn_icb_cmd_valid <= 1'b1;
	end
	else begin
		cnn_icb_cmd_valid <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnn_icb_cmd_read <= 1'b0;		
	end
	else if(weight_addr_send_start || image_addr_send_start)begin
		cnn_icb_cmd_read <= 1'b1;
	end
	else begin
		cnn_icb_cmd_read <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnn_icb_cmd_addr <= 32'h0;
	end
	else if(weight_addr_send_start && send_update_control)begin
		cnn_icb_cmd_addr <= weight_addr_next;
	end
	else if(image_addr_send_start && send_update_control)begin
		cnn_icb_cmd_addr <= image_addr_next;
	end
	else if(store_data_send_start && send_update_control)begin
		cnn_icb_cmd_addr <= store_data_addr_next;
	end
	else if((weight_addr_send_start || image_addr_send_start || store_data_send_start) && ~cnn_icb_cmd_ready)begin
		cnn_icb_cmd_addr <= cnn_icb_cmd_addr;
	end
	else begin
		cnn_icb_cmd_addr <= 32'h0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cnn_icb_cmd_wdata <= 32'b0;
	end
	else if(store_data_send_start && send_update_control)begin
		cnn_icb_cmd_wdata <= store_data_send_next;
	end
	else if(store_data_send_start && ~cnn_icb_cmd_ready)begin
		cnn_icb_cmd_wdata <= cnn_icb_cmd_wdata;
	end
	else begin
		cnn_icb_cmd_wdata <= 32'b0;
	end
end

assign cnn_icb_rsp_ready = 1'b1;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		done <= 1'b0;
	end
	else if(current_state == DONE)begin
		done <=	1'b1;
	end
	else begin
		done <=	1'b0;
	end
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////LOAD_WEIGHT state//////////////////////////////////////////////////////////

assign weight_addr_send_start = (current_state == LOAD_WEIGHT) && (~weight_addr_send_done);

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		weight_addr_send_done <= 0;
	end
    else if(weight_addr_send_cnt == 4'b1111) begin
        weight_addr_send_done <= 1;
    end
    else
        weight_addr_send_done <= weight_addr_send_done;
end

assign weight_data_rcpt_done = (weight_data_rcpt_cnt == 5'b10000) ;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		weight_addr_next <= weight_addr;
	end
	else if(current_state == IDLE)begin
		weight_addr_next <= weight_addr;
	end
	else if(weight_addr_send_start && send_update_control)begin
		weight_addr_next <= weight_addr_next + 32'd4;
	end
	else begin
		weight_addr_next <= weight_addr_next;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		weight_addr_send_cnt <= 4'b0000;
	end
    else if(weight_addr_send_cnt == 4'b1111) begin
        weight_addr_send_cnt <= weight_addr_send_cnt;
    end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_cmd_rd_hsk)begin
		weight_addr_send_cnt <= weight_addr_send_cnt + 4'b0001;
	end
	else if((current_state == LOAD_WEIGHT) && (~cnn_icb_cmd_rd_hsk))begin
		weight_addr_send_cnt <= weight_addr_send_cnt;
	end
	else begin
		weight_addr_send_cnt <= weight_addr_send_cnt;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		weight_data_rcpt_cnt <= 5'b00000;
	end
    else if(weight_data_rcpt_cnt == 5'b10000) begin
        weight_data_rcpt_cnt <= weight_data_rcpt_cnt;
    end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk)begin
		weight_data_rcpt_cnt <= weight_data_rcpt_cnt + 5'b00001;
	end
	else if((current_state == LOAD_WEIGHT) && (~cnn_icb_rsp_hsk))begin
		weight_data_rcpt_cnt <= weight_data_rcpt_cnt;
	end
	else begin
		weight_data_rcpt_cnt <= 5'b00000;
	end
end


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////LOAD_IMAGE state////////////////////////////////////////////////////
assign image_addr_send_start = (current_state == LOAD_IMAGE) && (~image_addr_send_done);

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_addr_send_done <= 0;
	end
    else if(image_addr_send_cnt == 4'b1111) begin
        image_addr_send_done <= 1;
    end
    else
        image_addr_send_done <= image_addr_send_done;
end

assign image_data_rcpt_done = (image_data_rcpt_cnt == 5'b10000) ;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_addr_send_cnt <= 4'b0000;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_cmd_rd_hsk)begin
		image_addr_send_cnt <= image_addr_send_cnt + 4'b0001;
	end
	else if((current_state == LOAD_IMAGE) && (~cnn_icb_cmd_rd_hsk))begin
		image_addr_send_cnt <= image_addr_send_cnt;
	end
	else begin
		image_addr_send_cnt <= image_addr_send_cnt;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_addr_next <= image_addr;
	end
	else if(current_state == IDLE || current_state == LOAD_WEIGHT)begin
		image_addr_next <= image_addr;
	end
	else if(image_addr_send_start && send_update_control)begin
		image_addr_next <= image_addr_next + 32'd4;
	end
	else begin
		image_addr_next <= image_addr_next;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_rcpt_cnt <= 5'b0000;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk)begin
		image_data_rcpt_cnt <= image_data_rcpt_cnt + 5'b00001;
	end	
	else if((current_state == LOAD_IMAGE) && (~cnn_icb_rsp_hsk))begin
		image_data_rcpt_cnt <= image_data_rcpt_cnt;
	end
	else begin
		image_data_rcpt_cnt <= 5'b00000;
	end
end


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////COMPUTE state//////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		compute_cnt <= 0;
	end
	else if(compute_cnt == 4'b1010) begin
		compute_cnt <= 0;
	end
    else if((current_state == STORE) && (compute_cnt == 4'b0000)) begin
		compute_cnt <= 0;
	end
	else if((current_state == COMPUTE) || (current_state == STORE)) begin
		compute_cnt <= compute_cnt + 1;
	end
	else begin
		compute_cnt <= compute_cnt;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_weight_0 <= 0;
	end
	else if((compute_cnt == 4'b0000) && (mode == SINGLE)) begin
		in_weight_0 <= cur_weight_00;
	end
	else if((compute_cnt == 4'b0001) && (mode == SINGLE))begin
		in_weight_0 <= cur_weight_01;
	end
	else if((compute_cnt == 4'b0010) && (mode == SINGLE))begin
		in_weight_0 <= cur_weight_02;
	end
	else if((compute_cnt == 4'b0011) && (mode == SINGLE))begin
		in_weight_0 <= cur_weight_03;
	end
	else begin
		in_weight_0 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_weight_1 <= 0;
	end
	else if((compute_cnt == 4'b0001) && (mode == SINGLE)) begin
		in_weight_1 <= cur_weight_10;
	end
	else if((compute_cnt == 4'b0010) && (mode == SINGLE))begin
		in_weight_1 <= cur_weight_11;
	end
	else if((compute_cnt == 4'b0011) && (mode == SINGLE))begin
		in_weight_1 <= cur_weight_12;
	end
	else if((compute_cnt == 4'b0100) && (mode == SINGLE))begin
		in_weight_1 <= cur_weight_13;
	end
	else begin
		in_weight_1 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_weight_2 <= 0;
	end
	else if((compute_cnt == 4'b0010) && (mode == SINGLE)) begin
		in_weight_2 <= cur_weight_20;
	end
	else if((compute_cnt == 4'b0011) && (mode == SINGLE))begin
		in_weight_2 <= cur_weight_21;
	end
	else if((compute_cnt == 4'b0100) && (mode == SINGLE))begin
		in_weight_2 <= cur_weight_22;
	end
	else if((compute_cnt == 4'b0101) && (mode == SINGLE))begin
		in_weight_2 <= cur_weight_23;
	end
	else begin
		in_weight_2 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_weight_3 <= 0;
	end
	else if((compute_cnt == 4'b0011) && (mode == SINGLE)) begin
		in_weight_3 <= cur_weight_30;
	end
	else if((compute_cnt == 4'b0100) && (mode == SINGLE))begin
		in_weight_3 <= cur_weight_31;
	end
	else if((compute_cnt == 4'b0101) && (mode == SINGLE))begin
		in_weight_3 <= cur_weight_32;
	end
	else if((compute_cnt == 4'b0110) && (mode == SINGLE))begin
		in_weight_3 <= cur_weight_33;
	end
	else begin
		in_weight_3 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_data_0 <= 0;
	end
	else if((compute_cnt == 4'b0000) && (mode == SINGLE)) begin
		in_data_0 <= image_data_00;
	end
	else if((compute_cnt == 4'b0001) && (mode == SINGLE))begin
		in_data_0 <= image_data_01;
	end
	else if((compute_cnt == 4'b0010) && (mode == SINGLE))begin
		in_data_0 <= image_data_02;
	end
	else if((compute_cnt == 4'b0011) && (mode == SINGLE))begin
		in_data_0 <= image_data_03;
	end
	else begin
		in_data_0 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_data_1 <= 0;
	end
	else if((compute_cnt == 4'b0001) && (mode == SINGLE)) begin
		in_data_1 <= image_data_10;
	end
	else if((compute_cnt == 4'b0010) && (mode == SINGLE))begin
		in_data_1 <= image_data_11;
	end
	else if((compute_cnt == 4'b0011) && (mode == SINGLE))begin
		in_data_1 <= image_data_12;
	end
	else if((compute_cnt == 4'b0100) && (mode == SINGLE))begin
		in_data_1 <= image_data_13;
	end
	else begin
		in_data_1 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_data_2 <= 0;
	end
	else if((compute_cnt == 4'b0010) && (mode == SINGLE)) begin
		in_data_2 <= image_data_20;
	end
	else if((compute_cnt == 4'b0011) && (mode == SINGLE))begin
		in_data_2 <= image_data_21;
	end
	else if((compute_cnt == 4'b0100) && (mode == SINGLE))begin
		in_data_2 <= image_data_22;
	end
	else if((compute_cnt == 4'b0101) && (mode == SINGLE))begin
		in_data_2 <= image_data_23;
	end
	else begin
		in_data_2 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_data_3 <= 0;
	end
	else if((compute_cnt == 4'b0011) && (mode == SINGLE)) begin
		in_data_3 <= image_data_30;
	end
	else if((compute_cnt == 4'b0100) && (mode == SINGLE))begin
		in_data_3 <= image_data_31;
	end
	else if((compute_cnt == 4'b0101) && (mode == SINGLE))begin
		in_data_3 <= image_data_32;
	end
	else if((compute_cnt == 4'b0110) && (mode == SINGLE))begin
		in_data_3 <= image_data_33;
	end
	else begin
		in_data_3 <= 0;
	end
end


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////STORE state///////////////////////////////////////////////////////////////

assign store_data_send_start = (current_state == STORE) && (~store_data_send_done);

assign store_data_send_done  = ((store_data_send_cnt == 5'd15)  && (cnn_icb_cmd_ready)) || (store_data_send_cnt == 5'd16);

assign store_done = (store_rsp_rcpt_cnt == 5'd16);

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		store_data_send_cnt <= 5'b0;
	end
	else if((current_state == STORE) && cnn_icb_cmd_wr_hsk)begin
		store_data_send_cnt <= store_data_send_cnt + 5'h01;
	end
	else if((current_state == STORE) && (~cnn_icb_cmd_wr_hsk))begin
		store_data_send_cnt <= store_data_send_cnt;	
	end
	else begin
		store_data_send_cnt <= 5'b0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		store_rsp_rcpt_cnt <= 5'b0;
	end
	else if((current_state == STORE) && cnn_icb_rsp_hsk)begin
		store_rsp_rcpt_cnt <= store_rsp_rcpt_cnt + 5'h01;
	end
	else if((current_state == STORE) && (~cnn_icb_rsp_hsk))begin
		store_rsp_rcpt_cnt <= store_rsp_rcpt_cnt;
	end
	else begin
		store_rsp_rcpt_cnt <= 5'b0;
	end
end


always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		store_data_addr_next <= out_addr;
	end
	else if(store_data_send_start && send_update_control)begin
		store_data_addr_next <= store_data_addr_next + 32'd1;
	end
	else if(store_data_send_start && cnn_icb_cmd_valid && ~cnn_icb_cmd_ready)begin
		store_data_addr_next <= store_data_addr_next;
	end
	else begin
		store_data_addr_next <= out_addr;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		store_data_send_next_cnt <= 4'b0;
	end
	else if(store_data_send_start && send_update_control)begin
		store_data_send_next_cnt <= store_data_send_next_cnt + 4'b1;
	end
	else if(store_data_send_start && cnn_icb_cmd_valid && ~cnn_icb_cmd_ready)begin
		store_data_send_next_cnt <= store_data_send_next_cnt;
	end
	else begin
		store_data_send_next_cnt <= 4'b0;
	end
end

//******************************************//
//**************    GELU     ***************//
//******************************************//

//gelu_00
always@(*) begin
	case(result_00[15:13])
	3'b000:
		if(result_00[31:16] == 16'h01)
			gelu_00 = result_00 - DELTA10;
		else if(result_00[31:16] == 16'h02)
			gelu_00 = result_00 - DELTA20;
		else
			gelu_00 = result_00;
	3'b001:
		if(result_00[31:16] == 16'h00)
			gelu_00 = result_00 - DELTA01;
		else if(result_00[31:16] == 16'h01)
			gelu_00 = result_00 - DELTA11;
		else
			gelu_00 = result_00;
	3'b010:
		if(result_00[31:16] == 16'h00)
			gelu_00 = result_00 - DELTA02;
		else if(result_00[31:16] == 16'h01)
			gelu_00 = result_00 - DELTA12;
		else
			gelu_00 = result_00;
	3'b011:
		if(result_00[31:16] == 16'h00)
			gelu_00 = result_00 - DELTA03;
		else if(result_00[31:16] == 16'h01)
			gelu_00 = result_00 - DELTA13;
		else
			gelu_00 = result_00;
	3'b100:
		if(result_00[31:16] == 16'h00)
			gelu_00 = result_00 - DELTA04;
		else if(result_00[31:16] == 16'h01)
			gelu_00 = result_00 - DELTA14;
		else
			gelu_00 = result_00;
	3'b101:
		if(result_00[31:16] == 16'h00)
			gelu_00 = result_00 - DELTA05;
		else if(result_00[31:16] == 16'h01)
			gelu_00 = result_00 - DELTA15;
		else
			gelu_00 = result_00;
	3'b110:
		if(result_00[31:16] == 16'h00)
			gelu_00 = result_00 - DELTA06;
		else if(result_00[31:16] == 16'h01)
			gelu_00 = result_00 - DELTA16;
		else
			gelu_00 = result_00;
	3'b111:
		if(result_00[31:16] == 16'h00)
			gelu_00 = result_00 - DELTA07;
		else if(result_00[31:16] == 16'h01)
			gelu_00 = result_00 - DELTA17;
		else
			gelu_00 = result_00;
	default: gelu_00 = result_00;
	endcase
end

//gelu_01
always@(*) begin
	case(result_01[15:13])
	3'b000:
		if(result_01[31:16] == 16'h01)
			gelu_01 = result_01 - DELTA10;
		else if(result_01[31:16] == 16'h02)
			gelu_01 = result_01 - DELTA20;
		else
			gelu_01 = result_01;
	3'b001:
		if(result_01[31:16] == 16'h00)
			gelu_01 = result_01 - DELTA01;
		else if(result_01[31:16] == 16'h01)
			gelu_01 = result_01 - DELTA11;
		else
			gelu_01 = result_01;
	3'b010:
		if(result_01[31:16] == 16'h00)
			gelu_01 = result_01 - DELTA02;
		else if(result_01[31:16] == 16'h01)
			gelu_01 = result_01 - DELTA12;
		else
			gelu_01 = result_01;
	3'b011:
		if(result_01[31:16] == 16'h00)
			gelu_01 = result_01 - DELTA03;
		else if(result_01[31:16] == 16'h01)
			gelu_01 = result_01 - DELTA13;
		else
			gelu_01 = result_01;
	3'b100:
		if(result_01[31:16] == 16'h00)
			gelu_01 = result_01 - DELTA04;
		else if(result_01[31:16] == 16'h01)
			gelu_01 = result_01 - DELTA14;
		else
			gelu_01 = result_01;
	3'b101:
		if(result_01[31:16] == 16'h00)
			gelu_01 = result_01 - DELTA05;
		else if(result_01[31:16] == 16'h01)
			gelu_01 = result_01 - DELTA15;
		else
			gelu_01 = result_01;
	3'b110:
		if(result_01[31:16] == 16'h00)
			gelu_01 = result_01 - DELTA06;
		else if(result_01[31:16] == 16'h01)
			gelu_01 = result_01 - DELTA16;
		else
			gelu_01 = result_01;
	3'b111:
		if(result_01[31:16] == 16'h00)
			gelu_01 = result_01 - DELTA07;
		else if(result_01[31:16] == 16'h01)
			gelu_01 = result_01 - DELTA17;
		else
			gelu_01 = result_01;
	default: gelu_01 = result_01;
	endcase
end

//gelu_02
always@(*) begin
	case(result_02[15:13])
	3'b000:
		if(result_02[31:16] == 16'h01)
			gelu_02 = result_02 - DELTA10;
		else if(result_02[31:16] == 16'h02)
			gelu_02 = result_02 - DELTA20;
		else
			gelu_02 = result_02;
	3'b001:
		if(result_02[31:16] == 16'h00)
			gelu_02 = result_02 - DELTA01;
		else if(result_02[31:16] == 16'h01)
			gelu_02 = result_02 - DELTA11;
		else
			gelu_02 = result_02;
	3'b010:
		if(result_02[31:16] == 16'h00)
			gelu_02 = result_02 - DELTA02;
		else if(result_02[31:16] == 16'h01)
			gelu_02 = result_02 - DELTA12;
		else
			gelu_02 = result_02;
	3'b011:
		if(result_02[31:16] == 16'h00)
			gelu_02 = result_02 - DELTA03;
		else if(result_02[31:16] == 16'h01)
			gelu_02 = result_02 - DELTA13;
		else
			gelu_02 = result_02;
	3'b100:
		if(result_02[31:16] == 16'h00)
			gelu_02 = result_02 - DELTA04;
		else if(result_02[31:16] == 16'h01)
			gelu_02 = result_02 - DELTA14;
		else
			gelu_02 = result_02;
	3'b101:
		if(result_02[31:16] == 16'h00)
			gelu_02 = result_02 - DELTA05;
		else if(result_02[31:16] == 16'h01)
			gelu_02 = result_02 - DELTA15;
		else
			gelu_02 = result_02;
	3'b110:
		if(result_02[31:16] == 16'h00)
			gelu_02 = result_02 - DELTA06;
		else if(result_02[31:16] == 16'h01)
			gelu_02 = result_02 - DELTA16;
		else
			gelu_02 = result_02;
	3'b111:
		if(result_02[31:16] == 16'h00)
			gelu_02 = result_02 - DELTA07;
		else if(result_02[31:16] == 16'h01)
			gelu_02 = result_02 - DELTA17;
		else
			gelu_02 = result_02;
	default: gelu_02 = result_02;
	endcase
end

//gelu_03
always@(*) begin
	case(result_03[15:13])
	3'b000:
		if(result_03[31:16] == 16'h01)
			gelu_03 = result_03 - DELTA10;
		else if(result_03[31:16] == 16'h02)
			gelu_03 = result_03 - DELTA20;
		else
			gelu_03 = result_03;
	3'b001:
		if(result_03[31:16] == 16'h00)
			gelu_03 = result_03 - DELTA01;
		else if(result_03[31:16] == 16'h01)
			gelu_03 = result_03 - DELTA11;
		else
			gelu_03 = result_03;
	3'b010:
		if(result_03[31:16] == 16'h00)
			gelu_03 = result_03 - DELTA02;
		else if(result_03[31:16] == 16'h01)
			gelu_03 = result_03 - DELTA12;
		else
			gelu_03 = result_03;
	3'b011:
		if(result_03[31:16] == 16'h00)
			gelu_03 = result_03 - DELTA03;
		else if(result_03[31:16] == 16'h01)
			gelu_03 = result_03 - DELTA13;
		else
			gelu_03 = result_03;
	3'b100:
		if(result_03[31:16] == 16'h00)
			gelu_03 = result_03 - DELTA04;
		else if(result_03[31:16] == 16'h01)
			gelu_03 = result_03 - DELTA14;
		else
			gelu_03 = result_03;
	3'b101:
		if(result_03[31:16] == 16'h00)
			gelu_03 = result_03 - DELTA05;
		else if(result_03[31:16] == 16'h01)
			gelu_03 = result_03 - DELTA15;
		else
			gelu_03 = result_03;
	3'b110:
		if(result_03[31:16] == 16'h00)
			gelu_03 = result_03 - DELTA06;
		else if(result_03[31:16] == 16'h01)
			gelu_03 = result_03 - DELTA16;
		else
			gelu_03 = result_03;
	3'b111:
		if(result_03[31:16] == 16'h00)
			gelu_03 = result_03 - DELTA07;
		else if(result_03[31:16] == 16'h01)
			gelu_03 = result_03 - DELTA17;
		else
			gelu_03 = result_03;
	default: gelu_03 = result_03;
	endcase
end

//gelu_10
always@(*) begin
	case(result_10[15:13])
	3'b000:
		if(result_10[31:16] == 16'h01)
			gelu_10 = result_10 - DELTA10;
		else if(result_10[31:16] == 16'h02)
			gelu_10 = result_10 - DELTA20;
		else
			gelu_10 = result_10;
	3'b001:
		if(result_10[31:16] == 16'h00)
			gelu_10 = result_10 - DELTA01;
		else if(result_10[31:16] == 16'h01)
			gelu_10 = result_10 - DELTA11;
		else
			gelu_10 = result_10;
	3'b010:
		if(result_10[31:16] == 16'h00)
			gelu_10 = result_10 - DELTA02;
		else if(result_10[31:16] == 16'h01)
			gelu_10 = result_10 - DELTA12;
		else
			gelu_10 = result_10;
	3'b011:
		if(result_10[31:16] == 16'h00)
			gelu_10 = result_10 - DELTA03;
		else if(result_10[31:16] == 16'h01)
			gelu_10 = result_10 - DELTA13;
		else
			gelu_10 = result_10;
	3'b100:
		if(result_10[31:16] == 16'h00)
			gelu_10 = result_10 - DELTA04;
		else if(result_10[31:16] == 16'h01)
			gelu_10 = result_10 - DELTA14;
		else
			gelu_10 = result_10;
	3'b101:
		if(result_10[31:16] == 16'h00)
			gelu_10 = result_10 - DELTA05;
		else if(result_10[31:16] == 16'h01)
			gelu_10 = result_10 - DELTA15;
		else
			gelu_10 = result_10;
	3'b110:
		if(result_10[31:16] == 16'h00)
			gelu_10 = result_10 - DELTA06;
		else if(result_10[31:16] == 16'h01)
			gelu_10 = result_10 - DELTA16;
		else
			gelu_10 = result_10;
	3'b111:
		if(result_10[31:16] == 16'h00)
			gelu_10 = result_10 - DELTA07;
		else if(result_10[31:16] == 16'h01)
			gelu_10 = result_10 - DELTA17;
		else
			gelu_10 = result_10;
	default: gelu_10 = result_10;
	endcase
end

//gelu_11
always@(*) begin
	case(result_11[15:13])
	3'b000:
		if(result_11[31:16] == 16'h01)
			gelu_11 = result_11 - DELTA10;
		else if(result_11[31:16] == 16'h02)
			gelu_11 = result_11 - DELTA20;
		else
			gelu_11 = result_11;
	3'b001:
		if(result_11[31:16] == 16'h00)
			gelu_11 = result_11 - DELTA01;
		else if(result_11[31:16] == 16'h01)
			gelu_11 = result_11 - DELTA11;
		else
			gelu_11 = result_11;
	3'b010:
		if(result_11[31:16] == 16'h00)
			gelu_11 = result_11 - DELTA02;
		else if(result_11[31:16] == 16'h01)
			gelu_11 = result_11 - DELTA12;
		else
			gelu_11 = result_11;
	3'b011:
		if(result_11[31:16] == 16'h00)
			gelu_11 = result_11 - DELTA03;
		else if(result_11[31:16] == 16'h01)
			gelu_11 = result_11 - DELTA13;
		else
			gelu_11 = result_11;
	3'b100:
		if(result_11[31:16] == 16'h00)
			gelu_11 = result_11 - DELTA04;
		else if(result_11[31:16] == 16'h01)
			gelu_11 = result_11 - DELTA14;
		else
			gelu_11 = result_11;
	3'b101:
		if(result_11[31:16] == 16'h00)
			gelu_11 = result_11 - DELTA05;
		else if(result_11[31:16] == 16'h01)
			gelu_11 = result_11 - DELTA15;
		else
			gelu_11 = result_11;
	3'b110:
		if(result_11[31:16] == 16'h00)
			gelu_11 = result_11 - DELTA06;
		else if(result_11[31:16] == 16'h01)
			gelu_11 = result_11 - DELTA16;
		else
			gelu_11 = result_11;
	3'b111:
		if(result_11[31:16] == 16'h00)
			gelu_11 = result_11 - DELTA07;
		else if(result_11[31:16] == 16'h01)
			gelu_11 = result_11 - DELTA17;
		else
			gelu_11 = result_11;
	default: gelu_11 = result_11;
	endcase
end

//gelu_12
always@(*) begin
	case(result_12[15:13])
	3'b000:
		if(result_12[31:16] == 16'h01)
			gelu_12 = result_12 - DELTA10;
		else if(result_12[31:16] == 16'h02)
			gelu_12 = result_12 - DELTA20;
		else
			gelu_12 = result_12;
	3'b001:
		if(result_12[31:16] == 16'h00)
			gelu_12 = result_12 - DELTA01;
		else if(result_12[31:16] == 16'h01)
			gelu_12 = result_12 - DELTA11;
		else
			gelu_12 = result_12;
	3'b010:
		if(result_12[31:16] == 16'h00)
			gelu_12 = result_12 - DELTA02;
		else if(result_12[31:16] == 16'h01)
			gelu_12 = result_12 - DELTA12;
		else
			gelu_12 = result_12;
	3'b011:
		if(result_12[31:16] == 16'h00)
			gelu_12 = result_12 - DELTA03;
		else if(result_12[31:16] == 16'h01)
			gelu_12 = result_12 - DELTA13;
		else
			gelu_12 = result_12;
	3'b100:
		if(result_12[31:16] == 16'h00)
			gelu_12 = result_12 - DELTA04;
		else if(result_12[31:16] == 16'h01)
			gelu_12 = result_12 - DELTA14;
		else
			gelu_12 = result_12;
	3'b101:
		if(result_12[31:16] == 16'h00)
			gelu_12 = result_12 - DELTA05;
		else if(result_12[31:16] == 16'h01)
			gelu_12 = result_12 - DELTA15;
		else
			gelu_12 = result_12;
	3'b110:
		if(result_12[31:16] == 16'h00)
			gelu_12 = result_12 - DELTA06;
		else if(result_12[31:16] == 16'h01)
			gelu_12 = result_12 - DELTA16;
		else
			gelu_12 = result_12;
	3'b111:
		if(result_12[31:16] == 16'h00)
			gelu_12 = result_12 - DELTA07;
		else if(result_12[31:16] == 16'h01)
			gelu_12 = result_12 - DELTA17;
		else
			gelu_12 = result_12;
	default: gelu_12 = result_12;
	endcase
end

//gelu_13
always@(*) begin
	case(result_13[15:13])
	3'b000:
		if(result_13[31:16] == 16'h01)
			gelu_13 = result_13 - DELTA10;
		else if(result_13[31:16] == 16'h02)
			gelu_13 = result_13 - DELTA20;
		else
			gelu_13 = result_13;
	3'b001:
		if(result_13[31:16] == 16'h00)
			gelu_13 = result_13 - DELTA01;
		else if(result_13[31:16] == 16'h01)
			gelu_13 = result_13 - DELTA11;
		else
			gelu_13 = result_13;
	3'b010:
		if(result_13[31:16] == 16'h00)
			gelu_13 = result_13 - DELTA02;
		else if(result_13[31:16] == 16'h01)
			gelu_13 = result_13 - DELTA12;
		else
			gelu_13 = result_13;
	3'b011:
		if(result_13[31:16] == 16'h00)
			gelu_13 = result_13 - DELTA03;
		else if(result_13[31:16] == 16'h01)
			gelu_13 = result_13 - DELTA13;
		else
			gelu_13 = result_13;
	3'b100:
		if(result_13[31:16] == 16'h00)
			gelu_13 = result_13 - DELTA04;
		else if(result_13[31:16] == 16'h01)
			gelu_13 = result_13 - DELTA14;
		else
			gelu_13 = result_13;
	3'b101:
		if(result_13[31:16] == 16'h00)
			gelu_13 = result_13 - DELTA05;
		else if(result_13[31:16] == 16'h01)
			gelu_13 = result_13 - DELTA15;
		else
			gelu_13 = result_13;
	3'b110:
		if(result_13[31:16] == 16'h00)
			gelu_13 = result_13 - DELTA06;
		else if(result_13[31:16] == 16'h01)
			gelu_13 = result_13 - DELTA16;
		else
			gelu_13 = result_13;
	3'b111:
		if(result_13[31:16] == 16'h00)
			gelu_13 = result_13 - DELTA07;
		else if(result_13[31:16] == 16'h01)
			gelu_13 = result_13 - DELTA17;
		else
			gelu_13 = result_13;
	default: gelu_13 = result_13;
	endcase
end


//gelu_20
always@(*) begin
	case(result_20[15:13])
	3'b000:
		if(result_20[31:16] == 16'h01)
			gelu_20 = result_20 - DELTA10;
		else if(result_20[31:16] == 16'h02)
			gelu_20 = result_20 - DELTA20;
		else
			gelu_20 = result_20;
	3'b001:
		if(result_20[31:16] == 16'h00)
			gelu_20 = result_20 - DELTA01;
		else if(result_20[31:16] == 16'h01)
			gelu_20 = result_20 - DELTA11;
		else
			gelu_20 = result_20;
	3'b010:
		if(result_20[31:16] == 16'h00)
			gelu_20 = result_20 - DELTA02;
		else if(result_20[31:16] == 16'h01)
			gelu_20 = result_20 - DELTA12;
		else
			gelu_20 = result_20;
	3'b011:
		if(result_20[31:16] == 16'h00)
			gelu_20 = result_20 - DELTA03;
		else if(result_20[31:16] == 16'h01)
			gelu_20 = result_20 - DELTA13;
		else
			gelu_20 = result_20;
	3'b100:
		if(result_20[31:16] == 16'h00)
			gelu_20 = result_20 - DELTA04;
		else if(result_20[31:16] == 16'h01)
			gelu_20 = result_20 - DELTA14;
		else
			gelu_20 = result_20;
	3'b101:
		if(result_20[31:16] == 16'h00)
			gelu_20 = result_20 - DELTA05;
		else if(result_20[31:16] == 16'h01)
			gelu_20 = result_20 - DELTA15;
		else
			gelu_20 = result_20;
	3'b110:
		if(result_20[31:16] == 16'h00)
			gelu_20 = result_20 - DELTA06;
		else if(result_20[31:16] == 16'h01)
			gelu_20 = result_20 - DELTA16;
		else
			gelu_20 = result_20;
	3'b111:
		if(result_20[31:16] == 16'h00)
			gelu_20 = result_20 - DELTA07;
		else if(result_20[31:16] == 16'h01)
			gelu_20 = result_20 - DELTA17;
		else
			gelu_20 = result_20;
	default: gelu_20 = result_20;
	endcase
end

//gelu_21
always@(*) begin
	case(result_21[15:13])
	3'b000:
		if(result_21[31:16] == 16'h01)
			gelu_21 = result_21 - DELTA10;
		else if(result_21[31:16] == 16'h02)
			gelu_21 = result_21 - DELTA20;
		else
			gelu_21 = result_21;
	3'b001:
		if(result_21[31:16] == 16'h00)
			gelu_21 = result_21 - DELTA01;
		else if(result_21[31:16] == 16'h01)
			gelu_21 = result_21 - DELTA11;
		else
			gelu_21 = result_21;
	3'b010:
		if(result_21[31:16] == 16'h00)
			gelu_21 = result_21 - DELTA02;
		else if(result_21[31:16] == 16'h01)
			gelu_21 = result_21 - DELTA12;
		else
			gelu_21 = result_21;
	3'b011:
		if(result_21[31:16] == 16'h00)
			gelu_21 = result_21 - DELTA03;
		else if(result_21[31:16] == 16'h01)
			gelu_21 = result_21 - DELTA13;
		else
			gelu_21 = result_21;
	3'b100:
		if(result_21[31:16] == 16'h00)
			gelu_21 = result_21 - DELTA04;
		else if(result_21[31:16] == 16'h01)
			gelu_21 = result_21 - DELTA14;
		else
			gelu_21 = result_21;
	3'b101:
		if(result_21[31:16] == 16'h00)
			gelu_21 = result_21 - DELTA05;
		else if(result_21[31:16] == 16'h01)
			gelu_21 = result_21 - DELTA15;
		else
			gelu_21 = result_21;
	3'b110:
		if(result_21[31:16] == 16'h00)
			gelu_21 = result_21 - DELTA06;
		else if(result_21[31:16] == 16'h01)
			gelu_21 = result_21 - DELTA16;
		else
			gelu_21 = result_21;
	3'b111:
		if(result_21[31:16] == 16'h00)
			gelu_21 = result_21 - DELTA07;
		else if(result_21[31:16] == 16'h01)
			gelu_21 = result_21 - DELTA17;
		else
			gelu_21 = result_21;
	default: gelu_21 = result_21;
	endcase
end

//gelu_22
always@(*) begin
	case(result_22[15:13])
	3'b000:
		if(result_22[31:16] == 16'h01)
			gelu_22 = result_22 - DELTA10;
		else if(result_22[31:16] == 16'h02)
			gelu_22 = result_22 - DELTA20;
		else
			gelu_22 = result_22;
	3'b001:
		if(result_22[31:16] == 16'h00)
			gelu_22 = result_22 - DELTA01;
		else if(result_22[31:16] == 16'h01)
			gelu_22 = result_22 - DELTA11;
		else
			gelu_22 = result_22;
	3'b010:
		if(result_22[31:16] == 16'h00)
			gelu_22 = result_22 - DELTA02;
		else if(result_22[31:16] == 16'h01)
			gelu_22 = result_22 - DELTA12;
		else
			gelu_22 = result_22;
	3'b011:
		if(result_22[31:16] == 16'h00)
			gelu_22 = result_22 - DELTA03;
		else if(result_22[31:16] == 16'h01)
			gelu_22 = result_22 - DELTA13;
		else
			gelu_22 = result_22;
	3'b100:
		if(result_22[31:16] == 16'h00)
			gelu_22 = result_22 - DELTA04;
		else if(result_22[31:16] == 16'h01)
			gelu_22 = result_22 - DELTA14;
		else
			gelu_22 = result_22;
	3'b101:
		if(result_22[31:16] == 16'h00)
			gelu_22 = result_22 - DELTA05;
		else if(result_22[31:16] == 16'h01)
			gelu_22 = result_22 - DELTA15;
		else
			gelu_22 = result_22;
	3'b110:
		if(result_22[31:16] == 16'h00)
			gelu_22 = result_22 - DELTA06;
		else if(result_22[31:16] == 16'h01)
			gelu_22 = result_22 - DELTA16;
		else
			gelu_22 = result_22;
	3'b111:
		if(result_22[31:16] == 16'h00)
			gelu_22 = result_22 - DELTA07;
		else if(result_22[31:16] == 16'h01)
			gelu_22 = result_22 - DELTA17;
		else
			gelu_22 = result_22;
	default: gelu_22 = result_22;
	endcase
end

//gelu_23
always@(*) begin
	case(result_23[15:13])
	3'b000:
		if(result_23[31:16] == 16'h01)
			gelu_23 = result_23 - DELTA10;
		else if(result_23[31:16] == 16'h02)
			gelu_23 = result_23 - DELTA20;
		else
			gelu_23 = result_23;
	3'b001:
		if(result_23[31:16] == 16'h00)
			gelu_23 = result_23 - DELTA01;
		else if(result_23[31:16] == 16'h01)
			gelu_23 = result_23 - DELTA11;
		else
			gelu_23 = result_23;
	3'b010:
		if(result_23[31:16] == 16'h00)
			gelu_23 = result_23 - DELTA02;
		else if(result_23[31:16] == 16'h01)
			gelu_23 = result_23 - DELTA12;
		else
			gelu_23 = result_23;
	3'b011:
		if(result_23[31:16] == 16'h00)
			gelu_23 = result_23 - DELTA03;
		else if(result_23[31:16] == 16'h01)
			gelu_23 = result_23 - DELTA13;
		else
			gelu_23 = result_23;
	3'b100:
		if(result_23[31:16] == 16'h00)
			gelu_23 = result_23 - DELTA04;
		else if(result_23[31:16] == 16'h01)
			gelu_23 = result_23 - DELTA14;
		else
			gelu_23 = result_23;
	3'b101:
		if(result_23[31:16] == 16'h00)
			gelu_23 = result_23 - DELTA05;
		else if(result_23[31:16] == 16'h01)
			gelu_23 = result_23 - DELTA15;
		else
			gelu_23 = result_23;
	3'b110:
		if(result_23[31:16] == 16'h00)
			gelu_23 = result_23 - DELTA06;
		else if(result_23[31:16] == 16'h01)
			gelu_23 = result_23 - DELTA16;
		else
			gelu_23 = result_23;
	3'b111:
		if(result_23[31:16] == 16'h00)
			gelu_23 = result_23 - DELTA07;
		else if(result_23[31:16] == 16'h01)
			gelu_23 = result_23 - DELTA17;
		else
			gelu_23 = result_23;
	default: gelu_23 = result_23;
	endcase
end

//gelu_30
always@(*) begin
	case(result_30[15:13])
	3'b000:
		if(result_30[31:16] == 16'h01)
			gelu_30 = result_30 - DELTA10;
		else if(result_30[31:16] == 16'h02)
			gelu_30 = result_30 - DELTA20;
		else
			gelu_30 = result_30;
	3'b001:
		if(result_30[31:16] == 16'h00)
			gelu_30 = result_30 - DELTA01;
		else if(result_30[31:16] == 16'h01)
			gelu_30 = result_30 - DELTA11;
		else
			gelu_30 = result_30;
	3'b010:
		if(result_30[31:16] == 16'h00)
			gelu_30 = result_30 - DELTA02;
		else if(result_30[31:16] == 16'h01)
			gelu_30 = result_30 - DELTA12;
		else
			gelu_30 = result_30;
	3'b011:
		if(result_30[31:16] == 16'h00)
			gelu_30 = result_30 - DELTA03;
		else if(result_30[31:16] == 16'h01)
			gelu_30 = result_30 - DELTA13;
		else
			gelu_30 = result_30;
	3'b100:
		if(result_30[31:16] == 16'h00)
			gelu_30 = result_30 - DELTA04;
		else if(result_30[31:16] == 16'h01)
			gelu_30 = result_30 - DELTA14;
		else
			gelu_30 = result_30;
	3'b101:
		if(result_30[31:16] == 16'h00)
			gelu_30 = result_30 - DELTA05;
		else if(result_30[31:16] == 16'h01)
			gelu_30 = result_30 - DELTA15;
		else
			gelu_30 = result_30;
	3'b110:
		if(result_30[31:16] == 16'h00)
			gelu_30 = result_30 - DELTA06;
		else if(result_30[31:16] == 16'h01)
			gelu_30 = result_30 - DELTA16;
		else
			gelu_30 = result_30;
	3'b111:
		if(result_30[31:16] == 16'h00)
			gelu_30 = result_30 - DELTA07;
		else if(result_30[31:16] == 16'h01)
			gelu_30 = result_30 - DELTA17;
		else
			gelu_30 = result_30;
	default: gelu_30 = result_30;
	endcase
end

//gelu_31
always@(*) begin
	case(result_31[15:13])
	3'b000:
		if(result_31[31:16] == 16'h01)
			gelu_31 = result_31 - DELTA10;
		else if(result_31[31:16] == 16'h02)
			gelu_31 = result_31 - DELTA20;
		else
			gelu_31 = result_31;
	3'b001:
		if(result_31[31:16] == 16'h00)
			gelu_31 = result_31 - DELTA01;
		else if(result_31[31:16] == 16'h01)
			gelu_31 = result_31 - DELTA11;
		else
			gelu_31 = result_31;
	3'b010:
		if(result_31[31:16] == 16'h00)
			gelu_31 = result_31 - DELTA02;
		else if(result_31[31:16] == 16'h01)
			gelu_31 = result_31 - DELTA12;
		else
			gelu_31 = result_31;
	3'b011:
		if(result_31[31:16] == 16'h00)
			gelu_31 = result_31 - DELTA03;
		else if(result_31[31:16] == 16'h01)
			gelu_31 = result_31 - DELTA13;
		else
			gelu_31 = result_31;
	3'b100:
		if(result_31[31:16] == 16'h00)
			gelu_31 = result_31 - DELTA04;
		else if(result_31[31:16] == 16'h01)
			gelu_31 = result_31 - DELTA14;
		else
			gelu_31 = result_31;
	3'b101:
		if(result_31[31:16] == 16'h00)
			gelu_31 = result_31 - DELTA05;
		else if(result_31[31:16] == 16'h01)
			gelu_31 = result_31 - DELTA15;
		else
			gelu_31 = result_31;
	3'b110:
		if(result_31[31:16] == 16'h00)
			gelu_31 = result_31 - DELTA06;
		else if(result_31[31:16] == 16'h01)
			gelu_31 = result_31 - DELTA16;
		else
			gelu_31 = result_31;
	3'b111:
		if(result_31[31:16] == 16'h00)
			gelu_31 = result_31 - DELTA07;
		else if(result_31[31:16] == 16'h01)
			gelu_31 = result_31 - DELTA17;
		else
			gelu_31 = result_31;
	default: gelu_31 = result_31;
	endcase
end

//gelu_32
always@(*) begin
	case(result_32[15:13])
	3'b000:
		if(result_32[31:16] == 16'h01)
			gelu_32 = result_32 - DELTA10;
		else if(result_32[31:16] == 16'h02)
			gelu_32 = result_32 - DELTA20;
		else
			gelu_32 = result_32;
	3'b001:
		if(result_32[31:16] == 16'h00)
			gelu_32 = result_32 - DELTA01;
		else if(result_32[31:16] == 16'h01)
			gelu_32 = result_32 - DELTA11;
		else
			gelu_32 = result_32;
	3'b010:
		if(result_32[31:16] == 16'h00)
			gelu_32 = result_32 - DELTA02;
		else if(result_32[31:16] == 16'h01)
			gelu_32 = result_32 - DELTA12;
		else
			gelu_32 = result_32;
	3'b011:
		if(result_32[31:16] == 16'h00)
			gelu_32 = result_32 - DELTA03;
		else if(result_32[31:16] == 16'h01)
			gelu_32 = result_32 - DELTA13;
		else
			gelu_32 = result_32;
	3'b100:
		if(result_32[31:16] == 16'h00)
			gelu_32 = result_32 - DELTA04;
		else if(result_32[31:16] == 16'h01)
			gelu_32 = result_32 - DELTA14;
		else
			gelu_32 = result_32;
	3'b101:
		if(result_32[31:16] == 16'h00)
			gelu_32 = result_32 - DELTA05;
		else if(result_32[31:16] == 16'h01)
			gelu_32 = result_32 - DELTA15;
		else
			gelu_32 = result_32;
	3'b110:
		if(result_32[31:16] == 16'h00)
			gelu_32 = result_32 - DELTA06;
		else if(result_32[31:16] == 16'h01)
			gelu_32 = result_32 - DELTA16;
		else
			gelu_32 = result_32;
	3'b111:
		if(result_32[31:16] == 16'h00)
			gelu_32 = result_32 - DELTA07;
		else if(result_32[31:16] == 16'h01)
			gelu_32 = result_32 - DELTA17;
		else
			gelu_32 = result_32;
	default: gelu_32 = result_32;
	endcase
end

//gelu_33
always@(*) begin
	case(result_33[15:13])
	3'b000:
		if(result_33[31:16] == 16'h01)
			gelu_33 = result_33 - DELTA10;
		else if(result_33[31:16] == 16'h02)
			gelu_33 = result_33 - DELTA20;
		else
			gelu_33 = result_33;
	3'b001:
		if(result_33[31:16] == 16'h00)
			gelu_33 = result_33 - DELTA01;
		else if(result_33[31:16] == 16'h01)
			gelu_33 = result_33 - DELTA11;
		else
			gelu_33 = result_33;
	3'b010:
		if(result_33[31:16] == 16'h00)
			gelu_33 = result_33 - DELTA02;
		else if(result_33[31:16] == 16'h01)
			gelu_33 = result_33 - DELTA12;
		else
			gelu_33 = result_33;
	3'b011:
		if(result_33[31:16] == 16'h00)
			gelu_33 = result_33 - DELTA03;
		else if(result_33[31:16] == 16'h01)
			gelu_33 = result_33 - DELTA13;
		else
			gelu_33 = result_33;
	3'b100:
		if(result_33[31:16] == 16'h00)
			gelu_33 = result_33 - DELTA04;
		else if(result_33[31:16] == 16'h01)
			gelu_33 = result_33 - DELTA14;
		else
			gelu_33 = result_33;
	3'b101:
		if(result_33[31:16] == 16'h00)
			gelu_33 = result_33 - DELTA05;
		else if(result_33[31:16] == 16'h01)
			gelu_33 = result_33 - DELTA15;
		else
			gelu_33 = result_33;
	3'b110:
		if(result_33[31:16] == 16'h00)
			gelu_33 = result_33 - DELTA06;
		else if(result_33[31:16] == 16'h01)
			gelu_33 = result_33 - DELTA16;
		else
			gelu_33 = result_33;
	3'b111:
		if(result_33[31:16] == 16'h00)
			gelu_33 = result_33 - DELTA07;
		else if(result_33[31:16] == 16'h01)
			gelu_33 = result_33 - DELTA17;
		else
			gelu_33 = result_33;
	default: gelu_33 = result_33;
	endcase
end


//******************************************//
//**************    GELU     ***************//
//******************************************//


always @(*)begin
	if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b0000))begin
		store_data_send_next = gelu_00;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b0001))begin
		store_data_send_next = gelu_01;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b0010))begin
		store_data_send_next = gelu_02;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b0011))begin
		store_data_send_next = gelu_03;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b0100))begin
		store_data_send_next = gelu_10;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b0101))begin
		store_data_send_next = gelu_11;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b0110))begin
		store_data_send_next = gelu_12;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b0111))begin
		store_data_send_next = gelu_13;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b1000))begin
		store_data_send_next = gelu_20;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b1001))begin
		store_data_send_next = gelu_21;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b1010))begin
		store_data_send_next = gelu_22;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b1011))begin
		store_data_send_next = gelu_23;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b1100))begin
		store_data_send_next = gelu_30;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b1101))begin
		store_data_send_next = gelu_31;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b1110))begin
		store_data_send_next = gelu_32;	
	end
	else if(store_data_send_start && send_update_control && (store_data_send_next_cnt == 4'b1111))begin
		store_data_send_next = gelu_33;	
	end
	else begin
		store_data_send_next = 32'b0;
	end
end



//******************************************//
//**************weight buffer***************//
//******************************************//

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_00 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b00000))begin
		cur_weight_00 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_00 <= cur_weight_00;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_01 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b00001))begin
		cur_weight_01 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_01 <= cur_weight_01;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_02 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b00010))begin
		cur_weight_02 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_02 <= cur_weight_02;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_03 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b00011))begin
		cur_weight_03 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_03 <= cur_weight_03;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_10 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b00100))begin
		cur_weight_10 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_10 <= cur_weight_10;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_11 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b00101))begin
		cur_weight_11 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_11 <= cur_weight_11;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_12 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b00110))begin
		cur_weight_12 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_12 <= cur_weight_12;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_13 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b00111))begin
		cur_weight_13 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_13 <= cur_weight_13;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_20 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b01000))begin
		cur_weight_20 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_20 <= cur_weight_20;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_21 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b01001))begin
		cur_weight_21 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_21 <= cur_weight_21;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_22 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b01010))begin
		cur_weight_22 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_22 <= cur_weight_22;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_23 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b01011))begin
		cur_weight_23 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_23 <= cur_weight_23;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_30 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b01100))begin
		cur_weight_30 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_30 <= cur_weight_30;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_31 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b01101))begin
		cur_weight_31 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_31 <= cur_weight_31;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_32 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b01110))begin
		cur_weight_32 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_32 <= cur_weight_32;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		cur_weight_33 <= 32'h00;
	end
	else if((current_state == LOAD_WEIGHT) && cnn_icb_rsp_hsk && (weight_data_rcpt_cnt == 5'b01111))begin
		cur_weight_33 <= cnn_icb_rsp_rdata;
	end
	else begin
		cur_weight_33 <= cur_weight_33;
	end
end

//******************************************//
//**************weight buffer***************//
//******************************************//



//******************************************//
//**************data buffer***************//
//******************************************//

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_00 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b00000))begin
		image_data_00 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_00 <= image_data_00;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_01 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b00001))begin
		image_data_01 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_01 <= image_data_01;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_02 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b00010))begin
		image_data_02 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_02 <= image_data_02;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_03 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b00011))begin
		image_data_03 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_03 <= image_data_03;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_10 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b00100))begin
		image_data_10 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_10 <= image_data_10;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_11 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b00101))begin
		image_data_11 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_11 <= image_data_11;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_12 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b00110))begin
		image_data_12 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_12 <= image_data_12;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_13 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b00111))begin
		image_data_13 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_13 <= image_data_13;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_20 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b01000))begin
		image_data_20 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_20 <= image_data_20;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_21 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b01001))begin
		image_data_21 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_21 <= image_data_21;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_22 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b01010))begin
		image_data_22 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_22 <= image_data_22;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_23 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b01011))begin
		image_data_23 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_23 <= image_data_23;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_30 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b01100))begin
		image_data_30 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_30 <= image_data_30;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_31 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b01101))begin
		image_data_31 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_31 <= image_data_31;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_32 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b01110))begin
		image_data_32 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_32 <= image_data_32;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_data_33 <= 32'h00;
	end
	else if((current_state == LOAD_IMAGE) && cnn_icb_rsp_hsk && (image_data_rcpt_cnt == 5'b01111))begin
		image_data_33 <= cnn_icb_rsp_rdata;
	end
	else begin
		image_data_33 <= image_data_33;
	end
end

//******************************************//
//**************data buffer***************//
//******************************************//


endmodule
