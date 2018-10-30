onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/clk_sys_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rst_n_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/src_i
add wave -noupdate -group Streamers -expand /main/DUT/cmp_xwr_streamers/src_o
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/snk_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/snk_o
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tx_data_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tx_valid_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tx_dreq_o
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tx_last_p1_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tx_flush_p1_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_first_p1_o
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_last_p1_o
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_data_o
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_valid_o
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_dreq_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/clk_ref_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tm_time_valid_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tm_tai_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tm_cycles_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/link_ok_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/wb_slave_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/wb_slave_o
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/snmp_array_o
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/snmp_array_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tx_streamer_cfg_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_streamer_cfg_i
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/to_wb
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/from_wb
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/dbg_word
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/start_bit
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_data
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/wb_regs_slave_in
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/wb_regs_slave_out
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tx_frame
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/reset_time_tai
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/latency_acc
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/latency_cnt
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/sent_frame_cnt_out
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rcvd_frame_cnt_out
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/lost_frame_cnt_out
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/lost_block_cnt_out
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_valid
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_latency_valid
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_latency
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_lost_frames
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_lost_frames_cnt
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_lost_blocks
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_frame
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/tx_streamer_cfg
add wave -noupdate -group Streamers /main/DUT/cmp_xwr_streamers/rx_streamer_cfg
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/clk_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rst_n_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_data_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_valid_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_dreq_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_last_p1_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_flush_p1_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_data_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_valid_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_first_p1_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_dreq_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_last_p1_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_FrameHeader_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_RFmFramePayloads_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_RFsFramePayloads_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_PFramePayloads_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_Frame_valid_pX_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_Frame_typeID_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/ready_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_TransmitFrame_p1_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_FrameHeader_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_RFmFramePayloads_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_RFsFramePayloads_i
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_PFramePayloads_i
add wave -noupdate -group RFTransceiver -expand /main/DUT/cmp_RF/wb_slave_i
add wave -noupdate -group RFTransceiver -expand /main/DUT/cmp_RF/wb_slave_o
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/send_RF_frame
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/send_tick_p
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/wb_in_tx_ctrl
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/wb_in
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/wb_out
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_Frame_valid_p1
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_FrameHeader
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_RFmFramePayloads
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_RFsFramePayloads
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_PFramePayloads
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/s_out_state
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/output_cnt
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_data_time_valid
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_data_time_delay
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/rx_valid_pol_inv
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_period_value
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/sample_rate_cnt
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_data
add wave -noupdate -group RFTransceiver /main/DUT/cmp_RF/tx_valid
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/clk_sys_i
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/clk_ref_i
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rst_n_i
add wave -noupdate -group rxStreamer -expand /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/snk_i
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/snk_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/tm_time_valid_i
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/tm_tai_i
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/tm_cycles_i
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_first_p1_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_last_p1_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_data_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_valid_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_dreq_i
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_lost_p1_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_lost_blocks_p1_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_lost_frames_p1_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_lost_frames_cnt_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_latency_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_latency_valid_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_frame_p1_o
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_streamer_cfg_i
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fab
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fsm_in
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/state
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/ser_count
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/seq_no
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/seq_new
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/count
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/crc_match
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/crc_en
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/crc_en_masked
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/crc_restart
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/detect_escapes
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/is_escape
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_pending
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/pack_data
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_data
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_drop
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_accept
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_accept_d0
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_dvalid
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_sync
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_last
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/frames_lost
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/blocks_lost
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_dout
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_din
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_target_ts_en
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_target_ts
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/pending_write
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fab_dvalid_pre
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/tx_tag_cycles
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_tag_cycles
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/tx_tag_valid
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_tag_valid
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_tag_valid_stored
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/got_next_subframe
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/is_frame_seq_id
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/word_count
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/sync_seq_no
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_latency
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_latency_stored
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/rx_latency_valid
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/is_vlan
add wave -noupdate -group rxStreamer /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/fifo_last_int
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/clk_i
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/rst_n_i
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/arm_i
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/ts_origin_i
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/ts_latency_i
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/tm_time_valid_i
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/tm_tai_i
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/tm_cycles_i
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/match_o
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/ts_adjusted
add wave -noupdate -group FixedLatTsCompare /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/U_Compare/armed
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/rst_n_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/clk_sys_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/clk_ref_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/tm_time_valid_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/tm_tai_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/tm_cycles_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/d_data_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/d_last_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/d_sync_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/d_target_ts_en_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/d_target_ts_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/d_valid_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/d_drop_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/d_accept_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/d_req_o
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/rx_first_p1_o
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/rx_last_p1_o
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/rx_data_o
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/rx_valid_o
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/rx_dreq_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/rx_streamer_cfg_i
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/State
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/rst_n_ref
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/wr_full
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/fifo_rd
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/fifo_empty
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/dbuf_d
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/dbuf_q
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/fifo_q
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/dbuf_q_valid
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/dbuf_req
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/fifo_data
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/fifo_sync
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/fifo_last
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/fifo_target_ts_en
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/fifo_target_ts
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/fifo_we
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/delay_arm
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/delay_match
add wave -noupdate -group Dela /main/DUT/cmp_xwr_streamers/gen_rx/U_RX/U_FixLatencyDelay/delay_miss
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/clk_sys_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/clk_dmtd_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/clk_ref_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/clk_aux_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/clk_ext_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/clk_ext_mul_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/clk_ext_mul_locked_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/clk_ext_stopped_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/clk_ext_rst_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/pps_ext_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/rst_n_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/dac_hpll_load_p1_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/dac_hpll_data_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/dac_dpll_load_p1_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/dac_dpll_data_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_ref_clk_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_tx_data_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_tx_k_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_tx_disparity_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_tx_enc_err_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_rx_data_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_rx_rbclk_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_rx_k_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_rx_enc_err_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_rx_bitslide_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_rst_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_rdy_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_loopen_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_loopen_vec_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_tx_prbs_sel_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_sfp_tx_fault_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_sfp_los_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy_sfp_tx_disable_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy8_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy8_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy16_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/phy16_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/led_act_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/led_link_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/scl_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/scl_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/sda_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/sda_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/sfp_scl_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/sfp_scl_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/sfp_sda_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/sfp_sda_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/sfp_det_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/btn1_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/btn2_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/spi_sclk_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/spi_ncs_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/spi_mosi_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/spi_miso_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/uart_rxd_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/uart_txd_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/owr_pwren_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/owr_en_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/owr_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/slave_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/slave_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/aux_master_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/aux_master_i
add wave -noupdate -group WRC -expand /main/DUT/U_WR_CORE/wrf_src_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/wrf_src_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/wrf_snk_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/wrf_snk_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/timestamps_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/timestamps_ack_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/abscal_txts_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/abscal_rxts_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/fc_tx_pause_req_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/fc_tx_pause_delay_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/fc_tx_pause_ready_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/tm_link_up_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/tm_dac_value_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/tm_dac_wr_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/tm_clk_aux_lock_en_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/tm_clk_aux_locked_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/tm_time_valid_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/tm_tai_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/tm_cycles_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/pps_csync_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/pps_p_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/pps_led_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/rst_aux_n_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/aux_diag_i
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/aux_diag_o
add wave -noupdate -group WRC /main/DUT/U_WR_CORE/link_ok_o
add wave -noupdate -group Top /main/DUT/clk_20m_vcxo_i
add wave -noupdate -group Top /main/DUT/clk_dsp_1_i
add wave -noupdate -group Top /main/DUT/rst_dsp_1_n_i
add wave -noupdate -group Top /main/DUT/axi4l_aclk
add wave -noupdate -group Top /main/DUT/axi4l_aresetn
add wave -noupdate -group Top /main/DUT/axi4l_arvalid
add wave -noupdate -group Top /main/DUT/axi4l_awvalid
add wave -noupdate -group Top /main/DUT/axi4l_bready
add wave -noupdate -group Top /main/DUT/axi4l_rready
add wave -noupdate -group Top /main/DUT/axi4l_wlast
add wave -noupdate -group Top /main/DUT/axi4l_wvalid
add wave -noupdate -group Top /main/DUT/axi4l_araddr
add wave -noupdate -group Top /main/DUT/axi4l_awaddr
add wave -noupdate -group Top /main/DUT/axi4l_wdata
add wave -noupdate -group Top /main/DUT/axi4l_wstrb
add wave -noupdate -group Top /main/DUT/axi4l_arready
add wave -noupdate -group Top /main/DUT/axi4l_awready
add wave -noupdate -group Top /main/DUT/axi4l_bvalid
add wave -noupdate -group Top /main/DUT/axi4l_rlast
add wave -noupdate -group Top /main/DUT/axi4l_rvalid
add wave -noupdate -group Top /main/DUT/axi4l_wready
add wave -noupdate -group Top /main/DUT/axi4l_bresp
add wave -noupdate -group Top /main/DUT/axi4l_rresp
add wave -noupdate -group Top /main/DUT/axi4l_rdata
add wave -noupdate -group Top /main/DUT/clk_ctrl_conf_done_o
add wave -noupdate -group Top /main/DUT/clk_ctrl_en_man_clk_sel_o
add wave -noupdate -group Top /main/DUT/clk_ctrl_clk_sel_o
add wave -noupdate -group Top /main/DUT/clk_ctrl_en_auto_clk_sel_o
add wave -noupdate -group Top /main/DUT/clk_ctrl_rst_dsp_o
add wave -noupdate -group Top /main/DUT/clk_ctrl_clk_source_i
add wave -noupdate -group Top /main/DUT/clk_ctrl_rst_dsp_ctrl_i
add wave -noupdate -group Top /main/DUT/clk_ctrl_rst_dsp_i
add wave -noupdate -group Top /main/DUT/clk_ctrl_man_ready_i
add wave -noupdate -group Top /main/DUT/clk_ctrl_state_i
add wave -noupdate -group Top /main/DUT/clk_ctrl_ext_freq_i
add wave -noupdate -group Top /main/DUT/pci_access_i
add wave -noupdate -group Top /main/DUT/pci_link_up_i
add wave -noupdate -group Top /main/DUT/mmc_zone3_a1_flag_i
add wave -noupdate -group Top /main/DUT/mmc_zone3_a0_flag_i
add wave -noupdate -group Top /main/DUT/mmu_fpga_rxd_i
add wave -noupdate -group Top /main/DUT/mmu_fpga_txd_i
add wave -noupdate -group Top /main/DUT/adc_temp_sda_b
add wave -noupdate -group Top /main/DUT/adc_temp_scl_b
add wave -noupdate -group Top /main/DUT/adc1_d_p_i
add wave -noupdate -group Top /main/DUT/adc1_d_n_i
add wave -noupdate -group Top /main/DUT/adc2_d_p_i
add wave -noupdate -group Top /main/DUT/adc2_d_n_i
add wave -noupdate -group Top /main/DUT/adc3_d_p_i
add wave -noupdate -group Top /main/DUT/adc3_d_n_i
add wave -noupdate -group Top /main/DUT/adc4_d_p_i
add wave -noupdate -group Top /main/DUT/adc4_d_n_i
add wave -noupdate -group Top /main/DUT/adc5_d_p_i
add wave -noupdate -group Top /main/DUT/adc5_d_n_i
add wave -noupdate -group Top /main/DUT/dac_clk_p_o
add wave -noupdate -group Top /main/DUT/dac_clk_n_o
add wave -noupdate -group Top /main/DUT/dac_seliq_p_o
add wave -noupdate -group Top /main/DUT/dac_seliq_n_o
add wave -noupdate -group Top /main/DUT/dac_pd_h_o
add wave -noupdate -group Top /main/DUT/dac_torb_o
add wave -noupdate -group Top /main/DUT/dac_d_p_o
add wave -noupdate -group Top /main/DUT/dac_d_n_o
add wave -noupdate -group Top /main/DUT/rxtx_drive_o
add wave -noupdate -group Top /main/DUT/rxtx_data_o
add wave -noupdate -group Top /main/DUT/rxtx_data_i
add wave -noupdate -group Top /main/DUT/ilock_en_n_o
add wave -noupdate -group Top /main/DUT/ilock0_o
add wave -noupdate -group Top /main/DUT/ilock1_o
add wave -noupdate -group Top /main/DUT/si_rst_n_o
add wave -noupdate -group Top /main/DUT/si_int_c1b_i
add wave -noupdate -group Top /main/DUT/si_lol_i
add wave -noupdate -group Top /main/DUT/si_spi_ss_n_o
add wave -noupdate -group Top /main/DUT/si_spi_sclk_o
add wave -noupdate -group Top /main/DUT/si_spi_din_o
add wave -noupdate -group Top /main/DUT/si_spi_dout_i
add wave -noupdate -group Top /main/DUT/clk_muxab_sel_o
add wave -noupdate -group Top /main/DUT/clk_mux1a_sel_o
add wave -noupdate -group Top /main/DUT/clk_mux1b_sel_o
add wave -noupdate -group Top /main/DUT/clk_mux2a_sel_o
add wave -noupdate -group Top /main/DUT/clk_mux2b_sel_o
add wave -noupdate -group Top /main/DUT/mux_dac_sel_o
add wave -noupdate -group Top /main/DUT/clk_div_spi_sclk_o
add wave -noupdate -group Top /main/DUT/clk_div_spi_dio_b
add wave -noupdate -group Top /main/DUT/clk_div_spi_cs_n_o
add wave -noupdate -group Top /main/DUT/clk_div_status_i
add wave -noupdate -group Top /main/DUT/clk_div_function_o
add wave -noupdate -group Top /main/DUT/wr_dac_sync_n_o
add wave -noupdate -group Top /main/DUT/wr_dac_sclk_o
add wave -noupdate -group Top /main/DUT/wr_dac_din_o
add wave -noupdate -group Top /main/DUT/adc_sync_o
add wave -noupdate -group Top /main/DUT/adc_oeb_l_o
add wave -noupdate -group Top /main/DUT/adc_pdwn_o
add wave -noupdate -group Top /main/DUT/adc_spi_cs_l_o
add wave -noupdate -group Top /main/DUT/adc_spi_sclk_o
add wave -noupdate -group Top /main/DUT/adc_spi_dio_b
add wave -noupdate -group Top /main/DUT/mgt_ck_int_i
add wave -noupdate -group Top /main/DUT/mgt_ck_sda_b
add wave -noupdate -group Top /main/DUT/mgt_ck_scl_b
add wave -noupdate -group Top /main/DUT/sfp1_prsnt_n_i
add wave -noupdate -group Top /main/DUT/sfp2_prsnt_n_i
add wave -noupdate -group Top /main/DUT/sfp1_scl_b
add wave -noupdate -group Top /main/DUT/sfp1_sda_b
add wave -noupdate -group Top /main/DUT/rtm_usr_scl_b
add wave -noupdate -group Top /main/DUT/rtm_usr_sda_b
add wave -noupdate -group Top /main/DUT/mgtclk0_224_p_i
add wave -noupdate -group Top /main/DUT/mgtclk0_224_n_i
add wave -noupdate -group Top /main/DUT/mgtclk1_224_p_i
add wave -noupdate -group Top /main/DUT/mgtclk1_224_n_i
add wave -noupdate -group Top /main/DUT/sfp_tx_p_o
add wave -noupdate -group Top /main/DUT/sfp_tx_n_o
add wave -noupdate -group Top /main/DUT/sfp_rx_p_i
add wave -noupdate -group Top /main/DUT/sfp_rx_n_i
add wave -noupdate -group Top /main/DUT/led_serial_o
add wave -noupdate -group Top /main/DUT/fpga_watchdog_o
add wave -noupdate -group Top /main/DUT/flash_cs_n_o
add wave -noupdate -group Top /main/DUT/flash_sck_o
add wave -noupdate -group Top /main/DUT/flash_mosi_o
add wave -noupdate -group Top /main/DUT/flash_miso_i
add wave -noupdate -group Top /main/DUT/clk_adc_i
add wave -noupdate -group Top /main/DUT/rst_adc_i
add wave -noupdate -group Top /main/DUT/clk_dac_i
add wave -noupdate -group Top /main/DUT/rst_dac_i
add wave -noupdate -group Top /main/DUT/adc_or_ch1_o
add wave -noupdate -group Top /main/DUT/adc_data_ch1_o
add wave -noupdate -group Top /main/DUT/adc_or_ch2_o
add wave -noupdate -group Top /main/DUT/adc_data_ch2_o
add wave -noupdate -group Top /main/DUT/adc_or_ch3_o
add wave -noupdate -group Top /main/DUT/adc_data_ch3_o
add wave -noupdate -group Top /main/DUT/adc_or_ch4_o
add wave -noupdate -group Top /main/DUT/adc_data_ch4_o
add wave -noupdate -group Top /main/DUT/adc_or_ch5_o
add wave -noupdate -group Top /main/DUT/adc_data_ch5_o
add wave -noupdate -group Top /main/DUT/adc_or_ch6_o
add wave -noupdate -group Top /main/DUT/adc_data_ch6_o
add wave -noupdate -group Top /main/DUT/adc_or_ch7_o
add wave -noupdate -group Top /main/DUT/adc_data_ch7_o
add wave -noupdate -group Top /main/DUT/adc_or_ch8_o
add wave -noupdate -group Top /main/DUT/adc_data_ch8_o
add wave -noupdate -group Top /main/DUT/adc_or_ch9_o
add wave -noupdate -group Top /main/DUT/adc_data_ch9_o
add wave -noupdate -group Top /main/DUT/adc_or_ch10_o
add wave -noupdate -group Top /main/DUT/adc_data_ch10_o
add wave -noupdate -group Top /main/DUT/dac_i_data_i
add wave -noupdate -group Top /main/DUT/dac_q_data_i
add wave -noupdate -group Top /main/DUT/acq_ext_start_o
add wave -noupdate -group Top /main/DUT/acq_ext_ready_i
add wave -noupdate -group Top /main/DUT/acq_ext_error_i
add wave -noupdate -group Top /main/DUT/ilock_en_i
add wave -noupdate -group Top /main/DUT/ilock0_off_i
add wave -noupdate -group Top /main/DUT/ilock1_off_i
add wave -noupdate -group Top /main/DUT/led_u_state_i
add wave -noupdate -group Top /main/DUT/led_u_blink_i
add wave -noupdate -group Top /main/DUT/led_l2_state_i
add wave -noupdate -group Top /main/DUT/led_l2_blink_i
add wave -noupdate -group Top /main/DUT/tm_link_up_o
add wave -noupdate -group Top /main/DUT/tm_time_valid_o
add wave -noupdate -group Top /main/DUT/tm_tai_o
add wave -noupdate -group Top /main/DUT/tm_cycles_o
add wave -noupdate -group Top /main/DUT/pps_p_o
add wave -noupdate -group Top /main/DUT/tm_dac_value_o
add wave -noupdate -group Top /main/DUT/tm_dac_wr_o
add wave -noupdate -group Top /main/DUT/tm_clk_aux_lock_en_i
add wave -noupdate -group Top /main/DUT/tm_clk_aux_locked_o
add wave -noupdate -group Top /main/DUT/timestamps_ack_i
add wave -noupdate -group Top /main/DUT/abscal_txts_o
add wave -noupdate -group Top /main/DUT/abscal_rxts_o
add wave -noupdate -group Top /main/DUT/fc_tx_pause_req_i
add wave -noupdate -group Top /main/DUT/fc_tx_pause_delay_i
add wave -noupdate -group Top /main/DUT/fc_tx_pause_ready_o
add wave -noupdate -group Top /main/DUT/rfm_rx_valid_o
add wave -noupdate -group Top /main/DUT/rf_rx_rfm0_o
add wave -noupdate -group Top /main/DUT/trig_out_p_o
add wave -noupdate -group Top /main/DUT/trig_out_n_o
add wave -noupdate -group Top /main/DUT/tx_data
add wave -noupdate -group Top /main/DUT/tx_valid
add wave -noupdate -group Top /main/DUT/tx_dreq
add wave -noupdate -group Top /main/DUT/tx_last_p1
add wave -noupdate -group Top /main/DUT/tx_flush_p1
add wave -noupdate -group Top /main/DUT/rx_data
add wave -noupdate -group Top /main/DUT/rx_valid
add wave -noupdate -group Top /main/DUT/rx_first_p1
add wave -noupdate -group Top /main/DUT/rx_dreq
add wave -noupdate -group Top /main/DUT/rx_last_p1
add wave -noupdate -group Top /main/DUT/tx_ready
add wave -noupdate -group Top /main/DUT/tx_TransmitFrame_p1
add wave -noupdate -group Top /main/DUT/tx_FrameHeader
add wave -noupdate -group Top /main/DUT/tx_RFmFramePayloads
add wave -noupdate -group Top /main/DUT/tx_RFsFramePayloads
add wave -noupdate -group Top /main/DUT/tx_PFramePayloads
add wave -noupdate -group Top /main/DUT/rx_FrameHeader
add wave -noupdate -group Top /main/DUT/rx_RFmFramePayloads
add wave -noupdate -group Top /main/DUT/rx_RFsFramePayloads
add wave -noupdate -group Top /main/DUT/rx_PFramePayloads
add wave -noupdate -group Top /main/DUT/rx_Frame_valid_pX
add wave -noupdate -group Top /main/DUT/rx_Frame_typeID
add wave -noupdate -group Top /main/DUT/timestamps_o
add wave -noupdate -group Top /main/DUT/aux_diag_i
add wave -noupdate -group Top /main/DUT/aux_diag_o
add wave -noupdate -group Top /main/DUT/wrs_tx_cfg_i
add wave -noupdate -group Top /main/DUT/wrs_rx_cfg_i
add wave -noupdate -group Top /main/DUT/tm_time_valid
add wave -noupdate -group Top /main/DUT/tm_tai
add wave -noupdate -group Top /main/DUT/tm_cycles
add wave -noupdate -group Top /main/DUT/wrf_src_out
add wave -noupdate -group Top /main/DUT/wrf_src_in
add wave -noupdate -group Top /main/DUT/wrf_snk_out
add wave -noupdate -group Top /main/DUT/wrf_snk_in
add wave -noupdate -group Top /main/DUT/aux_master_out
add wave -noupdate -group Top /main/DUT/aux_master_in
add wave -noupdate -group Top /main/DUT/aux_rst_n
add wave -noupdate -group Top /main/DUT/aux_diag_in
add wave -noupdate -group Top /main/DUT/aux_diag_out
add wave -noupdate -group Top /main/DUT/link_ok
add wave -noupdate -group Top /main/DUT/trig_out
add wave -noupdate -group Top /main/DUT/cnx_slave_in
add wave -noupdate -group Top /main/DUT/cnx_slave_out
add wave -noupdate -group Top /main/DUT/cnx_master_in
add wave -noupdate -group Top /main/DUT/cnx_master_out
add wave -noupdate -group Top /main/DUT/rst_sys
add wave -noupdate -group Top /main/DUT/rst_sys_n
add wave -noupdate -group Top /main/DUT/gpio_out
add wave -noupdate -group Top /main/DUT/gpio_in
add wave -noupdate -group Top /main/DUT/gpio_oen
add wave -noupdate -group Top /main/DUT/gpio_oen_n
add wave -noupdate -group Top /main/DUT/s_fpga_ready
add wave -noupdate -group Top /main/DUT/led_fp_a
add wave -noupdate -group Top /main/DUT/led_fp_u
add wave -noupdate -group Top /main/DUT/led_fp_l1
add wave -noupdate -group Top /main/DUT/led_fp_l2
add wave -noupdate -group Top /main/DUT/rxtx_drive
add wave -noupdate -group Top /main/DUT/rxtx_data_out
add wave -noupdate -group Top /main/DUT/adc_data
add wave -noupdate -group Top /main/DUT/dac_data
add wave -noupdate -group Top /main/DUT/dac_hpll_load_p1
add wave -noupdate -group Top /main/DUT/dac_dpll_load_p1
add wave -noupdate -group Top /main/DUT/dac_hpll_data
add wave -noupdate -group Top /main/DUT/dac_dpll_data
add wave -noupdate -group Top /main/DUT/sfp_scl_out
add wave -noupdate -group Top /main/DUT/sfp_scl_in
add wave -noupdate -group Top /main/DUT/sfp_sda_out
add wave -noupdate -group Top /main/DUT/sfp_sda_in
add wave -noupdate -group Top /main/DUT/pps
add wave -noupdate -group Top /main/DUT/pps_led
add wave -noupdate -group Top /main/DUT/phy_tx_data
add wave -noupdate -group Top /main/DUT/phy_tx_k
add wave -noupdate -group Top /main/DUT/phy_tx_disparity
add wave -noupdate -group Top /main/DUT/phy_tx_enc_err
add wave -noupdate -group Top /main/DUT/phy_rx_data
add wave -noupdate -group Top /main/DUT/phy_rx_rbclk
add wave -noupdate -group Top /main/DUT/phy_rx_k
add wave -noupdate -group Top /main/DUT/phy_rx_enc_err
add wave -noupdate -group Top /main/DUT/phy_rx_bitslide
add wave -noupdate -group Top /main/DUT/phy_rst
add wave -noupdate -group Top /main/DUT/phy_loopen
add wave -noupdate -group Top /main/DUT/phy_rdy
add wave -noupdate -group Top /main/DUT/phy_tx_clk
add wave -noupdate -group Top /main/DUT/clk_dmtd
add wave -noupdate -group Top /main/DUT/led_act
add wave -noupdate -group Top /main/DUT/led_link
add wave -noupdate -group Top /main/DUT/clk_dmtd_fbout
add wave -noupdate -group Top /main/DUT/clk_dmtd_fbin
add wave -noupdate -group Top /main/DUT/clk_dmtd_bufin
add wave -noupdate -group Top /main/DUT/clk_20m_vcxo_buf
add wave -noupdate -group Top /main/DUT/dmtd_pll_locked
add wave -noupdate -group Top /main/DUT/wb_rf_frame_txrx_out
add wave -noupdate -group Top /main/DUT/wb_rf_frame_txrx_in
add wave -noupdate -group Top /main/DUT/zero
add wave -noupdate -group Top /main/DUT/sys_far_data_out
add wave -noupdate -group Top /main/DUT/sys_far_data_in
add wave -noupdate -group Top /main/DUT/sys_far_data_load
add wave -noupdate -group Top /main/DUT/sys_far_xfer
add wave -noupdate -group Top /main/DUT/sys_far_ready
add wave -noupdate -group Top /main/DUT/sys_far_cs
add wave -noupdate -group Top /main/DUT/rst_sys_n_i
add wave -noupdate -group Top /main/DUT/clk_sys_i
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/clk_sys_i
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/rst_sys_n_i
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/sys_far_data_o
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/sys_far_data_i
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/sys_far_data_load_i
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/sys_far_xfer_i
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/sys_far_ready_o
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/sys_far_cs_i
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/flash_spi_start
add wave -noupdate -group FlashCtl -expand /main/DUT/U_Flash/flash_spi_wdata
add wave -noupdate -group FlashCtl -expand /main/DUT/U_Flash/flash_mosi
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/flash_miso
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/flash_cs_n
add wave -noupdate -group FlashCtl /main/DUT/U_Flash/flash_sck
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/clk_sys_i
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/clk_rx_i
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rst_n_sys_i
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rst_n_rx_i
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/pcs_fab_i
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/pcs_fifo_almostfull_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/pcs_busy_i
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/src_wb_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/src_wb_i
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/fc_pause_p_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/fc_pause_quanta_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/fc_pause_prio_mask_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/fc_buffer_occupation_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rmon_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/regs_i
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/regs_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/pfilter_pclass_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/pfilter_drop_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/pfilter_done_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rtu_rq_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rtu_full_i
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rtu_rq_valid_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rtu_rq_abort_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/nice_dbg_o
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/fab_pipe
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/dreq_pipe
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/ematch_done
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/ematch_is_hp
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/ematch_is_pause
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/fc_pause_p
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/pfilter_pclass
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/pfilter_drop
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/pfilter_done
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/vlan_tclass
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/vlan_vid
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/vlan_tag_done
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/vlan_is_tagged
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/pcs_fifo_almostfull
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/mbuf_rd
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/mbuf_valid
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/mbuf_we
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/mbuf_pf_drop
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/mbuf_is_hp
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/mbuf_is_pause
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/mbuf_full
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/mbuf_pf_class
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rtu_rq_valid
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/stat_reg_mbuf_valid
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rxbuf_full
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rxbuf_dropped
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/src_wb_out
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/src_wb_cyc_d0
add wave -noupdate -group rxpath /main/DUT/U_WR_CORE/WRPC/U_Endpoint/U_Wrapped_Endpoint/U_Rx_Path/rst_n_rx_match_buff
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/clk_sys_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/clk_ref_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/rst_n_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/src_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/src_o
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tm_time_valid_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tm_tai_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tm_cycles_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/link_ok_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_data_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_valid_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_dreq_o
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_sync_o
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_last_p1_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_flush_p1_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_reset_seq_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_frame_p1_o
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_streamer_cfg_i
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_threshold_hit
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_timeout_hit
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_flush_latched
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_idle
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_last
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_we
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_full
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_empty
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_rd
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_empty_int
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_rd_int
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_rd_int_d
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_q_int
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_q_reg
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_q_valid
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_q
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_fifo_d
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/state
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/seq_no
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/count
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/ser_count
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/word_count
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/total_words
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/timeout_counter
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/pack_data
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/fsm_out
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/escaper
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/fab_src
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/fsm_escape
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/fsm_escape_enable
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/crc_en
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/crc_en_masked
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/crc_reset
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/crc_value
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_almost_empty
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tx_almost_full
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/buf_frame_count_inc_ref
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/buf_frame_count_dec_sys
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/buf_frame_count
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tag_cycles
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tag_valid
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/tag_valid_latched
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/link_ok_delay_cnt
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/link_ok_delay_expired
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/link_ok_delay_expired_ref
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/link_ok_ref
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/clk_data
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/rst_n_ref
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/stamper_pulse_a
add wave -noupdate -expand -group txstreamer /main/DUT/cmp_xwr_streamers/gen_tx/U_TX/rst_int_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {504373477 ps} 0}
configure wave -namecolwidth 254
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
configure wave -timelineunits ps
update
WaveRestoreZoom {250765517 ps} {2092064973 ps}
