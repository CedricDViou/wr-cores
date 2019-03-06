// wr_arria10_scu4_rst_ctl.v

// Generated using ACDS version 18.1 625

`timescale 1 ps / 1 ps
module wr_arria10_scu4_rst_ctl (
		input  wire       clock,              //              clock.clk
		input  wire [0:0] pll_locked,         //         pll_locked.pll_locked
		output wire [0:0] pll_powerdown,      //      pll_powerdown.pll_powerdown
		input  wire [0:0] pll_select,         //         pll_select.pll_select
		input  wire       reset,              //              reset.reset
		output wire [0:0] rx_analogreset,     //     rx_analogreset.rx_analogreset
		input  wire [0:0] rx_cal_busy,        //        rx_cal_busy.rx_cal_busy
		output wire [0:0] rx_digitalreset,    //    rx_digitalreset.rx_digitalreset
		input  wire [0:0] rx_is_lockedtodata, // rx_is_lockedtodata.rx_is_lockedtodata
		output wire [0:0] rx_ready,           //           rx_ready.rx_ready
		output wire [0:0] tx_analogreset,     //     tx_analogreset.tx_analogreset
		input  wire [0:0] tx_cal_busy,        //        tx_cal_busy.tx_cal_busy
		output wire [0:0] tx_digitalreset,    //    tx_digitalreset.tx_digitalreset
		output wire [0:0] tx_ready            //           tx_ready.tx_ready
	);

	altera_xcvr_reset_control #(
		.CHANNELS              (1),
		.PLLS                  (1),
		.SYS_CLK_IN_MHZ        (125),
		.SYNCHRONIZE_RESET     (1),
		.REDUCED_SIM_TIME      (1),
		.TX_PLL_ENABLE         (1),
		.T_PLL_POWERDOWN       (1000),
		.SYNCHRONIZE_PLL_RESET (0),
		.TX_ENABLE             (1),
		.TX_PER_CHANNEL        (0),
		.T_TX_ANALOGRESET      (70000),
		.T_TX_DIGITALRESET     (70000),
		.T_PLL_LOCK_HYST       (0),
		.EN_PLL_CAL_BUSY       (0),
		.RX_ENABLE             (1),
		.RX_PER_CHANNEL        (0),
		.T_RX_ANALOGRESET      (70000),
		.T_RX_DIGITALRESET     (4000)
	) xcvr_reset_control_0 (
		.clock              (clock),              //              clock.clk
		.reset              (reset),              //              reset.reset
		.pll_powerdown      (pll_powerdown),      //      pll_powerdown.pll_powerdown
		.tx_analogreset     (tx_analogreset),     //     tx_analogreset.tx_analogreset
		.tx_digitalreset    (tx_digitalreset),    //    tx_digitalreset.tx_digitalreset
		.tx_ready           (tx_ready),           //           tx_ready.tx_ready
		.pll_locked         (pll_locked),         //         pll_locked.pll_locked
		.pll_select         (pll_select),         //         pll_select.pll_select
		.tx_cal_busy        (tx_cal_busy),        //        tx_cal_busy.tx_cal_busy
		.rx_analogreset     (rx_analogreset),     //     rx_analogreset.rx_analogreset
		.rx_digitalreset    (rx_digitalreset),    //    rx_digitalreset.rx_digitalreset
		.rx_ready           (rx_ready),           //           rx_ready.rx_ready
		.rx_is_lockedtodata (rx_is_lockedtodata), // rx_is_lockedtodata.rx_is_lockedtodata
		.rx_cal_busy        (rx_cal_busy),        //        rx_cal_busy.rx_cal_busy
		.pll_cal_busy       (1'b0),               //        (terminated)
		.tx_manual          (1'b0),               //        (terminated)
		.rx_manual          (1'b0),               //        (terminated)
		.tx_digitalreset_or (1'b0),               //        (terminated)
		.rx_digitalreset_or (1'b0)                //        (terminated)
	);

endmodule
