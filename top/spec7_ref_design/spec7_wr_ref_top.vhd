-------------------------------------------------------------------------------
-- Title      : WRPC reference design for SPEC7
--            : based on ZYNQ Z030/Z035/Z045
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : spec7_wr_ref_top.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2017-11-08
-- Last update: 2017-11-08
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level file for the WRPC reference design on the SPEC7.
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

    clk_125m_gtx_n_i : in std_logic;              -- 125 MHz GTX reference (either from WR
    clk_125m_gtx_p_i : in std_logic;              -- Oscillators of stable external oscillator)

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
--  pps_p_i           : in std_logic;
--  pps_n_i           : in std_logic;
    --  9,10 10MHz_out                   (Bank 35 F15,E15)
--  clk_10m_p_o       : out std_logic;
--  clk_10m_n_o       : out std_logic;
    -- 11,12 10MHZ_in                    (Bank 35 J14,H14)
--  clk_10m_p_i       : in std_logic;
--  clk_10m_n_i       : in std_logic;

    ---------------------------------------------------------------------------
    -- Digital I/O FMC Pins
    -- used in this design to output WR-aligned 1-PPS (in Slave mode) and input
    -- 10MHz & 1-PPS from external reference (in GrandMaster mode).
    ---------------------------------------------------------------------------

    -- Clock input from LEMO 5 on the mezzanine front panel. Used as 10MHz
    -- external reference input.
    dio_clk_p_i : in std_logic;
    dio_clk_n_i : in std_logic;

    -- Differential inputs, dio_p_i(N) inputs the current state of I/O (N+1) on
    -- the mezzanine front panel.
    dio_n_i : in std_logic_vector(4 downto 0);
    dio_p_i : in std_logic_vector(4 downto 0);

    -- Differential outputs. When the I/O (N+1) is configured as output (i.e. when
    -- dio_oe_n_o(N) = 0), the value of dio_p_o(N) determines the logic state
    -- of I/O (N+1) on the front panel of the mezzanine
    dio_n_o : out std_logic_vector(4 downto 0);
    dio_p_o : out std_logic_vector(4 downto 0);

    -- Output enable. When dio_oe_n_o(N) is 0, connector (N+1) on the front
    -- panel is configured as an output.
    dio_oe_n_o    : out std_logic_vector(4 downto 0);

    -- Termination enable. When dio_term_en_o(N) is 1, connector (N+1) on the front
    -- panel is 50-ohm terminated
    dio_term_en_o : out std_logic_vector(4 downto 0);

    -- Two LEDs on the mezzanine panel. Only Top one is currently used - to
    -- blink 1-PPS.
    dio_led_top_o : out std_logic;
    dio_led_bot_o : out std_logic;

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
    
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;

    ---------------------------------------------------------------------------
    -- Programmable Logic DDR3
    ---------------------------------------------------------------------------

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
    DDR3_odt : out STD_LOGIC_VECTOR ( 0 to 0 )


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
  signal clk_ext_10m     : std_logic;

  -- I2C EEPROM
  signal eeprom_sda_in  : std_logic;
  signal eeprom_sda_out : std_logic;
  signal eeprom_scl_in  : std_logic;
  signal eeprom_scl_out : std_logic;

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
  signal araddr : std_logic_vector(31 downto 0);
  signal awaddr : std_logic_vector(31 downto 0);

  --Wishbone
  signal wb_master_i : t_wishbone_master_in; 
  signal wb_master_o : t_wishbone_master_out;

  --PCIe 
  signal pci_clk : std_logic;

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

  Pcie: processing_system_pcie_wrapper
  port map (
    DDR3_addr         => DDR3_addr,
    DDR3_ba           => DDR3_ba,
    DDR3_cas_n        => DDR3_cas_n,
    DDR3_ck_n         => DDR3_ck_n,
    DDR3_ck_p         => DDR3_ck_p,
    DDR3_cke          => DDR3_cke,
    DDR3_cs_n         => DDR3_cs_n,
    DDR3_dm           => DDR3_dm,
    DDR3_dq           => DDR3_dq,
    DDR3_dqs_n        => DDR3_dqs_n,
    DDR3_dqs_p        => DDR3_dqs_p,
    DDR3_odt          => DDR3_odt,
    DDR3_ras_n        => DDR3_ras_n,
    DDR3_reset_n      => DDR3_reset_n,
    DDR3_we_n         => DDR3_we_n,
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
      abscal_rxts_o       => wrc_abscal_rxts_out,

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

-- Bulls-Eye input conflicting with FMC-DIO reference design
--  cmp_ibuf_pps_in: IBUFDS
--    generic map (
--      DIFF_TERM => true)
--    port map (
--      O  => wrc_pps_in,
--      I  => pps_p_i,
--      IB => pps_n_i);
  
-- Standard reference design has no 10 MHz output
--  cmp_obuf_10mhz_out : OBUFDS
--    port map (
--      I  => clk_10m_out,
--      O  => clk_10m_p_o,
--      OB => clk_10m_n_o);

-- Bulls-Eye input conflicting with FMC-DIO reference design
--  cmp_ibufgds_10mhz_in: IBUFGDS
--    generic map (
--      DIFF_TERM => true)
--    port map (
--      O  => clk_ext_10m,
--      I  => clk_10m_p_i,
--      IB => clk_10m_n_i);

  ------------------------------------------------------------------------------
  -- Digital I/O FMC Mezzanine connections
  ------------------------------------------------------------------------------
  gen_dio_iobufs: for I in 0 to 4 generate
    U_ibuf: IBUFDS
      generic map (
        DIFF_TERM => true)
      port map (
        O  => dio_in(i),
        I  => dio_p_i(i),
        IB => dio_n_i(i));

    U_obuf : OBUFDS
      port map (
        I  => dio_out(i),
        O  => dio_p_o(i),
        OB => dio_n_o(i));
  end generate;
  -- Configure Digital I/Os 0 to 3 as outputs
  dio_oe_n_o(2 downto 0) <= (others => '0');
  -- Configure Digital I/Os 3 and 4 as inputs for external reference
  dio_oe_n_o(3)          <= '1';  -- for external 1-PPS
  dio_oe_n_o(4)          <= '1';  -- for external 10MHz clock
  -- All DIO connectors are not terminated
  dio_term_en_o          <= (others => '0');

  -- Div by 2 reference clock to LEMO connector
  process(clk_ref_62m5)
  begin
    if rising_edge(clk_ref_62m5) then
      clk_ref_div2 <= not clk_ref_div2;
    end if;
  end process;

  cmp_ibugds_extref: IBUFGDS
    generic map (
      DIFF_TERM => true)
    port map (
      O  => clk_ext_10m,
      I  => dio_clk_p_i,
      IB => dio_clk_n_i);

  wrc_pps_in    <= dio_in(3);
  dio_out(0)    <= wrc_pps_out;
  dio_out(1)    <= wrc_abscal_rxts_out;
  dio_out(2)    <= wrc_abscal_txts_out;

  -- EEPROM I2C tri-states
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
    extended_o => dio_led_top_o);

  dio_led_bot_o <= '0';

end architecture top;
