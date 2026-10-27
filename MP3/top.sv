`include "ws2812b.sv"
`include "controller.sv"
`include "game_of_life.sv"
`include "color_cycle.sv"

// led_matrix top level module

module top(
    input logic     clk, 
    output logic    _48b, 
    output logic    _45a
);

    // Variables to configure color cycling
    logic [7:0] hue_red;
    logic [7:0] hue_green;
    logic [7:0] hue_blue;

    // Board 
    logic [63:0] board;
    logic update_board;
    
    // For updating game of life cycle
    logic [2:0] life_frame_count = 3'd0;
    logic life_update;

    logic [5:0] pixel;
    logic [4:0] frame;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;

    // Instance the WS2812B output driver
    ws2812b driver (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    // Instance the controller
    controller controller (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel), 
        .frame          (frame),
        .update_board   (update_board)
    );

    // Instance game of life logic
    game_of_life life (
        .clk        (clk),
        .update     (life_update),
        .board      (board)
    );

    // Instance color cycling
    color_cycle colors (
        .clk    (clk),
        .step   (update_board),
        .red    (hue_red),
        .green  (hue_green),
        .blue   (hue_blue)
    );

   
        // Life update true if update board signal and frame count signal sent
    assign life_update =
        update_board && (life_frame_count == 3'd7);
    
     // If the board update signal is sent, increase life frame count by one
    always_ff @(negedge clk) begin
        if (update_board)
            life_frame_count <= life_frame_count + 3'd1;
    end

    // 
    always_ff @(posedge clk) begin
        if (load_sreg) begin
            shift_reg <= board[pixel] ? {hue_green, hue_red, hue_blue} : 24'd0;
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end 
    end


    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
