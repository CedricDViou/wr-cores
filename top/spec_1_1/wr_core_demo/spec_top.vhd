
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.gn4124_core_pkg.all;
use work.wrcore_pkg.all;
use work.wbconmax_pkg.all;

library UNISIM;
use UNISIM.vcomponents.all;


entity spec_top is
  generic
    (
      TAR_ADDR_WDTH : integer := 13     -- not used for this project
      );
  port
    (
      -- Global ports
      clk_20m_vcxo_i : in std_logic;    -- 20MHz VCXO clock

      clk_125m_pllref_p_i : in std_logic;  -- 125 MHz PLL reference
      clk_125m_pllref_n_i : in std_logic;

      -- From GN4124 Local bus
      L_CLKp : in std_logic;  -- Local bus clock (frequency set in GN4124 config registers)
      L_CLKn : in std_logic;  -- Local bus clock (frequency set in GN4124 config registers)

      L_RST_N : in std_logic;           -- Reset from GN4124 (RSTOUT18_N)

      -- General Purpose Interface
      GPIO : inout std_logic_vector(1 downto 0);  -- GPIO[0] -> GN4124 GPIO8
                                                  -- GPIO[1] -> GN4124 GPIO9

      -- PCIe to Local [Inbound Data] - RX
      P2L_RDY    : out std_logic;       -- Rx Buffer Full Flag
      P2L_CLKn   : in  std_logic;       -- Receiver Source Synchronous Clock-
      P2L_CLKp   : in  std_logic;       -- Receiver Source Synchronous Clock+
      P2L_DATA   : in  std_logic_vector(15 downto 0);  -- Parallel receive data
      P2L_DFRAME : in  std_logic;       -- Receive Frame
      P2L_VALID  : in  std_logic;       -- Receive Data Valid

      -- Inbound Buffer Request/Status
      P_WR_REQ : in  std_logic_vector(1 downto 0);  -- PCIe Write Request
      P_WR_RDY : out std_logic_vector(1 downto 0);  -- PCIe Write Ready
      RX_ERROR : out std_logic;                     -- Receive Error

      -- Local to Parallel [Outbound Data] - TX
      L2P_DATA   : out std_logic_vector(15 downto 0);  -- Parallel transmit data
      L2P_DFRAME : out std_logic;       -- Transmit Data Frame
      L2P_VALID  : out std_logic;       -- Transmit Data Valid
      L2P_CLKn   : out std_logic;  -- Transmitter Source Synchronous Clock-
      L2P_CLKp   : out std_logic;  -- Transmitter Source Synchronous Clock+
      L2P_EDB    : out std_logic;       -- Packet termination and discard

      -- Outbound Buffer Status
      L2P_RDY    : in std_logic;        -- Tx Buffer Full Flag
      L_WR_RDY   : in std_logic_vector(1 downto 0);  -- Local-to-PCIe Write
      P_RD_D_RDY : in std_logic_vector(1 downto 0);  -- PCIe-to-Local Read Response Data Ready
      TX_ERROR   : in std_logic;        -- Transmit Error
      VC_RDY     : in std_logic_vector(1 downto 0);  -- Channel ready

      -- Font panel LEDs
      LED_RED   : out std_logic;
      LED_GREEN : out std_logic;

      dac_sclk_o  : out std_logic;
      dac_din_o   : out std_logic;
      dac_clr_n_o : out std_logic;
      dac_cs1_n_o : out std_logic;
      dac_cs2_n_o : out std_logic;


      sfp_txp_o : out std_logic;
      sfp_txn_o : out std_logic;

      sfp_rxp_i : in std_logic;
      sfp_rxn_i : in std_logic;

      fpga_scl_b : inout std_logic;
      fpga_sda_b : inout std_logic;

      button1_i : inout std_logic;
      button2_i : inout std_logic;

      sfp_mod_def0_b    : inout std_logic;  -- rate_select
      sfp_mod_def1_b    : inout std_logic;  -- scl
      sfp_mod_def2_b    : inout std_logic;  -- sda
      sfp_rate_select_b : inout std_logic;
      sfp_tx_fault_i    : in    std_logic;
      sfp_tx_disable_o  : out   std_logic;
      sfp_los_i         : in    std_logic;

      dio_o      : out std_logic_vector(3 downto 0);
      dio_en_n_o : out std_logic;
      dio_dir_o  : out std_logic


      );

end spec_top;

architecture rtl of spec_top is

  ------------------------------------------------------------------------------
  -- Components declaration
  ------------------------------------------------------------------------------

  component gn4124_core
    generic(
      -- g_IS_SPARTAN6       : boolean := false;  -- This generic is used to instanciate spartan6 specific primitives
      g_BAR0_APERTURE     : integer := 20;  -- BAR0 aperture, defined in GN4124 PCI_BAR_CONFIG register (0x80C)
                                            -- => number of bits to address periph on the board
      g_CSR_WB_SLAVES_NB  : integer := 1;   -- Number of CSR wishbone slaves
      g_DMA_WB_SLAVES_NB  : integer := 1;   -- Number of DMA wishbone slaves
      g_DMA_WB_ADDR_WIDTH : integer := 26;  -- DMA wishbone address bus width;
      g_CSR_WB_MODE       : string  := "classic"
      );
    port
      (
        ---------------------------------------------------------
        -- Control and status
        --
        -- Asynchronous reset from GN4124
        rst_n_a_i      : in  std_logic;
        -- P2L clock PLL locked
        p2l_pll_locked : out std_logic;
        -- Debug ouputs
        debug_o        : out std_logic_vector(7 downto 0);

        ---------------------------------------------------------
        -- P2L Direction
        --
        -- Source Sync DDR related signals
        p2l_clk_p_i  : in  std_logic;   -- Receiver Source Synchronous Clock+
        p2l_clk_n_i  : in  std_logic;   -- Receiver Source Synchronous Clock-
        p2l_data_i   : in  std_logic_vector(15 downto 0);  -- Parallel receive data
        p2l_dframe_i : in  std_logic;   -- Receive Frame
        p2l_valid_i  : in  std_logic;   -- Receive Data Valid
        -- P2L Control
        p2l_rdy_o    : out std_logic;   -- Rx Buffer Full Flag
        p_wr_req_i   : in  std_logic_vector(1 downto 0);  -- PCIe Write Request
        p_wr_rdy_o   : out std_logic_vector(1 downto 0);  -- PCIe Write Ready
        rx_error_o   : out std_logic;   -- Receive Error

        ---------------------------------------------------------
        -- L2P Direction
        --
        -- Source Sync DDR related signals
        l2p_clk_p_o  : out std_logic;  -- Transmitter Source Synchronous Clock+
        l2p_clk_n_o  : out std_logic;  -- Transmitter Source Synchronous Clock-
        l2p_data_o   : out std_logic_vector(15 downto 0);  -- Parallel transmit data
        l2p_dframe_o : out std_logic;   -- Transmit Data Frame
        l2p_valid_o  : out std_logic;   -- Transmit Data Valid
        l2p_edb_o    : out std_logic;   -- Packet termination and discard
        -- L2P Control
        l2p_rdy_i    : in  std_logic;   -- Tx Buffer Full Flag
        l_wr_rdy_i   : in  std_logic_vector(1 downto 0);  -- Local-to-PCIe Write
        p_rd_d_rdy_i : in  std_logic_vector(1 downto 0);  -- PCIe-to-Local Read Response Data Ready
        tx_error_i   : in  std_logic;   -- Transmit Error
        vc_rdy_i     : in  std_logic_vector(1 downto 0);  -- Channel ready

        ---------------------------------------------------------
        -- Interrupt interface
        dma_irq_o : out std_logic_vector(1 downto 0);  -- Interrupts sources to IRQ manager
        irq_p_i   : in  std_logic;  -- Interrupt request pulse from IRQ manager
        irq_p_o   : out std_logic;  -- Interrupt request pulse to GN4124 GPIO

        ---------------------------------------------------------
        -- Target interface (CSR wishbone master)
        wb_clk_i : in  std_logic;
        wb_adr_o : out std_logic_vector(g_BAR0_APERTURE-priv_log2_ceil(g_CSR_WB_SLAVES_NB+1)-1 downto 0);
        wb_dat_o : out std_logic_vector(31 downto 0);  -- Data out
        wb_sel_o : out std_logic_vector(3 downto 0);   -- Byte select
        wb_stb_o : out std_logic;
        wb_we_o  : out std_logic;
        wb_cyc_o : out std_logic_vector(g_CSR_WB_SLAVES_NB-1 downto 0);
        wb_dat_i : in  std_logic_vector((32*g_CSR_WB_SLAVES_NB)-1 downto 0);  -- Data in
        wb_ack_i : in  std_logic_vector(g_CSR_WB_SLAVES_NB-1 downto 0);

        ---------------------------------------------------------
        -- DMA interface (Pipelined wishbone master)
        dma_clk_i   : in  std_logic;
        dma_adr_o   : out std_logic_vector(31 downto 0);
        dma_dat_o   : out std_logic_vector(31 downto 0);  -- Data out
        dma_sel_o   : out std_logic_vector(3 downto 0);   -- Byte select
        dma_stb_o   : out std_logic;
        dma_we_o    : out std_logic;
        dma_cyc_o   : out std_logic;  --_vector(g_DMA_WB_SLAVES_NB-1 downto 0);
        dma_dat_i   : in  std_logic_vector((32*g_DMA_WB_SLAVES_NB)-1 downto 0);  -- Data in
        dma_ack_i   : in  std_logic;  --_vector(g_DMA_WB_SLAVES_NB-1 downto 0);
        dma_stall_i : in  std_logic--_vector(g_DMA_WB_SLAVES_NB-1 downto 0)        -- for pipelined Wishbone
        );
  end component;  --  gn4124_core
  component wr_core
    generic (
      g_simulation         : integer;
      g_virtual_uart       : natural;
      g_ep_rxbuf_size_log2 : integer;
      g_dpram_initf        : string;
      g_dpram_size         : integer;
      g_num_gpio           : integer);
    port (
      clk_sys_i          : in  std_logic;
      clk_dmtd_i         : in  std_logic;
      clk_ref_i          : in  std_logic;
      rst_n_i            : in  std_logic;
      pps_p_o            : out std_logic;
      dac_hpll_load_p1_o : out std_logic;
      dac_hpll_data_o    : out std_logic_vector(15 downto 0);
      dac_dpll_load_p1_o : out std_logic;
      dac_dpll_data_o    : out std_logic_vector(15 downto 0);
      phy_ref_clk_i      : in  std_logic;
      phy_tx_data_o      : out std_logic_vector(7 downto 0);
      phy_tx_k_o         : out std_logic;
      phy_tx_disparity_i : in  std_logic;
      phy_tx_enc_err_i   : in  std_logic;
      phy_rx_data_i      : in  std_logic_vector(7 downto 0);
      phy_rx_rbclk_i     : in  std_logic;
      phy_rx_k_i         : in  std_logic;
      phy_rx_enc_err_i   : in  std_logic;
      phy_rx_bitslide_i  : in  std_logic_vector(3 downto 0);
      phy_rst_o          : out std_logic;
      phy_loopen_o       : out std_logic;
      gpio_o             : out std_logic_vector(g_num_gpio-1 downto 0);
      gpio_i             : in  std_logic_vector(g_num_gpio-1 downto 0);
      gpio_dir_o         : out std_logic_vector(g_num_gpio-1 downto 0);
      uart_rxd_i         : in  std_logic;
      uart_txd_o         : out std_logic;
      wb_addr_i          : in  std_logic_vector(c_aw-1 downto 0);
      wb_data_i          : in  std_logic_vector(c_dw-1 downto 0);
      wb_data_o          : out std_logic_vector(c_dw-1 downto 0);
      wb_sel_i           : in  std_logic_vector(c_sw-1 downto 0);
      wb_we_i            : in  std_logic;
      wb_cyc_i           : in  std_logic;
      wb_stb_i           : in  std_logic;
      wb_ack_o           : out std_logic;
      genrest_n          : out std_logic;
      dio_o              : out std_logic_vector(3 downto 0));
  end component;

  component wr_gtp_phy_spartan6
    generic (
      g_simulation : integer;
      g_ch0_use_refclk_out : boolean := false;
    g_ch1_use_refclk_out : boolean := false);
    port (
      ch0_ref_clk_i      : in  std_logic;
      ch0_ref_clk_o      : out std_logic;
      ch0_tx_data_i      : in  std_logic_vector(7 downto 0);
      ch0_tx_k_i         : in  std_logic;
      ch0_tx_disparity_o : out std_logic;
      ch0_tx_enc_err_o   : out std_logic;
      ch0_rx_rbclk_o     : out std_logic;
      ch0_rx_data_o      : out std_logic_vector(7 downto 0);
      ch0_rx_k_o         : out std_logic;
      ch0_rx_enc_err_o   : out std_logic;
      ch0_rx_bitslide_o  : out std_logic_vector(3 downto 0);
      ch0_rst_i          : in  std_logic;
      ch0_loopen_i       : in  std_logic;
      ch1_ref_clk_i      : in  std_logic;
      ch1_ref_clk_o      : out std_logic;
      ch1_tx_data_i      : in  std_logic_vector(7 downto 0) := "00000000";
      ch1_tx_k_i         : in  std_logic                    := '0';
      ch1_tx_disparity_o : out std_logic;
      ch1_tx_enc_err_o   : out std_logic;
      ch1_rx_data_o      : out std_logic_vector(7 downto 0);
      ch1_rx_rbclk_o     : out std_logic;
      ch1_rx_k_o         : out std_logic;
      ch1_rx_enc_err_o   : out std_logic;
      ch1_rx_bitslide_o  : out std_logic_vector(3 downto 0);
      ch1_rst_i          : in  std_logic                    := '0';
      ch1_loopen_i       : in  std_logic                    := '0';
      pad_txn0_o         : out std_logic;
      pad_txp0_o         : out std_logic;
      pad_rxn0_i         : in  std_logic                    := '0';
      pad_rxp0_i         : in  std_logic                    := '0';
      pad_txn1_o         : out std_logic;
      pad_txp1_o         : out std_logic;
      pad_rxn1_i         : in  std_logic                    := '0';
      pad_rxp1_i         : in  std_logic                    := '0');
  end component;

  component spec_serial_dac_arb
    generic(
      g_invert_sclk    : boolean;
      g_num_extra_bits : integer);        
    port (
      clk_i       : in  std_logic;
      rst_n_i     : in  std_logic;
      val1_i      : in  std_logic_vector(15 downto 0);
      load1_i     : in  std_logic;
      val2_i      : in  std_logic_vector(15 downto 0);
      load2_i     : in  std_logic;
      dac_cs_n_o  : out std_logic_vector(1 downto 0);
      dac_clr_n_o : out std_logic;
      dac_sclk_o  : out std_logic;
      dac_din_o   : out std_logic);
  end component;

  ------------------------------------------------------------------------------
  -- Constants declaration
  ------------------------------------------------------------------------------
  constant c_BAR0_APERTURE     : integer := 20;
  constant c_CSR_WB_SLAVES_NB  : integer := 1;
  constant c_DMA_WB_SLAVES_NB  : integer := 1;
  constant c_DMA_WB_ADDR_WIDTH : integer := 26;

  ------------------------------------------------------------------------------
  -- Signals declaration
  ------------------------------------------------------------------------------

  -- LCLK from GN4124 used as system clock
  signal l_clk : std_logic;

  -- P2L colck PLL status
  signal p2l_pll_locked : std_logic;

  -- Reset
  signal rst_a : std_logic;
  signal rst   : std_logic;

  -- CSR wishbone bus
  signal wb_adr     : std_logic_vector(c_BAR0_APERTURE-priv_log2_ceil(c_CSR_WB_SLAVES_NB+1)-1 downto 0);
  signal wb_dat_i   : std_logic_vector((32*c_CSR_WB_SLAVES_NB)-1 downto 0);
  signal wb_dat_o   : std_logic_vector(31 downto 0);
  signal wb_sel     : std_logic_vector(3 downto 0);
  signal wb_cyc     : std_logic_vector(c_CSR_WB_SLAVES_NB-1 downto 0);
  signal wb_stb     : std_logic;
  signal wb_we      : std_logic;
  signal wb_ack     : std_logic_vector(c_CSR_WB_SLAVES_NB-1 downto 0);
  signal spi_wb_adr : std_logic_vector(4 downto 0);

  -- DMA wishbone bus
  signal dma_adr     : std_logic_vector(31 downto 0);
  signal dma_dat_i   : std_logic_vector((32*c_DMA_WB_SLAVES_NB)-1 downto 0);
  signal dma_dat_o   : std_logic_vector(31 downto 0);
  signal dma_sel     : std_logic_vector(3 downto 0);
  signal dma_cyc     : std_logic;  --_vector(c_DMA_WB_SLAVES_NB-1 downto 0);
  signal dma_stb     : std_logic;
  signal dma_we      : std_logic;
  signal dma_ack     : std_logic;  --_vector(c_DMA_WB_SLAVES_NB-1 downto 0);
  signal dma_stall   : std_logic;  --_vector(c_DMA_WB_SLAVES_NB-1 downto 0);
  signal ram_we      : std_logic_vector(0 downto 0);
  signal ddr_dma_adr : std_logic_vector(29 downto 0);

  signal irq_to_gn4124 : std_logic;

  -- SPI
  signal spi_slave_select : std_logic_vector(7 downto 0);


  signal pllout_clk_sys       : std_logic;
  signal pllout_clk_dmtd      : std_logic;
  signal pllout_clk_fb_pllref : std_logic;
  signal pllout_clk_fb_dmtd   : std_logic;

  signal clk_20m_vcxo_buf : std_logic;
  signal clk_125m_pllref  : std_logic;
  signal clk_sys          : std_logic;
  signal clk_dmtd         : std_logic;
  signal dac_rst_n        : std_logic;
  signal led_divider      : unsigned(23 downto 0);

  signal wrc_gpio_out : std_logic_vector(7 downto 0);
  signal wrc_gpio_in  : std_logic_vector(7 downto 0);
  signal wrc_gpio_dir : std_logic_vector(7 downto 0);
  signal wb_adr_wrc   : std_logic_vector(17 downto 0);
  signal dio          : std_logic_vector(3 downto 0);

  signal dac_hpll_load_p1 : std_logic;
  signal dac_dpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_data    : std_logic_vector(15 downto 0);

  signal pps : std_logic;

  signal phy_tx_data      : std_logic_vector(7 downto 0);
  signal phy_tx_k         : std_logic;
  signal phy_tx_disparity : std_logic;
  signal phy_tx_enc_err   : std_logic;
  signal phy_rx_data      : std_logic_vector(7 downto 0);
  signal phy_rx_rbclk     : std_logic;
  signal phy_rx_k         : std_logic;
  signal phy_rx_enc_err   : std_logic;
  signal phy_rx_bitslide  : std_logic_vector(3 downto 0);
  signal phy_rst          : std_logic;
  signal phy_loopen       : std_logic;
  
begin

  
  

  cmp_sys_clk_pll : PLL_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",
      CLK_FEEDBACK       => "CLKFBOUT",
      COMPENSATION       => "INTERNAL",
      DIVCLK_DIVIDE      => 1,
      CLKFBOUT_MULT      => 8,
      CLKFBOUT_PHASE     => 0.000,
      CLKOUT0_DIVIDE     => 16,         -- 62.5 MHz
      CLKOUT0_PHASE      => 0.000,
      CLKOUT0_DUTY_CYCLE => 0.500,
      CLKOUT1_DIVIDE     => 16,         -- 125 MHz
      CLKOUT1_PHASE      => 0.000,
      CLKOUT1_DUTY_CYCLE => 0.500,
      CLKOUT2_DIVIDE     => 16,
      CLKOUT2_PHASE      => 0.000,
      CLKOUT2_DUTY_CYCLE => 0.500,
      CLKIN_PERIOD       => 8.0,
      REF_JITTER         => 0.016)
    port map (
      CLKFBOUT => pllout_clk_fb_pllref,
      CLKOUT0  => pllout_clk_sys,
      CLKOUT1  => open,
      CLKOUT2  => open,
      CLKOUT3  => open,
      CLKOUT4  => open,
      CLKOUT5  => open,
      LOCKED   => open,
      RST      => '0',
      CLKFBIN  => pllout_clk_fb_pllref,
      CLKIN    => clk_125m_pllref);

  cmp_dmtd_clk_pll : PLL_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",
      CLK_FEEDBACK       => "CLKFBOUT",
      COMPENSATION       => "INTERNAL",
      DIVCLK_DIVIDE      => 1,
      CLKFBOUT_MULT      => 50,
      CLKFBOUT_PHASE     => 0.000,
      CLKOUT0_DIVIDE     => 8,          -- 62.5 MHz
      CLKOUT0_PHASE      => 0.000,
      CLKOUT0_DUTY_CYCLE => 0.500,
      CLKOUT1_DIVIDE     => 8,          -- 125 MHz
      CLKOUT1_PHASE      => 0.000,
      CLKOUT1_DUTY_CYCLE => 0.500,
      CLKOUT2_DIVIDE     => 8,
      CLKOUT2_PHASE      => 0.000,
      CLKOUT2_DUTY_CYCLE => 0.500,
      CLKIN_PERIOD       => 50.0,
      REF_JITTER         => 0.016)
    port map (
      CLKFBOUT => pllout_clk_fb_dmtd,
      CLKOUT0  => pllout_clk_dmtd,
      CLKOUT1  => open,
      CLKOUT2  => open,
      CLKOUT3  => open,
      CLKOUT4  => open,
      CLKOUT5  => open,
      LOCKED   => open,
      RST      => '0',
      CLKFBIN  => pllout_clk_fb_dmtd,
      CLKIN    => clk_20m_vcxo_buf);



  cmp_clk_sys_buf : BUFG
    port map (
      O => clk_sys,
      I => pllout_clk_sys);

  cmp_clk_dmtd_buf : BUFG
    port map (
      O => clk_dmtd,
      I => pllout_clk_dmtd);

  cmp_clk_vcxo : BUFG
    port map (
      O => clk_20m_vcxo_buf,
      I => clk_20m_vcxo_i);

  ------------------------------------------------------------------------------
  -- Local clock from gennum LCLK
  ------------------------------------------------------------------------------
  cmp_l_clk_buf : IBUFDS
    generic map (
      DIFF_TERM    => false,            -- Differential Termination
      IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => l_clk,                      -- Buffer output
      I  => L_CLKp,  -- Diff_p buffer input (connect directly to top-level port)
      IB => L_CLKn  -- Diff_n buffer input (connect directly to top-level port)
      );

  cmp_pllrefclk_buf : IBUFGDS
    generic map (
      DIFF_TERM    => true,             -- Differential Termination
      IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => clk_125m_pllref,            -- Buffer output
      I  => clk_125m_pllref_p_i,  -- Diff_p buffer input (connect directly to top-level port)
      IB => clk_125m_pllref_n_i  -- Diff_n buffer input (connect directly to top-level port)
      );



  ------------------------------------------------------------------------------
  -- Active high reset
  ------------------------------------------------------------------------------
  rst <= not(L_RST_N);

  ------------------------------------------------------------------------------
  -- GN4124 interface
  ------------------------------------------------------------------------------
  cmp_gn4124_core : gn4124_core
    generic map (
      -- g_IS_SPARTAN6       => true,
      g_BAR0_APERTURE     => c_BAR0_APERTURE,
      g_CSR_WB_SLAVES_NB  => c_CSR_WB_SLAVES_NB,
      g_DMA_WB_SLAVES_NB  => c_DMA_WB_SLAVES_NB,
      g_DMA_WB_ADDR_WIDTH => c_DMA_WB_ADDR_WIDTH,
      g_CSR_WB_MODE       => "classic"
      )
    port map
    (
      ---------------------------------------------------------
      -- Control and status
      --
      -- Asynchronous reset from GN4124
      rst_n_a_i      => L_RST_N,
      -- P2L clock PLL locked
      p2l_pll_locked => p2l_pll_locked,
      -- Debug outputs
      debug_o        => open,

      ---------------------------------------------------------
      -- P2L Direction
      --
      -- Source Sync DDR related signals
      p2l_clk_p_i  => P2L_CLKp,
      p2l_clk_n_i  => P2L_CLKn,
      p2l_data_i   => P2L_DATA,
      p2l_dframe_i => P2L_DFRAME,
      p2l_valid_i  => P2L_VALID,

      -- P2L Control
      p2l_rdy_o  => P2L_RDY,
      p_wr_req_i => P_WR_REQ,
      p_wr_rdy_o => P_WR_RDY,
      rx_error_o => RX_ERROR,

      ---------------------------------------------------------
      -- L2P Direction
      --
      -- Source Sync DDR related signals
      l2p_clk_p_o  => L2P_CLKp,
      l2p_clk_n_o  => L2P_CLKn,
      l2p_data_o   => L2P_DATA,
      l2p_dframe_o => L2P_DFRAME,
      l2p_valid_o  => L2P_VALID,
      l2p_edb_o    => L2P_EDB,

      -- L2P Control
      l2p_rdy_i    => L2P_RDY,
      l_wr_rdy_i   => L_WR_RDY,
      p_rd_d_rdy_i => P_RD_D_RDY,
      tx_error_i   => TX_ERROR,
      vc_rdy_i     => VC_RDY,

      ---------------------------------------------------------
      -- Interrupt interface
      dma_irq_o => open,
      irq_p_i   => '0',
      irq_p_o   => GPIO(0),

      ---------------------------------------------------------
      -- Target Interface (Wishbone master)
      wb_clk_i => clk_sys,
      wb_adr_o => wb_adr,
      wb_dat_o => wb_dat_o,
      wb_sel_o => wb_sel,
      wb_stb_o => wb_stb,
      wb_we_o  => wb_we,
      wb_cyc_o => wb_cyc,
      wb_dat_i => wb_dat_i,
      wb_ack_i => wb_ack,

      ---------------------------------------------------------
      -- L2P DMA Interface (Pipelined Wishbone master)
      dma_clk_i   => clk_sys,
      dma_adr_o   => dma_adr,
      dma_dat_o   => dma_dat_o,
      dma_sel_o   => dma_sel,
      dma_stb_o   => dma_stb,
      dma_we_o    => dma_we,
      dma_cyc_o   => dma_cyc,
      dma_dat_i   => dma_dat_i,
      dma_ack_i   => dma_ack,
      dma_stall_i => dma_stall
      );

  process(clk_sys, rst)
  begin
    if rising_edge(clk_sys) then
      led_divider <= led_divider + 1;
    end if;
  end process;

  LED_RED <= std_logic(led_divider(led_divider'high));

  wb_adr_wrc <= '0' & wb_adr (16 downto 0);

  U_WR_CORE : wr_core
    generic map (
      g_simulation             => 0,
      g_virtual_uart           => 1,
      g_ep_rxbuf_size_log2     => 12,
      g_dpram_initf            => "",
      g_dpram_size             => 16384,
      g_num_gpio               => 8)
    port map (
      clk_sys_i  => clk_sys,
      clk_dmtd_i => clk_dmtd,
      clk_ref_i  => clk_125m_pllref,
      rst_n_i    => L_RST_N,

      pps_p_o => pps,

      dac_hpll_load_p1_o => dac_hpll_load_p1,
      dac_hpll_data_o    => dac_hpll_data,

      dac_dpll_load_p1_o => dac_dpll_load_p1,
      dac_dpll_data_o    => dac_dpll_data,

      gpio_o     => wrc_gpio_out,
      gpio_i     => wrc_gpio_in,
      gpio_dir_o => wrc_gpio_dir,

      uart_rxd_i => '0',
      uart_txd_o => open,
      wb_addr_i  => wb_adr_wrc,
      wb_data_i  => wb_dat_o,
      wb_data_o  => wb_dat_i(31 downto 0),
      wb_sel_i   => wb_sel,
      wb_we_i    => wb_we,
      wb_cyc_i   => wb_cyc(0),
      wb_stb_i   => wb_stb,
      wb_ack_o   => wb_ack(0),
      genrest_n  => open,
      dio_o      => dio,

      phy_ref_clk_i      => clk_125m_pllref,
      phy_tx_data_o      => phy_tx_data,
      phy_tx_k_o         => phy_tx_k,
      phy_tx_disparity_i => phy_tx_disparity,
      phy_tx_enc_err_i   => phy_tx_enc_err,
      phy_rx_data_i      => phy_rx_data,
      phy_rx_rbclk_i     => phy_rx_rbclk,
      phy_rx_k_i         => phy_rx_k,
      phy_rx_enc_err_i   => phy_rx_enc_err,
      phy_rx_bitslide_i  => phy_rx_bitslide,
      phy_rst_o          => phy_rst,
      phy_loopen_o       => phy_loopen
      );


  U_GTP: wr_gtp_phy_spartan6
    generic map (
      g_simulation => 0)
    port map (
      ch0_ref_clk_i      => clk_125m_pllref,
      ch0_ref_clk_o      => open,
      ch0_tx_data_i      => x"00",
      ch0_tx_k_i         => '0',
      ch0_tx_disparity_o => open,
      ch0_tx_enc_err_o   => open,
      ch0_rx_rbclk_o     => open,
      ch0_rx_data_o      => open,
      ch0_rx_k_o         => open,
      ch0_rx_enc_err_o   => open,
      ch0_rx_bitslide_o  => open,
      ch0_rst_i          => '1',
      ch0_loopen_i       => '0',

      ch1_ref_clk_i      => clk_125m_pllref,
      ch1_ref_clk_o      => open,
      ch1_tx_data_i      => phy_tx_data,
      ch1_tx_k_i         => phy_tx_k,
      ch1_tx_disparity_o => phy_tx_disparity,
      ch1_tx_enc_err_o   => phy_tx_enc_err,
      ch1_rx_data_o      => phy_rx_data,
      ch1_rx_rbclk_o     => phy_rx_rbclk,
      ch1_rx_k_o         => phy_rx_k,
      ch1_rx_enc_err_o   => phy_rx_enc_err,
      ch1_rx_bitslide_o  => phy_rx_bitslide,
      ch1_rst_i          => phy_rst,
      ch1_loopen_i       => phy_loopen,
      pad_txn0_o         => open,
      pad_txp0_o         => open,
      pad_rxn0_i         => '0',
      pad_rxp0_i         => '0',
      pad_txn1_o         => sfp_txn_o,
      pad_txp1_o         => sfp_txp_o,
      pad_rxn1_i         => sfp_rxn_i,
      pad_rxp1_i         => sfp_rxp_i);

  
  U_DAC_ARB : spec_serial_dac_arb
    generic map (
      g_invert_sclk    => false,
      g_num_extra_bits => 8)

    port map (
      clk_i   => clk_sys,
      rst_n_i => L_RST_N,

      val1_i  => dac_dpll_data,
      load1_i => dac_dpll_load_p1,

      val2_i  => dac_hpll_data,
      load2_i => dac_hpll_load_p1,

      dac_cs_n_o(0) => dac_cs1_n_o,
      dac_cs_n_o(1) => dac_cs2_n_o,
      dac_clr_n_o   => dac_clr_n_o,
      dac_sclk_o    => dac_sclk_o,
      dac_din_o     => dac_din_o);

  --dac_cs1_n_o <= wrc_gpio(1);
  --dac_cs2_n_o <= wrc_gpio(2);
  --dac_clr_n_o <= wrc_gpio(3);
  --dac_sclk_o <= wrc_gpio(4);
  --dac_din_o <= wrc_gpio(5);
  

  dio_o(3 downto 1) <= dio(3 downto 1);
  dio_o(0)          <= pps;



  --LED_GREEN <= clk_125m_pllref;
  LED_GREEN <= wrc_gpio_out(0);

  fpga_scl_b <= '0' when wrc_gpio_out(1) = '0' else 'Z';
  fpga_sda_b <= '0' when wrc_gpio_out(2) = '0' else 'Z';

  wrc_gpio_in(3) <= fpga_sda_b;
  wrc_gpio_in(4) <= button1_i;
  wrc_gpio_in(5) <= button2_i;


  sfp_mod_def0_b <= '0';
  sfp_mod_def1_b <= '0';
  sfp_mod_def2_b <= '0';

  sfp_tx_disable_o <= '0';

  dio_en_n_o <= '0';
  dio_dir_o  <= '0';
  

  
end rtl;


