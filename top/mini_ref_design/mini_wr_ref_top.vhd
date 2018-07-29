library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;
use work.wr_board_pkg.all;
use work.wr_mini_pkg.all;
use work.wrcore_pkg.all;
use work.wr_xilinx_pkg.all;
use work.endpoint_pkg.all;
use work.etherbone_pkg.all;
use work.wr_fabric_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity mini_wr_ref_top is
generic (
  g_dpram_initf : string := "../../bin/wrpc/wrc_mini_phy8.bram";
  g_sfp0_enable : boolean:= true;
  g_sfp1_enable : boolean:= false;
  g_aux_sdb            : t_sdb_device  := c_xwb_xil_multiboot_sdb;
  g_multiboot_enable   : boolean:= true
);
port
(
-- clock
  -- clk20              : in std_logic;    -- 20mhz vcxo clock
  fpga_clk_p         : in std_logic;  -- 125 mhz pll reference
  fpga_clk_n         : in std_logic;
  -- ref_1_101_clk_p  : in std_logic;  -- dedicated clock for xilinx gtp transceiver
  -- ref_1_101_clk_n  : in std_logic;
  ref_1_123_clk_p  : in std_logic;  -- dedicated clock for xilinx gtp transceiver
  ref_1_123_clk_n  : in std_logic;
  
-- pll
  plldac_sclk        : out std_logic;
  plldac_din         : out std_logic;
  plldac_load_n      : out std_logic;
  plldac_sync_n      : out std_logic;
  
-- eeprom
  eeprom_scl         : inout std_logic;
  eeprom_sda         : inout std_logic;
  
-- 1-wire
  one_wire           : inout std_logic;      -- 1-wire interface to ds18b20
  
  -- flash
  flash_sclk_o       : out std_logic;
  flash_ncs_o        : out std_logic;
  flash_mosi_o       : out std_logic;
  flash_miso_i       : in  std_logic:='1';

-- sfp0 pins
  m_sfp0_tx_p        : out   std_logic;
  m_sfp0_tx_n        : out   std_logic;
  m_sfp0_rx_p        : in    std_logic;
  m_sfp0_rx_n        : in    std_logic;
  m_sfp0_c1          : inout std_logic;  -- scl
  m_sfp0_c2          : inout std_logic;  -- sda

-- sfp1 pins 
  -- m_sfp1_tx_p        : out   std_logic;
  -- m_sfp1_tx_n        : out   std_logic;
  -- m_sfp1_rx_p        : in    std_logic;
  -- m_sfp1_rx_n        : in    std_logic;
  -- m_sfp1_c1          : inout std_logic;  -- scl
  -- m_sfp1_c2          : inout std_logic;  -- sda

  --uart
  m_uart_rx        : out std_logic;
  m_uart_tx        : in  std_logic;

  -- user interface
  m_pps_o_p        : out   std_logic;
  m_pps_o_n        : out   std_logic;
  -- m_clk_o_p        : out   std_logic;
  -- m_clk_o_n        : out   std_logic;
  m_clk_125_o_p    : out   std_logic;
  m_clk_125_o_n    : out   std_logic
  -- m_pdata_tx_0_7_dat : in  std_logic_vector(7 downto 0);
  -- m_pdata_tx_8_valid : in  std_logic;
  -- m_pdata_tx_9_cts   : out std_logic; 
  -- m_pdata_rx_0_7_dat : out std_logic_vector(7 downto 0);
  -- m_pdata_rx_8_9_ctl : out std_logic_vector(1 downto 0)

  -- s_sfp0_tx_p      : out   std_logic;
  -- s_sfp0_tx_n      : out   std_logic;
  -- s_sfp0_rx_p      : in    std_logic;
  -- s_sfp0_rx_n      : in    std_logic;
  -- s_sfp0_c0        : in    std_logic;  -- det
  -- s_sfp0_c1        : inout std_logic;  -- scl
  -- s_sfp0_c2        : inout std_logic;  -- sda
  -- s_sfp1_tx_p      : out   std_logic;
  -- s_sfp1_tx_n      : out   std_logic;
  -- s_sfp1_rx_p      : in    std_logic;
  -- s_sfp1_rx_n      : in    std_logic;
  -- s_sfp1_c0        : in    std_logic;  -- det
  -- s_sfp1_c1        : inout std_logic;  -- scl
  -- s_sfp1_c2        : inout std_logic;  -- sda
  -- s_uart_rx        : out   std_logic;  -- uart
  -- s_uart_tx        : in    std_logic;  -- uart
  -- s_pps_o_p        : out   std_logic;
  -- s_pps_o_n        : out   std_logic;
  -- s_clk_o_p        : out   std_logic;
  -- s_clk_o_n        : out   std_logic;
  -- s_clk_125_o_p    : out   std_logic;
  -- s_clk_125_o_n    : out   std_logic
);
end mini_wr_ref_top;

architecture rtl of mini_wr_ref_top is

------------------------------------------------------------------------------
-- components declaration
------------------------------------------------------------------------------
component mini_reset_gen is
  port (
    clk_sys_i : in std_logic;
    rst_button_n_a_i : in std_logic;
    rst_n_o : out std_logic
  );
end component;

component mini_serial_dac_arb is
  generic(
    g_invert_sclk    : boolean;
    g_num_data_bits  : integer;
    g_num_extra_bits : integer);
  port(
    clk_i   : in std_logic;
    rst_n_i : in std_logic;

    val_i   : in std_logic_vector(g_num_data_bits-1 downto 0);
    load_i  : in std_logic;

    plldac_load_n_o : out std_logic;
    plldac_sync_n_o : out std_logic;
    plldac_sclk_o   : out std_logic;
    plldac_din_o    : out std_logic);
end component;

component mini_core_ref_top is
  generic
    (
      g_simulation                : integer              := 0;
      g_dpram_initf : string := "../../bin/wrpc/wrc_phy8.bram";
      g_sfp0_enable               : boolean:= true;
      g_sfp1_enable               : boolean:= false;
      g_aux_sdb                   : t_sdb_device  := c_xwb_xil_multiboot_sdb;
      g_multiboot_enable          : boolean:= false);
  port
    (
      rst_n_i              : in  std_logic;
      clk_20m_i            : in  std_logic;
      clk_dmtd_i           : in  std_logic;
      clk_sys_i            : in  std_logic;    
      clk_ref_i            : in  std_logic;
      clk_sfp0_i           : in  std_logic :='0';
      clk_sfp1_i           : in  std_logic :='0';
      dac_hpll_load_p1_o   : out std_logic;
      dac_hpll_data_o      : out std_logic_vector(15 downto 0);
      dac_dpll_load_p1_o   : out std_logic;
      dac_dpll_data_o      : out std_logic_vector(15 downto 0);
      eeprom_scl_i         : in  std_logic;
      eeprom_scl_o         : out std_logic;
      eeprom_sda_i         : in  std_logic;
      eeprom_sda_o         : out std_logic;
      flash_sclk_o         : out std_logic;
      flash_ncs_o          : out std_logic;
      flash_mosi_o         : out std_logic;
      flash_miso_i         : in  std_logic:='1';
      onewire_i            : in  std_logic;
      onewire_oen_o        : out std_logic;
      uart_rxd_i           : in  std_logic:='0';
      uart_txd_o           : out std_logic;
      sfp0_txp_o           : out std_logic;
      sfp0_txn_o           : out std_logic;
      sfp0_rxp_i           : in  std_logic:='0';
      sfp0_rxn_i           : in  std_logic:='0';
      sfp0_det_i           : in  std_logic:='0';  -- sfp detect
      sfp0_scl_i           : in  std_logic:='0';  -- scl
      sfp0_scl_o           : out std_logic;  -- scl
      sfp0_sda_i           : in  std_logic:='0';  -- sda
      sfp0_sda_o           : out std_logic;  -- sda
      sfp0_rate_select_o   : out std_logic;
      sfp0_tx_fault_i      : in  std_logic:='0';
      sfp0_tx_disable_o    : out std_logic;
      sfp0_los_i           : in  std_logic:='0';
      sfp0_refclk_sel_i    : in  std_logic_vector(2 downto 0):="000";
      sfp0_rx_rbclk_o      : out std_logic;
      sfp1_txp_o           : out std_logic;
      sfp1_txn_o           : out std_logic;
      sfp1_rxp_i           : in  std_logic:='0';
      sfp1_rxn_i           : in  std_logic:='0';
      sfp1_det_i           : in  std_logic:='0';
      sfp1_scl_i           : in  std_logic:='0';
      sfp1_scl_o           : out std_logic:='0';
      sfp1_sda_i           : in  std_logic:='0';
      sfp1_sda_o           : out std_logic:='0';
      sfp1_rate_select_o   : out std_logic;
      sfp1_tx_fault_i      : in  std_logic:='0';
      sfp1_tx_disable_o    : out std_logic;
      sfp1_los_i           : in  std_logic:='0';
      sfp1_refclk_sel_i    : in  std_logic_vector(2 downto 0):="000";
      sfp1_rx_rbclk_o      : out std_logic;
      wb_slave_o           : out t_wishbone_slave_out;
      wb_slave_i           : in  t_wishbone_slave_in := cc_dummy_slave_in;
      aux_master_o         : out t_wishbone_master_out;
      aux_master_i         : in  t_wishbone_master_in := cc_dummy_master_in;
      wrf_src_o            : out t_wrf_source_out;
      wrf_src_i            : in  t_wrf_source_in := c_dummy_src_in;
      wrf_snk_o            : out t_wrf_sink_out;
      wrf_snk_i            : in  t_wrf_sink_in   := c_dummy_snk_in;
      wb_eth_master_o      : out t_wishbone_master_out;
      wb_eth_master_i      : in  t_wishbone_master_in := cc_dummy_master_in;
      tm_link_up_o         : out std_logic;
      tm_time_valid_o      : out std_logic;
      tm_tai_o             : out std_logic_vector(39 downto 0);
      tm_cycles_o          : out std_logic_vector(27 downto 0);
      led_act_o            : out std_logic;
      led_link_o           : out std_logic;
      btn1_i               : in  std_logic := '1';
      btn2_i               : in  std_logic := '1';
      pps_p_o              : out std_logic;
      pps_led_o            : out std_logic;
      pps_csync_o          : out std_logic;
      link_ok_o            : out std_logic
      );
end component;

------------------------------------------------------------------------------
-- signals declaration
------------------------------------------------------------------------------
  signal local_reset_n      : std_logic;
  signal fpga_clk_i         : std_logic;
  signal clk_ref_i          : std_logic;
  signal clk_sys_i          : std_logic;
  signal clk_dmtd_i         : std_logic;
  signal clk_sfp0_i         : std_logic;
  signal clk_sfp1_i         : std_logic;
  signal pllout_clk_20      : std_logic;
  signal pllout_clk_62_5    : std_logic;
  signal pllout_clk_125     : std_logic;
  signal pllout_clk_fb_ref  : std_logic;
  signal pllout_clk_fb_dmtd : std_logic;
  signal pllout_clk_dmtd    : std_logic;
  signal clk_ref_output     : std_logic;
  signal uart_tx            : std_logic;
  signal uart_rx            : std_logic;
  signal onewire_i          : std_logic;
  signal onewire_oen_o      : std_logic;
  signal sfp0_tx_p          : std_logic;
  signal sfp0_tx_n          : std_logic;
  signal sfp0_rx_p          : std_logic;
  signal sfp0_rx_n          : std_logic;
  signal sfp1_tx_p          : std_logic;
  signal sfp1_tx_n          : std_logic;
  signal sfp1_rx_p          : std_logic;
  signal sfp1_rx_n          : std_logic;
  signal sfp0_scl_i         : std_logic;
  signal sfp0_scl_o         : std_logic;
  signal sfp0_sda_i         : std_logic;
  signal sfp0_sda_o         : std_logic;
  signal sfp0_tx_fault      : std_logic:='0';
  signal sfp0_tx_disable    : std_logic;
  signal sfp0_tx_los        : std_logic:='0';
  signal sfp1_scl_i         : std_logic;
  signal sfp1_scl_o         : std_logic;
  signal sfp1_sda_i         : std_logic;
  signal sfp1_sda_o         : std_logic;
  signal sfp1_tx_fault      : std_logic:='0';
  signal sfp1_tx_disable    : std_logic;
  signal sfp1_tx_los        : std_logic:='0';
  signal dac_dpll_load_p1   : std_logic;
  signal dac_dpll_data      : std_logic_vector(15 downto  0);
  signal pps_out            : std_logic;
  signal pps_p1             : std_logic;
  signal tm_tai             : std_logic_vector(39 downto 0);
  signal tm_tai_valid       : std_logic;
  signal cnx_master_out     : t_wishbone_master_out_array(0 downto 0);
  signal cnx_master_in      : t_wishbone_master_in_array(0 downto 0);
  signal cnx_slave_out      : t_wishbone_slave_out_array(0 downto 0);
  signal cnx_slave_in       : t_wishbone_slave_in_array(0 downto 0);

  -- cascaded PLL
  signal clk_chainpll          : std_logic;
  signal clk_chainpll_bufg     : std_logic;
  signal clk_rx                : std_logic;
  signal pllout_clk_39         : std_logic;
  signal pllout_clk_51         : std_logic;
  signal pllout_clk_fb_chain1  : std_logic;
  signal pllout_clk_fb_chain2  : std_logic;
  signal pllout_clk_fb_chain3  : std_logic;
  signal pllout_clk_chain1     : std_logic;
  signal pllout_clk_chain2     : std_logic;
  signal pllout_clk_chain3     : std_logic;
  signal pllout_rst_chain1     : std_logic;
  signal pllout_rst_chain2     : std_logic;
  signal pllout_rst_chain3     : std_logic;
  
begin

u_reset_gen : mini_reset_gen
  port map (
    clk_sys_i        => clk_sys_i,
    rst_button_n_a_i => '1',
    rst_n_o          => local_reset_n);

cmp_refclk_buf : ibufgds
  generic map (
    diff_term    => true,  -- differential termination
    ibuf_low_pwr => true,  -- low power (true) vs. performance (false) setting for referenced i/o standards
    iostandard   => "default")
  port map (
    o  => fpga_clk_i,  -- buffer output
    i  => fpga_clk_p,  -- diff_p buffer input (connect directly to top-level port)
    ib => fpga_clk_n); -- diff_n buffer input (connect directly to top-level port)

cmp_sfp0_dedicated_clk_buf : ibufds
 generic map(
   diff_term    => true,
   ibuf_low_pwr => true,
   iostandard   => "default")
 port map (
   o  => clk_sfp0_i,
   i  => ref_1_123_clk_p,
   ib => ref_1_123_clk_n);

-- cmp_sfp1_dedicated_clk_buf : ibufds
--   generic map(
--     diff_term    => true,
--     ibuf_low_pwr => true,
--     iostandard   => "default")
--   port map (
--     o  => clk_sfp1_i,
--     i  => ref_1_101_clk_p,
--     ib => ref_1_101_clk_n);

cmp_sys_clk_pll : pll_base
  generic map (
    bandwidth          => "optimized",
    clk_feedback       => "clkfbout",
    compensation       => "internal",
    divclk_divide      => 1,
    clkfbout_mult      => 8,
    clkfbout_phase     => 0.000,
    clkout0_divide     => 16,        -- 62.5 mhz
    clkout0_phase      => 0.000,
    clkout0_duty_cycle => 0.500,
    clkout1_divide     => 8,         -- 125 mhz
    clkout1_phase      => 0.000,
    clkout1_duty_cycle => 0.500,
    clkout2_divide     => 50,        -- 20 mhz
    clkout2_phase      => 0.000,
    clkout2_duty_cycle => 0.500,
    clkin_period       => 8.0,
    ref_jitter         => 0.016)
  port map (
    clkfbout => pllout_clk_fb_ref,
    clkout0  => pllout_clk_62_5,
    clkout1  => pllout_clk_125,
    clkout2  => pllout_clk_20,
    clkout3  => open,
    clkout4  => open,
    clkout5  => open,
    locked   => open,
    rst      => '0',
    clkfbin  => pllout_clk_fb_ref,
    clkin    => fpga_clk_i);

cmp_clk_sys_buf : bufg
  port map (
    o => clk_sys_i,
    i => pllout_clk_62_5);

cmd_clk_ref_buf: bufg
  port map(
    o => clk_ref_i,
    i => pllout_clk_125);

cmp_chain1_clk_pll : pll_base
  generic map (
    bandwidth          => "optimized",
    clk_feedback       => "clkfbout",
    compensation       => "internal",
    divclk_divide      => 1,
    clkfbout_mult      => 5,
    clkfbout_phase     => 0.000,
    clkout0_divide     => 16,        -- 125*5/16 = 39.0625 
    clkout0_phase      => 0.000,
    clkout0_duty_cycle => 0.500,
    clkout1_divide     => 5,         -- 125 mhz
    clkout1_phase      => 0.000,
    clkout1_duty_cycle => 0.500,
    clkout2_divide     => 10,        -- 62.5 mhz
    clkout2_phase      => 0.000,
    clkout2_duty_cycle => 0.500,
    clkout5_divide     => 5,         -- 125 mhz
    clkout5_phase      => 0.000,
    clkout5_duty_cycle => 0.500,
    clkin_period       => 8.0,
    ref_jitter         => 0.016)
  port map (
    clkfbout => pllout_clk_fb_chain1,
    clkout0  => pllout_clk_39,
    clkout1  => open,
    clkout2  => open,
    clkout3  => open,
    clkout4  => open,
    clkout5  => open,
    locked   => open,
    rst      => '0',
    clkfbin  => pllout_clk_fb_chain1,
    clkin    => clk_rx);

cmp_dmtd2_clk_pll : pll_base
  generic map (
    bandwidth          => "optimized",
    clk_feedback       => "clkfbout",
    compensation       => "internal",
    divclk_divide      => 1,
    clkfbout_mult      => 21,
    clkfbout_phase     => 0.000,
    clkout0_divide     => 16,     -- 125*5/16.0*21/16 = 51.3  
    clkout0_phase      => 0.000,
    clkout0_duty_cycle => 0.500,
    clkout1_divide     => 16,         
    clkout1_phase      => 0.000,
    clkout1_duty_cycle => 0.500,
    clkout2_divide     => 16,         
    clkout2_phase      => 0.000,
    clkout2_duty_cycle => 0.500,
    clkin_period       => 25.6,
    ref_jitter         => 0.016)
  port map (
    clkfbout => pllout_clk_fb_chain2,
    clkout0  => pllout_clk_51,
    clkout1  => open,
    clkout2  => open,
    clkout3  => open,
    clkout4  => open,
    clkout5  => open,
    locked   => pllout_rst_chain2,
    rst      => '0',
    clkfbin  => pllout_clk_fb_chain2,
    clkin    => pllout_clk_chain1);

cmp_dmtd3_clk_pll : pll_base
  generic map (
    bandwidth          => "optimized",
    clk_feedback       => "clkfbout",
    compensation       => "internal",
    divclk_divide      => 2,
    clkfbout_mult      => 39,
    clkfbout_phase     => 0.000,
    clkout0_divide     => 16,    -- 125*4095/4096/2 = 62.48
    clkout0_phase      => 0.000,
    clkout0_duty_cycle => 0.500,
    clkout1_divide     => 16,         
    clkout1_phase      => 0.000,
    clkout1_duty_cycle => 0.500,
    clkout2_divide     => 16,         
    clkout2_phase      => 0.000,
    clkout2_duty_cycle => 0.500,
    clkin_period       => 19.505,
    ref_jitter         => 0.016)
  port map (
    clkfbout => pllout_clk_fb_chain3,
    clkout0  => clk_chainpll,
    clkout1  => open,
    clkout2  => open,
    clkout3  => open,
    clkout4  => open,
    clkout5  => open,
    locked   => pllout_rst_chain3,
    rst      => '0',
    clkfbin  => pllout_clk_fb_chain3,
    clkin    => pllout_clk_chain2);

cmp_clk_dmtd1_buf : bufg
  port map (
    o => pllout_clk_chain1,
    i => pllout_clk_39);

cmp_clk_dmtd2_buf : bufg
  port map (
    o => pllout_clk_chain2,
    i => pllout_clk_51);

cmp_clk_chain_buf : BUFG
  port map (
    O => clk_dmtd_i,
    I => clk_chainpll);

u_wr_core : mini_core_ref_top
  generic map(
    g_dpram_initf => g_dpram_initf,
    g_sfp0_enable => g_sfp0_enable,
    g_sfp1_enable => g_sfp1_enable,
    g_aux_sdb     => g_aux_sdb,
    g_multiboot_enable => g_multiboot_enable)
  port map (
    rst_n_i             => local_reset_n,
    clk_20m_i           => pllout_clk_20,
    clk_sys_i           => clk_sys_i,
    clk_dmtd_i          => clk_dmtd_i,
    clk_ref_i           => clk_ref_i,
    clk_sfp0_i          => clk_sfp0_i,
    -- clk_sfp1_i          => clk_sfp1_i,
    dac_hpll_load_p1_o  => open,
    dac_hpll_data_o     => open,
    dac_dpll_load_p1_o  => dac_dpll_load_p1,
    dac_dpll_data_o     => dac_dpll_data,
    eeprom_scl_i        => '1',
    eeprom_scl_o        => open,
    eeprom_sda_i        => '1',
    eeprom_sda_o        => open,
    onewire_i           => onewire_i,
    onewire_oen_o       => onewire_oen_o,
    flash_sclk_o        => flash_sclk_o,
    flash_ncs_o         => flash_ncs_o,
    flash_mosi_o        => flash_mosi_o,
    flash_miso_i        => flash_miso_i,
    uart_rxd_i          => uart_tx,
    uart_txd_o          => uart_rx,
    sfp0_txp_o          => sfp0_tx_p,
    sfp0_txn_o          => sfp0_tx_n,
    sfp0_rxp_i          => sfp0_rx_p,
    sfp0_rxn_i          => sfp0_rx_n,
    sfp0_det_i          => '0',
    sfp0_scl_i          => sfp0_scl_i,
    sfp0_scl_o          => sfp0_scl_o,
    sfp0_sda_i          => sfp0_sda_i,
    sfp0_sda_o          => sfp0_sda_o,
    sfp0_rate_select_o  => open,
    sfp0_tx_fault_i     => sfp0_tx_fault,
    sfp0_tx_disable_o   => sfp0_tx_disable,
    sfp0_los_i          => sfp0_tx_los,
    sfp0_refclk_sel_i   => "100",
    sfp0_rx_rbclk_o     => clk_rx,
    -- sfp1_txp_o          => sfp1_tx_p,
    -- sfp1_txn_o          => sfp1_tx_n,
    -- sfp1_rxp_i          => sfp1_rx_p,
    -- sfp1_rxn_i          => sfp1_rx_n,
    -- sfp1_det_i          => '0',
    -- sfp1_scl_i          => sfp1_scl_i,
    -- sfp1_scl_o          => sfp1_scl_o,
    -- sfp1_sda_i          => sfp1_sda_i,
    -- sfp1_sda_o          => sfp1_sda_o,
    -- sfp1_rate_select_o  => open,
    -- sfp1_tx_fault_i     => sfp1_tx_fault,
    -- sfp1_tx_disable_o   => sfp1_tx_disable,
    -- sfp1_los_i          => sfp1_tx_los,
    -- sfp1_refclk_sel_i   => "100",
    -- sfp1_rx_rbclk_o     => open,
    -- wb_slave_o          => cnx_slave_out(0),
    -- wb_slave_i          => cnx_slave_in(0),
    -- wb_eth_master_o     => cnx_master_out(0),
    -- wb_eth_master_i     => cnx_master_in(0),
    tm_link_up_o        => open,
    tm_time_valid_o     => tm_tai_valid,
    tm_tai_o            => tm_tai,
    tm_cycles_o         => open,
    pps_p_o             => pps_out,
    pps_csync_o         => pps_p1,
    link_ok_o           => open);
  
  -- cnx_slave_in <= cnx_master_out;
  -- cnx_master_in <= cnx_slave_out;

u_dac_arb: mini_serial_dac_arb
generic map (
    g_invert_sclk    => false,
    g_num_data_bits  => 16,
    g_num_extra_bits => 8)
port map (
    clk_i            => clk_sys_i,
    rst_n_i          => local_reset_n,
    val_i            => dac_dpll_data,
    load_i           => dac_dpll_load_p1,
    plldac_sync_n_o  => plldac_sync_n,
    plldac_load_n_o  => plldac_load_n,
    plldac_sclk_o    => plldac_sclk,
    plldac_din_o     => plldac_din
);

  m_sfp0_tx_p <= sfp0_tx_p;
  m_sfp0_tx_n <= sfp0_tx_n;
  sfp0_rx_p <= m_sfp0_rx_p;
  sfp0_rx_n <= m_sfp0_rx_n;

  -- m_sfp1_tx_p <= sfp1_tx_p;
  -- m_sfp1_tx_n <= sfp1_tx_n;
  -- sfp1_rx_p <= m_sfp1_rx_p;
  -- sfp1_rx_n <= m_sfp1_rx_n;

  uart_tx <= m_uart_tx;
  m_uart_rx <= uart_rx;

  m_sfp0_c1   <= '0' when sfp0_scl_o = '0' else 'Z';
  m_sfp0_c2   <= '0' when sfp0_sda_o = '0' else 'Z';
  sfp0_scl_i <= m_sfp0_c1;
  sfp0_sda_i <= m_sfp0_c2;

  -- m_sfp1_c1   <= '0' when sfp1_scl_o = '0' else 'Z';
  -- m_sfp1_c2   <= '0' when sfp1_sda_o = '0' else 'Z';
  -- sfp1_scl_i <= m_sfp1_c1;
  -- sfp1_sda_i <= m_sfp1_c2;

  one_wire <= '0' when onewire_oen_o = '1' else 'Z';
  onewire_i  <= one_wire;

  cmp_pps_output:obufds
  port map(
    o  => m_pps_o_p,
    ob => m_pps_o_n,
    i  => pps_out);

  cmp_ref_output_p:oddr2
  generic map(
    ddr_alignment => "none",
    init => '0',
    srtype => "sync")
  port map(
    q  => clk_ref_output,
    c0 => clk_ref_i,
    c1 => not clk_ref_i,
    ce => '1',
    d0 => '1',
    d1 => '0',
    r  => '0',
    s  => '0'
  );
  
  cmp_clk_ref_output:obufds
  port map(
    o  => m_clk_125_o_p,
    ob => m_clk_125_o_n,
    i  => clk_ref_output);

end rtl;
