
module wr_arria10_tx_pll (
	pll_refclk0,
	pll_powerdown,
	pll_locked,
	tx_serial_clk,
	pll_cal_busy);	

	input		pll_refclk0;
	input		pll_powerdown;
	output		pll_locked;
	output		tx_serial_clk;
	output		pll_cal_busy;
endmodule
