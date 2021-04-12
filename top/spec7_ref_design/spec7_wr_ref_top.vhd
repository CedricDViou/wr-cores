-------------------------------------------------------------------------------
-- Title      : WRPC reference design for SPEC7
--            : based on ZYNQ Z030/Z035/Z045
-- Project    : WR PTP Core and EMPIR 17IND14 WRITE 
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
--            : http://empir.npl.co.uk/write/
-------------------------------------------------------------------------------
-- File       : spec7_wr_ref_top.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2018-12-10
-- Last update: 2020-10-01
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level file for the WRPC reference design on the SPEC7
--              See also EMPIR 17IND14 WRITE Project (http://empir.npl.co.uk/write/)
--
--              SPEC7 Reference design is deployed in combination with
--              fmc-dio-5chttla => See also:
--              https://ohwr.org/project/fmc-dio-5chttla/wikis/home
--
--              SPEC7 HPSEC design used Bulls-Eye connector and may be deployed in combination
--              with the High Precision Slaved External Clock. See also:
--              https://ohwr.org/project/hpsec/wikis/home
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

entity spec7_wr_ref_top is
  generic (
    g_design      : string := "spec7_ref_top";
    g_dpram_initf : string := "../../../../bin/wrpc/wrc_v5_spec7.bram";
    -- In Vivado Project-Mode, during a Synthesis run or an Implementation run, the Vivado working
    -- directory temporarily changes to the "project_name/project_name.runs/run_name" directory.

    -- Simulation-mode enable parameter. Set by default (synthesis) to 0, and
    -- changed to non-zero in the instantiation of the top level DUT in the testbench.
    -- Its purpose is to reduce some internal counters/timeouts to speed up simulations.
    g_simulation : integer := 0;
    g_use_pps_in : string := "single"
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
    -- PLL Control signals
    -------------------------------------------------------------------------------    

    pll_status_i      : in  std_logic;
    pll_mosi_o        : out std_logic;
    pll_miso_i        : in  std_logic;
    pll_sck_o         : out std_logic;
    pll_cs_n_o        : out std_logic;
    pll_sync_o        : out std_logic;
    pll_lock_i        : in  std_logic;
    pll_wr_mode_o     : out std_logic_vector(1 downto 0);
    
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

    -- blink 1-PPS.
    led_pps_o     : out std_logic;
    aligned_10mhz_o : out std_logic;
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
    txp       : out std_logic_vector(1 downto 0);
    
    ---------------------------------------------------------------------------
    -- Processing System interface
    ---------------------------------------------------------------------------
    
    DDR_addr          : inout std_logic_vector ( 14 downto 0 );
    DDR_ba            : inout std_logic_vector ( 2 downto 0 );
    DDR_cas_n         : inout std_logic;
    DDR_ck_n          : inout std_logic;
    DDR_ck_p          : inout std_logic;
    DDR_cke           : inout std_logic;
    DDR_cs_n          : inout std_logic;
    DDR_dm            : inout std_logic_vector ( 3 downto 0 );
    DDR_dq            : inout std_logic_vector ( 31 downto 0 );
    DDR_dqs_n         : inout std_logic_vector ( 3 downto 0 );
    DDR_dqs_p         : inout std_logic_vector ( 3 downto 0 );
    DDR_odt           : inout std_logic;
    DDR_ras_n         : inout std_logic;
    DDR_reset_n       : inout std_logic;
    DDR_we_n          : inout std_logic;
    FIXED_IO_ddr_vrn  : inout std_logic;
    FIXED_IO_ddr_vrp  : inout std_logic;
    FIXED_IO_mio      : inout std_logic_vector ( 53 downto 0 );
    FIXED_IO_ps_clk   : inout std_logic;
    FIXED_IO_ps_porb  : inout std_logic;
    FIXED_IO_ps_srstb : inout std_logic;

    ------------------------------------------------------------------------------
    -- Digital I/O Bulls-Eye connector pins
    ------------------------------------------------------------------------------
    -- A09,A10 ABSCAL_TXTS                 (Bank 35 C17,C16)
    be_abscal_txts_p_o : out std_logic;
    be_abscal_txts_n_o : out std_logic;
    -- A01,A02 PPS_out                     (Bank 35 G16,G15)
    be_pps_p_o        : out std_logic;
    be_pps_n_o        : out std_logic;
    -- B01,B02 PPS_in                      (Bank 35 G14,F14)
    be_pps_p_i        : in std_logic;
    be_pps_n_i        : in std_logic;
    -- A03,A04 10MHz_out                   (Bank 35 F15,E15)
    be_clk_10m_p_o    : out std_logic;
    be_clk_10m_n_o    : out std_logic;
    -- B03,B04 10MHZ_in                    (Bank 13 AF24,AF25)
    be_clk_10m_p_i    : in std_logic;
    be_clk_10m_n_i    : in std_logic;

    -- B11 Single ended PPS_in             (Bank 13 AE23)
    be_pps_i          : in std_logic;

    ---------------------------------------------------------------------------
    -- Digital I/O FMC connector pins
    ---------------------------------------------------------------------------
    fmc_prsnt_m2c_l   : in  std_logic;

    fmc_sda           : inout std_logic;
    fmc_scl           : inout std_logic;

    fmc_clk0_m2c_p    : in  std_logic;
    fmc_clk0_m2c_n    : in  std_logic;
    fmc_clk1_m2c_p    : in  std_logic;
    fmc_clk1_m2c_n    : in  std_logic;
    fmc_la00_cc_p     : inout std_logic;
    fmc_la00_cc_n     : inout std_logic;
    fmc_la01_cc_p     : inout std_logic;
    fmc_la01_cc_n     : inout std_logic;
    fmc_la02_p        : inout std_logic;
    fmc_la02_n        : inout std_logic;
    fmc_la03_p        : inout std_logic;
    fmc_la03_n        : inout std_logic;
    fmc_la04_p        : inout std_logic;
    fmc_la04_n        : inout std_logic;
    fmc_la05_p        : inout std_logic;
    fmc_la05_n        : inout std_logic;
    fmc_la06_p        : inout std_logic;
    fmc_la06_n        : inout std_logic;
    fmc_la07_p        : inout std_logic;
    fmc_la07_n        : inout std_logic;
    fmc_la08_p        : inout std_logic;
    fmc_la08_n        : inout std_logic;
    fmc_la09_p        : inout std_logic;
    fmc_la09_n        : inout std_logic;
    fmc_la10_p        : inout std_logic;
    fmc_la10_n        : inout std_logic;
    fmc_la11_p        : inout std_logic;
    fmc_la11_n        : inout std_logic;
    fmc_la12_p        : inout std_logic;
    fmc_la12_n        : inout std_logic;
    fmc_la13_p        : inout std_logic;
    fmc_la13_n        : inout std_logic;
    fmc_la14_p        : inout std_logic;
    fmc_la14_n        : inout std_logic;
    fmc_la15_p        : inout std_logic;
    fmc_la15_n        : inout std_logic;
    fmc_la16_p        : inout std_logic;
    fmc_la16_n        : inout std_logic;
    fmc_la17_cc_p     : inout std_logic;
    fmc_la17_cc_n     : inout std_logic;
    fmc_la18_cc_p     : inout std_logic;
    fmc_la18_cc_n     : inout std_logic;
    fmc_la19_p        : inout std_logic;
    fmc_la19_n        : inout std_logic;
    fmc_la20_p        : inout std_logic;
    fmc_la20_n        : inout std_logic;
    fmc_la21_p        : inout std_logic;
    fmc_la21_n        : inout std_logic;
    fmc_la22_p        : inout std_logic;
    fmc_la22_n        : inout std_logic;
    fmc_la23_p        : inout std_logic;
    fmc_la23_n        : inout std_logic;
    fmc_la24_p        : inout std_logic;
    fmc_la24_n        : inout std_logic;
    fmc_la25_p        : inout std_logic;
    fmc_la25_n        : inout std_logic;
    fmc_la26_p        : inout std_logic;
    fmc_la26_n        : inout std_logic;
    fmc_la27_p        : inout std_logic;
    fmc_la27_n        : inout std_logic;
    fmc_la28_p        : inout std_logic;
    fmc_la28_n        : inout std_logic;
    fmc_la29_p        : inout std_logic;
    fmc_la29_n        : inout std_logic;
    fmc_la30_p        : inout std_logic;
    fmc_la30_n        : inout std_logic;
    fmc_la31_p        : inout std_logic;
    fmc_la31_n        : inout std_logic;
    fmc_la32_p        : inout std_logic;
    fmc_la32_n        : inout std_logic;
    fmc_la33_p        : inout std_logic;
    fmc_la33_n        : inout std_logic;

    fmc_gbtclk0_m2c_p : in  std_logic;
    fmc_gbtclk0_m2c_n : in  std_logic
--  fmc_dp0_c2m_p     : out std_logic;
--  fmc_dp0_c2m_n     : out std_logic;
--  fmc_dp0_m2c_p     : in  std_logic;
--  fmc_dp0_m2c_n     : in  std_logic;
--  fmc_dp1_c2m_p     : out std_logic;
--  fmc_dp1_c2m_n     : out std_logic;
--  fmc_dp1_m2c_p     : in  std_logic;
--  fmc_dp1_m2c_n     : in  std_logic;
--  fmc_dp2_c2m_p     : out std_logic;
--  fmc_dp2_c2m_n     : out std_logic;
--  fmc_dp2_m2c_p     : in  std_logic;
--  fmc_dp2_m2c_n     : in  std_logic;
--  fmc_dp3_c2m_p     : out std_logic;
--  fmc_dp3_c2m_n     : out std_logic;
--  fmc_dp3_m2c_p     : in  std_logic;
--  fmc_dp3_m2c_n     : in  std_logic
  );
end entity spec7_wr_ref_top;

architecture top of spec7_wr_ref_top is

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
  signal clk_sys_62m5    : std_logic;
  signal rst_sys_62m5_n  : std_logic;
  signal rst_ref_62m5_n  : std_logic;
  signal clk_ref_62m5    : std_logic;
  signal clk_ref_div2    : std_logic;
  signal clk_10m_out     : std_logic;
  signal clk_500m        : std_logic;
  signal clk_ext_10m     : std_logic;

  -- DAC signals for reference clock
  signal dac_refclk_sclk_int_o  : std_logic;
  signal dac_refclk_din_int_o   : std_logic;
  signal dac_refclk_cs_n_int_o  : std_logic;

  -- SFP
  signal sfp_sda_in  : std_logic;
  signal sfp_sda_out : std_logic;
  signal sfp_scl_in  : std_logic;
  signal sfp_scl_out : std_logic;

  -- LEDs and GPIO
  signal wrc_abscal_txts_out : std_logic;
  signal wrc_abscal_rxts_out : std_logic;
  signal wrc_pps_out         : std_logic;
  signal wrc_pps_led         : std_logic;
  signal pps_led_ext         : std_logic;
  signal svec_led            : std_logic_vector(15 downto 0);
  signal wrc_pps_in          : std_logic;

  --Axi4
  signal m_axil_i : t_axi4_lite_master_in_32;
  signal m_axil_o : t_axi4_lite_master_out_32;
  signal araddr   : std_logic_vector(31 downto 0);
  signal awaddr   : std_logic_vector(31 downto 0);
  
  --Wishbone
  signal wb_master_i : t_wishbone_master_in; 
  signal wb_master_o : t_wishbone_master_out;

  --PCIe 
  signal pci_clk : std_logic;

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

  component probe_10mhz is
    port (
  	  rst_n_i        : in  std_logic;
      clk_ref_i      : in  std_logic;
      clk_10mhz_a_i  : in  std_logic;
      clk_10mhz_b_i  : in  std_logic;
      aligned_o      : out std_logic
    );
  end component probe_10mhz;

begin  -- architecture top

  -- Never trigger PS_POR or PROGRAM_B
  suicide_n_o <= '1';
  wdog_n_o    <= '1';
  -- fmc_prsnt_m2c_l isn't used but must be defined as input.
  -- fmc_pg_c2m      isn't used

pci_clk_buf : IBUFDS_GTE2
  port map(
    I  => pci_clk_p,
    IB => pci_clk_n,
    O  => pci_clk,
    ODIV2 => open,
    CEB => '0'
  ); 

Pcie: processing_system_pcie_wrapper
  port map (
    DDR_addr          =>DDR_addr         ,
    DDR_ba            =>DDR_ba           ,
    DDR_cas_n         =>DDR_cas_n        ,
    DDR_ck_n          =>DDR_ck_n         ,
    DDR_ck_p          =>DDR_ck_p         ,
    DDR_cke           =>DDR_cke          ,
    DDR_cs_n          =>DDR_cs_n         ,
    DDR_dm            =>DDR_dm           ,
    DDR_dq            =>DDR_dq           ,
    DDR_dqs_n         =>DDR_dqs_n        ,
    DDR_dqs_p         =>DDR_dqs_p        ,
    DDR_odt           =>DDR_odt          ,
    DDR_ras_n         =>DDR_ras_n        ,
    DDR_reset_n       =>DDR_reset_n      ,
    DDR_we_n          =>DDR_we_n         ,
    FIXED_IO_ddr_vrn  =>FIXED_IO_ddr_vrn ,
    FIXED_IO_ddr_vrp  =>FIXED_IO_ddr_vrp ,
    FIXED_IO_mio      =>FIXED_IO_mio     ,
    FIXED_IO_ps_clk   =>FIXED_IO_ps_clk  ,
    FIXED_IO_ps_porb  =>FIXED_IO_ps_porb ,
    FIXED_IO_ps_srstb =>FIXED_IO_ps_srstb,
    M00_AXI_0_araddr  => araddr,
    M00_AXI_0_arburst => open,              
    M00_AXI_0_arcache => open,              
    M00_AXI_0_arlen   => open,              
    M00_AXI_0_arlock  => open,              
    M00_AXI_0_arprot  => open,              
    M00_AXI_0_arqos   => open,              
    M00_AXI_0_arready => m_axil_i.arready,  
    M00_AXI_0_arsize  => open,              
    M00_AXI_0_arvalid => m_axil_o.arvalid,
    M00_AXI_0_awaddr  => awaddr,
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
    aclk1_0           => clk_sys_62m5,
    pcie_clk          => pci_clk,
    pcie_mgt_0_rxn    => rxn,
    pcie_mgt_0_rxp    => rxp,
    pcie_mgt_0_txn    => txn,
    pcie_mgt_0_txp    => txp,
    pcie_rst_n        => perst_n,
    user_lnk_up_0     => open,
    usr_irq_ack_0     => open,
    usr_irq_req_0     => "0"
  );
  m_axil_o.araddr(31 downto 28) <= x"0";
  m_axil_o.araddr(27 downto 0) <= araddr(27 downto 0); --compensates for the PCI 0x4XXXXXXX offset
  m_axil_o.awaddr(31 downto 28) <= x"0";               --not my cleanest fix....
  m_axil_o.awaddr(27 downto 0) <= awaddr(27 downto 0); 
  
  -----------------------------------------------------------------------------
  -- Axi to Wishbone converter
  -----------------------------------------------------------------------------
  
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
      clk_10m_ext_i       => clk_ext_10m,
      clk_sys_62m5_o      => clk_sys_62m5,
      clk_ref_62m5_o      => clk_ref_62m5,
      rst_sys_62m5_n_o    => rst_sys_62m5_n,
      rst_ref_62m5_n_o    => rst_ref_62m5_n,

      dac_refclk_cs_n_o   => dac_refclk_cs_n_int_o,
      dac_refclk_sclk_o   => dac_refclk_sclk_int_o,
      dac_refclk_din_o    => dac_refclk_din_int_o,
      dac_dmtd_cs_n_o     => dac_dmtd_cs_n_o,
      dac_dmtd_sclk_o     => dac_dmtd_sclk_o, 
      dac_dmtd_din_o      => dac_dmtd_din_o, 

      pll_status_i        => pll_status_i,
      pll_mosi_o          => pll_mosi_o,
      pll_miso_i          => pll_miso_i,
      pll_sck_o           => pll_sck_o,
      pll_cs_n_o          => pll_cs_n_o,
      pll_sync_o          => pll_sync_o,
      pll_reset_n_o       => open,
      pll_lock_i          => pll_lock_i,
      pll_wr_mode_o       => pll_wr_mode_o,

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

      eeprom_scl          => scl_b,
      eeprom_sda          => sda_b,

      aux_scl             => fmc_la23_p,
      aux_sda             => fmc_la06_p,

      onewire_i           => '1',  -- No onewire, Unique ID now via
      onewire_oen_o       => open, -- 24AA025EU48 (I2C Addr 1010.001x)

      -- Uart
      uart_rxd_i          => uart_rxd_i,
      uart_txd_o          => uart_txd_o,

      -- Wishbone
      wb_slave_i          => wb_master_o,
      wb_slave_o          => wb_master_i,
      
      abscal_txts_o       => wrc_abscal_txts_out,
      abscal_rxts_o       => wrc_abscal_rxts_out,

      pps_ext_i           => wrc_pps_in,
      pps_p_o             => wrc_pps_out,
      pps_led_o           => wrc_pps_led,
      led_link_o          => led_link_o,
      led_act_o           => led_act_o);

  -- DAC signals for on board reference clock
  dac_refclk_sclk_o <= dac_refclk_sclk_int_o;
  dac_refclk_din_o  <= dac_refclk_din_int_o;
  dac_refclk_cs_n_o <= dac_refclk_cs_n_int_o;

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
  -- B11, B12  PPS_IN single ended, NC     (Bank 13 AE23, )

  cmp_obuf_be_abscal_txts : OBUFDS
    port map (
      I  => wrc_abscal_txts_out,
      O  => be_abscal_txts_p_o,
      OB => be_abscal_txts_n_o);

  cmp_obuf_be_pps_out : OBUFDS
    port map (
      I  => wrc_pps_out,
      O  => be_pps_p_o,
      OB => be_pps_n_o);

  -- Div by 2 reference clock to LEMO connector
  process(clk_ref_62m5)
  begin
    if rising_edge(clk_ref_62m5) then
      clk_ref_div2 <= not clk_ref_div2;
    end if;
  end process;

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

  cmp_probe_10mhz: probe_10mhz
    port map (
  	  rst_n_i        => rst_ref_62m5_n,
      clk_ref_i      => clk_ref_62m5,
      clk_10mhz_a_i  => clk_ext_10m,
      clk_10mhz_b_i  => clk_10m_out,
      aligned_o      => aligned_10mhz_o);

  cmp_obuf_be_10mhz_out : OBUFDS
    port map (
      I  => clk_10m_out,
      O  => be_clk_10m_p_o,
      OB => be_clk_10m_n_o);

  ------------------------------------------------------------------------------
  -- LEDs
  ------------------------------------------------------------------------------
  U_Extend_PPS : gc_extend_pulse
  generic map (
    g_width => 10000000)
  port map (
    clk_i      => clk_ref_62m5,
    rst_n_i    => rst_ref_62m5_n,
    pulse_i    => wrc_pps_led,
    extended_o => pps_led_ext);

  led_pps_o <= pps_led_ext;
  fmc_la01_cc_p <= pps_led_ext;  -- dio_led_top_o
  fmc_la01_cc_n <= '0';          -- dio_led_bot_o

  ------------------------------------------------------------------------------
  -- Common FMC pin mapping Reference Design (spec7_ref_top)
  ------------------------------------------------------------------------------
  -- Configure DIO Output Enable
  -- Configure Digital I/Os 0 to 3 as outputs
  fmc_la30_p <= '0';                -- dio_oe_n_o(0)
  fmc_la24_n <= '0';                -- dio_oe_n_o(1)
  fmc_la15_n <= '0';                -- dio_oe_n_o(2)
  -- Configure Digital I/Os 3 and 4 as inputs for external reference
  fmc_la11_p <= '1';                -- dio_oe_n_o(3) for external 1-PPS
  fmc_la05_p <= '1';                -- dio_oe_n_o(4) for external 10MHz clock

  -- Configure DIO termination
  -- All DIO connectors are not terminated
  fmc_la30_n <= '0';                -- dio_term_n_o[0]
  fmc_la06_n <= '0';                -- dio_term_n_o[1]
  fmc_la05_n <= '0';                -- dio_term_n_o[2]
  fmc_la09_p <= '0';                -- dio_term_n_o[3]
  fmc_la09_n <= '0';                -- dio_term_n_o[4]

  U_obuf_dio_o_0 : OBUFDS
    port map (
      I  => wrc_pps_out,
      O  => fmc_la29_p,             -- dio_p_o[0] <=> DIO Lemo 1
      OB => fmc_la29_n);            -- dio_n_o[0] <=> DIO Lemo 1

  U_obuf_dio_o_1 : OBUFDS
    port map (
      I  => wrc_abscal_rxts_out,
      O  => fmc_la28_p,             -- dio_p_o[1] <=> DIO Lemo 2
      OB => fmc_la28_n);            -- dio_n_o[1] <=> DIO Lemo 2

  U_obuf_dio_o_2 : OBUFDS
    port map (
      I  => wrc_abscal_txts_out,
      O  => fmc_la08_p,  -- dio_p_o[2] <=> DIO Lemo 3
      OB => fmc_la08_n); -- dio_n_o[2] <=> DIO Lemo 3

  ------------------------------------------------------------------------------
  -- Design specific generates:
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- It depends on the design what input signals are used for external 10 MHz
  -- and 1 PPS input.
  -- spec7_ref_top   : use DIO Lemo-5 10MHZ_in, Lemo-4 PPS_in
  -- spec7_hpsec_top : use B03,B04 10MHZ_in, B01,B02 PPS_in
  -- clk_ext_10m is also used as input to IDDR in the "even_odd_det" which poses
  -- routing restrictions (i.e. clk_ext_10m for refrence and hpsec design can't
  -- be OR-ed).
  -- Note that output signals are available on FMC as well as Bulls-Eye
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- Design Specific FMC pin mapping Reference Design (spec7_ref_top)
  ------------------------------------------------------------------------------
  gen_ref_design : if (g_design = "spec7_ref_top") generate

    U_ibuf_dio_i_3: IBUFDS
      generic map (
        DIFF_TERM => true)
      port map (
        O  => wrc_pps_in,
        I  => fmc_la03_p,      -- dio_p_i[3] <=> DIO Lemo 4
        IB => fmc_la03_n);     -- dio_n_i[3] <=> DIO Lemo 4

    cmp_ibugds_extref: IBUFGDS
      generic map (
        DIFF_TERM => true)
      port map (
        O  => clk_ext_10m,
        I  => fmc_clk1_m2c_p,  -- dio_clk_p_i <=> DIO Lemo 5
        IB => fmc_clk1_m2c_n); -- dio_clk_n_i <=> DIO Lemo 5

  end generate gen_ref_design;

  ------------------------------------------------------------------------------
  -- Design Specific Bulls-Eye pin mapping HPSEC Design (spec7_hpsec_top)
  ------------------------------------------------------------------------------
  gen_hpsec_design : if (g_design = "spec7_hpsec_top") generate
  
    -- Type of PPS_IN input:
    -- Differential LVDS OR Single ended 5V capable
    gen_pps_in_single : if (g_use_pps_in = "single") generate
      begin
        wrc_pps_in <= be_pps_i;
      end generate gen_pps_in_single;

    gen_pps_in_diff : if (g_use_pps_in = "diff") generate
      begin
        cmp_ibuf_pps_in: IBUFDS
          generic map (
            DIFF_TERM => true)
          port map (
            O  => wrc_pps_in,
            I  => be_pps_p_i,
            IB => be_pps_n_i);
    end generate gen_pps_in_diff;

    cmp_ibufds_10mhz_in: IBUFDS
      generic map (
        DIFF_TERM => true)
      port map (
        O  => clk_ext_10m,
        I  => be_clk_10m_p_i,
        IB => be_clk_10m_n_i);

  end generate gen_hpsec_design;
  
  ------------------------------------------------------------------------------
  -- Design Specific Bulls-Eye / FMC pin mapping HPSEC Design (spec7_hpsec_top)
  ------------------------------------------------------------------------------
  -- Forward DAC SPI via the FMC connnector to the HPSEC. It is safe to always 
  -- output these signals even with fmc-dio-5chttla plugged since LA02, LA04 and
  -- LA07 are either not used or input on fmc-dio-5chttla.
  ------------------------------------------------------------------------------
  dac_refclk_sclk_diff : OBUFDS
    port map (
      I  =>  dac_refclk_sclk_int_o,
      O  => fmc_la02_p,             -- dac_refclk_sclk_p_o
      OB => fmc_la02_n);            -- dac_refclk_sclk_n_o

  dac_refclk_din_diff  : OBUFDS
    port map (
      I  => dac_refclk_din_int_o,
      O  => fmc_la04_p,             -- dac_refclk_din_p_o
      OB => fmc_la04_n);            -- dac_refclk_din_n_o

  dac_refclk_cs_diff   : OBUFDS
    port map (
      I  => dac_refclk_cs_n_int_o,
      O  => fmc_la07_p,             -- dac_refclk_cs_n_p_o
      OB => fmc_la07_n);            -- dac_refclk_cs_n_n_o

end architecture top;
