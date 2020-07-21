`timescale 1ns / 1ps

module RSA_KEYGEN_Engine_tb ();
  localparam      CLK                 = 4;
  localparam      HALF_CLK            = CLK/2;
  localparam      WIDTH               = 512;

  reg           aclk;
  reg           aresetn;
  reg           next,done;

  RSA_KEYGEN_Engine 
#(
  .WIDTH(WIDTH)
)
RSA_KEYGEN_Engine_dut
(
  .aclk(aclk),    // Clock
  .aresetn(aresetn),  // Asynchronous reset active low
  .next(next),
  .done(done)
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
    next = 1'b1;
    @(posedge aclk);
    next = 1'b0;

    /*if (done) begin
      next = 1'b1;
      @(posedge aclk);
      next = 1'b0;
    end*/
 
    end // initial

    always @(posedge aclk) begin
      if(!aresetn) begin
        
      end else begin
        if (done) begin
          next = 1'b1;
          @(posedge aclk);
          next = 1'b0;
        end
      end
    end

endmodule 

