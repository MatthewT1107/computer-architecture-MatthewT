`timescale 10ns/10ns
`include "top.sv"

module top_tb;

    parameter PWM_INTERVAL = 1000;

    logic clk = 0;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;
    real perc_r = 0.0;
    real perc_g = 0.0;
    real perc_b = 0.0;

    
    top # (
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk            (clk), 
        .RGB_R            (RGB_R),
        .RGB_G            (RGB_G),
        .RGB_B            (RGB_B)
    );

    initial begin
        $dumpfile("pwm_cycle.vcd");
        $dumpvars(0, top_tb);
        #200000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end
    
    always @(posedge clk) begin
        perc_r <= (u0.red.u1.pwm_value * 100.0) / PWM_INTERVAL;
        perc_g <= (u0.green.u1.pwm_value * 100.0) / PWM_INTERVAL;
        perc_b <= (u0.blue.u1.pwm_value * 100.0) / PWM_INTERVAL;
    end

endmodule

