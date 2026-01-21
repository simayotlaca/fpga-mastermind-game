module top_module(
    input clk,
    input rst,
    
    input enterA,
    input enterB,
    input [2:0] letterIn,			 
    
    output [7:0] led,
    output a_out,b_out,c_out,d_out,e_out,f_out,g_out,p_out,
    output [3:0] an
);
  

    wire slow_clk;
    wire enterA_clean;
    wire enterB_clean;

    wire [7:0] game_led;
    wire [7:0] disp3, disp2, disp1, disp0;
    wire [7:0] seven;
    wire [3:0] segment;

    clk_divider clk_div (
        .clk_in(clk),
        .divided_clk(slow_clk)
    );

    debouncer dbA (
        .clk(slow_clk),
        .rst(~rst),
        .noisy_in(~enterA),
        .clean_out(enterA_clean)
    );

    debouncer dbB (
        .clk(slow_clk),
        .rst(~rst),
        .noisy_in(~enterB),
        .clean_out(enterB_clean)
    );


    mastermind game (
        .clk(slow_clk),
        .rst(~rst),
        .enterA(enterA_clean),
        .enterB(enterB_clean),
        .letterIn(letterIn),
        .LEDX(game_led),
        .disp3(disp3),
        .disp2(disp2),
        .disp1(disp1),
        .disp0(disp0)
    );

    assign led = game_led;

    ssd ssd_driver (
        .clk(clk),
        .disp0(disp0),
        .disp1(disp1),
        .disp2(disp2),
        .disp3(disp3),
        .seven(seven),
        .segment(segment)
    );

    assign a_out = ~seven[0];
    assign b_out = ~seven[1];
    assign c_out = ~seven[2];
    assign d_out = ~seven[3];
    assign e_out = ~seven[4];
    assign f_out = ~seven[5];
    assign g_out = ~seven[6];
    assign p_out = ~seven[7];

    assign an = segment;

endmodule
