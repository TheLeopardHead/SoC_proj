module pe #(
	parameter       DISABLE = 2'b00,
    parameter       SINGLE = 2'b01,
	parameter       CLEAR = 2'b10)
(
	input 							clk,
	input 							rst_n,
		
	input 				[31:0]		data_in,
	input 				[31:0]		weight_in,
	output 		reg		[31:0]		result,
	output 		reg		[31:0]		data_out,
	output		reg		[31:0]		weight_out,
	input				[1:0]		mode
);

wire [31:0] weight0, weight1;
wire [31:0] data0, data1;

assign weight0 = weight_in[15:0];
assign weight1 = weight_in[31:16];
assign data0 = data_in[15:0];
assign data1 = data_in[31:16];

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		result <= 0;
	end
	else if(mode == CLEAR) begin
		result <= 0;
	end
	else if(mode == SINGLE) begin
		result <= result + (weight0 * data0) + (weight1 * data1) ;
	end
	else if(mode == DISABLE) begin
		result <= result;
	end
	else begin
		result <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_out <= 0;
	end
	else if(mode == CLEAR) begin
		data_out <= 0;
	end
	else if(mode == SINGLE) begin
		data_out <= data_in;
	end
	else if(mode == DISABLE) begin
		data_out <= 0;
	end
	else begin
		data_out <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		weight_out <= 0;
	end
	else if(mode == CLEAR) begin
		weight_out <= 0;
	end
	else if(mode == SINGLE) begin
		weight_out <= weight_in;
	end
	else if(mode == DISABLE) begin
		weight_out <= 0;
	end
	else begin
		weight_out <= 0;
	end
end

endmodule
