-------------------------------------------------------------------------------
-- Title      : WRPC Wrapper for SVEC
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : xwrc_board_svec.vhd
-- Author(s)  : Dimitrios Lampridis  <dimitrios.lampridis@cern.ch>
-- Company    : CERN (BE-CO-HT)
-- Created    : 2017-02-16
-- Last update: 2017-02-17
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level wrapper for WR PTP core including all the modules
-- needed to operate the core on the SVEC board.
-- http://www.ohwr.org/projects/svec/
-------------------------------------------------------------------------------
-- Copyright (c) 2016-2017 CERN
-------------------------------------------------------------------------------
-- GNU LESSER GENERAL PUBLIC LICENSE
--
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wishbone_pkg.all;
use work.etherbone_pkg.all;
use work.wr_fabric_pkg.all;
use work.endpoint_pkg.all;
use work.streamers_pkg.all;
use work.wr_xilinx_pkg.all;
use work.wr_svec_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity xwrc_board_svec is
  generic(
    -- set to 1 to speed up some initialization processes during simulation
    g_simulation                : integer := 0;
    -- Select whether to include external ref clock input
    g_with_external_clock_input : boolean := TRUE;
    -- "plainfbrc" = expose WRC fabric interface
    -- "streamers" = attach WRC streamers to fabric interface
    -- "etherbone" = attach Etherbone slave to fabric interface
    g_fabric_iface              : string  := "plainfbrc";
    -- data width when g_fabric_iface = "streamers" (otherwise ignored)
    g_streamer_width            : integer := 32;
    -- memory initialisation file for embedded CPU
    g_dpram_initf               : string  := "../../bin/wrpc/wrc_phy8.bram"
    );
  port (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------

    -- Reset from system fpga
    areset_n_i : in std_logic;

    -- Clock inputs from the board
    clk_20m_vcxo_i : in std_logic;

    clk_125m_pllref_p_i : in std_logic;
    clk_125m_pllref_n_i : in std_logic;

    clk_125m_gtp_n_i : in std_logic;
    clk_125m_gtp_p_i : in std_logic;

    -- 10MHz ext ref clock input (g_with_external_clock_input = TRUE)
    clk_10m_ext_ref_i : in std_logic := '0';

    -- 62.5MHz sys clock output
    clk_sys_62m5_o : out std_logic;

    -- 125MHz ref clock output
    clk_ref_125m_o : out std_logic;

    -- active high reset output, synchronous to clk_sys_62m5_o
    rst_sys_62m5_o : out std_logic;

    ---------------------------------------------------------------------------
    -- SPI interfaces to DACs
    ---------------------------------------------------------------------------

    pll20dac_din_o    : out std_logic;
    pll20dac_sclk_o   : out std_logic;
    pll20dac_sync_n_o : out std_logic;
    pll25dac_din_o    : out std_logic;
    pll25dac_sclk_o   : out std_logic;
    pll25dac_sync_n_o : out std_logic;

    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver and SFP management info
    ---------------------------------------------------------------------------

    sfp_txp_o         : out std_logic;
    sfp_txn_o         : out std_logic;
    sfp_rxp_i         : in  std_logic;
    sfp_rxn_i         : in  std_logic;
    sfp_det_i         : in  std_logic := '1';
    sfp_sda_i         : in  std_logic;
    sfp_sda_o         : out std_logic;
    sfp_scl_i         : in  std_logic;
    sfp_scl_o         : out std_logic;
    sfp_rate_select_o : out std_logic;
    sfp_tx_fault_i    : in  std_logic := '0';
    sfp_tx_disable_o  : out std_logic;
    sfp_los_i         : in  std_logic := '0';

    ---------------------------------------------------------------------------
    -- I2C EEPROM
    ---------------------------------------------------------------------------

    eeprom_sda_i : in  std_logic;
    eeprom_sda_o : out std_logic;
    eeprom_scl_i : in  std_logic;
    eeprom_scl_o : out std_logic;

    ---------------------------------------------------------------------------
    -- Onewire interface
    ---------------------------------------------------------------------------

    onewire_i     : in  std_logic;
    onewire_oen_o : out std_logic;

    ---------------------------------------------------------------------------
    -- UART
    ---------------------------------------------------------------------------

    uart_rxd_i : in  std_logic;
    uart_txd_o : out std_logic;

    ---------------------------------------------------------------------------
    -- SPI (flash is connected to SFPGA and routed to AFPGA
    -- once the boot process is complete)
    ---------------------------------------------------------------------------

    spi_sclk_o : out std_logic;
    spi_ncs_o  : out std_logic;
    spi_mosi_o : out std_logic;
    spi_miso_i : in  std_logic;

    ---------------------------------------------------------------------------
    -- External WB interface
    ---------------------------------------------------------------------------

    wb_slave_o : out t_wishbone_slave_out;
    wb_slave_i : in  t_wishbone_slave_in := cc_dummy_slave_in;

    ---------------------------------------------------------------------------
    -- WR fabric interface (when g_fabric_iface = "plainfbrc")
    ---------------------------------------------------------------------------

    wrf_src_o : out t_wrf_source_out;
    wrf_src_i : in  t_wrf_source_in := c_dummy_src_in;
    wrf_snk_o : out t_wrf_sink_out;
    wrf_snk_i : in  t_wrf_sink_in   := c_dummy_snk_in;

    ---------------------------------------------------------------------------
    -- WR streamers (when g_fabric_iface = "streamers")
    ---------------------------------------------------------------------------

    wrs_tx_data_i  : in  std_logic_vector(g_streamer_width-1 downto 0) := (others => '0');
    wrs_tx_valid_i : in  std_logic                                     := '0';
    wrs_tx_dreq_o  : out std_logic;
    wrs_tx_last_i  : in  std_logic                                     := '1';
    wrs_tx_flush_i : in  std_logic                                     := '0';
    wrs_rx_first_o : out std_logic;
    wrs_rx_last_o  : out std_logic;
    wrs_rx_data_o  : out std_logic_vector(g_streamer_width-1 downto 0);
    wrs_rx_valid_o : out std_logic;
    wrs_rx_dreq_i  : in  std_logic                                     := '0';

    ---------------------------------------------------------------------------
    -- Etherbone WB master interface (when g_fabric_iface = "etherbone")
    ---------------------------------------------------------------------------

    wb_eth_master_o : out t_wishbone_master_out;
    wb_eth_master_i : in  t_wishbone_master_in := cc_dummy_master_in;

    ---------------------------------------------------------------------------
    -- WRPC timing interface and status
    ---------------------------------------------------------------------------

    pps_ext_i       : in  std_logic;
    pps_p_o         : out std_logic;
    pps_led_o       : out std_logic;
    tm_time_valid_o : out std_logic;
    tm_tai_o        : out std_logic_vector(39 downto 0);
    tm_cycles_o     : out std_logic_vector(27 downto 0);
    led_link_o      : out std_logic;
    led_act_o       : out std_logic);

end entity xwrc_board_svec;


architecture struct of xwrc_board_svec is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- IBUFDS
  signal clk_125m_pllref_buf : std_logic;

  -- PLLs
  signal clk_pll_62m5 : std_logic;
  signal clk_pll_125m : std_logic;
  signal clk_pll_dmtd : std_logic;
  signal pll_locked   : std_logic;

  -- Reset logic
  signal rst_62m5_n       : std_logic;
  signal rstlogic_arst_n  : std_logic;
  signal rstlogic_clk_in  : std_logic_vector(0 downto 0);
  signal rstlogic_rst_out : std_logic_vector(0 downto 0);

  -- PLL DAC ARB
  signal dac_hpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_load_p1 : std_logic;
  signal dac_dpll_data    : std_logic_vector(15 downto 0);

  -- OneWire
  signal onewire_in : std_logic_vector(1 downto 0);
  signal onewire_en : std_logic_vector(1 downto 0);

  -- PHY
  signal phy8_to_wrc    : t_phy_8bits_to_wrc;
  signal phy8_from_wrc  : t_phy_8bits_from_wrc;
  signal phy16_to_wrc   : t_phy_16bits_to_wrc;
  signal phy16_from_wrc : t_phy_16bits_from_wrc;

  -- Timecode interface
  signal tm_time_valid : std_logic;
  signal tm_tai        : std_logic_vector(39 downto 0);
  signal tm_cycles     : std_logic_vector(27 downto 0);

  -- WR SNMP
  signal aux_diag_in  : t_generic_word_array(c_WR_TRANS_ARR_SIZE_OUT-1 downto 0);
  signal aux_diag_out : t_generic_word_array(c_WR_TRANS_ARR_SIZE_IN-1 downto 0);

  -- WR fabric interface
  signal wrf_src_out : t_wrf_source_out;
  signal wrf_src_in  : t_wrf_source_in;
  signal wrf_snk_out : t_wrf_sink_out;
  signal wrf_snk_in  : t_wrf_sink_in;

  -- Aux WB interface
  signal aux_master_out : t_wishbone_master_out;
  signal aux_master_in  : t_wishbone_master_in;
  signal aux_rst_n      : std_logic;

  -- External reference
  signal ext_ref_mul         : std_logic;
  signal ext_ref_mul_locked  : std_logic;
  signal ext_ref_mul_stopped : std_logic;
  signal ext_ref_rst         : std_logic;


  component spec_serial_dac is
    generic (
      g_num_data_bits  : integer;
      g_num_extra_bits : integer;
      g_num_cs_select  : integer);
    port (
      clk_i         : in  std_logic;
      rst_n_i       : in  std_logic;
      value_i       : in  std_logic_vector(g_num_data_bits-1 downto 0);
      cs_sel_i      : in  std_logic_vector(g_num_cs_select-1 downto 0);
      load_i        : in  std_logic;
      sclk_divsel_i : in  std_logic_vector(2 downto 0);
      dac_cs_n_o    : out std_logic_vector(g_num_cs_select-1 downto 0);
      dac_sclk_o    : out std_logic;
      dac_sdata_o   : out std_logic;
      xdone_o       : out std_logic);
  end component spec_serial_dac;

begin  -- architecture struct

  -----------------------------------------------------------------------------
  -- Check for unsupported features and/or misconfiguration
  -----------------------------------------------------------------------------

  gen_unknown_wrfabric : if(g_fabric_iface /= "plainfbrc") and
                           (g_fabric_iface /= "streamers") and
                           (g_fabric_iface /= "etherbone")
  generate
    assert FALSE
      report "WR PTP core fabric interface [" & g_fabric_iface & "] is not supported"
      severity ERROR;
  end generate gen_unknown_wrfabric;

  -----------------------------------------------------------------------------
  -- Platform-dependent part (PHY, PLLs, buffers, etc)
  -----------------------------------------------------------------------------

  cmp_ibufgds_pllref : IBUFGDS
    generic map (
      DIFF_TERM    => TRUE,
      IBUF_LOW_PWR => TRUE,
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => clk_125m_pllref_buf,
      I  => clk_125m_pllref_p_i,
      IB => clk_125m_pllref_n_i);

  cmp_xwrc_platform : xwrc_platform_xilinx
    generic map (
      g_fpga_family               => "spartan6",
      g_with_external_clock_input => g_with_external_clock_input,
      g_use_default_plls          => TRUE,
      g_simulation                => g_simulation)
    port map (
      areset_n_i            => areset_n_i,
      clk_10m_ext_i         => clk_10m_ext_ref_i,
      clk_20m_vcxo_i        => clk_20m_vcxo_i,
      clk_125m_pllref_i     => clk_125m_pllref_buf,
      clk_125m_gtp_p_i      => clk_125m_gtp_p_i,
      clk_125m_gtp_n_i      => clk_125m_gtp_n_i,
      sfp_txn_o             => sfp_txn_o,
      sfp_txp_o             => sfp_txp_o,
      sfp_rxn_i             => sfp_rxn_i,
      sfp_rxp_i             => sfp_rxp_i,
      sfp_tx_fault_i        => sfp_tx_fault_i,
      sfp_los_i             => sfp_los_i,
      sfp_tx_disable_o      => sfp_tx_disable_o,
      clk_62m5_sys_o        => clk_pll_62m5,
      clk_125m_ref_o        => clk_pll_125m,
      clk_62m5_dmtd_o       => clk_pll_dmtd,
      pll_locked_o          => pll_locked,
      phy8_o                => phy8_to_wrc,
      phy8_i                => phy8_from_wrc,
      phy16_o               => phy16_to_wrc,
      phy16_i               => phy16_from_wrc,
      ext_ref_mul_o         => ext_ref_mul,
      ext_ref_mul_locked_o  => ext_ref_mul_locked,
      ext_ref_mul_stopped_o => ext_ref_mul_stopped,
      ext_ref_rst_i         => ext_ref_rst);

  clk_sys_62m5_o <= clk_pll_62m5;
  clk_ref_125m_o <= clk_pll_125m;

  -----------------------------------------------------------------------------
  -- Reset logic
  -----------------------------------------------------------------------------

  -- logic AND of all async reset sources (active low)
  rstlogic_arst_n <= pll_locked and areset_n_i;

  -- concatenation of all clocks required to have synced resets
  rstlogic_clk_in(0) <= clk_pll_62m5;

  cmp_rstlogic_reset : gc_reset
    generic map (
      g_clocks    => 1,                           -- 62.5MHz
      g_logdelay  => 4,                           -- 16 clock cycles
      g_syncdepth => 3)                           -- length of sync chains
    port map (
      free_clk_i => clk_125m_pllref_buf,
      locked_i   => rstlogic_arst_n,
      clks_i     => rstlogic_clk_in,
      rstn_o     => rstlogic_rst_out);

  -- distribution of resets (already synchronized to their clock domains)
  rst_62m5_n <= rstlogic_rst_out(0);

  rst_sys_62m5_o <= not rst_62m5_n;

  -----------------------------------------------------------------------------
  -- 2x SPI DAC
  -----------------------------------------------------------------------------

  cmp_dac_helper : spec_serial_dac
    generic map (
      g_num_data_bits  => 16,
      g_num_extra_bits => 8,
      g_num_cs_select  => 1)
    port map (
      clk_i         => clk_pll_62m5,
      rst_n_i       => rst_62m5_n,
      value_i       => dac_hpll_data,
      cs_sel_i      => "1",
      load_i        => dac_hpll_load_p1,
      sclk_divsel_i => "010",
      dac_cs_n_o(0) => pll20dac_sync_n_o,
      dac_sclk_o    => pll20dac_sclk_o,
      dac_sdata_o   => pll20dac_din_o,
      xdone_o       => open);

  cmp_dac_main : spec_serial_dac
    generic map (
      g_num_data_bits  => 16,
      g_num_extra_bits => 8,
      g_num_cs_select  => 1)
    port map (
      clk_i         => clk_pll_62m5,
      rst_n_i       => rst_62m5_n,
      value_i       => dac_dpll_data,
      cs_sel_i      => "1",
      load_i        => dac_dpll_load_p1,
      sclk_divsel_i => "010",
      dac_cs_n_o(0) => pll25dac_sync_n_o,
      dac_sclk_o    => pll25dac_sclk_o,
      dac_sdata_o   => pll25dac_din_o,
      xdone_o       => open);

  -----------------------------------------------------------------------------
  -- The WR PTP core itself
  -----------------------------------------------------------------------------

  cmp_xwr_core : xwr_core
    generic map (
      g_simulation                => g_simulation,
      g_with_external_clock_input => TRUE,
      g_phys_uart                 => TRUE,
      g_virtual_uart              => TRUE,
      g_aux_clks                  => 0,
      g_ep_rxbuf_size             => 1024,
      g_tx_runt_padding           => TRUE,
      g_dpram_initf               => g_dpram_initf,
      g_dpram_size                => 131072/4,
      g_interface_mode            => PIPELINED,
      g_address_granularity       => BYTE,
      g_aux_sdb                   => c_wrc_periph3_sdb,
      g_softpll_enable_debugger   => FALSE,
      g_vuart_fifo_size           => 1024,
      g_pcs_16bit                 => FALSE,
      g_records_for_phy           => TRUE,
      g_diag_id                   => 0,
      g_diag_ver                  => 0,
      g_diag_ro_size              => c_WR_TRANS_ARR_SIZE_OUT,
      g_diag_rw_size              => c_WR_TRANS_ARR_SIZE_IN
      )
    port map (
      clk_sys_i            => clk_pll_62m5,
      clk_dmtd_i           => clk_pll_dmtd,
      clk_ref_i            => clk_pll_125m,
      clk_aux_i            => (others => '0'),
      clk_ext_i            => clk_10m_ext_ref_i,
      clk_ext_mul_i        => ext_ref_mul,
      clk_ext_mul_locked_i => ext_ref_mul_locked,
      clk_ext_stopped_i    => ext_ref_mul_stopped,
      clk_ext_rst_o        => ext_ref_rst,
      pps_ext_i            => pps_ext_i,
      rst_n_i              => rst_62m5_n,
      dac_hpll_load_p1_o   => dac_hpll_load_p1,
      dac_hpll_data_o      => dac_hpll_data,
      dac_dpll_load_p1_o   => dac_dpll_load_p1,
      dac_dpll_data_o      => dac_dpll_data,
      phy8_o               => phy8_from_wrc,
      phy8_i               => phy8_to_wrc,
      phy16_o              => phy16_from_wrc,
      phy16_i              => phy16_to_wrc,
      led_act_o            => led_act_o,
      led_link_o           => led_link_o,
      scl_o                => eeprom_scl_o,
      scl_i                => eeprom_scl_i,
      sda_o                => eeprom_sda_o,
      sda_i                => eeprom_sda_i,
      sfp_scl_o            => sfp_scl_o,
      sfp_scl_i            => sfp_scl_i,
      sfp_sda_o            => sfp_sda_o,
      sfp_sda_i            => sfp_sda_i,
      sfp_det_i            => sfp_det_i,
      btn1_i               => '1',
      btn2_i               => '1',
      spi_sclk_o           => spi_sclk_o,
      spi_ncs_o            => spi_ncs_o,
      spi_mosi_o           => spi_mosi_o,
      spi_miso_i           => spi_miso_i,
      uart_rxd_i           => uart_rxd_i,
      uart_txd_o           => uart_txd_o,
      owr_pwren_o          => open,
      owr_en_o             => onewire_en,
      owr_i                => onewire_in,
      slave_i              => wb_slave_i,
      slave_o              => wb_slave_o,
      aux_master_o         => aux_master_out,
      aux_master_i         => aux_master_in,
      wrf_src_o            => wrf_src_out,
      wrf_src_i            => wrf_src_in,
      wrf_snk_o            => wrf_snk_out,
      wrf_snk_i            => wrf_snk_in,
      timestamps_o         => open,
      timestamps_ack_i     => '1',
      fc_tx_pause_req_i    => '0',
      fc_tx_pause_delay_i  => (others => '0'),
      fc_tx_pause_ready_o  => open,
      tm_link_up_o         => open,
      tm_dac_value_o       => open,
      tm_dac_wr_o          => open,
      tm_clk_aux_lock_en_i => (others => '0'),
      tm_clk_aux_locked_o  => open,
      tm_time_valid_o      => tm_time_valid,
      tm_tai_o             => tm_tai,
      tm_cycles_o          => tm_cycles,
      pps_p_o              => pps_p_o,
      pps_led_o            => pps_led_o,
      rst_aux_n_o          => aux_rst_n,
      aux_diag_i           => aux_diag_in,
      aux_diag_o           => aux_diag_out,
      link_ok_o            => open);

  sfp_rate_select_o <= '1';

  onewire_oen_o <= onewire_en(0);
  onewire_in(0) <= onewire_i;
  onewire_in(1) <= '1';

  tm_time_valid_o <= tm_time_valid;
  tm_tai_o        <= tm_tai;
  tm_cycles_o     <= tm_cycles;

  gen_wr_streamers : if (g_fabric_iface = "streamers") generate

    cmp_xwr_transmission : xwr_transmission
      generic map (
        g_tx_data_width => g_streamer_width,
        g_rx_data_width => g_streamer_width)
      port map (
        clk_sys_i       => clk_pll_62m5,
        rst_n_i         => rst_62m5_n,
        src_i           => wrf_snk_out,
        src_o           => wrf_snk_in,
        snk_i           => wrf_src_out,
        snk_o           => wrf_src_in,
        tx_data_i       => wrs_tx_data_i,
        tx_valid_i      => wrs_tx_valid_i,
        tx_dreq_o       => wrs_tx_dreq_o,
        tx_last_p1_i    => wrs_tx_last_i,
        tx_flush_p1_i   => wrs_tx_flush_i,
        rx_first_p1_o   => wrs_rx_first_o,
        rx_last_p1_o    => wrs_rx_last_o,
        rx_data_o       => wrs_rx_data_o,
        rx_valid_o      => wrs_rx_valid_o,
        rx_dreq_i       => wrs_rx_dreq_i,
        clk_ref_i       => clk_pll_125m,
        tm_time_valid_i => tm_time_valid,
        tm_tai_i        => tm_tai,
        tm_cycles_i     => tm_cycles,
        wb_slave_i      => aux_master_out,
        wb_slave_o      => aux_master_in,
        snmp_array_o    => aux_diag_in,
        snmp_array_i    => aux_diag_out);

    -- unused output ports
    wrf_src_o <= c_dummy_snk_in;
    wrf_snk_o <= c_dummy_src_in;

    wb_eth_master_o <= cc_dummy_master_out;

  end generate gen_wr_streamers;

  gen_etherbone : if (g_fabric_iface = "etherbone") generate

    cmp_eb_ethernet_slave : eb_ethernet_slave
      generic map (
        g_sdb_address => x"0000000000030000")
      port map (
        clk_i       => clk_pll_62m5,
        nRst_i      => aux_rst_n,
        src_o       => wrf_snk_in,
        src_i       => wrf_snk_out,
        snk_o       => wrf_src_in,
        snk_i       => wrf_src_out,
        cfg_slave_o => aux_master_in,
        cfg_slave_i => aux_master_out,
        master_o    => wb_eth_master_o,
        master_i    => wb_eth_master_i);

    -- unused output ports
    wrf_src_o <= c_dummy_snk_in;
    wrf_snk_o <= c_dummy_src_in;

    wrs_tx_dreq_o  <= '0';
    wrs_rx_first_o <= '0';
    wrs_rx_last_o  <= '0';
    wrs_rx_valid_o <= '0';
    wrs_rx_data_o  <= (others => '0');

    -- unused inputs to WR PTP core
    aux_diag_in <= (others => (others => '0'));

  end generate gen_etherbone;

  gen_wr_fabric : if (g_fabric_iface = "plainfbrc") generate

    wrf_src_o <= wrf_src_out;
    wrf_snk_o <= wrf_snk_out;

    wrf_src_in <= wrf_src_i;
    wrf_snk_in <= wrf_snk_i;

    -- unused output ports
    wrs_tx_dreq_o  <= '0';
    wrs_rx_first_o <= '0';
    wrs_rx_last_o  <= '0';
    wrs_rx_valid_o <= '0';
    wrs_rx_data_o  <= (others => '0');

    wb_eth_master_o <= cc_dummy_master_out;

    -- unused inputs to WR PTP core
    aux_diag_in   <= (others => (others => '0'));
    aux_master_in <= cc_dummy_master_in;

  end generate gen_wr_fabric;

end architecture struct;
