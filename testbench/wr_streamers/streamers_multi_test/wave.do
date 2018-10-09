onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group CH0 /main/DUT/clk_sys_i
add wave -noupdate -expand -group CH0 /main/DUT/rst_sys_n_i
add wave -noupdate -expand -group CH0 /main/DUT/clk_tdc_i
add wave -noupdate -expand -group CH0 /main/DUT/rst_tdc_n_i
add wave -noupdate -expand -group CH0 /main/DUT/clk_cal_i
add wave -noupdate -expand -group CH0 /main/DUT/coarse_i
add wave -noupdate -expand -group CH0 /main/DUT/signal_i
add wave -noupdate -expand -group CH0 /main/DUT/slave_i
add wave -noupdate -expand -group CH0 /main/DUT/slave_o
add wave -noupdate -expand -group CH0 /main/DUT/calib_sel_d
add wave -noupdate -expand -group CH0 /main/DUT/muxed_signal
add wave -noupdate -expand -group CH0 /main/DUT/tdc_inv_input_signal
add wave -noupdate -expand -group CH0 /main/DUT/taps
add wave -noupdate -expand -group CH0 /main/DUT/taps_latched
add wave -noupdate -expand -group CH0 /main/DUT/ipolarity
add wave -noupdate -expand -group CH0 /main/DUT/polarity
add wave -noupdate -expand -group CH0 /main/DUT/polarity_d1
add wave -noupdate -expand -group CH0 /main/DUT/polarity_d2
add wave -noupdate -expand -group CH0 /main/DUT/detect_d1
add wave -noupdate -expand -group CH0 /main/DUT/raw
add wave -noupdate -expand -group CH0 /main/DUT/raw_d1
add wave -noupdate -expand -group CH0 /main/DUT/raw_d2
add wave -noupdate -expand -group CH0 /main/DUT/lut_rvalue
add wave -noupdate -expand -group CH0 /main/DUT/ro_en
add wave -noupdate -expand -group CH0 /main/DUT/count
add wave -noupdate -expand -group CH0 /main/DUT/tdc_slave_out
add wave -noupdate -expand -group CH0 /main/DUT/tdc_slave_in
add wave -noupdate -expand -group CH0 /main/DUT/regs_in
add wave -noupdate -expand -group CH0 /main/DUT/regs_out
add wave -noupdate -expand -group CH0 /main/DUT/calib_next_sample
add wave -noupdate -expand -group CH0 /main/DUT/calib_cur_sample
add wave -noupdate -expand -group CH0 /main/DUT/calib_step_d
add wave -noupdate -expand -group CH0 /main/DUT/calib_offset_d
add wave -noupdate -expand -group CH0 /main/DUT/calib_p
add wave -noupdate -expand -group CH0 /main/DUT/calib_rst_n
add wave -noupdate -expand -group CH0 /main/DUT/rst_tdc
add wave -noupdate -expand -group CH0 /main/DUT/ro_clk
add wave -noupdate -expand -group CH0 /main/DUT/detect
add wave -noupdate -expand -group CH0 /main/DUT/prev_taps_zero
add wave -noupdate -expand -group CH0 /main/DUT/taps_latched_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11994963738 fs} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 fs} {70811648 ps}
