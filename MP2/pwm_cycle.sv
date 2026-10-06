// Pwm Cycle

module pwm_cycle #(
    parameter INC_DEC_INTERVAL = 2000, 
    parameter INC_DEC_MAX = 1000,            
    parameter PWM_INTERVAL = 1000,          
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX, //Increase and decrease by 1
    parameter STARTING_STATE = 0 //Starting state for each RGB led
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value
);

    // Define state variable values
    // Each value represents 60 degree to create trapezoid pattern
    // Increasing for 60, high for 120, decreasing for 60, low for 120, repeat
    localparam PWM_INC = 3'b001; 
    localparam PWM_CEIL1 = 3'b010;
    localparam PWM_CEIL2 = 3'b011;
    localparam PWM_DEC = 3'b100;
    localparam PWM_FLOOR1 = 3'b101;
    localparam PWM_FLOOR2 = 3'b110;

    // Declare state variables
    logic[2:0] current_state = STARTING_STATE;
    logic[2:0] next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition;

    // Sets correct initial brightness value
    initial begin
        if (STARTING_STATE == PWM_CEIL1 || STARTING_STATE == PWM_CEIL2 || STARTING_STATE == PWM_DEC)
            pwm_value = PWM_INTERVAL;
        else
            pwm_value = 0;
        time_to_transition = 0;
    end

        // Register the next state of the FSM
    always_ff @(posedge time_to_transition)
        current_state <= next_state;


    // Compute the next state of the FSM
    always_comb begin
        case (current_state)   
            PWM_FLOOR2:
                next_state = PWM_INC;
            default: 
                next_state = current_state + 1;
        endcase
    end

    // Counter for checking if its time to change pwm value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            PWM_INC:
                pwm_value <= pwm_value + INC_DEC_VAL;
            PWM_DEC:
                pwm_value <= pwm_value - INC_DEC_VAL;
            // The default setting to occur if the other cases are not met
            default:
                pwm_value <= pwm_value;
        endcase
    end

  // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
