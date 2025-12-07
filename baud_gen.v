// baud_gen.v
// Baud Rate Generator with Oversampling
// This module generates a single-cycle 'tick' pulse at a frequency of 
// (BAUD * OVERSAMPLE). It is used to synchronize UART RX/TX modules.

module baud_gen #(
    parameter integer CLOCK_FREQ = 50000000, // System clock frequency in Hz (e.g., 50 MHz)
    parameter integer BAUD       = 115200,   // Target UART baud rate
    parameter integer OVERSAMPLE = 16        // Oversampling factor (usually 16)
) (
    input  wire clk,      // System clock input
    input  wire rst_n,    // Active-low asynchronous reset
    output reg  tick      // Single-cycle output pulse (1 = tick event)
);

    // Calculate the number of system clock cycles required for one oversample tick.
    // Formula: System_Freq / (Baud_Rate * Oversample_Factor)
    localparam integer CLKS_PER_TICK = CLOCK_FREQ / (BAUD * OVERSAMPLE);

    // Calculate the required bit width for the counter based on CLKS_PER_TICK.
    // $clog2 calculates the ceiling log base 2.
    localparam integer CNT_WIDTH = $clog2(CLKS_PER_TICK > 0 ? CLKS_PER_TICK : 1);

    // Counter register
    reg [CNT_WIDTH-1:0] counter;

    // Main sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset: clear counter and output
            counter <= 0;
            tick    <= 1'b0;
        end else begin
            // Check if the counter has reached the limit
            // (CLKS_PER_TICK - 1 because we start counting from 0)
            if (counter == CLKS_PER_TICK - 1) begin
                counter <= 0;    // Reset counter
                tick    <= 1'b1; // Generate pulse
            end else begin
                counter <= counter + 1; // Increment counter
                tick    <= 1'b0;        // Keep output low
            end
        end
    end

endmodule
