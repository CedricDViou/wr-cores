
module wr_arria10_scu4_det_phy (
	tx_analogreset,
	tx_digitalreset,
	rx_analogreset,
	rx_digitalreset,
	tx_cal_busy,
	rx_cal_busy,
	tx_serial_clk0,
	rx_cdr_refclk0,
	tx_serial_data,
	rx_serial_data,
	rx_is_lockedtoref,
	rx_is_lockedtodata,
	tx_coreclkin,
	rx_coreclkin,
	tx_clkout,
	rx_clkout,
	tx_parallel_data,
	rx_parallel_data,
	unused_tx_parallel_data,
	unused_rx_parallel_data,
	rx_seriallpbken,
	tx_datak,
	rx_datak,
	rx_errdetect,
	rx_disperr,
	rx_runningdisp,
	rx_patterndetect,
	rx_syncstatus,
	rx_std_wa_patternalign,
	rx_std_bitslipboundarysel,
	reconfig_clk,
	reconfig_reset,
	reconfig_write,
	reconfig_read,
	reconfig_address,
	reconfig_writedata,
	reconfig_readdata,
	reconfig_waitrequest);	

	input	[0:0]	tx_analogreset;
	input	[0:0]	tx_digitalreset;
	input	[0:0]	rx_analogreset;
	input	[0:0]	rx_digitalreset;
	output	[0:0]	tx_cal_busy;
	output	[0:0]	rx_cal_busy;
	input	[0:0]	tx_serial_clk0;
	input		rx_cdr_refclk0;
	output	[0:0]	tx_serial_data;
	input	[0:0]	rx_serial_data;
	output	[0:0]	rx_is_lockedtoref;
	output	[0:0]	rx_is_lockedtodata;
	input	[0:0]	tx_coreclkin;
	input	[0:0]	rx_coreclkin;
	output	[0:0]	tx_clkout;
	output	[0:0]	rx_clkout;
	input	[7:0]	tx_parallel_data;
	output	[7:0]	rx_parallel_data;
	input	[118:0]	unused_tx_parallel_data;
	output	[113:0]	unused_rx_parallel_data;
	input	[0:0]	rx_seriallpbken;
	input		tx_datak;
	output		rx_datak;
	output		rx_errdetect;
	output		rx_disperr;
	output		rx_runningdisp;
	output		rx_patterndetect;
	output		rx_syncstatus;
	input	[0:0]	rx_std_wa_patternalign;
	output	[4:0]	rx_std_bitslipboundarysel;
	input	[0:0]	reconfig_clk;
	input	[0:0]	reconfig_reset;
	input	[0:0]	reconfig_write;
	input	[0:0]	reconfig_read;
	input	[9:0]	reconfig_address;
	input	[31:0]	reconfig_writedata;
	output	[31:0]	reconfig_readdata;
	output	[0:0]	reconfig_waitrequest;
endmodule
