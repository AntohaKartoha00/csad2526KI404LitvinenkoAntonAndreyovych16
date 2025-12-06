onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /uart_tb/clk
add wave -noupdate /uart_tb/rst_n
add wave -noupdate -radix binary /uart_tb/tick
add wave -noupdate -radix hexadecimal /uart_tb/tx_data_in
add wave -noupdate -radix binary /uart_tb/tx_line
add wave -noupdate -radix binary /uart_tb/tx_busy
add wave -noupdate -radix binary /uart_tb/tx_done
add wave -noupdate -radix hexadecimal /uart_tb/rx_data_out
add wave -noupdate -radix binary /uart_tb/rx_ready
add wave -noupdate -radix binary /uart_tb/rx_frame_err
add wave -noupdate -radix unsigned /uart_tb/u_tx/state
add wave -noupdate -radix unsigned /uart_tb/u_tx/bit_index
add wave -noupdate /uart_tb/u_tx/shift_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82475708 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 183
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {256650583 ps} {257549458 ps}
