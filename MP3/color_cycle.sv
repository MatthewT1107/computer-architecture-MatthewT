module color_cycle (
    input  logic       clk,
    input  logic       step,
    output logic [7:0] red   = 8'd32,
    output logic [7:0] green = 8'd0,
    output logic [7:0] blue  = 8'd0
);

    logic [2:0] hue_phase = 3'd0;

    always_ff @(negedge clk) begin
    if (step) begin
        // Cases for hue_phase
        // Increase or decrease how much of each color there is until it is maxed
        // Then move to the next value of hue_phase and alter the next color
        case (hue_phase)
            3'd0:
                if (green == 8'd32)
                    hue_phase <= 3'd1;
                else
                    green <= green + 8'd4;

            3'd1:
                if (red == 8'd0)
                    hue_phase <= 3'd2;
                else
                    red <= red - 8'd4;

            3'd2:
                if (blue == 8'd32)
                    hue_phase <= 3'd3;
                else
                    blue <= blue + 8'd4;

            3'd3:
                if (green == 8'd0)
                    hue_phase <= 3'd4;
                else
                    green <= green - 8'd4;

            3'd4:
                if (red == 8'd32)
                    hue_phase <= 3'd5;
                else
                    red <= red + 8'd4;

            3'd5:
                if (blue == 8'd0)
                    hue_phase <= 3'd0;
                else
                    blue <= blue - 8'd4;
            // Begin with red
            default: begin
                red   <= 8'd32;
                green <= 8'd0;
                blue  <= 8'd0;
                hue_phase <= 3'd0;
            end
        endcase
    end
end

endmodule