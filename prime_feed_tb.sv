`timescale 1ns / 1ps

module prime_feed_tb ();
  localparam      CLK                 = 4;
  localparam      HALF_CLK            = CLK/2;
  localparam      WIDTH               = 512;

  reg              aclk;
  reg              aresetn;
  reg              next;
    
  reg              pqrs_ready;
  reg [WIDTH-1:0]  p;
  reg [WIDTH-1:0]  q;
  reg [WIDTH-1:0]  r;
  reg [WIDTH-1:0]  s;

  prime_feed 
#(
  .WIDTH(WIDTH)
)
prime_feed_dut
(
  .aclk(aclk),
  .aresetn(aresetn),
  .next(next),
  .pqrs_ready(pqrs_ready),
  .p(p),
  .q(q),
  .r(r),
  .s(s)
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
        if (pqrs_ready) begin
          next = 1'b1;
          @(posedge aclk);
          next = 1'b0;
        end
      end
    end

endmodule 

