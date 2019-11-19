-------------------------------------------------------------------------------
-- Title      : WRPC Wrapper for kc705 package
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : wr_kc705_pkg.vhd
-- Author(s)  : Pascal Bos
-- Company    : Nikhef
-- Created    : 2018-09-18
-- Last update: 2018-09-18
-- Standard   : VHDL'93
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
use work.wishbone_pkg.all;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;
use work.endpoint_pkg.all;
use work.wr_board_pkg.all;
use work.streamers_pkg.all;

package wr_kc705_pkg is

  component xwrc_board_kc705 is
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
  
        areset_n_i          : in  std_logic;
      
        areset_edge_n_i     : in  std_logic := '1';
        clk_20m_vcxo_i      : in  std_logic;
        clk_125m_gtp_n_i    : in  std_logic;
        clk_125m_gtp_p_i    : in  std_logic;
        clk_aux_i           : in  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
        clk_10m_ext_i       : in  std_logic                               := '0';
        pps_ext_i           : in  std_logic                               := '0';
        clk_sys_62m5_o      : out std_logic;
        clk_ref_62m5_o      : out std_logic;
        rst_sys_62m5_n_o    : out std_logic;
        rst_ref_62m5_n_o    : out std_logic;
        pci_clk_i           : in  std_logic;

        dac_refclk_cs_n_o : out std_logic;
        dac_refclk_sclk_o : out std_logic;
        dac_refclk_din_o  : out std_logic;
    
        dac_dmtd_cs_n_o   : out std_logic;
        dac_dmtd_sclk_o   : out std_logic;
        dac_dmtd_din_o    : out std_logic;
    
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
    
        eeprom_sda_i : in  std_logic;
        eeprom_sda_o : out std_logic;
        eeprom_scl_i : in  std_logic;
        eeprom_scl_o : out std_logic;
    
        onewire_i     : in  std_logic;
        onewire_oen_o : out std_logic;
 
        uart_rxd_i : in  std_logic;
        uart_txd_o : out std_logic;
    
--        rxn : in std_logic_vector(0 downto 0);
--        rxp : in std_logic_vector(0 downto 0);
--        txn : out std_logic_vector(0 downto 0);
--        txp : out std_logic_vector(0 downto 0);
--        pci_rst_n_i : in std_logic;
--        pci_clk : in std_logic;
             
        wrf_src_o : out t_wrf_source_out;
        wrf_src_i : in  t_wrf_source_in := c_dummy_src_in;
        wrf_snk_o : out t_wrf_sink_out;
        wrf_snk_i : in  t_wrf_sink_in   := c_dummy_snk_in;
   
        wrs_tx_data_i  : in  std_logic_vector(g_tx_streamer_params.data_width-1 downto 0) := (others => '0');
        wrs_tx_valid_i : in  std_logic                                        := '0';
        wrs_tx_dreq_o  : out std_logic;
        wrs_tx_last_i  : in  std_logic                                        := '1';
        wrs_tx_flush_i : in  std_logic                                        := '0';
        wrs_tx_cfg_i   : in  t_tx_streamer_cfg                                := c_tx_streamer_cfg_default;
        wrs_rx_first_o : out std_logic;
        wrs_rx_last_o  : out std_logic;
        wrs_rx_data_o  : out std_logic_vector(g_rx_streamer_params.data_width-1 downto 0);
        wrs_rx_valid_o : out std_logic;
        wrs_rx_dreq_i  : in  std_logic                                        := '0';
        wrs_rx_cfg_i   : in t_rx_streamer_cfg                                 := c_rx_streamer_cfg_default;
 
        wb_slave_i : in  t_wishbone_slave_in := cc_dummy_slave_in;
        wb_slave_o : out t_wishbone_slave_out;
        
        aux_diag_i : in  t_generic_word_array(g_diag_ro_size-1 downto 0) := (others => (others => '0'));
        aux_diag_o : out t_generic_word_array(g_diag_rw_size-1 downto 0);
    
        tm_dac_value_o       : out std_logic_vector(23 downto 0);
        tm_dac_wr_o          : out std_logic_vector(g_aux_clks-1 downto 0);
        tm_clk_aux_lock_en_i : in  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
        tm_clk_aux_locked_o  : out std_logic_vector(g_aux_clks-1 downto 0);
    
        timestamps_o     : out t_txtsu_timestamp;
        timestamps_ack_i : in  std_logic := '1';
 
        abscal_txts_o       : out std_logic;
        abscal_rxts_o       : out std_logic;
   
        fc_tx_pause_req_i   : in  std_logic                     := '0';
        fc_tx_pause_delay_i : in  std_logic_vector(15 downto 0) := x"0000";
        fc_tx_pause_ready_o : out std_logic;
    
        tm_link_up_o    : out std_logic;
        tm_time_valid_o : out std_logic;
        tm_tai_o        : out std_logic_vector(39 downto 0);
        tm_cycles_o     : out std_logic_vector(27 downto 0);
        led_act_o  : out std_logic;
        led_link_o : out std_logic;
        btn1_i     : in  std_logic := '1';
        btn2_i     : in  std_logic := '1';

        pps_p_o    : out std_logic;
        pps_led_o  : out std_logic;

        link_ok_o  : out std_logic
        );
  end component xwrc_board_kc705;


component wrc_board_kc705 is
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
    clk_sys_62m5_o    : out std_logic;
    clk_ref_62m5_n_o  : out std_logic;
    clk_ref_62m5_p_o  : out std_logic;
    pci_clk_i         : in  std_logic;

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
    
    fan : out std_logic;
    wb_adr_i   : in  std_logic_vector(c_wishbone_address_width-1 downto 0)   := (others => '0');
    wb_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0)      := (others => '0');
    wb_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i   : in  std_logic_vector(c_wishbone_address_width/8-1 downto 0) := (others => '0');
    wb_we_i    : in  std_logic                                               := '0';
    wb_cyc_i   : in  std_logic                                               := '0';
    wb_stb_i   : in  std_logic                                               := '0';
    wb_ack_o   : out std_logic;
    wb_err_o   : out std_logic;
    wb_rty_o   : out std_logic;
    wb_stall_o : out std_logic
    );

end component ;
  
end wr_kc705_pkg;
