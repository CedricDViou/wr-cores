
module wr_arria10_e3p1_phy (
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
	rx_set_locktodata,
	rx_set_locktoref);	

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
	input	[119:0]	unused_tx_parallel_data;
	output	[119:0]	unused_rx_parallel_data;
	input	[0:0]	rx_set_locktodata;
	input	[0:0]	rx_set_locktoref;
endmodule
