// uart_rx.v
// UART Receiver with Oversampling

module uart_rx #(
    parameter integer OVERSAMPLE = 16
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick,
    input  wire        i_rx,
    output reg [7:0]   o_data,
    output reg         o_data_ready,
    output reg         o_frame_err
);

    parameter [1:0]
        RX_IDLE  = 2'b00,
        RX_START = 2'b01,
        RX_DATA  = 2'b10,
        RX_STOP  = 2'b11;

    reg [1:0] state;
    reg [4:0] oversample_cnt;
    reg [2:0] bit_index;
    reg [7:0] shift_reg;
    reg       rx_sync;
    reg       rx_sync_0;

    // Double-flop synchronizer
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync_0 <= 1'b1;
            rx_sync   <= 1'b1;
        end else begin
            rx_sync_0 <= i_rx;
            rx_sync   <= rx_sync_0;
        end
    end

    // Main UART RX State Machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= RX_IDLE;
            oversample_cnt <= 0;
            bit_index      <= 0;
            shift_reg      <= 8'h00;
            o_data         <= 8'h00;
            o_data_ready   <= 1'b0;
            o_frame_err    <= 1'b0;
        end else begin
            o_data_ready <= 1'b0;
            
            case (state)
                RX_IDLE: begin
                    o_frame_err <= 1'b0;
                    if (!rx_sync) begin
                        oversample_cnt <= 0;
                        state <= RX_START;
                    end
                end
                
                RX_START: begin
                    if (tick) begin
                        if (oversample_cnt == (OVERSAMPLE/2 - 1)) begin
                            oversample_cnt <= 0;
                            if (!rx_sync) begin
                                bit_index <= 0;
                                state <= RX_DATA;
                            end else begin
                                state <= RX_IDLE;
                            end
                        end else begin
                            oversample_cnt <= oversample_cnt + 1;
                        end
                    end
                end
                
                RX_DATA: begin
                    if (tick) begin
                        if (oversample_cnt == (OVERSAMPLE - 1)) begin
                            oversample_cnt <= 0;
                            
                            // ВИПРАВЛЕНО: Правильний порядок бітів
                            // LSB-first (як у UART TX)
                            shift_reg <= {rx_sync, shift_reg[7:1]};
                            
                            bit_index <= bit_index + 1;
                            if (bit_index == 7) state <= RX_STOP;
                        end else begin
                            oversample_cnt <= oversample_cnt + 1;
                        end
                    end
                end
                
                RX_STOP: begin
                    if (tick) begin
                        if (oversample_cnt == (OVERSAMPLE - 1)) begin
                            oversample_cnt <= 0;
                            o_data <= shift_reg;
                            o_data_ready <= 1'b1;
                            o_frame_err <= ~rx_sync;
                            state <= RX_IDLE;
                        end else begin
                            oversample_cnt <= oversample_cnt + 1;
                        end
                    end
                end
                
                default: state <= RX_IDLE;
            endcase
        end
    end

endmodule