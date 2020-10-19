//mod_power_tb
`timescale 1ns / 1ps

module mod_power_tb ();
  localparam      CLK                 = 4;
  localparam      HALF_CLK            = CLK/2;
  localparam      WIDTH               = 512;

  reg           aclk;
  reg           aresetn;
	
  reg [WIDTH-1:0]	Number;
  reg [WIDTH-1:0]	Exponent;
  reg [WIDTH-1:0]	Modules;
  reg [WIDTH-1:0]	response;
  reg 				    res_done;  

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


    initial begin
        aclk                         = 0;
        forever begin      
            #(HALF_CLK)   aclk       = ~aclk;
        end
    end

    initial begin

    aresetn = 1'b0;
    @(negedge aclk);
    aresetn = 1'b1;
    @(posedge aclk);
    Number   = 512'd16; 
	  Exponent = 512'd22;   
	  Modules  = 512'd11;  
    end // initial

always @(posedge aclk ) begin
  if(!aresetn) begin
     
  end else begin
    if (res_done) begin
      Number   = Number  +512'd1; 
      Exponent = Exponent+512'd2;   
      Modules  = Modules +512'd2;  
    end
  end
end
    

endmodule 

