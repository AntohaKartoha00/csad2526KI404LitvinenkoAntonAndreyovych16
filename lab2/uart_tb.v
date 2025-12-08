`timescale 1ns / 1ps

module uart_tb;

    parameter CLOCK_FREQ = 50_000_000;
    parameter BAUD       = 115200;
    parameter OVERSAMPLE = 16;
    
    reg        clk;
    reg        rst_n;
    wire       tick;
    
    reg  [7:0] tx_data_in;
    reg        tx_start;
    wire       tx_line;
    wire       tx_busy;
    wire       tx_done;
    
    wire [7:0] rx_data_out;
    wire       rx_ready;
    wire       rx_frame_err;

    // Clock Generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Module Instantiation
    baud_gen #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD(BAUD),
        .OVERSAMPLE(OVERSAMPLE)
    ) u_baud (
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick)
    );

    uart_tx #(
        .OVERSAMPLE(OVERSAMPLE)
    ) u_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick),
        .i_data(tx_data_in),
        .i_send(tx_start),
        .o_tx(tx_line),
        .o_busy(tx_busy),
        .o_done(tx_done)
    );

    uart_rx #(
        .OVERSAMPLE(OVERSAMPLE)
    ) u_rx (
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick),
        .i_rx(tx_line),
        .o_data(rx_data_out),
        .o_data_ready(rx_ready),
        .o_frame_err(rx_frame_err)
    );

    // Helper Function for Bit Reversal (now optional)
    function [7:0] reverse_bits;
        input [7:0] in;
        integer i;
        begin
            for (i = 0; i < 8; i = i + 1) begin
                reverse_bits[7-i] = in[i];
            end
        end
    endfunction

    task send_and_verify;
        input [7:0] data_to_send;
        reg [7:0] expected_data;
        integer timeout;
        begin
            // Тепер реверс не потрібен, тому:
            expected_data = data_to_send;  // Без реверсу!
            
            $display("[Time %0t] Sending byte: 0x%h (Binary: %b)", 
                      $time, data_to_send, data_to_send);
            
            @(posedge clk);
            tx_data_in = data_to_send;
            tx_start   = 1'b1;
            @(posedge clk);
            tx_start   = 1'b0;
            
            timeout = 0;
            while (!rx_ready && timeout < 100000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end
            
            if (timeout >= 100000) begin
                $display("Error: RX Timeout!");
                $stop;
            end else begin
                if (rx_data_out === expected_data) begin
                    $display("[PASS] Sent: 0x%h, Received: 0x%h (Matches Expected)", 
                              data_to_send, rx_data_out);
                end else begin
                    $display("[FAIL] Sent: 0x%h, Expected: 0x%h, Got: 0x%h", 
                              data_to_send, expected_data, rx_data_out);
                end
            end
            
            if (rx_frame_err) $display("[WARN] Frame Error Detected!");
            #5000;
        end
    endtask

    // Main Test Sequence
    initial begin
        rst_n = 0;
        tx_start = 0;
        tx_data_in = 0;
        
        #200;
        rst_n = 1;
        $display("--- Starting UART Loopback Test (50 MHz Clock) ---");
        #200;
        
        send_and_verify(8'h81);
        send_and_verify(8'hA5);
        send_and_verify(8'h01);  // Тепер має бути 0x01, а не 0x80
        send_and_verify(8'hFF);
        
        $display("--- Test Completed Successfully ---");
        $stop;  // ВИПРАВЛЕНО: $stop замість $finish
    end

endmodule