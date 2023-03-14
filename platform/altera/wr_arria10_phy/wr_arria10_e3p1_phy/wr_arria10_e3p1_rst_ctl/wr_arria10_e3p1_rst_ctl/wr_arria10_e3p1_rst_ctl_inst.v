	wr_arria10_e3p1_rst_ctl u0 (
		.clock              (<connected-to-clock>),              //              clock.clk
		.reset              (<connected-to-reset>),              //              reset.reset
		.pll_powerdown      (<connected-to-pll_powerdown>),      //      pll_powerdown.pll_powerdown
		.tx_analogreset     (<connected-to-tx_analogreset>),     //     tx_analogreset.tx_analogreset
		.tx_digitalreset    (<connected-to-tx_digitalreset>),    //    tx_digitalreset.tx_digitalreset
		.tx_ready           (<connected-to-tx_ready>),           //           tx_ready.tx_ready
		.pll_locked         (<connected-to-pll_locked>),         //         pll_locked.pll_locked
		.pll_select         (<connected-to-pll_select>),         //         pll_select.pll_select
		.tx_cal_busy        (<connected-to-tx_cal_busy>),        //        tx_cal_busy.tx_cal_busy
		.rx_analogreset     (<connected-to-rx_analogreset>),     //     rx_analogreset.rx_analogreset
		.rx_digitalreset    (<connected-to-rx_digitalreset>),    //    rx_digitalreset.rx_digitalreset
		.rx_ready           (<connected-to-rx_ready>),           //           rx_ready.rx_ready
		.rx_is_lockedtodata (<connected-to-rx_is_lockedtodata>), // rx_is_lockedtodata.rx_is_lockedtodata
		.rx_cal_busy        (<connected-to-rx_cal_busy>)         //        rx_cal_busy.rx_cal_busy
	);
