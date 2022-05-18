	component wr_arria10_e3p1_cmu_pll is
		port (
			pll_cal_busy  : out std_logic;        -- pll_cal_busy
			pll_locked    : out std_logic;        -- pll_locked
			pll_powerdown : in  std_logic := 'X'; -- pll_powerdown
			pll_refclk0   : in  std_logic := 'X'; -- clk
			tx_serial_clk : out std_logic         -- clk
		);
	end component wr_arria10_e3p1_cmu_pll;

	u0 : component wr_arria10_e3p1_cmu_pll
		port map (
			pll_cal_busy  => CONNECTED_TO_pll_cal_busy,  --  pll_cal_busy.pll_cal_busy
			pll_locked    => CONNECTED_TO_pll_locked,    --    pll_locked.pll_locked
			pll_powerdown => CONNECTED_TO_pll_powerdown, -- pll_powerdown.pll_powerdown
			pll_refclk0   => CONNECTED_TO_pll_refclk0,   --   pll_refclk0.clk
			tx_serial_clk => CONNECTED_TO_tx_serial_clk  -- tx_serial_clk.clk
		);

