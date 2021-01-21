-------------------------------------------------------------------------------
-- Title      : WRPC Wrapper for SPEC7
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : wrc_board_spec7.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2017-11-08
-- Last update: 2020-10-05
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level wrapper for WR PTP core including all the modules
-- needed to operate the core on the SPEC7 board.
-- Version with no VHDL records on the top-level (mainly for Verilog
-- instantiation).
-- https://ohwr.org/project/spec7/wikis/home
-------------------------------------------------------------------------------
-- Copyright (c) 2017 Nikhef
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
use work.wr_fabric_pkg.all;
use work.endpoint_pkg.all;
use work.streamers_pkg.all;
use work.wr_xilinx_pkg.all;
use work.wr_board_pkg.all;
use work.wr_spec7_pkg.all;

entity wrc_board_spec7 is
  generic(
    -- set to 1 to speed up some initialization processes during simulation
    g_simulation                : integer              := 0;
    -- Select whether to include external ref clock input
    g_with_external_clock_input : integer              := 1;
    -- Number of aux clocks syntonized by WRPC to WR timebase
    g_aux_clks                  : integer              := 1;
    -- plainfbrc = expose WRC fabric interface
    -- streamers = attach WRC streamers to fabric interface
    -- etherbone = attach Etherbone slave to fabric interface
    g_fabric_iface              : string := "plainfbrc";
    -- parameters configuration when g_fabric_iface = "streamers" (otherwise ignored)
    g_streamers_op_mode        : t_streamers_op_mode  := TX_AND_RX;
    g_tx_streamer_params       : t_tx_streamer_params := c_tx_streamer_params_defaut;
    g_rx_streamer_params       : t_rx_streamer_params := c_rx_streamer_params_defaut;
    -- memory initialisation file for embedded CPU
    g_dpram_initf               : string               := "default_xilinx";
    -- identification (id and ver) of the layout of words in the generic diag interface
    g_diag_id                   : integer              := 0;
    g_diag_ver                  : integer              := 0;
    -- size the generic diag interface
    g_diag_ro_vector_width      : integer              := 0;
    g_diag_rw_vector_width      : integer              := 0
    );
  port (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------
    -- Reset input (active low, can be async)
    areset_n_i          : in  std_logic;
    -- Optional reset input active low with rising edge detection. Does not
    -- reset PLLs.
    areset_edge_n_i     : in  std_logic := '1';
    -- Clock inputs from the board
    clk_125m_dmtd_n_i   : in  std_logic;  -- 124.992 MHz
    clk_125m_dmtd_p_i   : in  std_logic;
    clk_125m_gtx_n_i    : in  std_logic;
    clk_125m_gtx_p_i    : in  std_logic;
    -- Aux clocks, which can be disciplined by the WR Core
    clk_aux_i           : in  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
    -- 10MHz ext ref clock input (g_with_external_clock_input = TRUE)
    clk_10m_ext_i       : in  std_logic                               := '0';
    -- External PPS input (g_with_external_clock_input = TRUE)
    pps_ext_i           : in  std_logic                               := '0';
    -- 62.5MHz sys clock output
    clk_sys_62m5_o      : out std_logic;
    -- 62.5MHz ref clock output
    clk_ref_62m5_o      : out std_logic;
    -- 124.992 / 2 = 62.496 MHz dmtd clock output
    clk_dmtd_62m5_o     : out std_logic;
    -- active low reset outputs, synchronous to 62m5 and 125m clocks
    rst_sys_62m5_n_o    : out std_logic;
    rst_ref_62m5_n_o    : out std_logic;

    ---------------------------------------------------------------------------
    -- Shared SPI interface to DACs
    ---------------------------------------------------------------------------
    dac_refclk_cs_n_o : out std_logic;
    dac_refclk_sclk_o : out std_logic;
    dac_refclk_din_o  : out std_logic;

    dac_dmtd_cs_n_o   : out std_logic;
    dac_dmtd_sclk_o   : out std_logic;
    dac_dmtd_din_o    : out std_logic;

    -------------------------------------------------------------------------------
    -- PLL Control signals
    -------------------------------------------------------------------------------    

    pll_status_i      : in  std_logic := '0';
    pll_mosi_o        : out std_logic;
    pll_miso_i        : in  std_logic := '0';
    pll_sck_o         : out std_logic;
    pll_cs_n_o        : out std_logic;
    pll_sync_o        : out std_logic;
    pll_reset_n_o     : out std_logic;
    pll_lock_i        : in  std_logic := '0';
    pll_wr_mode_o     : out std_logic_vector(1 downto 0);

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
    eeprom_sda : inout std_logic;
    eeprom_scl : inout std_logic;

    ---------------------------------------------------------------------------
    -- I2C AUXiliary
    ---------------------------------------------------------------------------
    aux_sda : inout std_logic;
    aux_scl : inout std_logic;

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
    -- No Flash memory SPI interface
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --External WB interface
    ---------------------------------------------------------------------------
    wb_slave_cyc_i   : in  std_logic := '0';
    wb_slave_stb_i   : in  std_logic := '0';
    wb_slave_adr_i   : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
    wb_slave_sel_i   : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0)  := (others => '0');
    wb_slave_we_i    : in  std_logic := '0';
    wb_slave_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0)    := (others => '0');
    wb_slave_ack_o   : out std_logic;
    wb_slave_err_o   : out std_logic;
    wb_slave_rty_o   : out std_logic;
    wb_slave_stall_o : out std_logic;
    wb_slave_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);

    ---------------------------------------------------------------------------
    -- WR fabric interface (when g_fabric_iface = "plainfbrc")
    ---------------------------------------------------------------------------
    wrf_src_adr_o    : out std_logic_vector(1 downto 0);
    wrf_src_dat_o    : out std_logic_vector(15 downto 0);
    wrf_src_cyc_o    : out std_logic;
    wrf_src_stb_o    : out std_logic;
    wrf_src_we_o     : out std_logic;
    wrf_src_sel_o    : out std_logic_vector(1 downto 0);
    wrf_src_ack_i    : in  std_logic := '0';
    wrf_src_stall_i  : in  std_logic := '0';
    wrf_src_err_i    : in  std_logic := '0';
    wrf_src_rty_i    : in  std_logic := '0';
    wrf_snk_ack_o    : out std_logic;
    wrf_snk_stall_o  : out std_logic;
    wrf_snk_err_o    : out std_logic;
    wrf_snk_rty_o    : out std_logic;
    wrf_snk_adr_i    : in  std_logic_vector(1 downto 0)  := (others => '0');
    wrf_snk_dat_i    : in  std_logic_vector(15 downto 0) := (others => '0');
    wrf_snk_cyc_i    : in  std_logic := '0';
    wrf_snk_stb_i    : in  std_logic := '0';
    wrf_snk_we_i     : in  std_logic := '0';
    wrf_snk_sel_i    : in  std_logic_vector(1 downto 0)  := (others => '0');

    ---------------------------------------------------------------------------
    -- WR streamers (when g_fabric_iface = "streamers")
    ---------------------------------------------------------------------------
    wrs_tx_data_i    : in  std_logic_vector(g_tx_streamer_params.data_width-1 downto 0) := (others => '0');
    wrs_tx_valid_i   : in  std_logic                                        := '0';
    wrs_tx_dreq_o    : out std_logic;
    wrs_tx_last_i    : in  std_logic                                        := '1';
    wrs_tx_flush_i   : in  std_logic                                        := '0';

    wrs_tx_cfg_mac_local_i  : in std_logic_vector(47 downto 0) := x"000000000000";
    wrs_tx_cfg_mac_target_i : in std_logic_vector(47 downto 0) := x"ffffffffffff";
    wrs_tx_cfg_ethertype_i  : in std_logic_vector(15 downto 0) := x"dbff";
    wrs_tx_cfg_qtag_ena_i   : in std_logic := '0';
    wrs_tx_cfg_qtag_vid_i   : in std_logic_vector(11 downto 0):= x"000";
    wrs_tx_cfg_qtag_prio_i  : in std_logic_vector(2  downto 0):= "000";
    wrs_tx_cfg_sw_reset_i   : in std_logic := '0';

    wrs_rx_first_o   : out std_logic;
    wrs_rx_last_o    : out std_logic;
    wrs_rx_data_o    : out std_logic_vector(g_rx_streamer_params.data_width-1 downto 0);
    wrs_rx_valid_o   : out std_logic;
    wrs_rx_dreq_i    : in  std_logic                                        := '0';

    wrs_rx_cfg_mac_local_i             : in std_logic_vector(47 downto 0) := x"000000000000";
    wrs_rx_cfg_mac_remote_i            : in std_logic_vector(47 downto 0) := x"000000000000";
    wrs_rx_cfg_ethertype_i             : in std_logic_vector(15 downto 0) := x"dbff";
    wrs_rx_cfg_accept_broadcasts_i     : in std_logic := '1';
    wrs_rx_cfg_filter_remote_i         : in std_logic := '0';
    wrs_rx_cfg_fixed_latency_i         : in std_logic_vector(27 downto 0) := x"0000000";
    wrs_rx_cfg_fixed_latency_timeout_i : in std_logic_vector(27 downto 0) := x"1000000";
    wrs_rx_cfg_sw_reset_i              : in std_logic := '0';

    ---------------------------------------------------------------------------
    -- No Etherbone WB master interface (when g_fabric_iface = "etherbone")
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Generic diagnostics interface (access from WRPC via SNMP or uart console
    ---------------------------------------------------------------------------
    aux_diag_i : in  std_logic_vector(g_diag_ro_vector_width - 1 downto 0) := (others => '0');
    aux_diag_o : out std_logic_vector(g_diag_rw_vector_width - 1 downto 0) := (others => '0');

    ---------------------------------------------------------------------------
    -- Aux clocks control
    ---------------------------------------------------------------------------
    tm_dac_value_o         : out std_logic_vector(23 downto 0);
    tm_dac_wr_o            : out std_logic_vector(g_aux_clks-1 downto 0);
    tm_clk_aux_lock_en_i   : in  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
    tm_clk_aux_locked_o    : out std_logic_vector(g_aux_clks-1 downto 0);

    ---------------------------------------------------------------------------
    -- External Tx Timestamping I/F
    ---------------------------------------------------------------------------
    timestamps_stb_o       : out std_logic;
    timestamps_tsval_o     : out std_logic_vector(31 downto 0);
    timestamps_port_id_o   : out std_logic_vector(5 downto 0);
    timestamps_frame_id_o  : out std_logic_vector(15 downto 0);
    timestamps_incorrect_o : out std_logic;
    timestamps_ack_i       : in  std_logic := '1';

    -----------------------------------------
    -- Timestamp helper signals, used for Absolute Calibration
    -----------------------------------------
    abscal_txts_o          : out std_logic;
    abscal_rxts_o          : out std_logic;

    ---------------------------------------------------------------------------
    -- Pause Frame Control
    ---------------------------------------------------------------------------
    fc_tx_pause_req_i      : in  std_logic                     := '0';
    fc_tx_pause_delay_i    : in  std_logic_vector(15 downto 0) := x"0000";
    fc_tx_pause_ready_o    : out std_logic;

    ---------------------------------------------------------------------------
    -- Timecode I/F
    ---------------------------------------------------------------------------
    tm_link_up_o           : out std_logic;
    tm_time_valid_o        : out std_logic;
    tm_tai_o               : out std_logic_vector(39 downto 0);
    tm_cycles_o            : out std_logic_vector(27 downto 0);

    ---------------------------------------------------------------------------
    -- Buttons, LEDs and PPS output
    ---------------------------------------------------------------------------

    led_act_o  : out std_logic;
    led_link_o : out std_logic;
    btn1_i     : in  std_logic := '1';
    btn2_i     : in  std_logic := '1';
    -- 1PPS output
    pps_p_o    : out std_logic;
    pps_led_o  : out std_logic;
    -- Link ok indication
    link_ok_o  : out std_logic
    );

end entity wrc_board_spec7;

architecture struct of wrc_board_spec7 is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- External WB interface
  signal wb_slave_i : t_wishbone_slave_in;
  signal wb_slave_o : t_wishbone_slave_out;

  -- WR fabric interface
  signal wrf_src_o : t_wrf_source_out;
  signal wrf_src_i : t_wrf_source_in;
  signal wrf_snk_o : t_wrf_sink_out;
  signal wrf_snk_i : t_wrf_sink_in;

  -- WR streamers
  signal wrs_tx_cfg_i : t_tx_streamer_cfg;
  signal wrs_rx_cfg_i : t_rx_streamer_cfg;

  -- Aux diagnostics
  constant c_diag_ro_size : integer := g_diag_ro_vector_width/32;
  constant c_diag_rw_size : integer := g_diag_rw_vector_width/32;

  signal aux_diag_in  : t_generic_word_array(c_diag_ro_size-1 downto 0);
  signal aux_diag_out : t_generic_word_array(c_diag_rw_size-1 downto 0);

  -- External Tx Timestamping I/F
  signal timestamps_o     : t_txtsu_timestamp;

begin  -- architecture struct

  -- Map top-level signals to internal records
  wb_slave_i.cyc <= wb_slave_cyc_i;
  wb_slave_i.stb <= wb_slave_stb_i;
  wb_slave_i.adr <= wb_slave_adr_i;
  wb_slave_i.sel <= wb_slave_sel_i;
  wb_slave_i.we  <= wb_slave_we_i;
  wb_slave_i.dat <= wb_slave_dat_i;
  
  wb_slave_ack_o   <= wb_slave_o.ack;
  wb_slave_err_o   <= wb_slave_o.err;
  wb_slave_rty_o   <= wb_slave_o.rty;
  wb_slave_stall_o <= wb_slave_o.stall;
  wb_slave_dat_o   <= wb_slave_o.dat;

  wrf_src_adr_o    <= wrf_src_o.adr;
  wrf_src_dat_o    <= wrf_src_o.dat;
  wrf_src_cyc_o    <= wrf_src_o.cyc;
  wrf_src_stb_o    <= wrf_src_o.stb;
  wrf_src_we_o     <= wrf_src_o.we;
  wrf_src_sel_o    <= wrf_src_o.sel;
  
  wrf_src_i.ack    <= wrf_src_ack_i;
  wrf_src_i.stall  <= wrf_src_stall_i;
  wrf_src_i.err    <= wrf_src_err_i;
  wrf_src_i.rty    <= wrf_src_rty_i;

  wrf_snk_ack_o    <= wrf_snk_o.ack;
  wrf_snk_stall_o  <= wrf_snk_o.stall;
  wrf_snk_err_o    <= wrf_snk_o.err;
  wrf_snk_rty_o    <= wrf_snk_o.rty;

  wrf_snk_i.adr    <= wrf_snk_adr_i;   
  wrf_snk_i.dat    <= wrf_snk_dat_i;   
  wrf_snk_i.cyc    <= wrf_snk_cyc_i;   
  wrf_snk_i.stb    <= wrf_snk_stb_i;   
  wrf_snk_i.we     <= wrf_snk_we_i;   
  wrf_snk_i.sel    <= wrf_snk_sel_i;   

  wrs_tx_cfg_i.mac_local  <= wrs_tx_cfg_mac_local_i;
  wrs_tx_cfg_i.mac_target <= wrs_tx_cfg_mac_target_i;
  wrs_tx_cfg_i.ethertype  <= wrs_tx_cfg_ethertype_i;
  wrs_tx_cfg_i.qtag_ena   <= wrs_tx_cfg_qtag_ena_i;
  wrs_tx_cfg_i.qtag_vid   <= wrs_tx_cfg_qtag_vid_i;
  wrs_tx_cfg_i.qtag_prio  <= wrs_tx_cfg_qtag_prio_i;
  wrs_tx_cfg_i.sw_reset   <= wrs_tx_cfg_sw_reset_i;

  wrs_rx_cfg_i.mac_local             <= wrs_rx_cfg_mac_local_i;
  wrs_rx_cfg_i.mac_remote            <= wrs_rx_cfg_mac_remote_i;
  wrs_rx_cfg_i.ethertype             <= wrs_rx_cfg_ethertype_i;
  wrs_rx_cfg_i.accept_broadcasts     <= wrs_rx_cfg_accept_broadcasts_i;
  wrs_rx_cfg_i.filter_remote         <= wrs_rx_cfg_filter_remote_i;
  wrs_rx_cfg_i.fixed_latency         <= wrs_rx_cfg_fixed_latency_i;
  wrs_rx_cfg_i.fixed_latency_timeout <= wrs_rx_cfg_fixed_latency_timeout_i;
  wrs_rx_cfg_i.sw_reset              <= wrs_rx_cfg_sw_reset_i;

  aux_diag_in <= f_de_vectorize_diag(aux_diag_i, g_diag_ro_vector_width);
  aux_diag_o  <= f_vectorize_diag(aux_diag_out, g_diag_rw_vector_width);

  timestamps_stb_o       <= timestamps_o.stb;
  timestamps_tsval_o     <= timestamps_o.tsval;
  timestamps_port_id_o   <= timestamps_o.port_id;
  timestamps_frame_id_o  <= timestamps_o.frame_id;
  timestamps_incorrect_o <= timestamps_o.incorrect;
  
  -- Instantiate the records-based module
    cmp_xwrc_board_spec7 : xwrc_board_spec7
    generic map (
      g_simulation                => g_simulation,
      g_with_external_clock_input => f_int2bool(g_with_external_clock_input),
      g_aux_clks                  => g_aux_clks,
      g_fabric_iface              => f_str2iface_type(g_fabric_iface),
      g_streamers_op_mode         => g_streamers_op_mode,
      g_tx_streamer_params        => g_tx_streamer_params,
      g_rx_streamer_params        => g_rx_streamer_params,
      g_dpram_initf               => g_dpram_initf,
      g_diag_id                   => g_diag_id,
      g_diag_ver                  => g_diag_ver,
      g_diag_ro_size              => c_diag_ro_size,
      g_diag_rw_size              => c_diag_rw_size)
    port map (
      areset_n_i           => areset_n_i,
      areset_edge_n_i      => areset_edge_n_i,
      clk_125m_dmtd_n_i    => clk_125m_dmtd_n_i,
      clk_125m_dmtd_p_i    => clk_125m_dmtd_p_i,
      clk_125m_gtx_n_i     => clk_125m_gtx_n_i,
      clk_125m_gtx_p_i     => clk_125m_gtx_p_i,
      clk_aux_i            => clk_aux_i,
      clk_10m_ext_i        => clk_10m_ext_i,
      pps_ext_i            => pps_ext_i,
      clk_sys_62m5_o       => clk_sys_62m5_o,
      clk_ref_62m5_o       => clk_ref_62m5_o,
      clk_dmtd_62m5_o      => clk_dmtd_62m5_o,
      rst_sys_62m5_n_o     => rst_sys_62m5_n_o,
      rst_ref_62m5_n_o     => rst_ref_62m5_n_o,
      dac_refclk_cs_n_o    => dac_refclk_cs_n_o,
      dac_refclk_sclk_o    => dac_refclk_sclk_o,
      dac_refclk_din_o     => dac_refclk_din_o,
      dac_dmtd_cs_n_o      => dac_dmtd_cs_n_o,
      dac_dmtd_sclk_o      => dac_dmtd_sclk_o,
      dac_dmtd_din_o       => dac_dmtd_din_o,
      pll_status_i         => pll_status_i,
      pll_mosi_o           => pll_mosi_o,
      pll_miso_i           => pll_miso_i,
      pll_sck_o            => pll_sck_o,
      pll_cs_n_o           => pll_cs_n_o,
      pll_sync_o           => pll_sync_o,
      pll_reset_n_o        => pll_reset_n_o,
      pll_lock_i           => pll_lock_i,
      pll_wr_mode_o        => pll_wr_mode_o,
      sfp_txp_o            => sfp_txp_o,
      sfp_txn_o            => sfp_txn_o,
      sfp_rxp_i            => sfp_rxp_i,
      sfp_rxn_i            => sfp_rxn_i,
      sfp_det_i            => sfp_det_i,
      sfp_sda_i            => sfp_sda_i,
      sfp_sda_o            => sfp_sda_o,
      sfp_scl_i            => sfp_scl_i,
      sfp_scl_o            => sfp_scl_o,
      sfp_rate_select_o    => sfp_rate_select_o,
      sfp_tx_fault_i       => sfp_tx_fault_i,
      sfp_tx_disable_o     => sfp_tx_disable_o,
      sfp_los_i            => sfp_los_i,
      eeprom_scl           => eeprom_scl,
      eeprom_sda           => eeprom_sda,
      aux_scl              => aux_scl,
      aux_sda              => aux_sda,
      onewire_i            => onewire_i,
      onewire_oen_o        => onewire_oen_o,
      uart_rxd_i           => uart_rxd_i,
      uart_txd_o           => uart_txd_o,
      wb_slave_i           => wb_slave_i,
      wb_slave_o           => wb_slave_o,
      wrf_src_o            => wrf_src_o,
      wrf_src_i            => wrf_src_i,
      wrf_snk_o            => wrf_snk_o,
      wrf_snk_i            => wrf_snk_i,
      wrs_tx_data_i        => wrs_tx_data_i,
      wrs_tx_valid_i       => wrs_tx_valid_i,
      wrs_tx_dreq_o        => wrs_tx_dreq_o,
      wrs_tx_last_i        => wrs_tx_last_i,
      wrs_tx_flush_i       => wrs_tx_flush_i,
      wrs_tx_cfg_i         => wrs_tx_cfg_i,
      wrs_rx_first_o       => wrs_rx_first_o,
      wrs_rx_last_o        => wrs_rx_last_o,
      wrs_rx_data_o        => wrs_rx_data_o,
      wrs_rx_valid_o       => wrs_rx_valid_o,
      wrs_rx_dreq_i        => wrs_rx_dreq_i,
      wrs_rx_cfg_i         => wrs_rx_cfg_i,
      aux_diag_i           => aux_diag_in,
      aux_diag_o           => aux_diag_out,
      tm_dac_value_o       => tm_dac_value_o,
      tm_dac_wr_o          => tm_dac_wr_o,
      tm_clk_aux_lock_en_i => tm_clk_aux_lock_en_i,
      tm_clk_aux_locked_o  => tm_clk_aux_locked_o,
      timestamps_o         => timestamps_o,
      timestamps_ack_i     => timestamps_ack_i,
      abscal_txts_o        => abscal_txts_o,
      abscal_rxts_o        => abscal_rxts_o,
      fc_tx_pause_req_i    => fc_tx_pause_req_i,
      fc_tx_pause_delay_i  => fc_tx_pause_delay_i,
      fc_tx_pause_ready_o  => fc_tx_pause_ready_o,
      tm_link_up_o         => tm_link_up_o,
      tm_time_valid_o      => tm_time_valid_o,
      tm_tai_o             => tm_tai_o,
      tm_cycles_o          => tm_cycles_o,
      led_act_o            => led_act_o,
      led_link_o           => led_link_o,
      btn1_i               => btn1_i,
      btn2_i               => btn2_i,
      pps_p_o              => pps_p_o,
      pps_led_o            => pps_led_o,
      link_ok_o            => link_ok_o);

end architecture struct;

