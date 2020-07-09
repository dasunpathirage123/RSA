`timescale 1ns / 1ps

module ext_euclidean_tb ();
  localparam      CLK                 = 4;
  localparam      HALF_CLK            = CLK/2;
  localparam      WIDTH               = 512;

  reg           aclk;
  reg           aresetn;
  reg [WIDTH-1:0] Multiplicative_Num;
  reg [WIDTH-1:0] Modular;
  reg [WIDTH-1:0] Multiplicative_Inv_Mod;
  reg [WIDTH-1:0] Multiplicative_Inv_Num;
  //reg             error;

  ext_euclidean
  #(
    .WIDTH (WIDTH)
  )
  ext_euclidean_dut
  (
    .aclk  (aclk ), 
    .aresetn(aresetn),
    .Multiplicative_Num(Multiplicative_Num),
    .Modular(Modular),
    .Multiplicative_Inv_Mod(Multiplicative_Inv_Mod),
    .Multiplicative_Inv_Num(Multiplicative_Inv_Num)
    //.error (error)
  );
  


    initial begin
        aclk                         = 0;
        forever begin      
            #(HALF_CLK)   aclk       = ~aclk;
        end
    end

    initial begin

    aresetn = 1'b0;
    Multiplicative_Num = 512'd3;
    Modular            = 512'd640;
    @(negedge aclk);
    aresetn = 1'b1;
    //#100
 
    end // initial

    

endmodule 

