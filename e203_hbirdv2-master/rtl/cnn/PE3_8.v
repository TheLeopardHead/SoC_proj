module pe3_8(
	input 							clk,
	input 							rst_n,
		
	input 			signed	[7:0]		image_in,
	input 			signed	[7:0]		weight,
	output 		reg	signed	[7:0]		product,
	output 		reg	signed	[7:0]		image_out,

	input						trans
);

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		product <= 8'b0;
	end
	else begin
		product <= image_in * weight;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		image_out <= 8'b0;
	end
	else if(trans)begin
		image_out <= image_in;
	end
	else begin
		image_out <= image_out;
	end
end

endmodule
