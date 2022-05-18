	component wr_arria10_scu4_det_phy is
		port (
			tx_analogreset            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- tx_analogreset
			tx_digitalreset           : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- tx_digitalreset
			rx_analogreset            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- rx_analogreset
			rx_digitalreset           : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- rx_digitalreset
			tx_cal_busy               : out std_logic_vector(0 downto 0);                      -- tx_cal_busy
			rx_cal_busy               : out std_logic_vector(0 downto 0);                      -- rx_cal_busy
			tx_serial_clk0            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk
			rx_cdr_refclk0            : in  std_logic                      := 'X';             -- clk
			tx_serial_data            : out std_logic_vector(0 downto 0);                      -- tx_serial_data
			rx_serial_data            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- rx_serial_data
			rx_is_lockedtoref         : out std_logic_vector(0 downto 0);                      -- rx_is_lockedtoref
			rx_is_lockedtodata        : out std_logic_vector(0 downto 0);                      -- rx_is_lockedtodata
			tx_coreclkin              : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk
			rx_coreclkin              : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk
			tx_clkout                 : out std_logic_vector(0 downto 0);                      -- clk
			rx_clkout                 : out std_logic_vector(0 downto 0);                      -- clk
			tx_parallel_data          : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- tx_parallel_data
			rx_parallel_data          : out std_logic_vector(7 downto 0);                      -- rx_parallel_data
			unused_tx_parallel_data   : in  std_logic_vector(118 downto 0) := (others => 'X'); -- unused_tx_parallel_data
			unused_rx_parallel_data   : out std_logic_vector(113 downto 0);                    -- unused_rx_parallel_data
			rx_seriallpbken           : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- rx_seriallpbken
			tx_datak                  : in  std_logic                      := 'X';             -- tx_datak
			rx_datak                  : out std_logic;                                         -- rx_datak
			rx_errdetect              : out std_logic;                                         -- rx_errdetect
			rx_disperr                : out std_logic;                                         -- rx_disperr
			rx_runningdisp            : out std_logic;                                         -- rx_runningdisp
			rx_patterndetect          : out std_logic;                                         -- rx_patterndetect
			rx_syncstatus             : out std_logic;                                         -- rx_syncstatus
			rx_std_wa_patternalign    : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- rx_std_wa_patternalign
			rx_std_bitslipboundarysel : out std_logic_vector(4 downto 0);                      -- rx_std_bitslipboundarysel
			reconfig_clk              : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk
			reconfig_reset            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- reset
			reconfig_write            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- write
			reconfig_read             : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- read
			reconfig_address          : in  std_logic_vector(9 downto 0)   := (others => 'X'); -- address
			reconfig_writedata        : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- writedata
			reconfig_readdata         : out std_logic_vector(31 downto 0);                     -- readdata
			reconfig_waitrequest      : out std_logic_vector(0 downto 0)                       -- waitrequest
		);
	end component wr_arria10_scu4_det_phy;

	u0 : component wr_arria10_scu4_det_phy
		port map (
			tx_analogreset            => CONNECTED_TO_tx_analogreset,            --            tx_analogreset.tx_analogreset
			tx_digitalreset           => CONNECTED_TO_tx_digitalreset,           --           tx_digitalreset.tx_digitalreset
			rx_analogreset            => CONNECTED_TO_rx_analogreset,            --            rx_analogreset.rx_analogreset
			rx_digitalreset           => CONNECTED_TO_rx_digitalreset,           --           rx_digitalreset.rx_digitalreset
			tx_cal_busy               => CONNECTED_TO_tx_cal_busy,               --               tx_cal_busy.tx_cal_busy
			rx_cal_busy               => CONNECTED_TO_rx_cal_busy,               --               rx_cal_busy.rx_cal_busy
			tx_serial_clk0            => CONNECTED_TO_tx_serial_clk0,            --            tx_serial_clk0.clk
			rx_cdr_refclk0            => CONNECTED_TO_rx_cdr_refclk0,            --            rx_cdr_refclk0.clk
			tx_serial_data            => CONNECTED_TO_tx_serial_data,            --            tx_serial_data.tx_serial_data
			rx_serial_data            => CONNECTED_TO_rx_serial_data,            --            rx_serial_data.rx_serial_data
			rx_is_lockedtoref         => CONNECTED_TO_rx_is_lockedtoref,         --         rx_is_lockedtoref.rx_is_lockedtoref
			rx_is_lockedtodata        => CONNECTED_TO_rx_is_lockedtodata,        --        rx_is_lockedtodata.rx_is_lockedtodata
			tx_coreclkin              => CONNECTED_TO_tx_coreclkin,              --              tx_coreclkin.clk
			rx_coreclkin              => CONNECTED_TO_rx_coreclkin,              --              rx_coreclkin.clk
			tx_clkout                 => CONNECTED_TO_tx_clkout,                 --                 tx_clkout.clk
			rx_clkout                 => CONNECTED_TO_rx_clkout,                 --                 rx_clkout.clk
			tx_parallel_data          => CONNECTED_TO_tx_parallel_data,          --          tx_parallel_data.tx_parallel_data
			rx_parallel_data          => CONNECTED_TO_rx_parallel_data,          --          rx_parallel_data.rx_parallel_data
			unused_tx_parallel_data   => CONNECTED_TO_unused_tx_parallel_data,   --   unused_tx_parallel_data.unused_tx_parallel_data
			unused_rx_parallel_data   => CONNECTED_TO_unused_rx_parallel_data,   --   unused_rx_parallel_data.unused_rx_parallel_data
			rx_seriallpbken           => CONNECTED_TO_rx_seriallpbken,           --           rx_seriallpbken.rx_seriallpbken
			tx_datak                  => CONNECTED_TO_tx_datak,                  --                  tx_datak.tx_datak
			rx_datak                  => CONNECTED_TO_rx_datak,                  --                  rx_datak.rx_datak
			rx_errdetect              => CONNECTED_TO_rx_errdetect,              --              rx_errdetect.rx_errdetect
			rx_disperr                => CONNECTED_TO_rx_disperr,                --                rx_disperr.rx_disperr
			rx_runningdisp            => CONNECTED_TO_rx_runningdisp,            --            rx_runningdisp.rx_runningdisp
			rx_patterndetect          => CONNECTED_TO_rx_patterndetect,          --          rx_patterndetect.rx_patterndetect
			rx_syncstatus             => CONNECTED_TO_rx_syncstatus,             --             rx_syncstatus.rx_syncstatus
			rx_std_wa_patternalign    => CONNECTED_TO_rx_std_wa_patternalign,    --    rx_std_wa_patternalign.rx_std_wa_patternalign
			rx_std_bitslipboundarysel => CONNECTED_TO_rx_std_bitslipboundarysel, -- rx_std_bitslipboundarysel.rx_std_bitslipboundarysel
			reconfig_clk              => CONNECTED_TO_reconfig_clk,              --              reconfig_clk.clk
			reconfig_reset            => CONNECTED_TO_reconfig_reset,            --            reconfig_reset.reset
			reconfig_write            => CONNECTED_TO_reconfig_write,            --             reconfig_avmm.write
			reconfig_read             => CONNECTED_TO_reconfig_read,             --                          .read
			reconfig_address          => CONNECTED_TO_reconfig_address,          --                          .address
			reconfig_writedata        => CONNECTED_TO_reconfig_writedata,        --                          .writedata
			reconfig_readdata         => CONNECTED_TO_reconfig_readdata,         --                          .readdata
			reconfig_waitrequest      => CONNECTED_TO_reconfig_waitrequest       --                          .waitrequest
		);

