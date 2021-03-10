-------------------------------------------------------------------------------
-- Title      : WRPC Wrapper for SPEC7 package
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : wr_spec7_pkg.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>, Pascal Bos <bosp@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2017-11-08
-- Last update: 2020-02-12
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Copyright (c) 2020 Nikhef
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
use work.wishbone_pkg.all;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;
use work.endpoint_pkg.all;
use work.wr_board_pkg.all;
use work.streamers_pkg.all;

package wr_spec7_pkg is

  component xwrc_board_spec7 is
    generic (
      g_simulation                : integer              := 0;
      g_with_external_clock_input : boolean              := TRUE;
      g_aux_clks                  : integer              := 0;
      g_fabric_iface              : t_board_fabric_iface := plain;
      g_streamers_op_mode         : t_streamers_op_mode  := TX_AND_RX;
      g_tx_streamer_params        : t_tx_streamer_params := c_tx_streamer_params_defaut;
      g_rx_streamer_params        : t_rx_streamer_params := c_rx_streamer_params_defaut;
      g_dpram_initf               : string               := "default_xilinx";
      g_diag_id                   : integer              := 0;
      g_diag_ver                  : integer              := 0;
      g_diag_ro_size              : integer              := 0;
      g_diag_rw_size              : integer              := 0);
    port (
      areset_n_i           : in  std_logic;
      areset_edge_n_i      : in  std_logic := '1';
      clk_125m_dmtd_n_i    : in  std_logic;
      clk_125m_dmtd_p_i    : in  std_logic;
      clk_125m_gtx_n_i     : in  std_logic;
      clk_125m_gtx_p_i     : in  std_logic;
      clk_aux_i            : in  std_logic_vector(g_aux_clks-1 downto 0)          := (others => '0');
      clk_10m_ext_i        : in  std_logic                                        := '0';
      pps_ext_i            : in  std_logic                                        := '0';
      clk_sys_62m5_o       : out std_logic;
      clk_ref_62m5_o       : out std_logic;
      clk_dmtd_62m5_o      : out std_logic;
      rst_sys_62m5_n_o     : out std_logic;
      rst_ref_62m5_n_o     : out std_logic;
      dac_refclk_cs_n_o    : out std_logic;
      dac_refclk_sclk_o    : out std_logic;
      dac_refclk_din_o     : out std_logic;
      dac_dmtd_cs_n_o      : out std_logic;
      dac_dmtd_sclk_o      : out std_logic;
      dac_dmtd_din_o       : out std_logic;
      pll_status_i         : in  std_logic := '0';
      pll_mosi_o           : out std_logic;
      pll_miso_i           : in  std_logic := '0';
      pll_sck_o            : out std_logic;
      pll_cs_n_o           : out std_logic;
      pll_sync_o           : out std_logic;
      pll_reset_n_o        : out std_logic;
      pll_lock_i           : in  std_logic := '0';
      pll_wr_mode_o        : out std_logic_vector(1 downto 0);
      sfp_txp_o            : out std_logic;
      sfp_txn_o            : out std_logic;
      sfp_rxp_i            : in  std_logic;
      sfp_rxn_i            : in  std_logic;
      sfp_det_i            : in  std_logic                                        := '1';
      sfp_sda_i            : in  std_logic;
      sfp_sda_o            : out std_logic;
      sfp_scl_i            : in  std_logic;
      sfp_scl_o            : out std_logic;
      sfp_rate_select_o    : out std_logic;
      sfp_tx_fault_i       : in  std_logic                                        := '0';
      sfp_tx_disable_o     : out std_logic;
      sfp_los_i            : in  std_logic                                        := '0';
      eeprom_sda_i         : in  std_logic;
      eeprom_sda_o         : out std_logic;
      eeprom_scl_i         : in  std_logic;
      eeprom_scl_o         : out std_logic;
      onewire_i            : in  std_logic;
      onewire_oen_o        : out std_logic;
      uart_rxd_i           : in  std_logic;
      uart_txd_o           : out std_logic;
      wb_slave_i           : in  t_wishbone_slave_in := cc_dummy_slave_in;
      wb_slave_o           : out t_wishbone_slave_out;
      wrf_src_o            : out t_wrf_source_out;
      wrf_src_i            : in  t_wrf_source_in                                  := c_dummy_src_in;
      wrf_snk_o            : out t_wrf_sink_out;
      wrf_snk_i            : in  t_wrf_sink_in                                    := c_dummy_snk_in;
      wrs_tx_data_i        : in  std_logic_vector(g_tx_streamer_params.data_width-1 downto 0) := (others => '0');
      wrs_tx_valid_i       : in  std_logic                                        := '0';
      wrs_tx_dreq_o        : out std_logic;
      wrs_tx_last_i        : in  std_logic                                        := '1';
      wrs_tx_flush_i       : in  std_logic                                        := '0';
      wrs_tx_cfg_i         : in  t_tx_streamer_cfg                                := c_tx_streamer_cfg_default;
      wrs_rx_first_o       : out std_logic;
      wrs_rx_last_o        : out std_logic;
      wrs_rx_data_o        : out std_logic_vector(g_rx_streamer_params.data_width-1 downto 0);
      wrs_rx_valid_o       : out std_logic;
      wrs_rx_dreq_i        : in  std_logic                                        := '0';
      wrs_rx_cfg_i         : in t_rx_streamer_cfg                                 := c_rx_streamer_cfg_default;
      aux_diag_i           : in  t_generic_word_array(g_diag_ro_size-1 downto 0)  := (others => (others => '0'));
      aux_diag_o           : out t_generic_word_array(g_diag_rw_size-1 downto 0);
      tm_dac_value_o       : out std_logic_vector(23 downto 0);
      tm_dac_wr_o          : out std_logic_vector(g_aux_clks-1 downto 0);
      tm_clk_aux_lock_en_i : in  std_logic_vector(g_aux_clks-1 downto 0)          := (others => '0');
      tm_clk_aux_locked_o  : out std_logic_vector(g_aux_clks-1 downto 0);
      timestamps_o         : out t_txtsu_timestamp;
      timestamps_ack_i     : in  std_logic                                        := '1';
      abscal_txts_o        : out std_logic;
      abscal_rxts_o        : out std_logic;
      fc_tx_pause_req_i    : in  std_logic                                        := '0';
      fc_tx_pause_delay_i  : in  std_logic_vector(15 downto 0)                    := x"0000";
      fc_tx_pause_ready_o  : out std_logic;
      tm_link_up_o         : out std_logic;
      tm_time_valid_o      : out std_logic;
      tm_tai_o             : out std_logic_vector(39 downto 0);
      tm_cycles_o          : out std_logic_vector(27 downto 0);
      led_act_o            : out std_logic;
      led_link_o           : out std_logic;
      btn1_i               : in  std_logic                                        := '1';
      btn2_i               : in  std_logic                                        := '1';
      pps_p_o              : out std_logic;
      pps_led_o            : out std_logic;
      link_ok_o            : out std_logic);
  end component xwrc_board_spec7;

  component Pcie_wrapper is
  port (
    aclk1_0 : in STD_LOGIC;
    pcie_clk : in STD_LOGIC;
    pcie_rst_n : in STD_LOGIC;
    user_lnk_up_0 : out STD_LOGIC;
    usr_irq_ack_0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    usr_irq_req_0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_0_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_0_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_0_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_0_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_0_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_0_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_0_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_0_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_0_awvalid : out STD_LOGIC;
    M00_AXI_0_awready : in STD_LOGIC;
    M00_AXI_0_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_0_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_0_wlast : out STD_LOGIC;
    M00_AXI_0_wvalid : out STD_LOGIC;
    M00_AXI_0_wready : in STD_LOGIC;
    M00_AXI_0_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_0_bvalid : in STD_LOGIC;
    M00_AXI_0_bready : out STD_LOGIC;
    M00_AXI_0_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_0_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_0_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_0_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_0_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_0_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_0_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_0_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_0_arvalid : out STD_LOGIC;
    M00_AXI_0_arready : in STD_LOGIC;
    M00_AXI_0_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_0_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_0_rlast : in STD_LOGIC;
    M00_AXI_0_rvalid : in STD_LOGIC;
    M00_AXI_0_rready : out STD_LOGIC;
    pcie_mgt_0_rxn : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pcie_mgt_0_rxp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pcie_mgt_0_txn : out STD_LOGIC_VECTOR ( 1 downto 0 );
    pcie_mgt_0_txp : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component Pcie_wrapper;
  
  component processing_system_pcie_wrapper is
  port (
    aclk1_0 : in STD_LOGIC;
    pcie_clk : in STD_LOGIC;
    pcie_rst_n : in STD_LOGIC;
    user_lnk_up_0 : out STD_LOGIC;
    usr_irq_ack_0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    usr_irq_req_0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR3_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR3_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR3_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR3_addr : out STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR3_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR3_ras_n : out STD_LOGIC;
    DDR3_cas_n : out STD_LOGIC;
    DDR3_we_n : out STD_LOGIC;
    DDR3_reset_n : out STD_LOGIC;
    DDR3_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_dm : out STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR3_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    M00_AXI_0_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_0_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_0_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_0_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_0_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_0_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_0_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_0_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_0_awvalid : out STD_LOGIC;
    M00_AXI_0_awready : in STD_LOGIC;
    M00_AXI_0_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_0_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_0_wlast : out STD_LOGIC;
    M00_AXI_0_wvalid : out STD_LOGIC;
    M00_AXI_0_wready : in STD_LOGIC;
    M00_AXI_0_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_0_bvalid : in STD_LOGIC;
    M00_AXI_0_bready : out STD_LOGIC;
    M00_AXI_0_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_0_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_0_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_0_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_0_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_0_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_0_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_0_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_0_arvalid : out STD_LOGIC;
    M00_AXI_0_arready : in STD_LOGIC;
    M00_AXI_0_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_0_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_0_rlast : in STD_LOGIC;
    M00_AXI_0_rvalid : in STD_LOGIC;
    M00_AXI_0_rready : out STD_LOGIC;
    pcie_mgt_0_rxn : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pcie_mgt_0_rxp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pcie_mgt_0_txn : out STD_LOGIC_VECTOR ( 1 downto 0 );
    pcie_mgt_0_txp : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component processing_system_pcie_wrapper;
end wr_spec7_pkg;
