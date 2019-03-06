
module wr_arria10_scu4_phy (
	rx_analogreset,
	rx_cal_busy,
	rx_cdr_refclk0,
	rx_clkout,
	rx_coreclkin,
	rx_digitalreset,
	rx_is_lockedtodata,
	rx_is_lockedtoref,
	rx_parallel_data,
	rx_serial_data,
	tx_analogreset,
	tx_cal_busy,
	tx_clkout,
	tx_coreclkin,
	tx_digitalreset,
	tx_parallel_data,
	tx_serial_clk0,
	tx_serial_data,
	unused_rx_parallel_data,
	unused_tx_parallel_data);	

	input	[0:0]	rx_analogreset;
	output	[0:0]	rx_cal_busy;
	input		rx_cdr_refclk0;
	output	[0:0]	rx_clkout;
	input	[0:0]	rx_coreclkin;
	input	[0:0]	rx_digitalreset;
	output	[0:0]	rx_is_lockedtodata;
	output	[0:0]	rx_is_lockedtoref;
	output	[7:0]	rx_parallel_data;
	input	[0:0]	rx_serial_data;
	input	[0:0]	tx_analogreset;
	output	[0:0]	tx_cal_busy;
	output	[0:0]	tx_clkout;
	input	[0:0]	tx_coreclkin;
	input	[0:0]	tx_digitalreset;
	input	[7:0]	tx_parallel_data;
	input	[0:0]	tx_serial_clk0;
	output	[0:0]	tx_serial_data;
	output	[119:0]	unused_rx_parallel_data;
	input	[119:0]	unused_tx_parallel_data;
endmodule
