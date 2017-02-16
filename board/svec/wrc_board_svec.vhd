-------------------------------------------------------------------------------
-- Title      : WRPC Wrapper for SVEC
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : wrc_board_svec.vhd
-- Author(s)  : Dimitrios Lampridis  <dimitrios.lampridis@cern.ch>
-- Company    : CERN (BE-CO-HT)
-- Created    : 2016-02-16
-- Last update: 2017-02-17
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level wrapper for WR PTP core including all the modules
-- needed to operate the core on the SVEC board.
-- Version with no VHDL records on the top-level (mainly for Verilog
-- instantiation).
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

entity wrc_board_svec is
  generic(
    -- set to 1 to speed up some initialization processes during simulation
    g_simulation                : integer := 0;
    -- Select whether to include external ref clock input
    g_with_external_clock_input : integer := 1;
    -- "plain" = expose WRC fabric interface
    -- "streamers" = attach WRC streamers to fabric interface
    -- "etherbone" = attach Etherbone slave to fabric interface
    g_fabric_iface              : string  := "plain";
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

    wb_adr_i   : in  std_logic_vector(c_wishbone_address_width-1 downto 0)   := (others => '0');
    wb_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0)      := (others => '0');
    wb_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i   : in  std_logic_vector(c_wishbone_address_width/8-1 downto 0) := (others => '0');
    wb_we_i    : in  std_logic                                               := '0';
    wb_cyc_i   : in  std_logic                                               := '0';
    wb_stb_i   : in  std_logic                                               := '0';
    wb_ack_o   : out std_logic;
    wb_int_o   : out std_logic;
    wb_err_o   : out std_logic;
    wb_rty_o   : out std_logic;
    wb_stall_o : out std_logic;

    ---------------------------------------------------------------------------
    -- WR fabric interface (when g_fabric_iface = "plain")
    ---------------------------------------------------------------------------

    wrf_src_adr_o   : out std_logic_vector(1 downto 0);
    wrf_src_dat_o   : out std_logic_vector(15 downto 0);
    wrf_src_cyc_o   : out std_logic;
    wrf_src_stb_o   : out std_logic;
    wrf_src_we_o    : out std_logic;
    wrf_src_sel_o   : out std_logic_vector(1 downto 0);
    wrf_src_ack_i   : in  std_logic;
    wrf_src_stall_i : in  std_logic;
    wrf_src_err_i   : in  std_logic;
    wrf_src_rty_i   : in  std_logic;
    wrf_snk_adr_i   : in  std_logic_vector(1 downto 0);
    wrf_snk_dat_i   : in  std_logic_vector(15 downto 0);
    wrf_snk_cyc_i   : in  std_logic;
    wrf_snk_stb_i   : in  std_logic;
    wrf_snk_we_i    : in  std_logic;
    wrf_snk_sel_i   : in  std_logic_vector(1 downto 0);
    wrf_snk_ack_o   : out std_logic;
    wrf_snk_stall_o : out std_logic;
    wrf_snk_err_o   : out std_logic;
    wrf_snk_rty_o   : out std_logic;

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

    wb_eth_adr_o   : out std_logic_vector(c_wishbone_address_width-1 downto 0);
    wb_eth_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_eth_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
    wb_eth_sel_o   : out std_logic_vector(c_wishbone_address_width/8-1 downto 0);
    wb_eth_we_o    : out std_logic;
    wb_eth_cyc_o   : out std_logic;
    wb_eth_stb_o   : out std_logic;
    wb_eth_ack_i   : in  std_logic                                          := '0';
    wb_eth_int_i   : in  std_logic                                          := '0';
    wb_eth_err_i   : in  std_logic                                          := '0';
    wb_eth_rty_i   : in  std_logic                                          := '0';
    wb_eth_stall_i : in  std_logic                                          := '0';

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

end entity wrc_board_svec;


architecture std_wrapper of wrc_board_svec is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- WR fabric interface
  signal wrf_src_out : t_wrf_source_out;
  signal wrf_src_in  : t_wrf_source_in;
  signal wrf_snk_out : t_wrf_sink_out;
  signal wrf_snk_in  : t_wrf_sink_in;

  -- External WB interface
  signal wb_slave_out : t_wishbone_slave_out;
  signal wb_slave_in  : t_wishbone_slave_in;

  -- Etherbone interface
  signal wb_eth_master_out : t_wishbone_master_out;
  signal wb_eth_master_in  : t_wishbone_master_in;

begin  -- architecture struct

  -- Map top-level signals to internal records
  wb_slave_in.cyc <= wb_cyc_i;
  wb_slave_in.stb <= wb_stb_i;
  wb_slave_in.adr <= wb_adr_i;
  wb_slave_in.sel <= wb_sel_i;
  wb_slave_in.we  <= wb_we_i;
  wb_slave_in.dat <= wb_dat_i;

  wb_ack_o   <= wb_slave_out.ack;
  wb_err_o   <= wb_slave_out.err;
  wb_rty_o   <= wb_slave_out.rty;
  wb_stall_o <= wb_slave_out.stall;
  wb_int_o   <= wb_slave_out.int;
  wb_dat_o   <= wb_slave_out.dat;

  wrf_src_adr_o    <= wrf_src_out.adr;
  wrf_src_dat_o    <= wrf_src_out.dat;
  wrf_src_cyc_o    <= wrf_src_out.cyc;
  wrf_src_stb_o    <= wrf_src_out.stb;
  wrf_src_we_o     <= wrf_src_out.we;
  wrf_src_sel_o    <= wrf_src_out.sel;
  wrf_src_in.ack   <= wrf_src_ack_i;
  wrf_src_in.stall <= wrf_src_stall_i;
  wrf_src_in.err   <= wrf_src_err_i;
  wrf_src_in.rty   <= wrf_src_rty_i;

  wrf_snk_in.adr  <= wrf_snk_adr_i;
  wrf_snk_in.dat  <= wrf_snk_dat_i;
  wrf_snk_in.cyc  <= wrf_snk_cyc_i;
  wrf_snk_in.stb  <= wrf_snk_stb_i;
  wrf_snk_in.we   <= wrf_snk_we_i;
  wrf_snk_in.sel  <= wrf_snk_sel_i;
  wrf_snk_ack_o   <= wrf_snk_out.ack;
  wrf_snk_stall_o <= wrf_snk_out.stall;
  wrf_snk_err_o   <= wrf_snk_out.err;
  wrf_snk_rty_o   <= wrf_snk_out.rty;


  wb_eth_adr_o <= wb_eth_master_out.adr;
  wb_eth_dat_o <= wb_eth_master_out.dat;
  wb_eth_cyc_o <= wb_eth_master_out.cyc;
  wb_eth_stb_o <= wb_eth_master_out.stb;
  wb_eth_sel_o <= wb_eth_master_out.sel;
  wb_eth_we_o  <= wb_eth_master_out.we;

  wb_eth_master_in.dat   <= wb_eth_dat_i;
  wb_eth_master_in.ack   <= wb_eth_ack_i;
  wb_eth_master_in.int   <= wb_eth_int_i;
  wb_eth_master_in.err   <= wb_eth_err_i;
  wb_eth_master_in.rty   <= wb_eth_rty_i;
  wb_eth_master_in.stall <= wb_eth_stall_i;

  -- Instantiate the records-based module
  cmp_xwrc_board_svec : xwrc_board_svec
    generic map (
      g_simulation                => g_simulation,
      g_with_external_clock_input => f_int2bool(g_with_external_clock_input),
      g_fabric_iface              => g_fabric_iface,
      g_streamer_width            => g_streamer_width,
      g_dpram_initf               => g_dpram_initf)
    port map (
      areset_n_i          => areset_n_i,
      clk_20m_vcxo_i      => clk_20m_vcxo_i,
      clk_125m_pllref_p_i => clk_125m_pllref_p_i,
      clk_125m_pllref_n_i => clk_125m_pllref_n_i,
      clk_125m_gtp_n_i    => clk_125m_gtp_n_i,
      clk_125m_gtp_p_i    => clk_125m_gtp_p_i,
      clk_10m_ext_ref_i   => clk_10m_ext_ref_i,
      clk_sys_62m5_o      => clk_sys_62m5_o,
      clk_ref_125m_o      => clk_ref_125m_o,
      rst_sys_62m5_o      => rst_sys_62m5_o,
      pll20dac_din_o      => pll20dac_din_o,
      pll20dac_sclk_o     => pll20dac_sclk_o,
      pll20dac_sync_n_o   => pll20dac_sync_n_o,
      pll25dac_din_o      => pll25dac_din_o,
      pll25dac_sclk_o     => pll25dac_sclk_o,
      pll25dac_sync_n_o   => pll25dac_sync_n_o,
      sfp_txp_o           => sfp_txp_o,
      sfp_txn_o           => sfp_txn_o,
      sfp_rxp_i           => sfp_rxp_i,
      sfp_rxn_i           => sfp_rxn_i,
      sfp_det_i           => sfp_det_i,
      sfp_sda_i           => sfp_sda_i,
      sfp_sda_o           => sfp_sda_o,
      sfp_scl_i           => sfp_scl_i,
      sfp_scl_o           => sfp_scl_o,
      sfp_rate_select_o   => sfp_rate_select_o,
      sfp_tx_fault_i      => sfp_tx_fault_i,
      sfp_tx_disable_o    => sfp_tx_disable_o,
      sfp_los_i           => sfp_los_i,
      eeprom_sda_i        => eeprom_sda_i,
      eeprom_sda_o        => eeprom_sda_o,
      eeprom_scl_i        => eeprom_scl_i,
      eeprom_scl_o        => eeprom_scl_o,
      onewire_i           => onewire_i,
      onewire_oen_o       => onewire_oen_o,
      uart_rxd_i          => uart_rxd_i,
      uart_txd_o          => uart_txd_o,
      spi_sclk_o          => spi_sclk_o,
      spi_ncs_o           => spi_ncs_o,
      spi_mosi_o          => spi_mosi_o,
      spi_miso_i          => spi_miso_i,
      wb_slave_o          => wb_slave_out,
      wb_slave_i          => wb_slave_in,
      wrf_src_o           => wrf_src_out,
      wrf_src_i           => wrf_src_in,
      wrf_snk_o           => wrf_snk_out,
      wrf_snk_i           => wrf_snk_in,
      wrs_tx_data_i       => wrs_tx_data_i,
      wrs_tx_valid_i      => wrs_tx_valid_i,
      wrs_tx_dreq_o       => wrs_tx_dreq_o,
      wrs_tx_last_i       => wrs_tx_last_i,
      wrs_tx_flush_i      => wrs_tx_flush_i,
      wrs_rx_first_o      => wrs_rx_first_o,
      wrs_rx_last_o       => wrs_rx_last_o,
      wrs_rx_data_o       => wrs_rx_data_o,
      wrs_rx_valid_o      => wrs_rx_valid_o,
      wrs_rx_dreq_i       => wrs_rx_dreq_i,
      wb_eth_master_o     => wb_eth_master_out,
      wb_eth_master_i     => wb_eth_master_in,
      pps_ext_i           => pps_ext_i,
      pps_p_o             => pps_p_o,
      pps_led_o           => pps_led_o,
      tm_time_valid_o     => tm_time_valid_o,
      tm_tai_o            => tm_tai_o,
      tm_cycles_o         => tm_cycles_o,
      led_link_o          => led_link_o,
      led_act_o           => led_act_o);

end architecture std_wrapper;
