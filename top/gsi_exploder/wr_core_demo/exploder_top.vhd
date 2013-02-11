library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;

library work;
use work.wishbone_pkg.all;
use work.wb_cores_pkg_gsi.all;
use work.xwr_eca_pkg.all;
use work.wr_altera_pkg.all;
use work.etherbone_pkg.all;
use work.wrc_bin_pkg.all;
use work.vme_pkg.all;

entity exploder_top is
  port(
    clk_20m_vcxo_i    : in std_logic;                    -- 20MHz VCXO clock
    clk_125m_pllref_p : in std_logic;                    -- 125 MHz PLL reference
	 -----------------------------------------------------------------------
	 -- Reset
	 -----------------------------------------------------------------------
    nres              : in std_logic;                    -- powerup reset
    -------------------------------------------------------------
    -- OneWire
    -----------------------------------------------------------------------
    OneWire_CB     : inout std_logic; 
    -----------------------------------------
    -- Timing SFP
    -----------------------------------------
    sfp_tx_disable_o : out std_logic;
    sfp_txp_o        : out std_logic;
    sfp_rxp_i        : in  std_logic;

    sfp_mod0         : in    std_logic; -- grounded by module
    sfp_mod1         : inout std_logic; -- SCL
    sfp_mod2         : inout std_logic; -- SDA
    
    ------------------------------------------------------------------------
    -- WR DAC signals
    ------------------------------------------------------------------------
    dac_sclk         : out std_logic;
    dac_din          : out std_logic;
    ndac_cs          : out std_logic_vector(2 downto 1);
	 
    -------------------------------------------------------------------------
    -- HPLW_1 pins
	 -------------------------------------------------------------------------
    uart_pwr : out std_logic;
    uart_tx  : out std_logic;
    uart_rx  : in  std_logic;
	 
    -----------------------------------------
    -- LED on baseboard
    -----------------------------------------
    led_bas    : out std_logic_vector(7 downto 0);
   
    -----------------------------------------
    -- LED on Exploder DB2
    -----------------------------------------
    leds_o  : out std_logic_vector(8 downto 0);

    -----------------------------------------
    -- I/O on Exploder DB2
    -----------------------------------------
    --TTLOUT
    lemo_o       : out std_logic_vector(7 downto 0); 
    lemo_en_o    : out std_logic_vector(1 downto 0); 
    --TTLIN
    lemo_i        : in std_logic_vector(7 downto 0); 
    lemo_en_i    : out std_logic_vector(1 downto 0));

end exploder_top;

architecture rtl of exploder_top is

  -- WR core layout
  constant c_wrcore_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"0003ffff", x"00030000");
  
  -- Ref clock crossbar
  constant c_ref_slaves  : natural := 2;
  constant c_ref_masters : natural := 1;
  constant c_ref_layout : t_sdb_record_array(c_ref_slaves-1 downto 0) :=
   (0 => f_sdb_embed_device(c_xwr_eca_sdb,                x"00040000"),
    1 => f_sdb_embed_device(c_xwr_wb_timestamp_latch_sdb, x"00080000"));
  constant c_ref_sdb_address : t_wishbone_address := x"000C0000";
  constant c_ref_bridge : t_sdb_bridge := 
    f_xwb_bridge_layout_sdb(true, c_ref_layout, c_ref_sdb_address);
  
  signal cbar_ref_slave_i  : t_wishbone_slave_in_array (c_ref_masters-1 downto 0);
  signal cbar_ref_slave_o  : t_wishbone_slave_out_array(c_ref_masters-1 downto 0);
  signal cbar_ref_master_i : t_wishbone_master_in_array(c_ref_slaves-1 downto 0);
  signal cbar_ref_master_o : t_wishbone_master_out_array(c_ref_slaves-1 downto 0);
  
  -- Top crossbar layout
  constant c_slaves : natural := 2;
  constant c_masters : natural := 1;
  constant c_test_dpram_size : natural := 2048;
  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
   (0 => f_sdb_embed_bridge(c_wrcore_bridge_sdb, x"00000000"),
    1 => f_sdb_embed_bridge(c_ref_bridge,        x"00100000"));
  constant c_sdb_address : t_wishbone_address := x"00300000";

  signal cbar_slave_i  : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_o  : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_i : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_o : t_wishbone_master_out_array(c_slaves-1 downto 0);

  signal pllout_clk_sys   : std_logic;
  signal pllout_clk_dmtd  : std_logic;
  signal locked           : std_logic;
  signal clk_sys          : std_logic;
  signal clk_dmtd         : std_logic;
  signal clk_reconf       : std_logic;
  signal vme_clk_100      : std_logic;
  signal vme_clk_50       : std_logic;
  signal vme_locked		  : std_logic;
  
  signal pllout_clk_sys_rstn    : std_logic;
  signal clk_125m_pllref_p_rstn : std_logic;
  signal reset_clks, reset_rstn : std_logic_vector(1 downto 0);

  signal dac_hpll_load_p1 : std_logic;
  signal dac_dpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_data    : std_logic_vector(15 downto 0);

  signal ext_pps : std_logic;
  signal pps : std_logic;

  signal phy_tx_clk       : std_logic;
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

  signal wrc_master_i  : t_wishbone_master_in;
  signal wrc_master_o  : t_wishbone_master_out;

  signal mb_src_out    : t_wrf_source_out;
  signal mb_src_in     : t_wrf_source_in;
  signal mb_snk_out    : t_wrf_sink_out;
  signal mb_snk_in     : t_wrf_sink_in;
  
  signal tm_utc    : std_logic_vector(39 downto 0);
  signal tm_cycles : std_logic_vector(27 downto 0);

  signal eca_toggle  : std_logic_vector(31 downto 0);
  signal triger_latch: std_logic_vector(0 downto 0);
  
  signal owr_pwren_o : std_logic_vector(1 downto 0);
  signal owr_en_o: std_logic_vector(1 downto 0);
  signal owr_i:	std_logic_vector(1 downto 0);
  
  signal sda_i:	std_logic;
  signal sda_o:	std_logic;
  signal scl_i:	std_logic;
  signal scl_o:	std_logic;
  
  signal sfp_scl_o : std_logic;
  signal sfp_scl_i : std_logic;
  signal sfp_sda_o : std_logic;
  signal sfp_sda_i : std_logic;
  signal sfp_det_i : std_logic;
  
  signal led_green : std_logic;
  signal led_red   : std_logic;
-- vme
  signal add_strb_sync    : std_logic;            -- synchronized  VME !AS 
  signal data_strb_sync   : std_logic;            -- synchronized  VME (!DS0 and !DS1)
  signal add_reg          : std_logic_vector (31 downto 0);   -- internal address register for VME address
  signal data_bus         : std_logic_vector (31 downto 0);   -- internal data bus
  signal ckcsr            : std_logic;            -- clock data into csr
  signal oecsr            : std_logic;            -- output data from csr to VME
  signal oecsro           : std_logic;

  signal u_add_reg        : std_logic_vector(21 downto 2);
  signal u_data_rx        : std_logic_vector(31 downto 0);
  signal u_data_tx        : std_logic_vector(31 downto 0); -- from ulogic in VULOM here our input????


begin
  Inst_flash_loader_v01 : flash_loader
    port map(
      noe_in   => '0');

  -- open drain buffer for one wire
  owr_i(0) <= OneWire_CB;
  OneWire_CB <= owr_pwren_o(0) when (owr_pwren_o(0) = '1' or owr_en_o(0) = '1') else 'Z';
  
  -- open drain buffer for SFP i2c
  sfp_scl_i <= sfp_mod1;
  sfp_sda_i <= sfp_mod2;
  
  sfp_det_i <= sfp_mod0;
  sfp_mod1 <= '0' when sfp_scl_o = '0' else 'Z';
  sfp_mod2 <= '0' when sfp_sda_o = '0' else 'Z';
  
  
  dmtd_clk_inst : dmtd_clk_pll port map (
    inclk0 => clk_20m_vcxo_i,           -- 20Mhz 
    c0     => pllout_clk_dmtd);         -- 62.5Mhz

  sys_pll_inst : sys_pll port map (
    inclk0 => clk_125m_pllref_p,        -- 125Mhz 
    c0     => pllout_clk_sys,           -- 62.5Mhy sys clk
    c1     => clk_reconf,               -- 50Mhz for reconfig block
    locked => locked);
  
 
  reset : gc_reset
    generic map(
      g_clocks => 2)
    port map(
      free_clk_i => clk_20m_vcxo_i,
      locked_i   => locked,
      clks_i     => reset_clks,
      rstn_o     => reset_rstn);
  reset_clks(0) <= pllout_clk_sys;
  reset_clks(1) <= clk_125m_pllref_p;
  pllout_clk_sys_rstn <= reset_rstn(0);
  clk_125m_pllref_p_rstn <= reset_rstn(1);

  U_WR_CORE : xwr_core
    generic map (
      g_simulation                => 0,
      g_phys_uart                 => true,
      g_virtual_uart              => false,
      g_with_external_clock_input => true,
      g_aux_clks                  => 1,
      g_ep_rxbuf_size             => 1024,
      g_dpram_initf               => "",
      --g_dpram_initv               => wrc_bin_init,
      g_dpram_size                => 90112/4,
      g_interface_mode            => PIPELINED,
      g_address_granularity       => BYTE)
    port map (
      clk_sys_i  => pllout_clk_sys,
      clk_dmtd_i => pllout_clk_dmtd,
      clk_ref_i  => clk_125m_pllref_p,
      clk_aux_i  => (others => '0'),
      clk_ext_i  => '0', -- g_with_external_clock_input controls usage
      pps_ext_i  => '0',
      rst_n_i    => pllout_clk_sys_rstn,

      dac_hpll_load_p1_o => dac_hpll_load_p1,
      dac_hpll_data_o    => dac_hpll_data,
      dac_dpll_load_p1_o => dac_dpll_load_p1,
      dac_dpll_data_o    => dac_dpll_data,
		
      phy_ref_clk_i      => phy_tx_clk,
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
      phy_loopen_o       => phy_loopen,
      
      led_red_o   => open,
      led_green_o => open,
      scl_o       => scl_o,
      scl_i       => scl_i,
      sda_i       => sda_i,
      sda_o       => sda_o,
      sfp_scl_i   => sfp_scl_i,
      sfp_sda_i   => sfp_sda_i,
      sfp_scl_o   => sfp_scl_o,
      sfp_sda_o   => sfp_sda_o,
      sfp_det_i   => sfp_det_i,
      btn1_i      => '0',
      btn2_i      => '0',

      uart_rxd_i => uart_rx,
      uart_txd_o => uart_tx,
      
      owr_pwren_o => owr_pwren_o,
      owr_en_o    => owr_en_o,
      owr_i       => owr_i,
      
      slave_i => cbar_master_o(0),
      slave_o => cbar_master_i(0),
      aux_master_o => wrc_master_o,
      aux_master_i => wrc_master_i,

      wrf_src_o => mb_snk_in,
      wrf_src_i => mb_snk_out,
      wrf_snk_o => mb_src_in,
      wrf_snk_i => mb_src_out,

      tm_link_up_o         => open,
      tm_dac_value_o       => open,
      tm_dac_wr_o          => open,
      tm_clk_aux_lock_en_i => '0',
      tm_clk_aux_locked_o  => open,
      tm_time_valid_o      => open,
      tm_utc_o             => tm_utc,
      tm_cycles_o          => tm_cycles,
      pps_p_o              => pps,
      
      dio_o                => open,
      rst_aux_n_o          => open,
      link_ok_o            => open);

  wr_gxb_phy_arriaii_1 : wr_gxb_phy_arriaii
    generic map (
      g_simulation      => 0,
      g_force_disparity => 1)
    port map (
      clk_reconf_i   => clk_reconf,
      clk_ref_i      => clk_125m_pllref_p,
      tx_clk_o       => phy_tx_clk,
      tx_data_i      => phy_tx_data,
      tx_k_i         => phy_tx_k,
      tx_disparity_o => phy_tx_disparity,
      tx_enc_err_o   => phy_tx_enc_err,
      rx_rbclk_o     => phy_rx_rbclk,
      rx_data_o      => phy_rx_data,
      rx_k_o         => phy_rx_k,
      rx_enc_err_o   => phy_rx_enc_err,
      rx_bitslide_o  => phy_rx_bitslide,
      rst_i          => phy_rst,
      loopen_i       => '0',
      pad_txp_o      => sfp_txp_o,
      pad_rxp_i      => sfp_rxp_i);

  U_DAC_ARB : spec_serial_dac_arb
    generic map (
      g_invert_sclk    => false,
      g_num_extra_bits => 8)            -- AD DACs with 24bit interface
    port map (
      clk_i   => pllout_clk_sys,
      rst_n_i => pllout_clk_sys_rstn,

      val1_i  => dac_dpll_data,
      load1_i => dac_dpll_load_p1,

      val2_i  => dac_hpll_data,
      load2_i => dac_hpll_load_p1,

      dac_cs_n_o(0) => ndac_cs(1),
      dac_cs_n_o(1) => ndac_cs(2),
      dac_clr_n_o   => open,
      dac_sclk_o    => dac_sclk,
      dac_din_o     => dac_din);

  U_Extend_PPS : gc_extend_pulse
    generic map (
      g_width => 10000000)
    port map (
      clk_i      => pllout_clk_sys,
      rst_n_i    => pllout_clk_sys_rstn,
      pulse_i    => pps,
      extended_o => ext_pps);
  
  U_ebone : EB_CORE
    generic map(
       g_sdb_address => x"00000000" & c_sdb_address)
    port map(
      clk_i       => pllout_clk_sys,
      nRst_i      => pllout_clk_sys_rstn,
      snk_i       => mb_snk_in,
      snk_o       => mb_snk_out,
      src_o       => mb_src_out,
      src_i       => mb_src_in,
      cfg_slave_o => wrc_master_i,
      cfg_slave_i => wrc_master_o,
      master_o    => cbar_slave_i(0),
      master_i    => cbar_slave_o(0));
  
  TLU : wb_timestamp_latch
    generic map (
      g_num_triggers => 1,
      g_fifo_depth   => 10)
    port map (
      ref_clk_i       => clk_125m_pllref_p,
      sys_clk_i       => clk_125m_pllref_p,
      nRSt_i          => clk_125m_pllref_p_rstn,
      triggers_i      => triger_latch,
      tm_time_valid_i => '0',
      tm_utc_i        => tm_utc,
      tm_cycles_i     => tm_cycles,
      wb_slave_i      => cbar_ref_master_o(1),
      wb_slave_o      => cbar_ref_master_i(1));

  ECA : xwr_eca
    port map(
      clk_i      => clk_125m_pllref_p,
      rst_n_i    => clk_125m_pllref_p_rstn,
      slave_i    => cbar_ref_master_o(0),
      slave_o    => cbar_ref_master_i(0),
      tm_utc_i   => tm_utc,
      tm_cycle_i => tm_cycles,
      toggle_o   => eca_toggle);
      
  GSI_REF_CON : xwb_sdb_crossbar
   generic map(
     g_num_masters => c_ref_masters,
     g_num_slaves  => c_ref_slaves,
     g_registered  => true,
     g_wraparound  => true,
     g_layout      => c_ref_layout,
     g_sdb_addr    => c_ref_sdb_address)
   port map(
     clk_sys_i     => clk_125m_pllref_p,
     rst_n_i       => clk_125m_pllref_p_rstn,
     -- Master connections (INTERCON is a slave)
     slave_i       => cbar_ref_slave_i,
     slave_o       => cbar_ref_slave_o,
     -- Slave connections (INTERCON is a master)
     master_i      => cbar_ref_master_i,
     master_o      => cbar_ref_master_o);
  
  cross_my_clocks : xwb_clock_crossing
    port map(
      slave_clk_i    => pllout_clk_sys,
      slave_rst_n_i  => pllout_clk_sys_rstn,
      slave_i        => cbar_master_o(1),
      slave_o        => cbar_master_i(1),
      master_clk_i   => clk_125m_pllref_p,
      master_rst_n_i => clk_125m_pllref_p_rstn,
      master_i       => cbar_ref_slave_o(0),
      master_o       => cbar_ref_slave_i(0));
   
  GSI_CON : xwb_sdb_crossbar
   generic map(
     g_num_masters => c_masters,
     g_num_slaves  => c_slaves,
     g_registered  => true,
     g_wraparound  => true,
     g_layout      => c_layout,
     g_sdb_addr    => c_sdb_address)
   port map(
     clk_sys_i     => pllout_clk_sys,
     rst_n_i       => pllout_clk_sys_rstn,
     -- Master connections (INTERCON is a slave)
     slave_i       => cbar_slave_i,
     slave_o       => cbar_slave_o,
     -- Slave connections (INTERCON is a master)
     master_i      => cbar_master_i,
     master_o      => cbar_master_o);

-- leds 
	leds_o(0)	<=	ext_pps;
	leds_o(1)	<=	eca_toggle(0);
	  
-- lemo I/O	  
   lemo_en_o 	<= "01";	-- lemo output enable
   
	lemo_o(0)			<=	ext_pps;
	lemo_o(1)			<= eca_toggle(0);
	triger_latch(0)	<=	lemo_i(0);

end rtl;
