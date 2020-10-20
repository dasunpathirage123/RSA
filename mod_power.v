`timescale 1ns / 1ps

module mod_power 
#(
	parameter       WIDTH 	= 512
)(
	input aclk,    // Clock
	input aresetn,  // Asynchronous reset active low

	input wire [WIDTH-1:0] Number,
	input wire [WIDTH-1:0] Exponent,
	input wire [WIDTH-1:0] Modules,

	output reg [WIDTH-1:0] response,
	output reg             res_done


);
//----------------------------------------------------------------
// Parameters.
//----------------------------------------------------------------

localparam STATE_INIT  	= 3'd0;
localparam STATE_ROUND 	= 3'd1;
localparam STATE_NEXT  	= 3'd2;
localparam STATE_DONE  	= 3'd3;
	

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------
reg start;
reg [WIDTH-1:0] E,M;
reg [2*(WIDTH)-1:0] N,R;
reg [2:0] state;
//----------------------------------------------------------------
// assignments for ports.
//----------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
always @(Number,Modules,Exponent) begin 
	start = 1'b1;
	res_done <= 1'b0;
end


always @(posedge aclk) begin 
	if(!aresetn) begin
		state <= STATE_INIT;
	end else begin
		case (state)
			STATE_INIT :
			begin
				if (start) begin
					state <= STATE_ROUND;
				end
			end
			STATE_ROUND :
			begin
				if (E != 512'd1) begin
					state 	<= STATE_NEXT;
				end else begin
					state   <= STATE_DONE;
				end
				
			end
			STATE_NEXT  :
			begin
				state <= STATE_ROUND;
			end
			STATE_DONE  :
			begin
				state <= STATE_INIT;
		    end 
			
		
			default : /* default */;
		endcase
	end
end

always @(posedge aclk) begin 
	if(!aresetn) begin
		start 		<= 1'b0;
		response	<= 512'b0;
		res_done	<= 1'b0;
		R           <= 512'd1;
	end else begin
		case (state)
			STATE_INIT :
			begin
				N 	<= Number%Modules;
				E 	<= Exponent;
				M 	<= Modules;
				R   <= 512'd1;
			end
			STATE_ROUND :
			begin
				start <= 1'b0;
				if (E%2) begin //if m is odd
					R <= (R*N)%M; 
					E <= E - 512'd1;
				end
			end
			STATE_NEXT  :
			begin
				N <= (N*N)%M;
				E <= E/2;
			end
			STATE_DONE  :
			begin
				response <= R;
				res_done <= 1'b1;
		    end 
			
		
			default : /* default */;
		endcase
	end
end


endmodule //mod_power

