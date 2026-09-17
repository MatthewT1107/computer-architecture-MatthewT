
module led_cycle (
    //Clock input
    input logic     clk,   // Clock input from the FPGA (12 MHz)
    //Outputs for active-low RGB LED
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B    // Output connected to the LED
);
     // Determines how long each color stays on for 12MHz clock. 
     // 12M a sec and 6 modes means interval must be 2M
    parameter BLINK_INTERVAL = 2000000;
     // Counter used to keep track of how many clock cycles have passed
    logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;
    // 1 bit signal communicating its time to switch colors
    logic timer_done;
    // When count is = to blink interval - 1, assign 1 to timer_done
    assign timer_done = (count == BLINK_INTERVAL - 1);
   

    // State definitions
    // 3 bits to represent 6 states
    localparam RED     = 3'b000;
    localparam YELLOW  = 3'b001;
    localparam GREEN   = 3'b010;
    localparam CYAN    = 3'b011;
    localparam BLUE    = 3'b100;
    localparam MAGENTA = 3'b101;

    // Stores the current state the cycle is in
    // Starts it off as red
    // logic [2:0] allows for 3 bits for the 6 states
    // Each state is a combination of 3 bits, which is how current and next state are set
    logic[2:0] current_state = RED;
    // Stores the next state the cycle will be in
    logic [2:0] next_state;

    // Register the next state of the cycle
    // always_ff: flip-flip/register behavior
    // Run when clock goes from 0 to 1
    // Nonblocking assignment (<=)
    always_ff @(posedge clk) begin
        current_state <= next_state;
    end

    // always_comb: continuously calculate output based on current inputs
    // Combinational Logic
    always_comb begin
        // Stay in state
        next_state = current_state;
        // If the timer has elapsed, check cases for color switching
        if (timer_done) begin
            // Set next state for each color
            case (current_state)

                RED:
                    next_state = YELLOW;

                YELLOW:
                    next_state = GREEN;

                GREEN:
                    next_state = CYAN;

                CYAN:
                    next_state = BLUE;

                BLUE:
                    next_state = MAGENTA;

                MAGENTA:
                     next_state = RED;

            endcase
        end
    end


    always_comb begin

    //All LEDs off initially

        RGB_R = 1'b1;
        RGB_G = 1'b1;
        RGB_B = 1'b1;
        case (current_state)

                RED:
                    RGB_R = 1'b0;

                YELLOW:
                    begin
                        RGB_R = 1'b0;
                        RGB_G = 1'b0;
                    end

                GREEN:
                    RGB_G = 1'b0;

                CYAN:
                    begin 
                        RGB_G = 1'b0;
                        RGB_B = 1'b0;
                    end 


                BLUE:
                   RGB_B = 1'b0;

                MAGENTA:
                    begin
                        RGB_B = 1'b0;
                        RGB_R = 1'b0;
                    end
            endcase
        end


    // Alter count based on the timer
    always_ff @(posedge clk) begin
      if (timer_done)
        count <= 0;
      else
        count <= count + 1;
    end

endmodule
