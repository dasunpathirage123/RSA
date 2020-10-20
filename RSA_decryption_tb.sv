`timescale 1ns / 1ps
                                                                         
module RSA_decryption_tb ();
  localparam      CLK                 = 4;
  localparam      HALF_CLK            = CLK/2;
  localparam      WIDTH               = 512;

  reg                     aclk;
  reg                     aresetn;

  //reg         next;
 // reg         done;

  reg  [(WIDTH*4)-1:0]    In_Data_word;
  reg                     In_Data_Ready;
  reg                     New_RSA_Start;
  reg  [WIDTH-1:0  ]      Out_publicKey_exp;
  reg  [(WIDTH*4)-1:0]    Out_publicKey_mod;
  reg  [(WIDTH*4)-1:0]    Out_Data_word;
  reg                     Decrypt_done;


  reg  [(WIDTH*4)-1:0]    Data_word;
  reg  [WIDTH-1:  0  ]    Exp_publicKey;
  reg  [(WIDTH*4)-1:0]    Mod_pqrs;
  reg  [(WIDTH*4)-1:0]    Encrypted_Data;
  reg                     Encrypt_done;
  

  RSA_decryption 
#(
  .WIDTH(WIDTH)
)
RSA_decryption_dut
(
  .aclk(aclk),    // Clock
  .aresetn(aresetn),  // Asynchronous reset active low
  .In_Data_word(In_Data_word),
  .In_Data_Ready(In_Data_Ready),
  .New_RSA_Start(New_RSA_Start),
  .Out_publicKey_exp(Out_publicKey_exp),
  .Out_publicKey_mod(Out_publicKey_mod),
  .ready_to_encryption(ready_to_encryption),
  .Out_Data_word(Out_Data_word),
  .Decrypt_done(Decrypt_done)
);

RSA_encryption
#(
  .WIDTH(WIDTH)
)
RSA_encryption_dut
(
  .aclk(aclk),
  .aresetn(aresetn),
  .Data_word(Data_word),
  .Exp_publicKey(Exp_publicKey),
  .Mod_pqrs(Mod_pqrs),
  .Encrypted_Data(Encrypted_Data),
  .Encrypt_done(Encrypt_done)
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
    New_RSA_Start = 1'b1;
    @(posedge aclk);
    New_RSA_Start = 1'b0;
    wait(ready_to_encryption);
    Data_word = 512'd100;
    Exp_publicKey = Out_publicKey_exp;
    Mod_pqrs = Out_publicKey_mod;

    wait(Encrypt_done);
    In_Data_word = Encrypted_Data;
    In_Data_Ready =1'b1;
    wait(Decrypt_done);
    @(posedge aclk);
    New_RSA_Start = 1'b1;
    @(posedge aclk);
    New_RSA_Start = 1'b0;
    wait(ready_to_encryption);
    Data_word = 512'd101;
    Exp_publicKey = Out_publicKey_exp;
    Mod_pqrs = Out_publicKey_mod;

    wait(Encrypt_done);
    In_Data_word = Encrypted_Data;
    In_Data_Ready =1'b1;
 
    end // initial

    always @(posedge aclk) begin
      if(!aresetn) begin
        
      end else begin
        if (Decrypt_done) begin
          In_Data_Ready =1'b0;
        end
      end
    end

endmodule 

