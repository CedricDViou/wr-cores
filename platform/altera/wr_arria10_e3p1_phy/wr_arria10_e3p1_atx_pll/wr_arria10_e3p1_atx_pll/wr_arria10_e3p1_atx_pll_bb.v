
module wr_arria10_e3p1_atx_pll (
	pll_powerdown,
	pll_refclk0,
	tx_serial_clk,
	pll_locked,
	pll_cal_busy);	

	input		pll_powerdown;
	input		pll_refclk0;
	output		tx_serial_clk;
	output		pll_locked;
	output		pll_cal_busy;
endmodule
