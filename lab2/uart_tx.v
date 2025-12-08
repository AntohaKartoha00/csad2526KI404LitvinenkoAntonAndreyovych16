// uart_tx.v
// Simple UART Transmitter (8N1 format) using oversampling logic.
// 8 data bits, No parity, 1 Stop bit.

module uart_tx #(
    parameter integer OVERSAMPLE = 16   // Ticks per bit duration
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick,        // Oversample tick pulse from baud_gen
    input  wire [7:0]  i_data,      // Byte to transmit
    input  wire        i_send,      // Pulse high to start transmission
    output reg         o_tx,        // Serial output line (Idle = 1)
    output reg         o_busy,      // High while transmitting
    output reg         o_done       // Single-cycle pulse when transmission is complete
);

    // --- State Machine States ---
    parameter [1:0]
        TX_IDLE  = 2'b00,
        TX_START = 2'b01,
        TX_DATA  = 2'b10,
        TX_STOP  = 2'b11;

    reg [1:0] state;          // Current FSM state
    reg [3:0] oversample_cnt; // Counter for bit duration
    reg [2:0] bit_index;      // Tracks which bit (0-7) is being sent
    reg [7:0] shift_reg;      // Internal register for shifting data

    // --- Main Process ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous Reset
            state          <= TX_IDLE;
            o_tx           <= 1'b1; // Idle line is High
            o_busy         <= 1'b0;
            o_done         <= 1'b0;
            oversample_cnt <= 4'd0;
            bit_index      <= 3'd0;
            shift_reg      <= 8'h00;
        end else begin
            o_done <= 1'b0; // Default: clear done signal (creates a pulse)

            case (state)
                // 1. Idle State
                TX_IDLE: begin
                    o_tx   <= 1'b1; // Keep line High
                    o_busy <= 1'b0;
                    
                    if (i_send) begin
                        // Load data and prepare for transmission
                        shift_reg      <= i_data;
                        oversample_cnt <= 4'd0;
                        bit_index      <= 3'd0;
                        o_busy         <= 1'b1;
                        state          <= TX_START;
                    end
                end

                // 2. Start Bit State
                TX_START: begin
                    o_tx <= 1'b0; // Drive Start Bit (Low)
                    
                    if (tick) begin
                        // Wait for full bit duration
                        if (oversample_cnt == (OVERSAMPLE - 1)) begin
                            oversample_cnt <= 4'd0;
                            state <= TX_DATA;
                        end else begin
                            oversample_cnt <= oversample_cnt + 1'b1;
                        end
                    end
                end

                // 3. Data Bits State (LSB First)
                TX_DATA: begin
                    o_tx <= shift_reg[0]; // Output LSB
                    
                    if (tick) begin
                        if (oversample_cnt == (OVERSAMPLE - 1)) begin
                            oversample_cnt <= 4'd0;
                            
                            // Shift right to get the next bit
                            shift_reg <= {1'b0, shift_reg[7:1]}; 
                            
                            if (bit_index == 3'd7) begin
                                bit_index <= 3'd0;
                                state <= TX_STOP; // All 8 bits sent
                            end else begin
                                bit_index <= bit_index + 1'b1;
                            end
                        end else begin
                            oversample_cnt <= oversample_cnt + 1'b1;
                        end
                    end
                end

                // 4. Stop Bit State
                TX_STOP: begin
                    o_tx <= 1'b1; // Drive Stop Bit (High)
                    
                    if (tick) begin
                        // Wait for full stop bit duration
                        if (oversample_cnt == (OVERSAMPLE - 1)) begin
                            oversample_cnt <= 4'd0;
                            state          <= TX_IDLE;
                            o_busy         <= 1'b0;
                            o_done         <= 1'b1; // Signal completion
                        end else begin
                            oversample_cnt <= oversample_cnt + 1'b1;
                        end
                    end
                end

                default: state <= TX_IDLE;
            endcase
        end
    end

endmodule
