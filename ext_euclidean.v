//extended euclidean algorithm
`timescale 1ns / 1ps
//Inverse
module ext_euclidean
#(
	parameter       WIDTH 	= 512
)(
	input aclk,    // Clock
	input aresetn,  // Asynchronous reset active low

	input wire [WIDTH-1:0] Multiplicative_Num,
	input wire [WIDTH-1:0] Modular,

	output reg [WIDTH-1:0] Multiplicative_Inv_Mod,
	output reg [WIDTH-1:0] Multiplicative_Inv_Num
	//output reg    		   error //if gcd of two numbers are != 1 ,output =1
);
//----------------------------------------------------------------
// Parameters.
//----------------------------------------------------------------

localparam STATE_INIT           = 1'd0 ;
localparam STATE_RUN            = 1'd1 ; 

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//--------------------------------------------------------------------------------------------------------------------- 
reg [WIDTH-1:0]	X_1;
reg [WIDTH-1:0] X_2;
reg [WIDTH-1:0]	Y_1;
reg [WIDTH-1:0] Y_2;

reg [WIDTH-1:0] q,r,a,b,x,y;

reg start;
reg state;
//----------------------------------------------------------------
// assignments for ports.
//----------------------------------------------------------------
 
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------

/*always @*
begin : start_algo
  start = 1'b1;
end // key_mem_read*/

always @(Multiplicative_Num,Modular) begin
	start = 1'b1;
end


//FSM
always @(posedge aclk ) begin 
	if(!aresetn) begin
		state <= STATE_INIT;
	end else begin
		case (state)
			STATE_INIT  :
			begin
				if (start) begin
					state <= STATE_RUN;
				end
			end
			STATE_RUN   :
			begin
				if (b!=512'b0) begin
					state <= STATE_RUN;
				end else begin
					state <= STATE_INIT;
				end
			end
			
		
			default : /* default */;
		endcase
	end
end

always @(posedge aclk ) begin 
	if(!aresetn) begin
		a <= Modular;
		b <= Multiplicative_Num;
		X_1	<= 512'd0;
		X_2	<= 512'd1;
		Y_1	<= 512'd1;
		Y_2	<= 512'd0;
	end else begin
		case (state)
			STATE_INIT  :
			begin
				a <= Modular;
				b <= Multiplicative_Num;
				X_1	<= 512'd0;
				X_2	<= 512'd1;
				Y_1	<= 512'd1;
				Y_2	<= 512'd0;
			end
			STATE_RUN   :
			begin
				start <= 1'b0;
			end
		
			default : /* default */;
		endcase
	end
end

always @(posedge aclk ) 
begin 
	if(!aresetn) begin
		q <= 512'd0;
		r <= 512'd0;
		x <= 512'd0;
		y <= 512'd0;
	end else begin
		case (state)
			STATE_RUN  :
			begin
				if (b!=512'b0) begin
					q <= a/b;
					r <= a%b;
				end else begin
					//check for sign bit
					if (Y_2[511]) begin //if number if negetive sign bit is one 
						Multiplicative_Inv_Mod <= Modular+Y_2;
					end else begin
						Multiplicative_Inv_Mod <= Y_2;
					end
					
					if (X_2[511]) begin //if number if negetive sign bit is one 
						Multiplicative_Inv_Num <= Modular+X_2;
					end else begin
						Multiplicative_Inv_Num <= X_2;
					end			

				/*	if (a) begin
						error <= 1'b0;
					end else begin
						error <= 1'b1;
					end*/
				end
			end
		
			default : /* default */;
		endcase
	end
end

always @(q) begin
	x <= X_2 - (q*X_1);
	y <= Y_2 - (q*Y_1);
end

always @(x,y) begin
	a = b;
	b = r;
	X_2 = X_1;
	X_1 = x;
	Y_2 = Y_1;
	Y_1 = y;
end



endmodule //aes_key_gen

