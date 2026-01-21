module mastermind_tb();

    reg clk;
    reg rst;
    reg enterA;
    reg enterB;
    reg [2:0] letterIn;

    wire [7:0] LEDX;
    wire [6:0] SSD3;
    wire [6:0] SSD2;
    wire [6:0] SSD1;
    wire [6:0] SSD0;

    mastermind dut (
        .clk(clk),
        .rst(rst),
        .enterA(enterA),
        .enterB(enterB),
        .letterIn(letterIn),
        .LEDX(LEDX),
        .SSD3(SSD3),
        .SSD2(SSD2),
        .SSD1(SSD1),
        .SSD0(SSD0)
    );

    parameter HP = 5;       
    parameter FP = (2*HP);  

    always #HP clk = ~clk;

    initial begin
        $dumpfile("mastermind_tb.vcd");
        $dumpvars(0, mastermind_tb);

        clk = 0;
        rst = 1;
        enterA = 0;
        enterB = 0;
        letterIn = 0;

        #FP;
        rst = 0;
        #FP;
        rst = 1;
        #(FP*2);

        enterA = 1; #FP; enterA = 0;
        #(FP*10);

        letterIn = 3'b001; 
        enterA = 1; #FP; enterA = 0; #FP;
        
        letterIn = 3'b111;
        enterB = 1; #FP; enterB = 0; #FP;
        
        letterIn = 3'b010; 
        enterA = 1; #FP; enterA = 0; #FP;
        
        letterIn = 3'b000;
        enterA = 1; #FP; enterA = 0; #FP;
        
        letterIn = 3'b011; 
        enterA = 1; #FP; enterA = 0; #FP;
        
        letterIn = 3'b110; 
        enterA = 1; #FP; enterA = 0; #FP;

        letterIn = 0;
        #(FP*10);

        letterIn = 3'b001; enterB = 1; #FP; enterB = 0; #FP;
        letterIn = 3'b010; enterB = 1; #FP; enterB = 0; #FP;
        letterIn = 3'b011; enterB = 1; #FP; enterB = 0; #FP;
        letterIn = 3'b110; enterB = 1; #FP; enterB = 0; #FP;

        letterIn = 0;
        #(FP*12);

        #(FP*10);

        letterIn = 3'b100; 
        enterB = 1; #FP; enterB = 0; #FP;
        
        letterIn = 3'b010;
        enterA = 1; #FP; enterA = 0; #FP;
        
        letterIn = 3'b101; 
        enterB = 1; #FP; enterB = 0; #FP;
        
        letterIn = 3'b000;
        enterB = 1; #FP; enterB = 0; #FP;
        
        letterIn = 3'b111; 
        enterB = 1; #FP; enterB = 0; #FP;
        
        letterIn = 3'b001; 
        enterB = 1; #FP; enterB = 0; #FP;

        letterIn = 0;
        #(FP*12);

        letterIn = 3'b010; enterA = 1; #FP; enterA = 0; #FP;
        letterIn = 3'b010; enterA = 1; #FP; enterA = 0; #FP;
        letterIn = 3'b010; enterA = 1; #FP; enterA = 0; #FP;
        letterIn = 3'b010; enterA = 1; #FP; enterA = 0; #FP;
        
        letterIn = 0;
        #(FP*8);

        letterIn = 3'b011; enterA = 1; #FP; enterA = 0; #FP;
        letterIn = 3'b011; enterA = 1; #FP; enterA = 0; #FP;
        letterIn = 3'b011; enterA = 1; #FP; enterA = 0; #FP;
        letterIn = 3'b011; enterA = 1; #FP; enterA = 0; #FP;
        
        letterIn = 0;
        #(FP*8);

        letterIn = 3'b110; enterA = 1; #FP; enterA = 0; #FP;
        letterIn = 3'b110; enterA = 1; #FP; enterA = 0; #FP;
        letterIn = 3'b110; enterA = 1; #FP; enterA = 0; #FP;
        letterIn = 3'b110; enterA = 1; #FP; enterA = 0; #FP;
        
        letterIn = 0;
        #(FP*20);

        enterA = 1; #FP; enterA = 0;
        #(FP*5);

        $finish;
    end

endmodule