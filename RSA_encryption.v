`timescale 1ns / 1ps

module RSA_encryption 
#(
	parameter       WIDTH 	= 512
)(
	input aclk,    // Clock
	input aresetn,  // Asynchronous reset active low

	input wire [(WIDTH*4)-1:0] 	Data_word,
	input wire [WIDTH-1:0  ] 	Exp_publicKey,
	input wire [(WIDTH*4)-1:0] 	Mod_pqrs,//pqrs=n

	output reg [(WIDTH*4)-1:0] 	Encrypted_Data,
	output reg             		Encrypt_done


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
reg [(4*WIDTH)-1:0] N,M,R;
reg [WIDTH-1:0] E;
reg [2:0] state;
//----------------------------------------------------------------
// assignments for ports.
//----------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
always @(Data_word,Exp_publicKey,Mod_pqrs) begin 
	start = 1'b1;
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
		Encrypted_Data	<= 512'b0;
		Encrypt_done	<= 1'b0;
		R           <= 512'd1;
	end else begin
		case (state)
			STATE_INIT :
			begin
				N 	<= Data_word%Mod_pqrs;
				E 	<= Exp_publicKey;
				M 	<= Mod_pqrs;
				Encrypt_done <= 1'b0;
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
				Encrypted_Data <= R;
				Encrypt_done <= 1'b1;
		    end 
			
		
			default : /* default */;
		endcase
	end
end


endmodule //mod_power

