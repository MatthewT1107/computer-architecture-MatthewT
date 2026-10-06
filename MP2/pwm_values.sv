`include "pwm_cycle.sv"
`include "pwm.sv"


module pwm_values #(
    parameter PWM_INTERVAL = 1000,
    parameter INC_DEC_INTERVAL = 2000,
    parameter STARTING_STATE = 0
)(
    input logic     clk, 
    output logic    pwm_out
);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value;

    // Use the values from pwm_cycle.sv
    pwm_cycle #(
        .PWM_INTERVAL   (PWM_INTERVAL),
        .INC_DEC_INTERVAL (INC_DEC_INTERVAL),
        .INC_DEC_MAX (PWM_INTERVAL),
        .STARTING_STATE (STARTING_STATE)
    // Sync clk and pwm_value in pwm_cycle to the one in pwm_values
    ) u1 (
        .clk            (clk), 
        .pwm_value      (pwm_value)
    );

    
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (pwm_value), 
        .pwm_out        (pwm_out)
    );

endmodule
