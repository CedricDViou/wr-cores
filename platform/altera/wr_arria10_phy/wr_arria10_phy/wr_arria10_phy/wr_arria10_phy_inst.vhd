	component wr_arria10_phy is
		port (
			rx_analogreset          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- rx_analogreset
			rx_cal_busy             : out std_logic_vector(0 downto 0);                      -- rx_cal_busy
			rx_cdr_refclk0          : in  std_logic                      := 'X';             -- clk
			rx_clkout               : out std_logic_vector(0 downto 0);                      -- clk
			rx_coreclkin            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk
			rx_digitalreset         : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- rx_digitalreset
			rx_is_lockedtodata      : out std_logic_vector(0 downto 0);                      -- rx_is_lockedtodata
			rx_is_lockedtoref       : out std_logic_vector(0 downto 0);                      -- rx_is_lockedtoref
			rx_parallel_data        : out std_logic_vector(7 downto 0);                      -- rx_parallel_data
			rx_serial_data          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- rx_serial_data
			tx_analogreset          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- tx_analogreset
			tx_cal_busy             : out std_logic_vector(0 downto 0);                      -- tx_cal_busy
			tx_clkout               : out std_logic_vector(0 downto 0);                      -- clk
			tx_coreclkin            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk
			tx_digitalreset         : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- tx_digitalreset
			tx_parallel_data        : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- tx_parallel_data
			tx_serial_clk0          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk
			tx_serial_data          : out std_logic_vector(0 downto 0);                      -- tx_serial_data
			rx_set_locktodata       : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- rx_set_locktodata
			rx_set_locktoref        : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- rx_set_locktoref
			unused_tx_parallel_data : in  std_logic_vector(119 downto 0) := (others => 'X'); -- unused_tx_parallel_data
			unused_rx_parallel_data : out std_logic_vector(119 downto 0)                     -- unused_rx_parallel_data
		);
	end component wr_arria10_phy;

	u0 : component wr_arria10_phy
		port map (
			rx_analogreset          => CONNECTED_TO_rx_analogreset,          --          rx_analogreset.rx_analogreset
			rx_cal_busy             => CONNECTED_TO_rx_cal_busy,             --             rx_cal_busy.rx_cal_busy
			rx_cdr_refclk0          => CONNECTED_TO_rx_cdr_refclk0,          --          rx_cdr_refclk0.clk
			rx_clkout               => CONNECTED_TO_rx_clkout,               --               rx_clkout.clk
			rx_coreclkin            => CONNECTED_TO_rx_coreclkin,            --            rx_coreclkin.clk
			rx_digitalreset         => CONNECTED_TO_rx_digitalreset,         --         rx_digitalreset.rx_digitalreset
			rx_is_lockedtodata      => CONNECTED_TO_rx_is_lockedtodata,      --      rx_is_lockedtodata.rx_is_lockedtodata
			rx_is_lockedtoref       => CONNECTED_TO_rx_is_lockedtoref,       --       rx_is_lockedtoref.rx_is_lockedtoref
			rx_parallel_data        => CONNECTED_TO_rx_parallel_data,        --        rx_parallel_data.rx_parallel_data
			rx_serial_data          => CONNECTED_TO_rx_serial_data,          --          rx_serial_data.rx_serial_data
			tx_analogreset          => CONNECTED_TO_tx_analogreset,          --          tx_analogreset.tx_analogreset
			tx_cal_busy             => CONNECTED_TO_tx_cal_busy,             --             tx_cal_busy.tx_cal_busy
			tx_clkout               => CONNECTED_TO_tx_clkout,               --               tx_clkout.clk
			tx_coreclkin            => CONNECTED_TO_tx_coreclkin,            --            tx_coreclkin.clk
			tx_digitalreset         => CONNECTED_TO_tx_digitalreset,         --         tx_digitalreset.tx_digitalreset
			tx_parallel_data        => CONNECTED_TO_tx_parallel_data,        --        tx_parallel_data.tx_parallel_data
			tx_serial_clk0          => CONNECTED_TO_tx_serial_clk0,          --          tx_serial_clk0.clk
			tx_serial_data          => CONNECTED_TO_tx_serial_data,          --          tx_serial_data.tx_serial_data
			rx_set_locktodata       => CONNECTED_TO_rx_set_locktodata,       --       rx_set_locktodata.rx_set_locktodata
			rx_set_locktoref        => CONNECTED_TO_rx_set_locktoref,        --        rx_set_locktoref.rx_set_locktoref
			unused_tx_parallel_data => CONNECTED_TO_unused_tx_parallel_data, -- unused_tx_parallel_data.unused_tx_parallel_data
			unused_rx_parallel_data => CONNECTED_TO_unused_rx_parallel_data  -- unused_rx_parallel_data.unused_rx_parallel_data
		);

