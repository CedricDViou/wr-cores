-------------------------------------------------------------------------------
-- Title      : WRPC Wrapper for kc705
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : wrc_board_kc705.vhd
-- Author(s)  : Pascal Bos <bosp@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2018-09-18
-- Last update: 2018-09-18
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level wrapper for WR PTP core including all the modules
-- needed to operate the core on the kc705 board with the rabbit_Fx.
-- Version with no VHDL records on the top-level (mainly for Verilog
-- instantiation).
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
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wishbone_pkg.all;
use work.wr_fabric_pkg.all;
use work.endpoint_pkg.all;
use work.streamers_pkg.all;
use work.wr_xilinx_pkg.all;
use work.wr_board_pkg.all;
use work.wr_kc705_pkg.all;

entity wrc_board_kc705 is
  generic(
    -- set to 1 to speed up some initialization processes during simulation
    g_simulation                : integer := 0;
    -- Select whether to include external ref clock input
    g_with_external_clock_input : integer := 1;
    -- Number of aux clocks syntonized by WRPC to WR timebase
    g_aux_clks                  : integer := 0;
    -- "plainfbrc" = expose WRC fabric interface
    -- "streamers" = attach WRC streamers to fabric interface
    -- "etherbone" = attach Etherbone slave to fabric interface
    g_fabric_iface              : string  := "plainfbrc";
    -- parameters configuration when g_fabric_iface = "streamers" (otherwise ignored)
    g_streamers_op_mode        : t_streamers_op_mode  := TX_AND_RX;
    g_tx_streamer_params       : t_tx_streamer_params := c_tx_streamer_params_defaut;
    g_rx_streamer_params       : t_rx_streamer_params := c_rx_streamer_params_defaut;
    -- memory initialisation file for embedded CPU
    --g_dpram_initf               : string  := "../../../../bin/wrpc/wrc_phy16.bram";
    g_dpram_initf               : string  := "../../wrc.bram";
    -- identification (id and ver) of the layout of words in the generic diag interface
    g_diag_id                   : integer := 0;
    g_diag_ver                  : integer := 0;
    -- size the generic diag interface
    g_diag_ro_vector_width      : integer := 0;
    g_diag_rw_vector_width      : integer := 0
    );
  port (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------
    -- Reset from system fpga
    areset_i          : in  std_logic;

    -- Clock inputs from the board
    clk_20m_vcxo_n_i  : in  std_logic;
    clk_20m_vcxo_p_i  : in  std_logic;
    clk_125m_gtp_n_i  : in  std_logic;
    clk_125m_gtp_p_i  : in  std_logic;
    -- 10MHz ext ref clock input (g_with_external_clock_input = TRUE)
    clk_10m_ext_n_i   : in  std_logic := '0';
    clk_10m_ext_p_i   : in  std_logic := '0';
    
    -- External PPS input (g_with_external_clock_input = TRUE)
    pps_ext_i         : in  std_logic := '0';
    -- 62.5MHz sys clock output
    clk_ref_62m5_n_o  : out std_logic;
    clk_ref_62m5_p_o  : out std_logic;

    ---------------------------------------------------------------------------
    -- Shared SPI interface to DACs
    ---------------------------------------------------------------------------
    dac_refclk_cs_n_o : out std_logic;
    dac_refclk_sclk_o : out std_logic;
    dac_refclk_din_o  : out std_logic;
    
    dac_dmtd_cs_n_o   : out std_logic;
    dac_dmtd_sclk_o   : out std_logic;
    dac_dmtd_din_o    : out std_logic;
    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver and SFP management info
    ---------------------------------------------------------------------------
    sfp_txp_o         : out std_logic;
    sfp_txn_o         : out std_logic;
    sfp_rxp_i         : in  std_logic;
    sfp_rxn_i         : in  std_logic;
    sfp_mod_def1_b    : inout std_logic;
    sfp_mod_def2_b    : inout std_logic;
    sfp_det_i         : in std_logic;   --moddef 0
    sfp_tx_fault_i    : in  std_logic := '0';
    sfp_tx_enable_o   : out std_logic;
    sfp_los_i         : in  std_logic := '0';
    --sfp_rs_o          : out  std_logic;
    ---------------------------------------------------------------------------
    -- I2C EEPROM
    ---------------------------------------------------------------------------
    i2c_switch_scl_b  : inout std_logic;
    i2c_switch_sda_b  : inout std_logic;
    i2c_switch_rst_o  : out std_logic;
    -----------------------------------------------------------------------------
    ---- Onewire interface
    -----------------------------------------------------------------------------
    onewire_b : inout std_logic;
    ---------------------------------------------------------------------------
    -- UART
    ---------------------------------------------------------------------------
    uart_rxd_i : in  std_logic;
    uart_txd_o : out std_logic;
    ---------------------------------------------------------------------------
    -- Buttons, LEDs and PPS output
    ---------------------------------------------------------------------------
    led_act_o  : out std_logic;
    led_link_o : out std_logic;
    -- 1PPS output
    pps_p_o    : out std_logic;
    pps_led_o  : out std_logic;
    -- Link ok indication
    link_ok_o  : out std_logic;
    
    fan : out std_logic
    );

end entity wrc_board_kc705;


architecture std_wrapper of wrc_board_kc705 is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------


  signal areset_n_i         : std_logic;
  signal clk_ref_62m5       : std_logic;
  signal clk_20m_vcxo       : std_logic;
  signal clk_10m_ext        : std_logic;
  
  -- WR fabric interface
  signal wrf_src_out : t_wrf_source_out;
  signal wrf_src_in  : t_wrf_source_in;
  signal wrf_snk_out : t_wrf_sink_out;
  signal wrf_snk_in  : t_wrf_sink_in;

  -- Aux diagnostics
  constant c_diag_ro_size : integer := g_diag_ro_vector_width/32;
  constant c_diag_rw_size : integer := g_diag_rw_vector_width/32;

  signal aux_diag_in  : t_generic_word_array(c_diag_ro_size-1 downto 0);
  signal aux_diag_out : t_generic_word_array(c_diag_rw_size-1 downto 0);

  -- External Tx Timestamping I/F
  signal timestamps_out : t_txtsu_timestamp;

  -- streamers config
  signal wrs_tx_cfg_in  : t_tx_streamer_cfg;
  signal wrs_rx_cfg_in  : t_rx_streamer_cfg;
  
  signal sfp_tx_disable_o  : std_logic;
  signal sfp_scl_i : std_logic;
  signal sfp_scl_o : std_logic;
  signal sfp_sda_i : std_logic;
  signal sfp_sda_o : std_logic;
  signal eeprom_sda_i :  std_logic;
  signal eeprom_sda_o :  std_logic;
  signal eeprom_scl_i :  std_logic;
  signal eeprom_scl_o :  std_logic;
  signal onewire_i     : std_logic;
  signal onewire_oen : std_logic;
  signal fan_cnt : unsigned(19 downto 0);
  
 
begin  -- architecture struct
  
  --the cooling fan on the kc705 is maddeningly loud this sets the fan to 25% duty cylce. short fan to '1' or 'Z' for default behaviour.
  fan_ctrl : process(clk_ref_62m5,areset_i) is
  begin
    if areset_i = '1' then
      fan_cnt <= (others => '0');
    elsif rising_edge(clk_ref_62m5) then
      fan_cnt <= fan_cnt + 1;
    end if;
  end process fan_ctrl;
  fan <= fan_cnt(19) and fan_cnt(18);
 
  areset_n_i <= not areset_i;
  i2c_switch_rst_o <= not areset_i;
  
  clk_20m_buf : IBUFDS 
    generic map(
      IOSTANDARD => "LVDS_25")
    port map(
      I => clk_20m_vcxo_n_i,
      IB=> clk_20m_vcxo_p_i,
      O => clk_20m_vcxo
    );

  clk_10m_ext_buf : IBUFDS 
    generic map(
      IOSTANDARD => "LVDS_25")
    port map(
      I => clk_10m_ext_p_i,
      IB=> clk_10m_ext_n_i,
      O => clk_10m_ext
    );
    
  areset_n_i <= not areset_i;
    clk_ref_62m5_buf : OBUFDS 
      generic map(
        IOSTANDARD => "LVDS_25")
      port map(
        O => clk_ref_62m5_p_o,
        OB=> clk_ref_62m5_n_o,
        I => clk_ref_62m5
      );
      
  wrs_tx_cfg_in.mac_local         <= x"000000000000";
  wrs_tx_cfg_in.mac_target        <= x"ffffffffffff";
  wrs_tx_cfg_in.ethertype         <= x"dbff";
  
  wrs_rx_cfg_in.mac_local         <= x"000000000000";
  wrs_rx_cfg_in.mac_remote        <= x"000000000000";
  wrs_rx_cfg_in.ethertype         <= x"dbff";
  wrs_rx_cfg_in.accept_broadcasts <= '1';
  wrs_rx_cfg_in.filter_remote     <= '0';
  wrs_rx_cfg_in.fixed_latency     <= x"0000000";
  --
  sfp_mod_def1_b  <= '0' when sfp_scl_o = '0' else 'Z';
  sfp_mod_def2_b  <= '0' when sfp_sda_o = '0' else 'Z';
  sfp_tx_enable_o <= not sfp_tx_disable_o;
  sfp_scl_i       <= sfp_mod_def1_b;
  sfp_sda_i       <= sfp_mod_def2_b;
  
  i2c_switch_scl_b <= '0' when eeprom_scl_o = '0' else 'Z';
  i2c_switch_sda_b <= '0' when eeprom_sda_o = '0' else 'Z';
  eeprom_scl_i     <= i2c_switch_scl_b;
  eeprom_sda_i     <= i2c_switch_sda_b;
  
  onewire_b    <= '0' when (onewire_oen = '1') else 'Z';
  onewire_i <= onewire_b;
  -- Instantiate the records-based module
  cmp_xwrc_board_kc705 : xwrc_board_kc705
    generic map (
      g_simulation                => g_simulation,
      g_with_external_clock_input => f_int2bool(g_with_external_clock_input),
      g_aux_clks                  => g_aux_clks,
      g_fabric_iface              => PLAIN,--f_str2iface_type(g_fabric_iface),
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
      areset_edge_n_i      => '1',  --areset_edge_n_i,
      clk_20m_vcxo_i       => clk_20m_vcxo,
      clk_125m_gtp_n_i     => clk_125m_gtp_n_i,
      clk_125m_gtp_p_i     => clk_125m_gtp_p_i,
      clk_10m_ext_i        => clk_10m_ext,
      pps_ext_i            => pps_ext_i,
      --clk_sys_62m5_o       => clk_sys_62m5_o,
      clk_sys_62m5_o       => open,
      clk_ref_62m5_o       => clk_ref_62m5,
      rst_sys_62m5_n_o     => open,
      rst_ref_62m5_n_o     => open,
      --rst_sys_62m5_n_o     => rst_sys_62m5_n_o,
      --rst_ref_62m5_n_o     => rst_ref_62m5_n_o,
      dac_refclk_cs_n_o    => dac_refclk_cs_n_o,
      dac_refclk_sclk_o    => dac_refclk_sclk_o, 
      dac_refclk_din_o     => dac_refclk_din_o,                  
      dac_dmtd_cs_n_o      => dac_dmtd_cs_n_o  , 
      dac_dmtd_sclk_o      => dac_dmtd_sclk_o   ,
      dac_dmtd_din_o       => dac_dmtd_din_o    ,
      sfp_txp_o            => sfp_txp_o,
      sfp_txn_o            => sfp_txn_o,
      sfp_rxp_i            => sfp_rxp_i,
      sfp_rxn_i            => sfp_rxn_i,
      sfp_det_i            => sfp_det_i,
      sfp_sda_i            => sfp_sda_i,
      sfp_sda_o            => sfp_sda_o,
      sfp_scl_i            => sfp_scl_i,
      sfp_scl_o            => sfp_scl_o,
      sfp_rate_select_o    => open,
      sfp_tx_fault_i       => sfp_tx_fault_i,
      sfp_tx_disable_o     => sfp_tx_disable_o,
      sfp_los_i            => sfp_los_i,
      eeprom_sda_i         => eeprom_sda_i,
      eeprom_sda_o         => eeprom_sda_o,
      eeprom_scl_i         => eeprom_scl_i,
      eeprom_scl_o         => eeprom_scl_o,
      onewire_i            => onewire_i,
      onewire_oen_o        => onewire_oen,
      uart_rxd_i           => uart_rxd_i,
      uart_txd_o           => uart_txd_o,

      wrf_src_o            => wrf_src_out,
      wrf_src_i            => wrf_src_in,
      wrf_snk_o            => wrf_snk_out,
      wrf_snk_i            => wrf_snk_in,
      wrs_tx_data_i        => (others => '0'),
      wrs_tx_valid_i       => '0',
      wrs_tx_dreq_o        => open,
      wrs_tx_last_i        => '0',
      wrs_tx_flush_i       => '0',
      wrs_tx_cfg_i         => wrs_tx_cfg_in,
      wrs_rx_first_o       => open,
      wrs_rx_last_o        => open,
      wrs_rx_data_o        => open,
      wrs_rx_valid_o       => open,
      wrs_rx_dreq_i        => '0',
      wrs_rx_cfg_i         => wrs_rx_cfg_in,
      aux_diag_i           => aux_diag_in,
      aux_diag_o           => aux_diag_out,
      tm_dac_value_o       => open,
      tm_dac_wr_o          => open,
      tm_clk_aux_lock_en_i => (others => '0'),
      tm_clk_aux_locked_o  => open,
      timestamps_o         => timestamps_out,
      timestamps_ack_i     => '0',
      abscal_txts_o        => open,
      abscal_rxts_o        => open,
      fc_tx_pause_req_i    => '0',
      fc_tx_pause_delay_i  => (others => '0'),
      fc_tx_pause_ready_o  => open,
      tm_link_up_o         => open,
      tm_time_valid_o      => open,
      tm_tai_o             => open,
      tm_cycles_o          => open,
      led_act_o            => led_act_o,
      led_link_o           => led_link_o,
      btn1_i               => '1',
      btn2_i               => '1',
      pps_p_o              => pps_p_o,
      pps_led_o            => pps_led_o,
      link_ok_o            => link_ok_o);
      
end architecture std_wrapper;
