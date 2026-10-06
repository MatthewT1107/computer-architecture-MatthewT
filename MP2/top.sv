`include "pwm_values.sv"

// RGB cycling top level module

module top #(
    parameter PWM_INTERVAL = 1000,      
    parameter INC_DEC_INTERVAL = 2000
)(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);
    // Give each LED a separate output
    logic pwm_out_r;
    logic pwm_out_g;
    logic pwm_out_b;

    // Give a starting state and output val for each RGB led
    // Similar to creating instances of a class
    pwm_values #(
        .PWM_INTERVAL   (PWM_INTERVAL),
        .INC_DEC_INTERVAL   (INC_DEC_INTERVAL),
        .STARTING_STATE (3)
    ) red (
        .clk            (clk), 
        .pwm_out      (pwm_out_r)

    );

    pwm_values #(   
        .PWM_INTERVAL       (PWM_INTERVAL),
        .INC_DEC_INTERVAL   (INC_DEC_INTERVAL),
        .STARTING_STATE (1)
    ) green (
        .clk            (clk), 
        .pwm_out        (pwm_out_g)
    );

    pwm_values #(
        .PWM_INTERVAL       (PWM_INTERVAL),
        .INC_DEC_INTERVAL   (INC_DEC_INTERVAL),
        .STARTING_STATE (5)
    ) blue (
        .clk            (clk), 
        .pwm_out        (pwm_out_b)

    );

    assign RGB_R = ~pwm_out_r;
    assign RGB_G = ~pwm_out_g;  
    assign RGB_B = ~pwm_out_b;

endmodule
