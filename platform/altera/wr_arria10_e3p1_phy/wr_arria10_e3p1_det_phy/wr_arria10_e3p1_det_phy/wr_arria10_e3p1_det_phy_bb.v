
module wr_arria10_e3p1_det_phy (
	reconfig_write,
	reconfig_read,
	reconfig_address,
	reconfig_writedata,
	reconfig_readdata,
	reconfig_waitrequest,
	reconfig_clk,
	reconfig_reset,
	rx_analogreset,
	rx_cal_busy,
	rx_cdr_refclk0,
	rx_clkout,
	rx_coreclkin,
	rx_datak,
	rx_digitalreset,
	rx_disperr,
	rx_errdetect,
	rx_is_lockedtodata,
	rx_is_lockedtoref,
	rx_parallel_data,
	rx_patterndetect,
	rx_runningdisp,
	rx_serial_data,
	rx_seriallpbken,
	rx_std_bitslipboundarysel,
	rx_std_wa_patternalign,
	rx_syncstatus,
	tx_analogreset,
	tx_cal_busy,
	tx_clkout,
	tx_coreclkin,
	tx_datak,
	tx_digitalreset,
	tx_parallel_data,
	tx_serial_clk0,
	tx_serial_data,
	unused_rx_parallel_data,
	unused_tx_parallel_data);	

	input	[0:0]	reconfig_write;
	input	[0:0]	reconfig_read;
	input	[9:0]	reconfig_address;
	input	[31:0]	reconfig_writedata;
	output	[31:0]	reconfig_readdata;
	output	[0:0]	reconfig_waitrequest;
	input	[0:0]	reconfig_clk;
	input	[0:0]	reconfig_reset;
	input	[0:0]	rx_analogreset;
	output	[0:0]	rx_cal_busy;
	input		rx_cdr_refclk0;
	output	[0:0]	rx_clkout;
	input	[0:0]	rx_coreclkin;
	output		rx_datak;
	input	[0:0]	rx_digitalreset;
	output		rx_disperr;
	output		rx_errdetect;
	output	[0:0]	rx_is_lockedtodata;
	output	[0:0]	rx_is_lockedtoref;
	output	[7:0]	rx_parallel_data;
	output		rx_patterndetect;
	output		rx_runningdisp;
	input	[0:0]	rx_serial_data;
	input	[0:0]	rx_seriallpbken;
	output	[4:0]	rx_std_bitslipboundarysel;
	input	[0:0]	rx_std_wa_patternalign;
	output		rx_syncstatus;
	input	[0:0]	tx_analogreset;
	output	[0:0]	tx_cal_busy;
	output	[0:0]	tx_clkout;
	input	[0:0]	tx_coreclkin;
	input		tx_datak;
	input	[0:0]	tx_digitalreset;
	input	[7:0]	tx_parallel_data;
	input	[0:0]	tx_serial_clk0;
	output	[0:0]	tx_serial_data;
	output	[113:0]	unused_rx_parallel_data;
	input	[118:0]	unused_tx_parallel_data;
endmodule
