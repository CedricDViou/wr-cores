-------------------------------------------------------------------------------
-- Title      : WRPC reference design for SPEC7
--            : based on ZYNQ Z030/Z035/Z045
-- Project    : WR PTP Core and EMPIR 17IND14 WRITE 
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
--            : http://empir.npl.co.uk/write/
-------------------------------------------------------------------------------
-- File       : spec7_write_top.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2018-12-10
-- Last update: 2018-12-10
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level file for the WRPC reference design on the SPEC7
--              in combination with the High Stability external Oscillator.
--              See also EMPIR 17IND14 WRITE Project (http://empir.npl.co.uk/write/)
--
-- This is a reference top HDL that instanciates the WR PTP Core together with
-- its peripherals to be run on a CLB card.
--
-- There are two main usecases for this HDL file:
-- * let new users easily synthesize a WR PTP Core bitstream that can be run on
--   reference hardware
-- * provide a reference top HDL file showing how the WRPC can be instantiated
--   in HDL projects.
--
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

library work;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;
use work.wr_board_pkg.all;
use work.wr_spec7_pkg.all;
use work.axi4_pkg.all;
library unisim;
use unisim.vcomponents.all;

entity spec7_write_top is
  generic (
    g_dpram_initf : string := "../../../../bin/wrpc/wrc_phy16_direct_dmtd.bram";
    -- In Vivado Project-Mode, during a Synthesis run or an Implementation run, the Vivado working
    -- directory temporarily changes to the "project_name/project_name.runs/run_name" directory.

    -- Simulation-mode enable parameter. Set by default (synthesis) to 0, and
    -- changed to non-zero in the instantiation of the top level DUT in the testbench.
    -- Its purpose is to reduce some internal counters/timeouts to speed up simulations.
    g_simulation : integer := 0
  );
  port (
    ---------------------------------------------------------------------------`
    -- Clocks/resets
    ---------------------------------------------------------------------------

    -- Local oscillators
    clk_125m_dmtd_p_i : in std_logic;             -- 124.992 MHz PLL reference
    clk_125m_dmtd_n_i : in std_logic;

    clk_125m_gtx_n_i  : in std_logic;             -- 125 MHz GTX reference (either from WR
    clk_125m_gtx_p_i  : in std_logic;             -- Oscillators of stable external oscillator)

    ---------------------------------------------------------------------------
    -- SPI interface to DACs
    ---------------------------------------------------------------------------

    dac_refclk_cs_n_o : out std_logic;
    dac_refclk_sclk_o : out std_logic;
    dac_refclk_din_o  : out std_logic;

    dac_dmtd_cs_n_o   : out std_logic;
    dac_dmtd_sclk_o   : out std_logic;
    dac_dmtd_din_o    : out std_logic;

    -------------------------------------------------------------------------------
    -- AD9516 PLL Control signals
    -------------------------------------------------------------------------------    

    pll_status_i      : in  std_logic;
    pll_mosi_o        : out std_logic;
    pll_miso_i        : in  std_logic;
    pll_sck_o         : out std_logic;
    pll_cs_n_o        : out std_logic;
    pll_sync_n_o      : out std_logic;
    pll_reset_n_o     : out std_logic;
    pll_refsel_o      : out std_logic;
    pll_lock_i        : in  std_logic;
    
    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver
    ---------------------------------------------------------------------------

    sfp_txp_o         : out   std_logic;
    sfp_txn_o         : out   std_logic;
    sfp_rxp_i         : in    std_logic;
    sfp_rxn_i         : in    std_logic;
    sfp_mod_def0_i    : in    std_logic;          -- sfp detect
    sfp_mod_def1_b    : inout std_logic;          -- scl
    sfp_mod_def2_b    : inout std_logic;          -- sda
    sfp_rate_select_o : out   std_logic;
    sfp_tx_fault_i    : in    std_logic;
    sfp_tx_disable_o  : out   std_logic;
    sfp_los_i         : in    std_logic;

    ---------------------------------------------------------------------------
    -- UART
    ---------------------------------------------------------------------------

    uart_rxd_i : in  std_logic;
    uart_txd_o : out std_logic;

    ---------------------------------------------------------------------------
    -- No Flash memory SPI interface
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Miscellanous SPEC7 pins
    ---------------------------------------------------------------------------
    -- Red LED next to the SFP: blinking indicates that packets are being
    -- transferred.
    led_act_o   : out std_logic;
    -- Green LED next to the SFP: indicates if the link is up.
    led_link_o  : out std_logic;

    reset_n_i   : in  std_logic;
    suicide_n_o : out std_logic;
    wdog_n_o    : out std_logic;
    prsnt_m2c_l_i : in  std_logic;

    ------------------------------------------------------------------------------
    -- Digital I/O Bulls-Eye connections
    ------------------------------------------------------------------------------
    --  3, 4 ABSCAL_TXTS                 (Bank 35 C17,C16)
    abscal_txts_p_o   : out std_logic;
    abscal_txts_n_o   : out std_logic;
    --  5, 6 PPS_OUT                     (Bank 35 G16,G15)
    pps_p_o           : out std_logic;
    pps_n_o           : out std_logic;
    --  7, 8 PPS_IN                      (Bank 35 G14,F14)
    pps_p_i           : in std_logic;
    pps_n_i           : in std_logic;
    --  9,10 10MHz_out                   (Bank 35 F15,E15)
    clk_10m_p_o       : out std_logic;
    clk_10m_n_o       : out std_logic;
    -- 11,12 10MHZ_in                    (Bank 35 J14,H14)
    clk_10m_p_i       : in std_logic;
    clk_10m_n_i       : in std_logic;

    -- blink 1-PPS.
    led_pps : out std_logic;

    ---------------------------------------------------------------------------
    -- EEPROM interface
    ---------------------------------------------------------------------------
    -- I2C interface for accessing
    -- EEPROM    (24AA64       Addr 1010.000x) and
    -- Unique ID (24AA025EU48, Addr 1010.001x).
    scl_b : inout std_logic;
    sda_b : inout std_logic;
    
    ---------------------------------------------------------------------------
    -- PCIe interface
    ---------------------------------------------------------------------------
    
    pci_clk_n : in  std_logic;
    pci_clk_p : in  std_logic;
    perst_n   : in  std_logic;
    rxn       : in  std_logic_vector(1 downto 0);
    rxp       : in  std_logic_vector(1 downto 0);
    txn       : out std_logic_vector(1 downto 0);
    txp       : out std_logic_vector(1 downto 0)

  );
end entity spec7_write_top;

architecture top of spec7_write_top is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------

  -- Number of masters on the wishbone crossbar
  constant c_NUM_WB_MASTERS : integer := 2;

  -- Number of slaves on the primary wishbone crossbar
  constant c_NUM_WB_SLAVES : integer := 1;

  -- Primary Wishbone master(s) offsets
  constant c_WB_MASTER_PCIE    : integer := 0;
  constant c_WB_MASTER_ETHBONE : integer := 1;

  -- Primary Wishbone slave(s) offsets
  constant c_WB_SLAVE_WRC : integer := 0;

  -- sdb header address on primary crossbar
  constant c_SDB_ADDRESS : t_wishbone_address := x"00040000";

  -- f_xwb_bridge_manual_sdb(size, sdb_addr)
  -- Note: sdb_addr is the sdb records address relative to the bridge base address
  constant c_wrc_bridge_sdb : t_sdb_bridge :=
    f_xwb_bridge_manual_sdb(x"0003ffff", x"00030000");

  -- Primary wishbone crossbar layout
  constant c_WB_LAYOUT : t_sdb_record_array(c_NUM_WB_SLAVES - 1 downto 0) := (
    c_WB_SLAVE_WRC => f_sdb_embed_bridge(c_wrc_bridge_sdb, x"00000000"));

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- clock and reset
--  signal clk_125m_pllref : std_logic;
  signal clk_sys_62m5    : std_logic;
  signal rst_sys_62m5_n  : std_logic;
  signal rst_ref_62m5_n  : std_logic;
--  signal rst_gen_10mhz_n : std_logic;
  signal clk_ref_62m5    : std_logic;
  signal clk_ext_10m     : std_logic;
  signal clk_10m_out     : std_logic;
  signal clk_500m        : std_logic;

  -- I2C EEPROM
  signal eeprom_sda_in   : std_logic;
  signal eeprom_sda_out  : std_logic;
  signal eeprom_scl_in   : std_logic;
  signal eeprom_scl_out  : std_logic;

  -- SFP
  signal sfp_sda_in  : std_logic;
  signal sfp_sda_out : std_logic;
  signal sfp_scl_in  : std_logic;
  signal sfp_scl_out : std_logic;

  -- LEDs and GPIO
  signal wrc_abscal_txts_out : std_logic;
  signal wrc_abscal_rxts_out : std_logic;
  signal wrc_pps_out : std_logic;
  signal wrc_pps_led : std_logic;
  signal wrc_pps_in  : std_logic;
  signal svec_led    : std_logic_vector(15 downto 0);

  -- DIO Mezzanine
  signal dio_in  : std_logic_vector(4 downto 0);
  signal dio_out : std_logic_vector(4 downto 0);
  
  --Axi4
  signal m_axil_i :  t_axi4_lite_master_in_32;
  signal m_axil_o :  t_axi4_lite_master_out_32;
  signal axis_icap: t_axis_64;
  
  --Wishbone
  signal wb_master_i : t_wishbone_master_in; 
  signal wb_master_o : t_wishbone_master_out;

  --PCIe 
  signal pci_clk : std_logic;
  signal axi_clk : std_logic;


  component pll_62m5_500m is
    port (
      areset_n_i        : in  std_logic;
      clk_62m5_pllref_i : in  std_logic;             
      clk_500m_o        : out std_logic;
      pll_500m_locked_o : out std_logic
    );
  end component pll_62m5_500m;

  component gen_10mhz is
    port (
      clk_500m_i       : in  std_logic;
      rst_n_i     : in  std_logic;
      pps_i       : in  std_logic;
      clk_10mhz_o : out std_logic
    );
  end component gen_10mhz;


begin  -- architecture top

  -- Never trigger PS_POR or PROGRAM_B
  suicide_n_o <= '1';
  wdog_n_o    <= '1';
  -- prsnt_m2c_l_i isn't used but must be defined as input.

pci_clk_buf : IBUFDS_GTE2
  port map(
    I  => pci_clk_p,
    IB => pci_clk_n,
    O  => pci_clk,
    ODIV2 => open,
    CEB => '0'
  ); 
Pcie: Pcie_wrapper
  port map (
    M00_AXI_0_araddr  => m_axil_o.araddr,
    M00_AXI_0_arburst => open,
    M00_AXI_0_arcache => open,
    M00_AXI_0_arlen   => open,
    M00_AXI_0_arlock  => open,
    M00_AXI_0_arprot  => open,
    M00_AXI_0_arqos   => open,
    M00_AXI_0_arready => m_axil_i.arready,
    M00_AXI_0_arsize  => open,
    M00_AXI_0_arvalid => m_axil_o.arvalid,
    M00_AXI_0_awaddr  => m_axil_o.awaddr,
    M00_AXI_0_awburst => open,
    M00_AXI_0_awcache => open,
    M00_AXI_0_awlen   => open,
    M00_AXI_0_awlock  => open,
    M00_AXI_0_awprot  => open,
    M00_AXI_0_awqos   => open,
    M00_AXI_0_awready => m_axil_i.awready,
    M00_AXI_0_awsize  => open,
    M00_AXI_0_awvalid => m_axil_o.awvalid,
    M00_AXI_0_bready  => m_axil_o.bready,
    M00_AXI_0_bresp   => m_axil_i.bresp,
    M00_AXI_0_bvalid  => m_axil_i.bvalid,
    M00_AXI_0_rdata   => m_axil_i.rdata,
    M00_AXI_0_rlast   => m_axil_i.rlast,
    M00_AXI_0_rready  => m_axil_o.rready,
    M00_AXI_0_rresp   => m_axil_i.rresp,
    M00_AXI_0_rvalid  => m_axil_i.rvalid,
    M00_AXI_0_wdata   => m_axil_o.wdata,
    M00_AXI_0_wlast   => m_axil_o.wlast,
    M00_AXI_0_wready  => m_axil_i.wready,
    M00_AXI_0_wstrb   => m_axil_o.wstrb,
    M00_AXI_0_wvalid  => m_axil_o.wvalid,
--    M_AXIS_H2C_0_0_tdata  => axis_icap.data,
--    M_AXIS_H2C_0_0_tkeep  => axis_icap.keep,
--    M_AXIS_H2C_0_0_tlast  => axis_icap.last,
--    M_AXIS_H2C_0_0_tready => axis_icap.ready,
--    M_AXIS_H2C_0_0_tvalid => axis_icap.valid,
    aclk1_0           => clk_sys_62m5,
    axi_aclk          => axi_clk,
    pcie_mgt_0_rxn    => rxn,
    pcie_mgt_0_rxp    => rxp,
    pcie_mgt_0_txn    => txn,
    pcie_mgt_0_txp    => txp,
    pcie_clk          => pci_clk,
    pcie_rst_n        => perst_n,
    user_lnk_up_0     => open,
    usr_irq_ack_0     => open,
    usr_irq_req_0     => "0"
  );
--Icap : icap_wrapper 
--  port map(
--    s_axis_tvalid => axis_icap.valid, 
--    s_axis_tready => axis_icap.ready, 
--    s_axis_tdata  => axis_icap.data, 
--    s_axis_tkeep  => axis_icap.keep,
--    s_axis_tlast  => axis_icap.last,
--    axi_clk       => axi_clk,
--    axi_rst_n     => reset_n_i
--  );
AXI2WB : xwb_axi4lite_bridge 
  port map(
    clk_sys_i => clk_sys_62m5,
    rst_n_i   => reset_n_i,
                
    axi4_slave_i => m_axil_o,
    axi4_slave_o => m_axil_i,
    wb_master_o  => wb_master_o,
    wb_master_i  => wb_master_i  
  );
  -----------------------------------------------------------------------------
  -- The WR PTP core board package (WB Slave + WB Master)
  -----------------------------------------------------------------------------

  cmp_xwrc_board_spec7 : xwrc_board_spec7
    generic map (
      g_simulation                => g_simulation,
      g_with_external_clock_input => TRUE,
      g_dpram_initf               => g_dpram_initf,
      g_fabric_iface              => PLAIN)
    port map (
      areset_n_i          => reset_n_i,
      clk_125m_dmtd_n_i   => clk_125m_dmtd_n_i,
      clk_125m_dmtd_p_i   => clk_125m_dmtd_p_i,
      clk_125m_gtx_n_i    => clk_125m_gtx_n_i,
      clk_125m_gtx_p_i    => clk_125m_gtx_p_i,
--      clk_125m_pllref_o   => clk_125m_pllref,
      clk_10m_ext_i       => clk_ext_10m,
      clk_sys_62m5_o      => clk_sys_62m5,
      clk_ref_62m5_o      => clk_ref_62m5,
      rst_sys_62m5_n_o    => rst_sys_62m5_n,
      rst_ref_62m5_n_o    => rst_ref_62m5_n,
      dac_refclk_cs_n_o   => dac_refclk_cs_n_o,
      dac_refclk_sclk_o   => dac_refclk_sclk_o,
      dac_refclk_din_o    => dac_refclk_din_o,
      dac_dmtd_cs_n_o     => dac_dmtd_cs_n_o,
      dac_dmtd_sclk_o     => dac_dmtd_sclk_o, 
      dac_dmtd_din_o      => dac_dmtd_din_o, 

      pll_status_i        => pll_status_i,
      pll_mosi_o          => pll_mosi_o,
      pll_miso_i          => pll_miso_i,
      pll_sck_o           => pll_sck_o,
      pll_cs_n_o          => pll_cs_n_o,
      pll_sync_n_o        => pll_sync_n_o,
      pll_reset_n_o       => pll_reset_n_o,
      pll_refsel_o        => pll_refsel_o,
      pll_lock_i          => pll_lock_i,

      sfp_txp_o           => sfp_txp_o,
      sfp_txn_o           => sfp_txn_o,
      sfp_rxp_i           => sfp_rxp_i,
      sfp_rxn_i           => sfp_rxn_i,
      sfp_det_i           => sfp_mod_def0_i,
      sfp_sda_i           => sfp_sda_in,
      sfp_sda_o           => sfp_sda_out,
      sfp_scl_i           => sfp_scl_in,
      sfp_scl_o           => sfp_scl_out,
      sfp_rate_select_o   => sfp_rate_select_o,
      sfp_tx_fault_i      => sfp_tx_fault_i,
      sfp_tx_disable_o    => sfp_tx_disable_o,
      sfp_los_i           => sfp_los_i,

      eeprom_sda_i        => eeprom_sda_in,
      eeprom_sda_o        => eeprom_sda_out,
      eeprom_scl_i        => eeprom_scl_in,
      eeprom_scl_o        => eeprom_scl_out,

      onewire_i           => '1',  -- No onewire, Unique ID now via
      onewire_oen_o       => open, -- 24AA025EU48 (I2C Addr 1010.001x)
      -- Uart
      uart_rxd_i          => uart_rxd_i,
      uart_txd_o          => uart_txd_o,
      -- Wishbone
      wb_slave_i          => wb_master_o,
      wb_slave_o          => wb_master_i,
      
      abscal_txts_o       => wrc_abscal_txts_out,
      abscal_rxts_o       => open,

      pps_ext_i           => wrc_pps_in,
      pps_p_o             => wrc_pps_out,
      pps_led_o           => wrc_pps_led,
      led_link_o          => led_link_o,
      led_act_o           => led_act_o);

  -- Tristates for SFP EEPROM
  sfp_mod_def1_b <= '0' when sfp_scl_out = '0' else 'Z';
  sfp_mod_def2_b <= '0' when sfp_sda_out = '0' else 'Z';
  sfp_scl_in     <= sfp_mod_def1_b;
  sfp_sda_in     <= sfp_mod_def2_b;

  ------------------------------------------------------------------------------
  -- Digital I/O Bulls-Eye connections
  ------------------------------------------------------------------------------
  -- A01, A02  PPS_OUT                     (Bank 35 G16,G15)
  -- A03, A04  10MHz_out                   (Bank 35 F15,E15)
  -- A05, A06  125 MHz Reference Clock Out (WR Oscillators)
  -- A07, A08  TX Spare GTX Out            (Bank 112 GTX3 R2, R1)
  -- A09, A10  ABSCAL_TXTS                 (Bank 35 C17,C16)
  -- A11, A12  General Purpose Spare Out   (Bank 35 K15,J15)
  -- B01, B02  PPS_IN                      (Bank 35 G14,F14)
  -- B03, B04  10MHZ_in                    (Bank 35 J14,H14)
  -- B05, B06  125 MHz Reference Clock In  (Bank 111 W6,W5)
  -- B07, B08  RX Spare GTX Out            (Bank 112 GTX3 T4, T3)
  -- B09, B10  NC
  -- B11, B12  NC

  cmp_obuf_abscal_txts : OBUFDS
    port map (
      I  => wrc_abscal_txts_out,
      O  => abscal_txts_p_o,
      OB => abscal_txts_n_o);

  cmp_obuf_pps_out : OBUFDS
    port map (
      I  => wrc_pps_out,
      O  => pps_p_o,
      OB => pps_n_o);

  cmp_ibuf_pps_in: IBUFDS
    generic map (
      DIFF_TERM => true)
    port map (
      O  => wrc_pps_in,
      I  => pps_p_i,
      IB => pps_n_i);
  
  cmp_obuf_10mhz_out : OBUFDS
    port map (
      I  => clk_10m_out,
      O  => clk_10m_p_o,
      OB => clk_10m_n_o);

  cmp_ibufgds_10mhz_in: IBUFGDS
    generic map (
      DIFF_TERM => true)
    port map (
      O  => clk_ext_10m,
      I  => clk_10m_p_i,
      IB => clk_10m_n_i);

  ------------------------------------------------------------------------------
  -- 10MHz output generation
  ------------------------------------------------------------------------------
  -- A 500 MHz reference clock is necessary since 10 MHz = 50 ns '1', 50 ns '0'
  -- and 50 ns is divisible by 2 ns (not by 8 or 4 ns!) hence 500 MHz.
  cmp_pll_62m5_500m: pll_62m5_500m
    port map (
      areset_n_i        => rst_ref_62m5_n,
      clk_62m5_pllref_i => clk_ref_62m5,
      clk_500m_o        => clk_500m,
      pll_500m_locked_o => open
    );

  cmp_gen_10mhz: gen_10mhz
    port map (
      clk_500m_i  => clk_500m,
      rst_n_i     => rst_ref_62m5_n,
      pps_i       => wrc_pps_out,
      clk_10mhz_o => clk_10m_out
    );
  
  ------------------------------------------------------------------------------
  -- EEPROM I2C tri-states
  ------------------------------------------------------------------------------
  sda_b <= '0' when (eeprom_sda_out = '0') else 'Z';
  eeprom_sda_in <= sda_b;
  scl_b <= '0' when (eeprom_scl_out = '0') else 'Z';
  eeprom_scl_in <= scl_b;

  -- LEDs
  U_Extend_PPS : gc_extend_pulse
  generic map (
    g_width => 10000000)
  port map (
    clk_i      => clk_ref_62m5,
    rst_n_i    => rst_ref_62m5_n,
    pulse_i    => wrc_pps_led,
    extended_o => led_pps);

end architecture top;
