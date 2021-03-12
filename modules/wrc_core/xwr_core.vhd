-------------------------------------------------------------------------------
-- Title      : WhiteRabbit PTP Core
-- Project    : WhiteRabbit
-------------------------------------------------------------------------------
-- File       : xwr_core.vhd
-- Author     : Grzegorz Daniluk <grzegorz.daniluk@cern.ch>
-- Company    : CERN (BE-CO-HT)
-- Created    : 2011-02-02
-- Last update: 2019-02-01
-- Platform   : FPGA-generics
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- WR PTP Core is a HDL module implementing a complete gigabit Ethernet 
-- interface (MAC + PCS + PHY) with integrated PTP slave ordinary clock 
-- compatible with White Rabbit protocol. It performs subnanosecond clock 
-- synchronization via WR protocol and also acts as an Ethernet "gateway", 
-- providing access to TX/RX interfaces of the built-in WR MAC.
--
-- Starting from version 2.0 all modules are interconnected with pipelined
-- wishbone interface (using wb crossbar and bus fanout). Separate pipelined
-- wishbone bus is used for passing packets between Endpoint, Mini-NIC
-- and External MAC interface.
-------------------------------------------------------------------------------
--
-- Copyright (c) 2012 - 2017 CERN
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
-- Memory map:
--  0x00000000: I/D Memory
--  0x00020000: Peripheral interconnect
--      +0x000: Minic
--      +0x100: Endpoint
--      +0x200: Softpll
--      +0x300: PPS gen
--      +0x400: Syscon
--      +0x500: UART
--      +0x600: OneWire
--      +0x700: Auxillary space (Etherbone config, etc)
--      +0x800: WRPC diagnostics registers

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wrcore_pkg.all;
use work.genram_pkg.all;
use work.wishbone_pkg.all;
use work.endpoint_pkg.all;
use work.wr_fabric_pkg.all;
use work.sysc_wbgen2_pkg.all;
use work.softpll_pkg.all;
use work.etherbone_pkg.all;

entity xwr_core is
  generic(
    --if set to 1, then blocks in PCS use smaller calibration counter to speed 
    --up simulation
    g_simulation                : integer                        := 0;
    -- set to false to reduce the number of information printed during simulation
    g_verbose                   : boolean                        := true;
    g_with_external_clock_input : boolean                        := true;
    --
    g_board_name                : string                         := "NA  ";
    g_flash_secsz_kb            : integer                        := 256;        -- default for SVEC (M25P128)
    g_flash_sdbfs_baddr         : integer                        := 16#600000#; -- default for SVEC (M25P128)
    g_phys_uart                 : boolean                        := true;
    g_virtual_uart              : boolean                        := true;
    g_aux_clks                  : integer                        := 0;
    g_ep_rxbuf_size             : integer                        := 1024;
    g_tx_runt_padding           : boolean                        := true;
    g_dpram_initf               : string                         := "";
    g_dpram_size                : integer                        := 131072/4;  --in 32-bit words
    g_interface_mode            : t_wishbone_interface_mode      := PIPELINED;
    g_address_granularity       : t_wishbone_address_granularity := BYTE;
    g_aux_sdb                   : t_sdb_device                   := c_wrc_periph3_sdb;
    g_aux1_sdb                  : t_sdb_device                   := c_wrc_periph3_sdb;
    g_etherbone_sdb             : t_sdb_device                   := c_etherbone_sdb;    
    g_softpll_enable_debugger   : boolean                        := false;
    g_vuart_fifo_size           : integer                        := 1024;
    g_pcs_16bit                 : boolean                        := false;
    g_ref_clock_rate            : integer                        := 62500000;
    g_sys_clock_rate            : integer                        := 62500000;
    g_ref_clock_hz              : integer                        := 62500000;
    g_sys_clock_hz              : integer                        := 62500000;
    g_ext_clock_rate            : integer                        := 1000000;    
    g_records_for_phy           : boolean                        := false;
    g_diag_id                   : integer                        := 0;
    g_diag_ver                  : integer                        := 0;
    g_diag_ro_size              : integer                        := 0;
    g_diag_rw_size              : integer                        := 0;
    g_num_phys                  : integer                        := 1;
    g_num_softpll_inputs        : integer                        := 2;
    g_with_10M_output           : boolean                        := true);
  port(
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------

    -- system reference clock (any frequency <= f(clk_ref_i))
    clk_sys_i : in std_logic;

    -- DDMTD offset clock (125.x MHz)
    clk_dmtd_i : in std_logic;

    -- Timing reference (125 MHz)
    clk_ref_i : in std_logic;

    -- Aux clock (i.e. the FMC clock), which can be disciplined by the WR Core
    clk_aux_i : in std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');

    -- External 10 MHz reference (cesium, GPSDO, etc.), used in Grandmaster mode
    clk_ext_i : in std_logic := '0';

    clk_ext_mul_i : in std_logic := '0';
    clk_ext_mul_locked_i : in std_logic := '1';
    clk_ext_stopped_i    : in  std_logic := '0';
    clk_ext_rst_o        : out std_logic;

    -- External PPS input (cesium, GPSDO, etc.), used in Grandmaster mode
    pps_ext_i : in std_logic := '0';
    ppsin_term_o : out std_logic;

    rst_n_i : in std_logic;

    -----------------------------------------
    --Timing system
    -----------------------------------------
    dac_hpll_load_p1_o : out std_logic;
    dac_hpll_data_o    : out std_logic_vector(15 downto 0);

    dac_dpll_load_p1_o : out std_logic;
    dac_dpll_data_o    : out std_logic_vector(15 downto 0);

    -----------------------------------------
    -- PHY I/f
    -----------------------------------------
    phy_ref_clk_i        : in std_logic:='0';

    phy_tx_data_o        : out std_logic_vector(f_pcs_data_width(g_pcs_16bit)-1 downto 0);
    phy_tx_k_o           : out std_logic_vector(f_pcs_k_width(g_pcs_16bit)-1 downto 0);
    phy_tx_disparity_i   : in  std_logic:='0';
    phy_tx_enc_err_i     : in  std_logic:='0';

    phy_rx_data_i        : in std_logic_vector(f_pcs_data_width(g_pcs_16bit)-1 downto 0):=(others=>'0');
    phy_rx_rbclk_i       : in std_logic:='0';
    phy_rx_k_i           : in std_logic_vector(f_pcs_k_width(g_pcs_16bit)-1 downto 0):=(others=>'0');
    phy_rx_enc_err_i     : in std_logic:='0';
    phy_rx_bitslide_i    : in std_logic_vector(f_pcs_bts_width(g_pcs_16bit)-1 downto 0):=(others=>'0');

    phy_rst_o            : out std_logic;
    phy_rdy_i            : in  std_logic := '1';
    phy_loopen_o         : out std_logic;
    phy_loopen_vec_o     : out std_logic_vector(2 downto 0);
    phy_tx_prbs_sel_o    : out std_logic_vector(2 downto 0);
    phy_sfp_tx_fault_i   : in std_logic := '0';
    phy_sfp_los_i        : in std_logic := '0';
    phy_sfp_tx_disable_o : out std_logic;
    -----------------------------------------
    -- PHY I/f - record-based
    -- selection done with g_records_for_phy
    -----------------------------------------
    phy8_o               : out t_phy_8bits_from_wrc_array(g_num_phys-1 downto 0);
    phy8_i               : in  t_phy_8bits_to_wrc_array(g_num_phys-1 downto 0):=(others=>c_dummy_phy8_to_wrc);
    phy16_o              : out t_phy_16bits_from_wrc_array(g_num_phys-1 downto 0);
    phy16_i              : in  t_phy_16bits_to_wrc_array(g_num_phys-1 downto 0):=(others=>c_dummy_phy16_to_wrc);
    -----------------------------------------
    --GPIO
    -----------------------------------------
    led_act_o  : out std_logic_vector(g_num_phys-1 downto 0);
    led_link_o : out std_logic_vector(g_num_phys-1 downto 0);
    scl_o      : out std_logic;
    scl_i      : in  std_logic := '1';
    sda_o      : out std_logic;
    sda_i      : in  std_logic := '1';
    sfp_scl_o  : out std_logic_vector(g_num_phys-1 downto 0);
    sfp_scl_i  : in  std_logic_vector(g_num_phys-1 downto 0):= (others=>'1');
    sfp_sda_o  : out std_logic_vector(g_num_phys-1 downto 0);
    sfp_sda_i  : in  std_logic_vector(g_num_phys-1 downto 0):= (others=>'1');
    sfp_det_i  : in  std_logic_vector(g_num_phys-1 downto 0):= (others=>'1');
    btn1_i     : in  std_logic := '1';
    btn2_i     : in  std_logic := '1';
    spi_sclk_o : out std_logic;
    spi_ncs_o  : out std_logic;
    spi_mosi_o : out std_logic;
    spi_miso_i : in  std_logic := '0';
    -----------------------------------------
    --UART
    -----------------------------------------
    uart_rxd_i : in  std_logic := '0';
    uart_txd_o : out std_logic;
    -----------------------------------------
    -- 1-wire
    -----------------------------------------
    owr_pwren_o : out std_logic_vector(1 downto 0);
    owr_en_o    : out std_logic_vector(1 downto 0);
    owr_i       : in  std_logic_vector(1 downto 0) := (others => '1');
    -----------------------------------------
    -- PLL chip configuration
    -----------------------------------------
    pll_mosi_o    : out std_logic;
    pll_miso_i    : in  std_logic:='0';
    pll_sck_o     : out std_logic;
    pll_cs_n_o    : out std_logic;
    pll_sync_n_o  : out std_logic;
    pll_reset_n_o : out std_logic;
    -----------------------------------------
    -- EXT IN PLL chip configuration
    -----------------------------------------
    ext_pll_mosi_o    : out std_logic;
    ext_pll_miso_i    : in  std_logic:='0';
    ext_pll_sck_o     : out std_logic;
    ext_pll_cs_n_o    : out std_logic;
    ext_pll_sync_n_o  : out std_logic;
    ext_pll_reset_n_o : out std_logic;
    -----------------------------------------
    --External WB interface
    -----------------------------------------
    slave_i : in  t_wishbone_slave_in := cc_dummy_slave_in;
    slave_o : out t_wishbone_slave_out;

    aux_master_o : out t_wishbone_master_out;
    aux_master_i : in  t_wishbone_master_in := cc_dummy_master_in;
    aux1_master_o : out t_wishbone_master_out;
    aux1_master_i : in  t_wishbone_master_in := cc_dummy_master_in;

    -----------------------------------------
    -- Etherbone config master
    -----------------------------------------
    eb_cfg_master_o : out t_wishbone_master_out;
    eb_cfg_master_i : in  t_wishbone_master_in := cc_dummy_master_in;
    
    -----------------------------------------
    -- Etherbone Fabric I/F
    -----------------------------------------
    eb_wrf_src_o : out t_wrf_source_out_array(g_num_phys-1 downto 0);
    eb_wrf_src_i : in  t_wrf_source_in_array(g_num_phys-1 downto 0):=(others=>c_dummy_src_in);
    eb_wrf_snk_o : out t_wrf_sink_out_array(g_num_phys-1 downto 0);
    eb_wrf_snk_i : in  t_wrf_sink_in_array(g_num_phys-1 downto 0):=(others=>c_dummy_snk_in);

    -----------------------------------------
    -- External Fabric I/F
    -----------------------------------------
    wrf_src_o : out t_wrf_source_out_array(g_num_phys-1 downto 0);
    wrf_src_i : in  t_wrf_source_in_array(g_num_phys-1 downto 0):=(others=>c_dummy_src_in);
    wrf_snk_o : out t_wrf_sink_out_array(g_num_phys-1 downto 0);
    wrf_snk_i : in  t_wrf_sink_in_array(g_num_phys-1 downto 0):=(others=>c_dummy_snk_in);

    -----------------------------------------
    -- External Tx Timestamping I/F
    -----------------------------------------
    timestamps_o     : out t_txtsu_timestamp_array(g_num_phys-1 downto 0);
    timestamps_ack_i : in  std_logic_vector(g_num_phys-1 downto 0):=(others=>'1');

    -----------------------------------------
    -- Timestamp helper signals, used for Absolute Calibration
    -----------------------------------------
    abscal_txts_o        : out std_logic_vector(g_num_phys-1 downto 0);
    abscal_rxts_o        : out std_logic_vector(g_num_phys-1 downto 0);

    -----------------------------------------
    -- Pause Frame Control
    -----------------------------------------
    fc_tx_pause_req_i   : in  std_logic_vector(g_num_phys-1 downto 0):=(others=>'0');
    fc_tx_pause_delay_i : in  std_logic_vector(16*g_num_phys-1 downto 0):=(others=>'0');
    fc_tx_pause_ready_o : out std_logic_vector(g_num_phys-1 downto 0);

    -----------------------------------------
    -- Timecode/Servo Control
    -----------------------------------------
    tm_link_up_o         : out std_logic_vector(g_num_phys-1 downto 0);
    -- DAC Control
    tm_dac_value_o       : out std_logic_vector(23 downto 0);
    tm_dac_wr_o          : out std_logic_vector(g_aux_clks-1 downto 0);
    -- Aux clock lock enable
    tm_clk_aux_lock_en_i : in  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
    -- Aux clock locked flag
    tm_clk_aux_locked_o  : out std_logic_vector(g_aux_clks-1 downto 0);
    -- Timecode output
    tm_time_valid_o      : out std_logic;
    tm_tai_o             : out std_logic_vector(39 downto 0);
    tm_cycles_o          : out std_logic_vector(27 downto 0);
    -- 1PPS output
    pps_csync_o          : out std_logic;
    pps_valid_o          : out std_logic;
    pps_p_o              : out std_logic;
    pps_led_o            : out std_logic;
    sync_data_p_o        : out std_logic;
    sync_data_n_o        : out std_logic;

    rst_aux_n_o          : out std_logic;

    aux_diag_i           : in  t_generic_word_array(g_diag_ro_size-1 downto 0) := (others =>(others=>'0'));
    aux_diag_o           : out t_generic_word_array(g_diag_rw_size-1 downto 0);

    link_ok_o : out std_logic_vector(g_num_phys-1 downto 0)
    );
end xwr_core;

architecture struct of xwr_core is
begin

  WRPC : wr_core
    generic map(
      g_simulation                => g_simulation,
      g_verbose                   => g_verbose,
      g_board_name                => g_board_name,
      g_flash_secsz_kb            => g_flash_secsz_kb,
      g_flash_sdbfs_baddr         => g_flash_sdbfs_baddr,
      g_phys_uart                 => g_phys_uart,
      g_virtual_uart              => g_virtual_uart,
      g_rx_buffer_size            => g_ep_rxbuf_size,
      g_tx_runt_padding           => g_tx_runt_padding,
      g_with_external_clock_input => g_with_external_clock_input,
      g_aux_clks                  => g_aux_clks,
      g_dpram_initf               => g_dpram_initf,
      g_dpram_size                => g_dpram_size,
      g_interface_mode            => g_interface_mode,
      g_address_granularity       => g_address_granularity,
      g_aux_sdb                   => g_aux_sdb,
      g_aux1_sdb                  => g_aux1_sdb,
      g_etherbone_sdb             => g_etherbone_sdb,
      g_softpll_enable_debugger   => g_softpll_enable_debugger,
      g_vuart_fifo_size           => g_vuart_fifo_size,
      g_pcs_16bit                 => g_pcs_16bit,
      g_ref_clock_rate            => g_ref_clock_rate,
      g_sys_clock_rate            => g_sys_clock_rate,
      g_ref_clock_hz              => g_ref_clock_hz,
      g_sys_clock_hz              => g_sys_clock_hz,
      g_ext_clock_rate            => g_ext_clock_rate,
      g_records_for_phy           => g_records_for_phy,
      g_diag_id                   => g_diag_id,
      g_diag_ver                  => g_diag_ver,
      g_diag_ro_size              => g_diag_ro_size,
      g_diag_rw_size              => g_diag_rw_size,
      g_num_phys                  => g_num_phys,
      g_num_softpll_inputs        => g_num_softpll_inputs,
      g_with_10M_output           => g_with_10M_output
      )
    port map(
      clk_sys_i            => clk_sys_i,
      clk_dmtd_i           => clk_dmtd_i,
      clk_ref_i            => clk_ref_i,
      clk_aux_i            => clk_aux_i,
      clk_ext_i            => clk_ext_i,
      clk_ext_mul_i        => clk_ext_mul_i,
      clk_ext_mul_locked_i => clk_ext_mul_locked_i,
      clk_ext_stopped_i    => clk_ext_stopped_i,
      clk_ext_rst_o        => clk_ext_rst_o,
      pps_ext_i            => pps_ext_i,
      ppsin_term_o         => ppsin_term_o,
      rst_n_i              => rst_n_i,

      dac_hpll_load_p1_o   => dac_hpll_load_p1_o,
      dac_hpll_data_o      => dac_hpll_data_o,
      dac_dpll_load_p1_o   => dac_dpll_load_p1_o,
      dac_dpll_data_o      => dac_dpll_data_o,

      phy_ref_clk_i        => phy_ref_clk_i,
      phy_tx_data_o        => phy_tx_data_o,
      phy_tx_k_o           => phy_tx_k_o,
      phy_tx_disparity_i   => phy_tx_disparity_i,
      phy_tx_enc_err_i     => phy_tx_enc_err_i,
      phy_rx_data_i        => phy_rx_data_i,
      phy_rx_rbclk_i       => phy_rx_rbclk_i,
      phy_rx_k_i           => phy_rx_k_i,
      phy_rx_enc_err_i     => phy_rx_enc_err_i,
      phy_rx_bitslide_i    => phy_rx_bitslide_i,
      phy_rst_o            => phy_rst_o,
      phy_rdy_i            => phy_rdy_i,
      phy_loopen_o         => phy_loopen_o,
      phy_loopen_vec_o     => phy_loopen_vec_o,
      phy_tx_prbs_sel_o    => phy_tx_prbs_sel_o,
      phy_sfp_tx_fault_i   => phy_sfp_tx_fault_i,
      phy_sfp_los_i        => phy_sfp_los_i,
      phy_sfp_tx_disable_o => phy_sfp_tx_disable_o,

      phy8_o     => phy8_o,
      phy8_i     => phy8_i,
      phy16_o    => phy16_o,
      phy16_i    => phy16_i,

      led_act_o  => led_act_o,
      led_link_o => led_link_o,
      scl_o      => scl_o,
      scl_i      => scl_i,
      sda_o      => sda_o,
      sda_i      => sda_i,
      sfp_scl_o  => sfp_scl_o,
      sfp_scl_i  => sfp_scl_i,
      sfp_sda_o  => sfp_sda_o,
      sfp_sda_i  => sfp_sda_i,
      sfp_det_i  => sfp_det_i,
      btn1_i     => btn1_i,
      btn2_i     => btn2_i,
      spi_sclk_o => spi_sclk_o,
      spi_ncs_o  => spi_ncs_o,
      spi_mosi_o => spi_mosi_o,
      spi_miso_i => spi_miso_i,
      uart_rxd_i => uart_rxd_i,
      uart_txd_o => uart_txd_o,

      owr_pwren_o => owr_pwren_o,
      owr_en_o    => owr_en_o,
      owr_i       => owr_i,

      ext_pll_mosi_o    => ext_pll_mosi_o,
      ext_pll_miso_i    => ext_pll_miso_i,
      ext_pll_sck_o     => ext_pll_sck_o,
      ext_pll_cs_n_o    => ext_pll_cs_n_o,
      ext_pll_sync_n_o  => ext_pll_sync_n_o,
      ext_pll_reset_n_o => ext_pll_reset_n_o,

      pll_mosi_o    => pll_mosi_o,
      pll_miso_i    => pll_miso_i,
      pll_sck_o     => pll_sck_o,
      pll_cs_n_o    => pll_cs_n_o,
      pll_sync_n_o  => pll_sync_n_o,
      pll_reset_n_o => pll_reset_n_o,      

      wb_adr_i   => slave_i.adr,
      wb_dat_i   => slave_i.dat,
      wb_dat_o   => slave_o.dat,
      wb_sel_i   => slave_i.sel,
      wb_we_i    => slave_i.we,
      wb_cyc_i   => slave_i.cyc,
      wb_stb_i   => slave_i.stb,
      wb_ack_o   => slave_o.ack,
      wb_err_o   => slave_o.err,
      wb_rty_o   => slave_o.rty,
      wb_stall_o => slave_o.stall,

      aux_adr_o   => aux_master_o.adr,
      aux_dat_o   => aux_master_o.dat,
      aux_sel_o   => aux_master_o.sel,
      aux_cyc_o   => aux_master_o.cyc,
      aux_stb_o   => aux_master_o.stb,
      aux_we_o    => aux_master_o.we,
      aux_stall_i => aux_master_i.stall,
      aux_ack_i   => aux_master_i.ack,
      aux_dat_i   => aux_master_i.dat,

      aux1_adr_o   => aux1_master_o.adr,
      aux1_dat_o   => aux1_master_o.dat,
      aux1_sel_o   => aux1_master_o.sel,
      aux1_cyc_o   => aux1_master_o.cyc,
      aux1_stb_o   => aux1_master_o.stb,
      aux1_we_o    => aux1_master_o.we,
      aux1_stall_i => aux1_master_i.stall,
      aux1_ack_i   => aux1_master_i.ack,
      aux1_dat_i   => aux1_master_i.dat,
    
      eb_cfg_adr_o   => eb_cfg_master_o.adr,
      eb_cfg_dat_o   => eb_cfg_master_o.dat,
      eb_cfg_dat_i   => eb_cfg_master_i.dat,
      eb_cfg_sel_o   => eb_cfg_master_o.sel,
      eb_cfg_we_o    => eb_cfg_master_o.we,
      eb_cfg_cyc_o   => eb_cfg_master_o.cyc,
      eb_cfg_stb_o   => eb_cfg_master_o.stb,
      eb_cfg_ack_i   => eb_cfg_master_i.ack,
      eb_cfg_stall_i => eb_cfg_master_i.stall,
    
      eb_wrf_snk_i   => eb_wrf_snk_i,
      eb_wrf_snk_o   => eb_wrf_snk_o,
      eb_wrf_src_i   => eb_wrf_src_i,
      eb_wrf_src_o   => eb_wrf_src_o,

      wrf_snk_i   => wrf_snk_i,
      wrf_snk_o   => wrf_snk_o,
      wrf_src_i   => wrf_src_i,
      wrf_src_o   => wrf_src_o,

      timestamps_o         => timestamps_o,
      txtsu_ack_i          => timestamps_ack_i,

      abscal_txts_o        => abscal_txts_o,
      abscal_rxts_o        => abscal_rxts_o,
      
      fc_tx_pause_req_i    => fc_tx_pause_req_i,
      fc_tx_pause_delay_i  => fc_tx_pause_delay_i,
      fc_tx_pause_ready_o  => fc_tx_pause_ready_o,

      tm_link_up_o         => tm_link_up_o,
      tm_dac_value_o       => tm_dac_value_o,
      tm_dac_wr_o          => tm_dac_wr_o,
      tm_clk_aux_lock_en_i => tm_clk_aux_lock_en_i,
      tm_clk_aux_locked_o  => tm_clk_aux_locked_o,
      tm_time_valid_o      => tm_time_valid_o,
      tm_tai_o             => tm_tai_o,
      tm_cycles_o          => tm_cycles_o,
      pps_csync_o          => pps_csync_o,
      pps_valid_o          => pps_valid_o,
      pps_p_o              => pps_p_o,
      pps_led_o            => pps_led_o,
      sync_data_p_o        => sync_data_p_o,
      sync_data_n_o        => sync_data_n_o,
      rst_aux_n_o          => rst_aux_n_o,
      link_ok_o            => link_ok_o,
      aux_diag_i => aux_diag_i,
      aux_diag_o => aux_diag_o
      );

end struct;
