`timescale 1ns / 1ps
// for 512 bit s value is around 6
module primality_test 
#(
	parameter       WIDTH 	= 512
)(
	input aclk,    // Clock
	input aresetn,  // Asynchronous reset active low
	input wire [WIDTH-1:0] 	Number_prime,

	output reg [ 1 : 0 ]	IsPrime, //01 prime / 10 not prime

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
reg [3:0] 		S;
reg 			rd_en_a;
reg [WIDTH-1:0] dout_a;
reg 			empty_a;

reg [WIDTH-1:0]	Number;
reg [WIDTH-1:0]	Exponent;
reg [WIDTH-1:0]	Modules;
reg [WIDTH-1:0]	response;
reg 			res_done; 

reg [WIDTH-1:0] a;
//----------------------------------------------------------------
// assignments for ports.
//----------------------------------------------------------------
assign S = 3'd6; // security value for 512 bit value
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
always @(Number) begin 
	start = 1'b1;
end


always @(posedge aclk) begin 
	if(!aresetn) begin
		state <= STATE_IDLE;
	end else begin
		case (state)
			STATE_IDLE :
			begin
				if (start) begin
					state <= STATE_ROUND;
				end
			end

			STATE_INIT :
			begin
				rd_en_a    <= 1'b1;

				Number 	   <= dout_a;			
				Exponent   <= Number_prime - 512'd1;				
				Modules    <= Number_prime;

				if (res_done) begin
					state  <= STATE_INIT_NEXT;
				end	
			end
			
			STATE_INIT_NEXT :
			begin
				if (response != 512'd1 ) begin
					IsPrime <= 2'b10; //not a prime
					state   <= STATE_DONE;//composite
				end else begin
					state   <= STATE_ROUND;
				end
			end

			STATE_ROUND_INIT:
			begin		
				if (r_done) begin
					state <= STATE_ROUND; 
				end	
			end
			STATE_ROUND    :
			begin
				Exponent <= r;
				r        <= r*2;
				if (res_done) begin
					state <= STATE_ROUND_NEXT;
				end
			end

			STATE_ROUND_NEXT
		
			default : /* default */;
		endcase
	end
end

fifo_generator_a FIFO_a (
  .clk(aclk),      // input wire clk
  .srst(aresetn),    // input wire srst
  //.din(din),      // input wire [511 : 0] din
  //.wr_en(wr_en),  // input wire wr_en
  .rd_en(rd_en_a),  // input wire rd_en
  .dout(dout_a),    // output wire [511 : 0] dout
  //.full(full),    // output wire full
  .empty(empty_a)  // output wire empty
);

 mod_power 
#(
  .WIDTH(WIDTH)
)
mod_power_dut
(
  .aclk(aclk),    // Clock
  .aresetn(aresetn),  // Asynchronous reset active low
  .Number(Number),
  .Exponent(Exponent),
  .Modules(Modules),
  .response(response),
  .res_done(res_done)
);

endmodule //primality_test

/*fifo_generator_0 your_instance_name (
  .clk(clk),      // input wire clk
  .srst(srst),    // input wire srst
  .din(din),      // input wire [511 : 0] din
  .wr_en(wr_en),  // input wire wr_en
  .rd_en(rd_en),  // input wire rd_en
  .dout(dout),    // output wire [511 : 0] dout
  .full(full),    // output wire full
  .empty(empty)  // output wire empty
);*/

//3 fifios rng-fifo prime-fifo a-fifo 