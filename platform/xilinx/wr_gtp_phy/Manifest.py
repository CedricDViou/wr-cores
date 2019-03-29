files = [
  "gtp_bitslide.vhd",
];

if (syn_device[0:4].upper()=="XC6S"): # Spartan6
	files.extend(["spartan6/wr_gtp_phy_spartan6.vhd",
                "spartan6/whiterabbitgtp_wrapper_tile_spartan6.vhd",
                "spartan6/gtp_phase_align.vhd"])
elif (syn_device[0:4].upper()=="XC6V"): # Virtex6
	files.extend(["virtex6/wr_gtx_phy_virtex6.vhd",
                "virtex6/whiterabbitgtx_wrapper_gtx.vhd",
                "virtex6/gtp_phase_align_virtex6.vhd",
                "virtex6/gtx_reset.vhd",
		"virtex6-low-phase-drift/gtx_comma_detect_lp.vhd",
		"virtex6-low-phase-drift/gtx_tx_reset_lp.vhd",
		"virtex6-low-phase-drift/whiterabbitgtx_wrapper_gtx_lp.vhd",
		"virtex6-low-phase-drift/wr_gtx_phy_virtex6_lp.vhd"])

elif (syn_device[0:4].upper()=="XC5V"): # Virtex5
	files.extend(["virtex5/wr_gtp_phy_virtex5.vhd",
                "virtex5/whiterabbit_gtp_wrapper_tile_virtex5.vhd",
                "spartan6/gtp_phase_align.vhd",
                "virtex5/v5_gtp_align_detect.vhd"])
elif (syn_device[0:4].upper()=="XC7A"): # Family 7 GTP (Artix7)
	files.extend(["family7-gtp/wr_gtp_phy_family7.vhd",
                "family7-gtp/whiterabbit_gtpe2_channel_wrapper.vhd",
                "family7-gtp/whiterabbit_gtpe2_channel_wrapper_gt.vhd",
                "family7-gtp/whiterabbit_gtpe2_channel_wrapper_gtrxreset_seq.vhd" ]);
elif (syn_device[0:4].upper()=="XC7K" or # Family 7 GTX (Kintex7 and Virtex7 585, 2000, X485)
      syn_device[0:7].upper()=="XC7V585" or
      syn_device[0:8].upper()=="XC7V2000" or
      syn_device[0:8].upper()=="XC7VX485"):
	files.extend([
#		"family7-gtx/wr_gtx_phy_family7.vhd",
#                "family7-gtx/whiterabbit_gtxe2_channel_wrapper_gt.vhd",
		"kintex7-lp/gtx_comma_detect_lp.vhd",
		"kintex7-lp/wr_gtx_phy_kintex7_lp.vhd",
		"kintex7-lp/gtxe2_lp.vhd"]);
elif (syn_device[0:4].upper()=="XC7V"): # Family 7 GTH (other Virtex7 devices)
	files.extend(["family7-gth/wr_gth_phy_family7.vhd",
                "whiterabbit_gthe2_channel_wrapper_gt.vhd",
                "whiterabbit_gthe2_channel_wrapper_gtrxreset_seq.vhd",
                "whiterabbit_gthe2_channel_wrapper_sync_block.vhd" ]);
elif (syn_device[0:4].upper()=="XCKU"): # Kintex Ultrascale GTH
	files.extend(["family7-gthe3/wr_gthe3_phy_family7.vhd",
                      "family7-gthe3/wr_gthe3_reset.vhd",
                      "family7-gthe3/wr_gthe3_rx_buffer_bypass.vhd",
                      "family7-gthe3/wr_gthe3_tx_buffer_bypass.vhd",
                      "family7-gthe3/wr_gthe3_wrapper.vhd",
                      "family7-gthe3/gc_reset_synchronizer.vhd" ]);
elif (syn_device[0:4].upper()=="XCZU"): # Zynq Ultrascale GTH
	files.extend(["family7-gthe4/wr_gthe4_phy_family7.vhd",
                      "family7-gthe4/wr_gthe4_phy_family7_xilinx_ip.vhd",
                      "family7-gthe4/wr_gthe4_reset.vhd",
                      "family7-gthe4/wr_gthe4_rx_buffer_bypass.vhd",
                      "family7-gthe4/wr_gthe4_tx_buffer_bypass.vhd",
                      "family7-gthe4/wr_gthe4_wrapper.vhd",
                      "family7-gthe4/gc_reset_synchronizer.vhd",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_bit_sync.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_tx.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_rx.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtwiz_reset.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_tx.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtwiz_userdata_rx.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtye4_cpll_cal.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gte4_drp_arb.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_reset_inv_sync.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_tx.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtye4_delay_powergood.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtwiz_userclk_tx.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_rx.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gthe3_cpll_cal.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gthe4_cal_freqcnt.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gthe4_delay_powergood.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gthe4_cpll_cal.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtwiz_userclk_rx.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_reset_sync.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtwiz_userdata_tx.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_rx.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gthe3_cal_freqcnt.v",
"family7-gthe4/gthe4/common/gtwizard_ultrascale_v1_7_gtye4_cal_freqcnt.v",
"family7-gthe4/gthe4/synth/gtwizard_ultrascale_2.v",
"family7-gthe4/gthe4/synth/gtwizard_ultrascale_2_gtwizard_top.v",
"family7-gthe4/gthe4/synth/gtwizard_ultrascale_2_gthe4_channel_wrapper.v",
"family7-gthe4/gthe4/synth/gtwizard_ultrascale_2_gtwizard_gthe4.v",
"family7-gthe4/gthe4/synth/gtwizard_ultrascale_v1_7_gthe4_channel.v"
]);
