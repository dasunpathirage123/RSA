`timescale 1ns / 1ps

module RSA_decryption 
#(
	parameter       WIDTH 	= 512
)(
	input aclk,    // Clock
	input aresetn,  // Asynchronous reset active low

	input wire [(WIDTH*4)-1:0] 	In_Data_word,//Encrypted_Data
	input 						In_Data_Ready,
	input 						New_RSA_Start,

	output reg [WIDTH-1:0  ] 	Out_publicKey_exp,
	output reg [(WIDTH*4)-1:0] 	Out_publicKey_mod,//pqrs=n
	output reg 					ready_to_encryption,

	output reg [(WIDTH*4)-1:0] 	Out_Data_word,//Decrypted_Data
	output reg             		Decrypt_done


);
//----------------------------------------------------------------
// Parameters.
//----------------------------------------------------------------
localparam 	STATE_IDLE 				= 4'd0 ;
localparam 	STATE_INIT 				= 4'd1 ;
localparam 	STATE_ROUND 			= 4'd2 ;
localparam 	STATE_SEND_PUBLIC_KEY 	= 4'd3 ;
localparam 	STATE_DECRYPT_READY 	= 4'd4 ;
localparam 	STATE_DECRYPT 			= 4'd5 ;
localparam 	STATE_DECRYPT_ROUND 	= 4'd6 ;
localparam 	STATE_DECRYPT_CAL 		= 4'd7 ;
localparam 	STATE_DECRYPT_DONE 		= 4'd8 ;

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------


reg 				next;
wire [WIDTH-1:0] 	p;
wire [WIDTH-1:0] 	q;
wire [WIDTH-1:0] 	r;
wire [WIDTH-1:0] 	s;

wire 				pqrs_done;
wire [WIDTH-1:0]		d_p;
wire [WIDTH-1:0]		d_q;
wire [WIDTH-1:0]		d_r;
wire [WIDTH-1:0]		d_s;
wire [WIDTH-1:0]		c_p;
wire [WIDTH-1:0]		c_q;
wire [WIDTH-1:0]		c_r;
wire [WIDTH-1:0]		c_s;
wire 				key_done;

reg [WIDTH-1:0] 	Number_00;
reg [WIDTH-1:0] 	Exponent_00;
reg [WIDTH-1:0] 	Modules_00;
wire[WIDTH-1:0]  	response_00;	
wire 				res_done_00;	
reg [WIDTH-1:0] 	Number_01;
reg [WIDTH-1:0] 	Exponent_01;
reg [WIDTH-1:0] 	Modules_01;
wire[WIDTH-1:0]  	response_01;	
wire 				res_done_01;	
reg [WIDTH-1:0] 	Number_02;
reg [WIDTH-1:0] 	Exponent_02;
reg [WIDTH-1:0] 	Modules_02;
wire[WIDTH-1:0]  	response_02;	
wire 				res_done_02;	
reg [WIDTH-1:0] 	Number_03;
reg [WIDTH-1:0] 	Exponent_03;
reg [WIDTH-1:0] 	Modules_03;
wire[WIDTH-1:0]  	response_03;	
wire 				res_done_03;

wire [(3*WIDTH)-1:0] qrs,prs,pqs,pqr;
wire [(4*WIDTH)-1:0] pqrs;

reg [3:0 ]           state;

//reg [(4*WIDTH)-1:0]  Decrypted_Data;
//wire [WIDTH-1:0]      Exponent;
//----------------------------------------------------------------
// assignments for ports.
//----------------------------------------------------------------
assign qrs = q*r*s; 
assign prs = p*r*s; 
assign pqs = p*q*s; 
assign pqr = p*q*r; 

assign pqrs = p*q*r*s;

//assign Exponent = 512'd65537;

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------

RSA_KEYGEN_Engine
#(
)RSA_KEYGEN_Engine_dut(

.aclk   (aclk   ),
.aresetn(aresetn),
.next(next),

.p(p),
.q(q),
.r(r),
.s(s),
.pqrs_ready(pqrs_done),
.d_p(d_p),
.d_q(d_q),
.d_r(d_r),
.d_s(d_s),
.c_p(c_p),
.c_q(c_q),
.c_r(c_r),
.c_s(c_s),
.done(key_done)

);


  mod_power 
#(
  .WIDTH(WIDTH)
)
mod_power_en_00
(
  .aclk(aclk),    // Clock
  .aresetn(aresetn),  // Asynchronous reset active low
  .Number(Number_00),
  .Exponent(Exponent_00),
  .Modules(Modules_00),
  .response(response_00),
  .res_done(res_done_00)
);

  mod_power 
#(
  .WIDTH(WIDTH)
)
mod_power_en_01
(
  .aclk(aclk),    // Clock
  .aresetn(aresetn),  // Asynchronous reset active low
  .Number(Number_01),
  .Exponent(Exponent_01),
  .Modules(Modules_01),
  .response(response_01),
  .res_done(res_done_01)
);

  mod_power 
#(
  .WIDTH(WIDTH)
)
mod_power_en_02
(
  .aclk(aclk),    // Clock
  .aresetn(aresetn),  // Asynchronous reset active low
  .Number(Number_02),
  .Exponent(Exponent_02),
  .Modules(Modules_02),
  .response(response_02),
  .res_done(res_done_02)
);

  mod_power 
#(
  .WIDTH(WIDTH)
)
mod_power_en_03
(
  .aclk(aclk),    // Clock
  .aresetn(aresetn),  // Asynchronous reset active low
  .Number(Number_03),
  .Exponent(Exponent_03),
  .Modules(Modules_03),
  .response(response_03),
  .res_done(res_done_03)
);

always @(posedge aclk) begin 
	if(!aresetn) begin
		state <= STATE_IDLE;
	end else begin
		case (state)

			STATE_IDLE :
			begin
				if (New_RSA_Start) begin
					state <= STATE_INIT;
				end
			end
			STATE_INIT :
			begin
				state <= STATE_ROUND;
			end
			STATE_ROUND :
			begin
				if (pqrs_done) begin
					state <= STATE_SEND_PUBLIC_KEY;
				end
			end
			STATE_SEND_PUBLIC_KEY :
			begin
				if (key_done) begin
					state <= STATE_DECRYPT_READY;
				end
			end
			STATE_DECRYPT_READY :
			begin
				if (In_Data_Ready) begin
					state <= STATE_DECRYPT;
				end
			end
			STATE_DECRYPT :
			begin 
				state <= STATE_DECRYPT_ROUND;
			end
			STATE_DECRYPT_ROUND :
			begin
				if (res_done_00 && res_done_01 && res_done_02 && res_done_03) begin
					state <= STATE_DECRYPT_CAL; 
				end
			end
			STATE_DECRYPT_CAL :
			begin 
				state <= STATE_DECRYPT_DONE;
			end
			STATE_DECRYPT_DONE :
			begin
				state <= STATE_IDLE;
			end
		
			default : state <= STATE_IDLE;
		endcase
	end
end


/*always @(posedge aclk) begin 
	if(!aresetn) begin
		
	end else begin
		case (state)
			STATE_IDLE :
			begin
				Decrypt_done <= 1'b0;
			end

			STATE_INIT :
			begin
				next <= 1'b1;		
			end
			STATE_ROUND :
			begin
				next <= 1'b0;
			end
			STATE_SEND_PUBLIC_KEY :
			begin
				Out_publicKey_exp 	<= 512'd65537;
				Out_publicKey_mod 	<= pqrs;
				ready_to_encryption <= 1'b1;
			end
			STATE_DECRYPT :
			begin
				ready_to_encryption <= 1'b0;

				Number_00  <= In_Data_word % p;
				Number_01  <= In_Data_word % q;
				Number_02  <= In_Data_word % r;
				Number_03  <= In_Data_word % s;

				Modules_00 <= p; 
				Modules_01 <= q; 
				Modules_02 <= r; 
				Modules_03 <= s; 

				Exponent_00 <= d_p; 
				Exponent_01 <= d_q;
				Exponent_02 <= d_r;
				Exponent_03 <= d_s;
			end

			STATE_DECRYPT_CAL :
			begin
				Out_Data_word <= (response_00*qrs*c_p + response_01*prs*c_q + response_02*pqs*c_r + response_03*pqr*c_s)%pqrs; 
			end
			STATE_DECRYPT_DONE :
			begin
				Decrypt_done <= 1'b1;
			end
		
			
		endcase
	end
end*/

//next
always @(posedge aclk) begin 
	if(!aresetn) begin
		next <= 1'b0;
	end else begin
		case (state)
		

			STATE_INIT :
			begin
				next <= 1'b1;		
			end
			STATE_ROUND :
			begin
				next <= 1'b0;
			end
			
		
		
		endcase
	end
end

//set pblic key
always @(posedge aclk) begin 
	if(!aresetn) begin
		Out_publicKey_exp   <= 512'b0; 
		Out_publicKey_mod   <= 512'b0; 
		ready_to_encryption <= 512'b0;
	end else begin
		case (state)
		
			STATE_SEND_PUBLIC_KEY :
			begin
				Out_publicKey_exp 	<= 512'd65537;
				Out_publicKey_mod 	<= pqrs;
				ready_to_encryption <= 1'b1;
			end
		
		endcase
	end
end

//set decryption
always @(posedge aclk) begin 
	if(!aresetn) begin
		/*Number_00 <= 512'b0;
		Number_01 <= 512'b0;
		Number_02 <= 512'b0;
		Number_03 <= 512'b0;
		Modules_00 <= 512'b0;
		Modules_01 <= 512'b0;
		Modules_02 <= 512'b0;
		Modules_03 <= 512'b0;
		Exponent_00 <= 512'b0;
		Exponent_01 <= 512'b0;
		Exponent_02 <= 512'b0;
		Exponent_03 <= 512'b0;*/
	end else begin
		case (state)
	
			STATE_DECRYPT :
			begin
				ready_to_encryption <= 1'b0;

				Number_00  <= In_Data_word % p;
				Number_01  <= In_Data_word % q;
				Number_02  <= In_Data_word % r;
				Number_03  <= In_Data_word % s;

				Modules_00 <= p; 
				Modules_01 <= q; 
				Modules_02 <= r; 
				Modules_03 <= s; 

				Exponent_00 <= d_p; 
				Exponent_01 <= d_q;
				Exponent_02 <= d_r;
				Exponent_03 <= d_s;
			end

		
		
		endcase
	end
end

//CRT calculation
always @(posedge aclk) begin 
	if(!aresetn) begin
		Out_Data_word <= 2048'b0;
	end else begin
		case (state)
	
			STATE_DECRYPT_CAL :
			begin
				Out_Data_word <= (response_00*qrs*c_p + response_01*prs*c_q + response_02*pqs*c_r + response_03*pqr*c_s)%pqrs; 
			end
		
		
		endcase
	end
end

//done decryption
always @(posedge aclk) begin 
	if(!aresetn) begin
		Decrypt_done <= 1'b0;
	end else begin
		case (state)
			STATE_IDLE :
			begin
				Decrypt_done <= 1'b0;
			end

			STATE_DECRYPT_DONE :
			begin
				Decrypt_done <= 1'b1;
			end
		
			
		endcase
	end
end

endmodule //RSA_decryption

