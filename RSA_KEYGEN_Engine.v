//RSA_Decryption_engine 
//extended euclidean algorithm
`timescale 1ns / 1ps
//Inverse
module RSA_KEYGEN_Engine 
#(
	parameter       WIDTH 	= 512
)(
	input aclk,    // Clock
	input aresetn,  // Asynchronous reset active low
	input next,

	output reg [(3*WIDTH)-1:0]  qrs,
	output reg [(3*WIDTH)-1:0]	prs,
	output reg [(3*WIDTH)-1:0]	pqs,
	output reg [(3*WIDTH)-1:0]	pqr,

	output reg [WIDTH-1:0] d_p,
	output reg [WIDTH-1:0] d_q,
	output reg [WIDTH-1:0] d_r,
	output reg [WIDTH-1:0] d_s,

	output reg [WIDTH-1:0] c_p,
	output reg [WIDTH-1:0] c_q,
	output reg [WIDTH-1:0] c_r,
	output reg [WIDTH-1:0] c_s,

	output reg 					done

);
//----------------------------------------------------------------
// Parameters.
//----------------------------------------------------------------

localparam  STATE_IDLE 				= 4'd0;
localparam  STATE_INIT_INIT 		= 4'd1;
localparam  STATE_INIT_DONE 	   	= 4'd2;
localparam  STATE_INIT_ROUND    	= 4'd3;
localparam  STATE_INIT_NEXT         = 4'd4;
localparam  STATE_INIT_RUN 			= 4'd5;
localparam  STATE_INIT_ROUND_DONE 	= 4'd6;

localparam STATE_ROUN_INIT 			= 3'd0;	
localparam STATE_ROUN_RUN 			= 3'd1;	
localparam STATE_ROUND_NEXT 		= 3'd2;		
localparam STATE_ROUND_DONE 		= 3'd3;		

//---------------------------------------------------------------------------------------------------------------------
// Internal wires and registers
//---------------------------------------------------------------------------------------------------------------------

wire [ 17  : 0 ] e;//public_key 

reg [WIDTH-1:0] p,q,r,s; // four prime numbers
//reg [WIDTH-1:0] d_p,d_q,d_r,d_s; // multiplicative inverse to e(public key) respectivly p,q,r,s
//reg [WIDTH-1:0] c_p,c_q,c_r,c_s; //CRT coefficient respectivly p,q,r,s

//reg [(3*WIDTH)-1:0] qrs,prs,pqs,pqr; // for CRT calculation
 
reg [(3*WIDTH)-1:0] temp_1,temp_2,temp_3,temp_4; // for CRT calculation & CRT coefficient calculation

reg [WIDTH-1 : 0] CRT_mem   [0 : 11];//

/*
			   multiplicarive invers
mod CRT_mem[0] 	-> q mod p  process 01 
mod CRT_mem[1] 	-> r mod p  process 02
mod CRT_mem[2] 	-> s mod p  process 03 
mod CRT_mem[3] 	-> p mod q  process 01 
mod CRT_mem[4] 	-> r mod q  process 04
mod CRT_mem[5] 	-> s mod q  process 05
mod CRT_mem[6] 	-> p mod r  process 02
mod CRT_mem[7] 	-> q mod r  process 04
mod CRT_mem[8] 	-> s mod r  process 06
mod CRT_mem[9] 	-> p mod s  process 03
mod CRT_mem[10] 	-> q mod s  process 05
mod CRT_mem[11] 	-> r mod s  process 06
*/

reg  [WIDTH-1:0]	Multiplicative_Num_engine_00;
reg  [WIDTH-1:0]	Modular_engine_00;
wire [WIDTH-1:0]	Multiplicative_Inv_Mod_engine_00;
wire [WIDTH-1:0]	Multiplicative_Inv_Num_engine_00;
wire 				Multiplicative_Inv_Done_engine_00;

reg  [WIDTH-1:0]	Multiplicative_Num_engine_01;
reg  [WIDTH-1:0]	Modular_engine_01;
wire [WIDTH-1:0]	Multiplicative_Inv_Mod_engine_01;
wire [WIDTH-1:0]	Multiplicative_Inv_Num_engine_01;
wire 				Multiplicative_Inv_Done_engine_01;

reg  [WIDTH-1:0]	Multiplicative_Num_engine_02;
reg  [WIDTH-1:0]	Modular_engine_02;
wire [WIDTH-1:0]	Multiplicative_Inv_Mod_engine_02;
wire [WIDTH-1:0]	Multiplicative_Inv_Num_engine_02;
wire 				Multiplicative_Inv_Done_engine_02;

reg  [WIDTH-1:0]	Multiplicative_Num_engine_03;
reg  [WIDTH-1:0]	Modular_engine_03;
wire [WIDTH-1:0]	Multiplicative_Inv_Mod_engine_03;
wire [WIDTH-1:0]	Multiplicative_Inv_Num_engine_03;
wire 				Multiplicative_Inv_Done_engine_03;

reg [ 2 : 0 ] 	init_round_count;
reg 			start_init;// start iniit
reg   			start_new;
reg 			start_round;
reg [ 3 : 0 ]   state_init;
reg [ 2 : 0 ]   state_round;
reg 			init_round_done;
reg             change_done;
reg [ 2 : 0 ]	count;

//----------------------------------------------------------------
// assignments for ports.
//----------------------------------------------------------------
assign e = 17'd65537; 

 
/*assign temp_1 = CRT_mem[0]*CRT_mem[1]*CRT_mem[2];
assign temp_2 = CRT_mem[3]*CRT_mem[4]*CRT_mem[5];
assign temp_3 = CRT_mem[6]*CRT_mem[7]*CRT_mem[8];
assign temp_4 = CRT_mem[9]*CRT_mem[10]*CRT_mem[11];*/
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
always @(aresetn,temp_1,temp_2,temp_3,temp_4) begin
	if(!aresetn) begin
		c_p = 512'd0;
		c_q = 512'd0;
		c_r = 512'd0;
		c_s = 512'd0;
	end else begin
		c_p = temp_1%p;
		c_q = temp_2%q;
		c_r = temp_3%r;
		c_s = temp_4%s;
	end
end

always @*
begin : CRT_memeory
  	temp_1 = CRT_mem[4'd0]*CRT_mem[4'd1]*CRT_mem[4'd2];
	temp_2 = CRT_mem[4'd3]*CRT_mem[4'd4]*CRT_mem[4'd5];
	temp_3 = CRT_mem[4'd6]*CRT_mem[4'd7]*CRT_mem[4'd8];
	temp_4 = CRT_mem[4'd9]*CRT_mem[4'd10]*CRT_mem[4'd11];	

end // CRT_mem


always @*
begin : pqrs
  	qrs = q*r*s;
	prs = p*r*s;
	pqs = p*q*s;
	pqr = p*q*r;

end // pqrs

//start selector
always @(*) begin 
	if(next && init_round_count == 3'b0) begin
		start_init = 1'b1;
		count      = 3'b0;
		p = 512'd5 ;//5
		q = 512'd11;
		r = 512'd17;
		s = 512'd19;
	end else if(next && init_round_count != 3'b0 ) begin
		start_new  = 1'b1;
		start_init = 1'b0;
		count      = (count + 3'd1)%3'd4;
		
	end else begin
		start_init = 1'b0;
		start_new  = 1'b0;
	end
end

//output done
always @(init_round_done,change_done,next)begin 
  	if ((init_round_done || change_done) && !next) begin
  		done = 1'b1;
  	end else if(next) begin
  		done = 1'b0;
  	end
  	
end // done



//load p,q,r,s
/*always @(posedge aclk) begin 
	if(!aresetn) begin
		start_init <= 1'b0;
	end else begin
		//load from fifo pqrs
		case ()
		
			default : ;
		endcase
	end*o?-
end*/
/*assign p = 512'd5 ;
assign q = 512'd11;
assign r = 512'd17;
assign s = 512'd19;*/

/*always @*
begin : pqrs
  	p = 512'd5 ;
	q = 512'd11;
	r = 512'd17;
	s = 512'd19;
end // pqrs*/

//FSM
always @(posedge aclk) begin 
	if(!aresetn) begin
		state_init <= STATE_IDLE;
	end else begin
		case (state_init)

			STATE_IDLE :
			begin
				if (start_init) begin
					state_init <= STATE_INIT_INIT;
				end
			end
			STATE_INIT_INIT:
			begin
				if(Multiplicative_Inv_Done_engine_00 &&
					Multiplicative_Inv_Done_engine_01 &&
					Multiplicative_Inv_Done_engine_02 &&
					Multiplicative_Inv_Done_engine_03) begin
					state_init <= STATE_INIT_DONE;
				end
			end
			STATE_INIT_DONE :
			begin
				state_init <= STATE_INIT_ROUND;
			end
			STATE_INIT_ROUND ://3
			begin
				state_init <= STATE_INIT_NEXT;
			end
			STATE_INIT_NEXT :
			begin
				if (Multiplicative_Inv_Done_engine_01 &&
					Multiplicative_Inv_Done_engine_02 &&
					Multiplicative_Inv_Done_engine_03) begin
					state_init <= STATE_INIT_RUN;
				end 
			end
			STATE_INIT_RUN :
			begin
				if (init_round_count == 3'd1) begin
					state_init <= STATE_INIT_ROUND_DONE;
				end else begin
					state_init <= STATE_INIT_ROUND;
				end
			end
			
			STATE_INIT_ROUND_DONE :
			begin
				state_init <= STATE_IDLE;
			end
		
			default : /* default */;
		endcase
	end
end

//mian
always @(posedge aclk) begin 
	if(!aresetn) begin
		d_p <= 512'b0;
		d_q <= 512'b0;
		d_r <= 512'b0;
		d_s <= 512'b0;
	end else begin
		case (state_init)

			STATE_IDLE :
			begin
				
			end
			STATE_INIT_INIT:
			begin
				Multiplicative_Num_engine_00 	<= e;
				Modular_engine_00 				<= p-512'd1; 
				Multiplicative_Num_engine_01 	<= e;
				Modular_engine_01 				<= q-512'd1; 
				Multiplicative_Num_engine_02 	<= e;
				Modular_engine_02 				<= r-512'd1; 
				Multiplicative_Num_engine_03 	<= e;
				Modular_engine_03 				<= s-512'd1; 
				
			end
			STATE_INIT_DONE  :
			begin
				d_p <= Multiplicative_Inv_Num_engine_00;
				d_q <= Multiplicative_Inv_Num_engine_01;
				d_r <= Multiplicative_Inv_Num_engine_02;
				d_s <= Multiplicative_Inv_Num_engine_03;
			end 
			STATE_INIT_ROUND ://3
			begin
				 if (init_round_count == 3'd0) begin
				 	//q mod p  process 01 
					//p mod q  process 01 
					Multiplicative_Num_engine_01 	<= q;
					Modular_engine_01 				<= p;
					//r mod p  process 02
					//p mod r  process 02
					Multiplicative_Num_engine_02 	<= r;
					Modular_engine_02 				<= p; 
					//s mod p  process 03
					//p mod s  process 03
					Multiplicative_Num_engine_03 	<= s;
					Modular_engine_03 				<= p; 
				end
				if (init_round_count == 3'd1) begin
					//r mod q  process 04
					//q mod r  process 04
					Multiplicative_Num_engine_01 	<= r;
					Modular_engine_01 				<= q;
					//s mod q  process 05
					//q mod s  process 05
					Multiplicative_Num_engine_02 	<= s;
					Modular_engine_02 				<= q; 
					//s mod r  process 06
					//r mod s  process 06
					Multiplicative_Num_engine_03 	<= s;
					Modular_engine_03 				<= r; 
				end
			end
			STATE_INIT_RUN ://4
			begin
				
				if (init_round_count == 3'd0) begin
					CRT_mem[4'd0]	<=	 Multiplicative_Inv_Num_engine_01;	//> q mod p  process 01 
					CRT_mem[4'd3]	<=	 Multiplicative_Inv_Mod_engine_01;	//> p mod q  process 01

					CRT_mem[4'd1]	<=	 Multiplicative_Inv_Num_engine_02;	//> r mod p  process 02
					CRT_mem[4'd6]	<=	 Multiplicative_Inv_Mod_engine_02;	//> p mod r  process 02

					CRT_mem[4'd2]	<=	 Multiplicative_Inv_Num_engine_03;	//> s mod p  process 03
					CRT_mem[4'd9]	<=	 Multiplicative_Inv_Mod_engine_03;	//> p mod s  process 03
				end
				if (init_round_count == 3'd1) begin
					CRT_mem[4'd4] 	<=	Multiplicative_Inv_Num_engine_01; 	//> r mod q  process 04
					CRT_mem[4'd7] 	<=	Multiplicative_Inv_Mod_engine_01; 	//> q mod r  process 04

					CRT_mem[4'd5] 	<=	Multiplicative_Inv_Num_engine_02; 	//> s mod q  process 05
					CRT_mem[4'd10] <=	Multiplicative_Inv_Mod_engine_02; 	//> q mod s  process 05

					CRT_mem[4'd8] 	<=	Multiplicative_Inv_Num_engine_03; 	//> s mod r  process 06
					CRT_mem[4'd11] <=	Multiplicative_Inv_Mod_engine_03; 	//> r mod s  process 06
				end
			end
			
		
			default : /* default */;
		endcase
	end
end

//init_round_count
always @(posedge aclk) begin 
	if(!aresetn) begin
		init_round_count <= 3'b0;
	end else begin
		case (state_init)

			STATE_IDLE :
			begin
				//init_round_count <= 3'b0;
			end
			
			STATE_INIT_RUN :
			begin
				init_round_count <= init_round_count + 1'b1;
			end
		
			default : /* default */;
		endcase
	end
end
//init_round_done
always @(posedge aclk) begin 
	if(!aresetn) begin
		init_round_done <= 1'b0;;
	end else begin
		case (state_init)

		
			STATE_IDLE            :
			begin
				init_round_done <= 1'b0;
			end
			
			STATE_INIT_ROUND_DONE :
			begin
				init_round_done <= 1'b1;
			end
		
			default : /* default */;
		endcase
	end
end

  ext_euclidean
  #(
    .WIDTH (WIDTH)
  )
  ext_euclidean_engine_00
  (
    .aclk  (aclk ), 
    .aresetn(aresetn),
    .Multiplicative_Num(Multiplicative_Num_engine_00),
    .Modular(Modular_engine_00),
    .Multiplicative_Inv_Mod(Multiplicative_Inv_Mod_engine_00),
    .Multiplicative_Inv_Num(Multiplicative_Inv_Num_engine_00),
    .Multiplicative_Inv_Done(Multiplicative_Inv_Done_engine_00)
    //.error (error)
  );

  ext_euclidean
  #(
    .WIDTH (WIDTH)
  )
  ext_euclidean_engine_01
  (
    .aclk  (aclk ), 
    .aresetn(aresetn),
    .Multiplicative_Num(Multiplicative_Num_engine_01),
    .Modular(Modular_engine_01),
    .Multiplicative_Inv_Mod(Multiplicative_Inv_Mod_engine_01),
    .Multiplicative_Inv_Num(Multiplicative_Inv_Num_engine_01),
    .Multiplicative_Inv_Done(Multiplicative_Inv_Done_engine_01)
    //.error (error)
  );

    ext_euclidean
  #(
    .WIDTH (WIDTH)
  )
  ext_euclidean_engine_02
  (
    .aclk  (aclk ), 
    .aresetn(aresetn),
    .Multiplicative_Num(Multiplicative_Num_engine_02),
    .Modular(Modular_engine_02),
    .Multiplicative_Inv_Mod(Multiplicative_Inv_Mod_engine_02),
    .Multiplicative_Inv_Num(Multiplicative_Inv_Num_engine_02),
    .Multiplicative_Inv_Done(Multiplicative_Inv_Done_engine_02)
    //.error (error)
  );

    ext_euclidean
  #(
    .WIDTH (WIDTH)
  )
  ext_euclidean_engine_03
  (
    .aclk  (aclk ), 
    .aresetn(aresetn),
    .Multiplicative_Num(Multiplicative_Num_engine_03),
    .Modular(Modular_engine_03),
    .Multiplicative_Inv_Mod(Multiplicative_Inv_Mod_engine_03),
    .Multiplicative_Inv_Num(Multiplicative_Inv_Num_engine_03),
    .Multiplicative_Inv_Done(Multiplicative_Inv_Done_engine_03)
    //.error (error)
  );
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @(*) begin 
	if (start_new) begin
		case (count)
			3'd0: p = 512'd23;
 			3'd1: q = 512'd23;
			3'd2: r = 512'd23;
			3'd3: s = 512'd23;
		
			default : ;
		endcase
		start_round = 1'b1;
	end else begin
		start_round = 1'b0;
	end
end
//FSM 2
always @(posedge aclk) begin 
	if(!aresetn) begin
		state_round <=	STATE_ROUN_INIT;
	end else begin
		case (state_round)
		STATE_ROUN_INIT :
		begin
			if (start_round) begin
				state_round <= STATE_ROUN_RUN;
			end
		end
		STATE_ROUN_RUN :
		begin
			state_round <= STATE_ROUND_NEXT;
		end
		STATE_ROUND_NEXT :
		begin
			if (Multiplicative_Inv_Done_engine_00 &&
					Multiplicative_Inv_Done_engine_01 &&
					Multiplicative_Inv_Done_engine_02 &&
					Multiplicative_Inv_Done_engine_03) begin
				state_round <= STATE_ROUND_DONE;
			end
		end
		STATE_ROUND_DONE :
		begin
			state_round <= STATE_ROUN_INIT;
		end
			default : /* default */;
		endcase
	end
end
always @(posedge aclk) begin 
	if(!aresetn) begin
		state_round <=	STATE_ROUN_INIT;
	end else begin
		case (state_round)
	
		STATE_ROUN_RUN :
		begin
			case (count)
			3'd0: //p change pocess
			begin
				Multiplicative_Num_engine_00 	<= e;
				Modular_engine_00 				<= p-512'd1; 
				
				//q mod p  process 01 
				//p mod q  process 01 
				Multiplicative_Num_engine_01 	<= q;
				Modular_engine_01 				<= p;
				//r mod p  process 02
				//p mod r  process 02
				Multiplicative_Num_engine_02 	<= r;
				Modular_engine_02 				<= p; 
				//s mod p  process 03
				//p mod s  process 03
				Multiplicative_Num_engine_03 	<= s;
				Modular_engine_03 				<= p; 
			end 
 			3'd1: //q change pocess
 			begin
 				Multiplicative_Num_engine_00 	<= e;
				Modular_engine_00 				<= q-512'd1; 


				//q mod p  process 01 
				//p mod q  process 01 
				Multiplicative_Num_engine_01 	<= q;
				Modular_engine_01 				<= p;
				//r mod q  process 04
				//q mod r  process 04
				Multiplicative_Num_engine_02 	<= r;
				Modular_engine_02 				<= q;
				//s mod q  process 05
				//q mod s  process 05
				Multiplicative_Num_engine_03 	<= s;
				Modular_engine_03 				<= q; 
 			end 
			3'd2: //r change pocess
			begin
				Multiplicative_Num_engine_00 	<= e;
				Modular_engine_00 				<= r-512'd1; 

				//r mod p  process 02
				//p mod r  process 02
				Multiplicative_Num_engine_01 	<= r;
				Modular_engine_01 				<= p; 
				//r mod q  process 04
				//q mod r  process 04
				Multiplicative_Num_engine_02 	<= r;
				Modular_engine_02 				<= q;
				//s mod r  process 06
				//r mod s  process 06
				Multiplicative_Num_engine_03 	<= s;
				Modular_engine_03 				<= r; 
			end 
			3'd3: //s change pocess
			begin
				Multiplicative_Num_engine_00 	<= e;
				Modular_engine_00 				<= s-512'd1; 

				//s mod p  process 03
				//p mod s  process 03
				Multiplicative_Num_engine_01 	<= s;
				Modular_engine_01 				<= p; 
				//s mod q  process 05
				//q mod s  process 05
				Multiplicative_Num_engine_02 	<= s;
				Modular_engine_02 				<= q; 
				//s mod r  process 06
				//r mod s  process 06
				Multiplicative_Num_engine_03 	<= s;
				Modular_engine_03 				<= r; 
			end 
		
			default : ;
		endcase
	
		end
		
			default : /* default */;
		endcase
	end
end



//done round
always @(posedge aclk) begin 
	if(!aresetn) begin
		change_done <= 1'b0;
	end else begin
		case (state_round)
		STATE_ROUN_INIT :
		begin
			change_done <= 1'b0;
		end

		STATE_ROUND_DONE :
		begin
			case (count)
			3'd0: //p change pocess
			begin
				d_p <= Multiplicative_Inv_Num_engine_00;
				
				CRT_mem[4'd0]	<=	 Multiplicative_Inv_Num_engine_01;	//> q mod p  process 01 
				CRT_mem[4'd3]	<=	 Multiplicative_Inv_Mod_engine_01;	//> p mod q  process 01

				CRT_mem[4'd1]	<=	 Multiplicative_Inv_Num_engine_02;	//> r mod p  process 02
				CRT_mem[4'd6]	<=	 Multiplicative_Inv_Mod_engine_02;	//> p mod r  process 02

				CRT_mem[4'd2]	<=	 Multiplicative_Inv_Num_engine_03;	//> s mod p  process 03
				CRT_mem[4'd9]	<=	 Multiplicative_Inv_Mod_engine_03;	//> p mod s  process 03
			end 
 			3'd1: //q change pocess
 			begin
 				d_q <= Multiplicative_Inv_Num_engine_00;
				
 				CRT_mem[4'd0]	<=	 Multiplicative_Inv_Num_engine_01;	//> q mod p  process 01 
				CRT_mem[4'd3]	<=	 Multiplicative_Inv_Mod_engine_01;	//> p mod q  process 01

				CRT_mem[4'd4] 	<=	Multiplicative_Inv_Num_engine_02; 	//> r mod q  process 04
				CRT_mem[4'd7] 	<=	Multiplicative_Inv_Mod_engine_02; 	//> q mod r  process 04

				CRT_mem[4'd5] 	<=	Multiplicative_Inv_Num_engine_03; 	//> s mod q  process 05
				CRT_mem[4'd10] <=	Multiplicative_Inv_Mod_engine_03; 	//> q mod s  process 05

 			end 
			3'd2: //r change pocess
			begin
				d_r <= Multiplicative_Inv_Num_engine_00;
				
				CRT_mem[4'd1]	<=	 Multiplicative_Inv_Num_engine_01;	//> r mod p  process 02
				CRT_mem[4'd6]	<=	 Multiplicative_Inv_Mod_engine_01;	//> p mod r  process 02

				CRT_mem[4'd4] 	<=	Multiplicative_Inv_Num_engine_02; 	//> r mod q  process 04
				CRT_mem[4'd7] 	<=	Multiplicative_Inv_Mod_engine_02; 	//> q mod r  process 04

				CRT_mem[4'd8] 	<=	Multiplicative_Inv_Num_engine_03; 	//> s mod r  process 06
				CRT_mem[4'd11] <=	Multiplicative_Inv_Mod_engine_03; 	//> r mod s  process 06
			end 
			3'd3: //s change pocess
			begin
				d_s <= Multiplicative_Inv_Num_engine_00;

				CRT_mem[4'd2]	<=	 Multiplicative_Inv_Num_engine_01;	//> s mod p  process 03
				CRT_mem[4'd9]	<=	 Multiplicative_Inv_Mod_engine_01;	//> p mod s  process 03

				CRT_mem[4'd5] 	<=	Multiplicative_Inv_Num_engine_02; 	//> s mod q  process 05
				CRT_mem[4'd10] <=	Multiplicative_Inv_Mod_engine_02; 	//> q mod s  process 05

				CRT_mem[4'd8] 	<=	Multiplicative_Inv_Num_engine_03; 	//> s mod r  process 06
				CRT_mem[4'd11] <=	Multiplicative_Inv_Mod_engine_03; 	//> r mod s  process 06
			end 
				default : /* default */;
			endcase
			change_done <= 1'b1;
		end
			default : /* default */;
		endcase
	end
end
/*integer i;
always @(posedge aclk ) begin 
	if(!aresetn) begin
	
	end else begin
		if (done) begin
			for ( i = 0; i < 12; i=i+1) begin
				$display("CRT_mem %h",CRT_mem[i]);
			end
			$display("CRT_mem .....................");
		end
	end
end*/

endmodule //RSA_KEYGEN_Engine

