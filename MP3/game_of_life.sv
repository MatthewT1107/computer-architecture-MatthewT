// Logic for computing how to change each cell in game of life
module game_of_life (
    input logic clk,
    input logic update,
    output logic [63:0] board

);
    integer row;
    integer col;
    integer neighbors;
    integer neighbor_row;
    integer neighbor_col;

    logic [63:0] next_board;
    
    // Read and load the initial grid
    logic [7:0] initial_grid [0:7];
    logic seed_loaded = 1'b0;

    initial begin
        $readmemh("initial_board.memh", initial_grid);
    end

    // Game of life logic
    always_comb begin
        next_board = 64'd0;
        // For each cell...
        for (int i = 0; i < 64; i++) begin
            // Find row and column
            row = i/8;
            col = i % 8; 
            // Neighbors of the cell
            neighbors = 0;
            // Checking neighbors using dr (change in row) and dc (change in column)  
            // Use nested if statements and for loops for each condition
            for (int dr = -1; dr <=1; dr++) begin
                for (int dc = -1; dc<=1; dc++) begin
                    // Calculate neighbor row and column considering cyclic boundary conditions
                    neighbor_row = (row + dr + 8) % 8;
                    neighbor_col = (col + dc + 8) % 8;
                    // Skip current cell
                    if (dr != 0 || dc != 0) begin
                            // Make sure neighbor is within the board
                            // Add 1 if neighbor is alive
                            if (board[neighbor_row * 8 + neighbor_col])
                                neighbors = neighbors + 1;
                                
                    end
                end
            end
        

            // If cell itself is alive
            if (board[i]) begin
                if (neighbors < 2 || neighbors > 3)
                    next_board[i] = 1'b0;
                else 
                    next_board[i] = 1'b1;

            end  

            // If cell is dead
            else begin
                if (neighbors == 3)
                    next_board[i] = 1'b1;
                else 
                    next_board[i] = 1'b0;
            end
        end
        end

    // Load the initial board
    always_ff @(negedge clk) begin
        if (!seed_loaded) begin
            // Load the file-backed seed before the first pixel is displayed.
            for (int i = 0; i < 8; i++) begin
                board[(7-i)*8 +: 8] <= initial_grid[i];
            end
            seed_loaded <= 1'b1;

        end
        // Update the current generation
        else if (update) begin
            board <= next_board;
        end
    end
    
endmodule