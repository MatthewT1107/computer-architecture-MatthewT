// NOTICE: Most comments on this code module are AI-Generated to help me check my understanding. 
// The module itself is identical to the example code
module controller (
    input logic clk, 
    output logic load_sreg,        // Signal to load pixel color data into shift register
    output logic transmit_pixel,   // Signal indicating pixel data should be transmitted
    output logic [5:0] pixel,      // Current pixel index (0-63) Each individual pixel has index 0-63 indicated by pixel 6 bit logic
    output logic [4:0] frame,       // Current frame index (0-31)
    output logic update_board
);  

    // ============================================================
    // STATE DEFINITIONS
    // ============================================================

    // Main FSM has two states:
    // TRANSMIT_FRAME: Send data for all 64 pixels
    // IDLE: Wait between frames to maintain the desired frame rate

    localparam TRANSMIT_FRAME       = 1'b0;
    localparam IDLE                 = 1'b1;

    // Each pixel transmission has three phases:
    // READ_CH_VALS: Allow color channel values to be read
    // LOAD_SREG: Load the color values into the shift register
    // TRANSMIT_PIXEL: Send the 24 bits of pixel data

    // One-hot encoding: each phase has a different bit set to 1
    localparam [2:0] READ_CH_VALS   = 3'b001;
    localparam [2:0] LOAD_SREG      = 3'b010;
    localparam [2:0] TRANSMIT_PIXEL = 3'b100;

    // ============================================================
    // TIMING CONSTANTS
    // ============================================================

    // Each pixel contains 24 bits, and each bit takes 15 clock cycles.
    // Total transmission time for one pixel = 24 * 15 = 360 cycles
    localparam [8:0] TRANSMIT_CYCLES = 9'd360;

    // Number of clock cycles to wait between frames.
    // 375000 cycles per frame at 12 MHz gives 32 frames per second.
    // Subtract time spent transmitting 64 pixels, including
    // two additional cycles per pixel for reading and loading.


    // Approximately 32 display frames per second at 12 MHz.
    localparam [19:0] IDLE_CYCLES = 20'd351832;
    
    // ============================================================
    // STATE REGISTERS
    // ============================================================

    // Current and next states for the main FSM.
    // Start by transmitting a frame.
    logic state = TRANSMIT_FRAME;
    logic next_state;

    // Current and next phases for transmitting an individual pixel.
    // Start by reading the color channel values.
    logic [2:0] transmit_phase = READ_CH_VALS;
    logic [2:0] next_transmit_phase;

    // ============================================================
    // COUNTERS
    // ============================================================

    // Tracks which of the 64 pixels is currently being transmitted.
    // 6 bits allow values from 0 to 63.
    logic [5:0] pixel_counter = 6'd0;

    // Tracks the current frame number.
    // 5 bits allow values from 0 to 31.
    logic [4:0] frame_counter = 5'd0;

    // Counts clock cycles during an individual pixel transmission.
    // 9 bits are enough to count up to 360.
    logic [8:0] transmit_counter = 9'd0;

    // Counts clock cycles spent waiting between frames.
    // 20 bits are enough to hold the idle cycle count.
    logic [19:0] idle_counter = 20'd0;

    // Flags indicating when transmission or idle timing is complete.
    logic transmit_pixel_done;
    logic idle_done;

    // These signals become 1 when their respective counters
    // reach the final cycle.
    // Subtract 1 because counting begins at zero.
    assign transmit_pixel_done = (transmit_counter == TRANSMIT_CYCLES - 1);
    assign idle_done = (idle_counter == IDLE_CYCLES - 1);

    // ============================================================
    // STATE REGISTER UPDATE
    // ============================================================

    // On every falling edge of the clock, update both FSMs
    // to their calculated next states.
    //
    // always_ff represents sequential logic (flip-flops).
    // Nonblocking assignments (<=) update registers together.

    always_ff @(negedge clk) begin
        state <= next_state;
        transmit_phase <= next_transmit_phase;
    end

    // ============================================================
    // MAIN FSM: FRAME TRANSMISSION VS IDLE
    // ============================================================

    // Combinational logic determines the next main state
    // based on the current state and counter values.

    always_comb begin

        // Default to unknown to help identify invalid states.
        next_state = 1'bx;

        unique case (state)

            TRANSMIT_FRAME:
                // Remain in TRANSMIT_FRAME until the final pixel
                // (pixel 63) has completed transmission.
                if ((pixel_counter == 6'd63) && (transmit_pixel_done))
                    next_state = IDLE;
                else
                    next_state = TRANSMIT_FRAME;

            IDLE:
                // Stay idle until the required number of
                // idle clock cycles has elapsed.
                if (idle_done)
                    next_state = TRANSMIT_FRAME;
                else
                    next_state = IDLE;

        endcase
    end

    // ============================================================
    // PIXEL TRANSMISSION FSM
    // ============================================================

    // Controls the three phases required to transmit each pixel.
    //
    // Sequence:
    // READ_CH_VALS -> LOAD_SREG -> TRANSMIT_PIXEL
    //
    // Once transmission finishes, return to READ_CH_VALS
    // to begin preparing the next pixel.

    always_comb begin

        // Default to reading color channel values.
        // This also resets the phase when not transmitting a frame.
        next_transmit_phase = READ_CH_VALS;

        // Only progress through transmission phases while
        // the main FSM is in TRANSMIT_FRAME.
        if (state == TRANSMIT_FRAME) begin

            case (transmit_phase)

                READ_CH_VALS:
                    // After allowing color values to be read,
                    // move to the shift register loading phase.
                    next_transmit_phase = LOAD_SREG;

                LOAD_SREG:
                    // After loading the shift register,
                    // begin transmitting the pixel data.
                    next_transmit_phase = TRANSMIT_PIXEL;

                TRANSMIT_PIXEL:
                    // Continue transmitting until the required
                    // 360 clock cycles have completed.
                    //
                    // If done, return to READ_CH_VALS.
                    // Otherwise, remain in TRANSMIT_PIXEL.
                    next_transmit_phase = transmit_pixel_done ? READ_CH_VALS : TRANSMIT_PIXEL;

            endcase
        end
    end

    // ============================================================
    // PIXEL COUNTER
    // ============================================================

    // Increment the pixel counter whenever a pixel finishes
    // transmitting while the main FSM is transmitting a frame.
    //
    // Because pixel_counter is 6 bits, incrementing past 63
    // automatically wraps it back to 0 for the next frame.

    always_ff @(negedge clk) begin
        if ((state == TRANSMIT_FRAME) && transmit_pixel_done) begin
            pixel_counter <= pixel_counter + 1;
        end
    end

    // ============================================================
    // FRAME COUNTER
    // ============================================================

    // Increment the frame counter whenever the idle period
    // reaches its final clock cycle.
    //
    // This means a new frame number is assigned at the end
    // of the waiting period, before the next frame begins.
    //
    // Since frame_counter is 5 bits, it wraps from 31 to 0.

    always_ff @(negedge clk) begin
        if (idle_done) begin
            frame_counter <= frame_counter + 1;
        end
    end

    // ============================================================
    // PIXEL TRANSMISSION TIMER
    // ============================================================

    // Counts how many clock cycles have passed during the
    // TRANSMIT_PIXEL phase.
    //
    // The counter increments every falling clock edge while
    // transmitting and resets to zero during the other phases.

    always_ff @(negedge clk) begin
        if (transmit_phase == TRANSMIT_PIXEL) begin
            transmit_counter <= transmit_counter + 1;
        end
        else begin
            transmit_counter <= 9'd0;
        end
    end

    // ============================================================
    // IDLE TIMER
    // ============================================================

    // Counts clock cycles while the main FSM is in IDLE.
    //
    // When the controller returns to TRANSMIT_FRAME,
    // reset the idle counter to zero for the next frame.

    always_ff @(negedge clk) begin
        if (state == IDLE) begin
            idle_counter <= idle_counter + 1;
        end
        else begin
            idle_counter <= 23'd0;
        end
    end

    // ============================================================
    // OUTPUT ASSIGNMENTS
    // ============================================================

    // Expose the current pixel and frame counters
    // to other modules in the system.
    assign pixel = pixel_counter;
    assign frame = frame_counter;

    // Assert load_sreg when the controller is in LOAD_SREG.
    // This tells the shift register to load new pixel data.
    assign load_sreg = (transmit_phase == LOAD_SREG);

    // Assert transmit_pixel during TRANSMIT_PIXEL.
    // This tells the transmission hardware to send pixel data.
    assign transmit_pixel = (transmit_phase == TRANSMIT_PIXEL);
    // Generation update signal
    assign update_board = (state == IDLE) && idle_done;
endmodule
