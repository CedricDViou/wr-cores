-------------------------------------------------------------------------------
-- Title      : WRPC reference design for SPIDR4
--            : based on ZYNQ Z035
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : spidr4_wr_ref_top.vhd
-- Author(s)  : Pascal Bos <bosp@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2017-26-08
-- Last update: 2020-26-08
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level file for the WRPC reference design on the SPIDR4.
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
use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;
use work.wr_board_pkg.all;
use work.wr_spidr4_pkg.all;
--use work.axi4_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity spidr4_wr_ref_top is
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
    CLK_DMTD_P : in std_logic;             -- 124.992 MHz PLL reference
    CLK_DMTD_N : in std_logic;

    CLK_125M_GTX_P : in std_logic;              -- 125 MHz GTX reference (either from WR
    CLK_125M_GTX_N : in std_logic;              -- Oscillators of stable external oscillator)

    ---------------------------------------------------------------------------
    -- SPI interface to DACs
    ---------------------------------------------------------------------------

    DAC_REF_SYNC_N : out std_logic;
    DAC_REF_SCLK : out std_logic;
    DAC_REF_DIN  : out std_logic;

    DAC_DMTD_SYNC_N   : out std_logic;
    DAC_DMTD_SCLK   : out std_logic;
    DAC_DMTD_DIN    : out std_logic;

    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver
    ---------------------------------------------------------------------------

    SFP1_1G_TXP         : out   std_logic;
    SFP1_1G_TXN         : out   std_logic;
    SFP1_1G_RXP         : in    std_logic;
    SFP1_1G_RXN         : in    std_logic;
    SFP1_Mod_ABS        : in    std_logic;          -- sfp detect
   -- sfp_mod_def1_b    : inout std_logic;          -- scl
    --sfp_mod_def2_b    : inout std_logic;          -- sda
   -- sfp_rate_select_o : out   std_logic;
    SFP1_Tx_Fault    : in    std_logic;
    SFP1_TxDisable  : out   std_logic;
    SFP1_Rx_LOS         : in    std_logic;

    ---------------------------------------------------------------------------
    -- UART
    ---------------------------------------------------------------------------

    uart_rxd_i : in  std_logic;
    uart_txd_o : out std_logic;

    ---------------------------------------------------------------------------
    -- EEPROM interface
    ---------------------------------------------------------------------------
    WR_I2C_SCL : inout std_logic;
    WR_I2C_SDA : inout std_logic;
    
    ---------------------------------------------------------------------------
    -- ZYNQ Subsystem interface
    ---------------------------------------------------------------------------
 
   -- AXI_CLK_100MHz : out STD_LOGIC;
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
    FIXED_IO_ps_srstb : inout STD_LOGIC
  --  SYS_CLK_20MHz : out STD_LOGIC;
  --  SYS_CLK_40MHz : out STD_LOGIC


  );
end entity spidr4_wr_ref_top;

architecture top of spidr4_wr_ref_top is

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
  signal clk_ext_10m     : std_logic;

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
  signal pps_led_ext : std_logic;
  signal wrc_pps_in  : std_logic;
  signal svec_led    : std_logic_vector(15 downto 0);

  -- Zynq
  signal PS_ARESETN  : std_logic; 
  signal PS_UART_rxd : std_logic;
  signal PS_UART_txd : std_logic;
  signal PS_M_AXI_0_araddr : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal PS_M_AXI_0_arprot : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal PS_M_AXI_0_arready : STD_LOGIC;
  signal PS_M_AXI_0_arvalid : STD_LOGIC;
  signal PS_M_AXI_0_awaddr : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal PS_M_AXI_0_awprot : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal PS_M_AXI_0_awready : STD_LOGIC;
  signal PS_M_AXI_0_awvalid : STD_LOGIC;
  signal PS_M_AXI_0_bready : STD_LOGIC;
  signal PS_M_AXI_0_bresp : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal PS_M_AXI_0_bvalid : STD_LOGIC;
  signal PS_M_AXI_0_rdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal PS_M_AXI_0_rready : STD_LOGIC;
  signal PS_M_AXI_0_rresp : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal PS_M_AXI_0_rvalid : STD_LOGIC;
  signal PS_M_AXI_0_wdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal PS_M_AXI_0_wready : STD_LOGIC;
  signal PS_M_AXI_0_wstrb : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal PS_M_AXI_0_wvalid : STD_LOGIC;
  signal PS_SPI_0_0_io0_i : std_logic := 'Z';
  signal PS_SPI_0_0_io0_o : STD_LOGIC;
  signal PS_SPI_0_0_io0_t : STD_LOGIC;
  signal PS_SPI_0_0_io1_i : STD_LOGIC;
  signal PS_SPI_0_0_io1_o : STD_LOGIC;
  signal PS_SPI_0_0_io1_t : STD_LOGIC;
  signal PS_SPI_0_0_sck_i : STD_LOGIC;
  signal PS_SPI_0_0_sck_o : STD_LOGIC;
  signal PS_SPI_0_0_sck_t : STD_LOGIC;
  signal PS_SPI_0_0_ss1_o : STD_LOGIC;
  signal PS_SPI_0_0_ss2_o : STD_LOGIC;            
  signal PS_SPI_0_0_ss_o  : STD_LOGIC;
  signal PS_SPI_0_0_ss_t  : STD_LOGIC;
  --Wishbone
--  signal wb_master_i : t_wishbone_master_in; 
--  signal wb_master_o : t_wishbone_master_out;


begin  -- architecture top



--  AXI2WB : xwb_axi4lite_bridge 
--    port map(
--      clk_sys_i => clk_sys_62m5,
--      rst_n_i   => reset_n_i,
                  
--      axi4_slave_i => m_axil_o,
--      axi4_slave_o => m_axil_i,
--      wb_master_o  => wb_master_o,
--      wb_master_i  => wb_master_i  
--    );


 	zynq_subsystem_i : zynq_subsystem
		port map(
			ARESETN(0)                => PS_ARESETN,
			AXI_CLK_100MHz            => open,
			SYS_CLK_40MHz             => open,
			SYS_CLK_20MHz             => open,
			DDR_addr(14 downto 0)     => DDR_addr(14 downto 0),
			DDR_ba(2 downto 0)        => DDR_ba(2 downto 0),
			DDR_cas_n                 => DDR_cas_n,
			DDR_ck_n                  => DDR_ck_n,
			DDR_ck_p                  => DDR_ck_p,
			DDR_cke                   => DDR_cke,
			DDR_cs_n                  => DDR_cs_n,
			DDR_dm(3 downto 0)        => DDR_dm(3 downto 0),
			DDR_dq(31 downto 0)       => DDR_dq(31 downto 0),
			DDR_dqs_n(3 downto 0)     => DDR_dqs_n(3 downto 0),
			DDR_dqs_p(3 downto 0)     => DDR_dqs_p(3 downto 0),
			DDR_odt                   => DDR_odt,
			DDR_ras_n                 => DDR_ras_n,
			DDR_reset_n               => DDR_reset_n,
			DDR_we_n                  => DDR_we_n,
			FIXED_IO_ddr_vrn          => FIXED_IO_ddr_vrn,
			FIXED_IO_ddr_vrp          => FIXED_IO_ddr_vrp,
			FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
			FIXED_IO_ps_clk           => FIXED_IO_ps_clk,
			FIXED_IO_ps_porb          => FIXED_IO_ps_porb,
			FIXED_IO_ps_srstb         => FIXED_IO_ps_srstb,
			M_AXI_0_araddr            => PS_M_AXI_0_araddr,
			M_AXI_0_arprot            => PS_M_AXI_0_arprot,
			M_AXI_0_arready           => PS_M_AXI_0_arready,
			M_AXI_0_arvalid           => PS_M_AXI_0_arvalid,
			M_AXI_0_awaddr            => PS_M_AXI_0_awaddr,
			M_AXI_0_awprot            => PS_M_AXI_0_awprot,
			M_AXI_0_awready           => PS_M_AXI_0_awready,
			M_AXI_0_awvalid           => PS_M_AXI_0_awvalid,
			M_AXI_0_bready            => PS_M_AXI_0_bready,
			M_AXI_0_bresp             => PS_M_AXI_0_bresp,
			M_AXI_0_bvalid            => PS_M_AXI_0_bvalid,
			M_AXI_0_rdata             => PS_M_AXI_0_rdata,
			M_AXI_0_rready            => PS_M_AXI_0_rready,
			M_AXI_0_rresp             => PS_M_AXI_0_rresp,
			M_AXI_0_rvalid            => PS_M_AXI_0_rvalid,
			M_AXI_0_wdata             => PS_M_AXI_0_wdata,
			M_AXI_0_wready            => PS_M_AXI_0_wready,
			M_AXI_0_wstrb             => PS_M_AXI_0_wstrb,
			M_AXI_0_wvalid            => PS_M_AXI_0_wvalid,
			SPI_0_0_io0_i             => PS_SPI_0_0_io0_i,
			SPI_0_0_io0_o             => PS_SPI_0_0_io0_o,
			SPI_0_0_io0_t             => PS_SPI_0_0_io0_t,
			SPI_0_0_io1_i             => PS_SPI_0_0_io1_i,
			SPI_0_0_io1_o             => PS_SPI_0_0_io1_o,
			SPI_0_0_io1_t             => PS_SPI_0_0_io1_t,
			SPI_0_0_sck_i             => PS_SPI_0_0_sck_i,
			SPI_0_0_sck_o             => PS_SPI_0_0_sck_o,
			SPI_0_0_sck_t             => PS_SPI_0_0_sck_t,
			SPI_0_0_ss1_o             => PS_SPI_0_0_ss1_o,
			SPI_0_0_ss2_o             => PS_SPI_0_0_ss2_o,
			SPI_0_0_ss_i              => '1',
			SPI_0_0_ss_o              => PS_SPI_0_0_ss_o,
			SPI_0_0_ss_t              => PS_SPI_0_0_ss_t
		);

  -----------------------------------------------------------------------------
  -- The WR PTP core board package (WB Slave)
  -----------------------------------------------------------------------------

  cmp_xwrc_board_spidr4 : xwrc_board_spidr4
    generic map (
      g_simulation                => g_simulation,
      g_with_external_clock_input => false,
      g_dpram_initf               => g_dpram_initf,
      g_fabric_iface              => PLAIN)
    port map (
      areset_n_i          => PS_ARESETN,
      clk_125m_dmtd_n_i   => CLK_DMTD_N,
      clk_125m_dmtd_p_i   => CLK_DMTD_P,
      clk_125m_gtx_n_i    => CLK_125M_GTX_N,
      clk_125m_gtx_p_i    => CLK_125M_GTX_P,
      clk_sys_62m5_o      => clk_sys_62m5,
      clk_ref_62m5_o      => clk_ref_62m5,
      rst_sys_62m5_n_o    => rst_sys_62m5_n,
      rst_ref_62m5_n_o    => rst_ref_62m5_n,

      dac_refclk_cs_n_o   => DAC_REF_SYNC_N,
      dac_refclk_sclk_o   => DAC_REF_SCLK,
      dac_refclk_din_o    => DAC_REF_DIN,
      dac_dmtd_cs_n_o     => DAC_DMTD_SYNC_N,
      dac_dmtd_sclk_o     => DAC_DMTD_SCLK, 
      dac_dmtd_din_o      => DAC_DMTD_DIN, 

      sfp_txp_o           => SFP1_1G_TXP,
      sfp_txn_o           => SFP1_1G_TXN,
      sfp_rxp_i           => SFP1_1G_RXP,
      sfp_rxn_i           => SFP1_1G_RXN,
      sfp_det_i           => SFP1_Mod_ABS,
      sfp_sda_i           => sfp_sda_in,
      sfp_sda_o           => sfp_sda_out,
      sfp_scl_i           => sfp_scl_in,
      sfp_scl_o           => sfp_scl_out,
      sfp_rate_select_o   => open,
      sfp_tx_fault_i      => SFP1_Tx_Fault,
      sfp_tx_disable_o    => SFP1_TxDisable,
      sfp_los_i           => SFP1_Rx_LOS,

      eeprom_scl          => WR_I2C_SCL,
      eeprom_sda          => WR_I2C_SDA,

      onewire_i           => '1',  -- No onewire, Unique ID now via
      onewire_oen_o       => open, -- 24AA025EU48 (I2C Addr 1010.001x)
      -- Uart
      uart_rxd_i          => uart_rxd_i,
      uart_txd_o          => uart_txd_o,
      
      -- Wishbone
      --wb_slave_i          => wb_master_o,
      --wb_slave_o          => wb_master_i,
      
      abscal_txts_o       => wrc_abscal_txts_out,
      abscal_rxts_o       => wrc_abscal_rxts_out,

      pps_ext_i           => wrc_pps_in,
      pps_p_o             => wrc_pps_out,
      pps_led_o           => wrc_pps_led,
      led_link_o          => open,
      led_act_o           => open);

  -- Tristates for SFP EEPROM
--  sfp_mod_def1_b <= '0' when sfp_scl_out = '0' else 'Z';
--  sfp_mod_def2_b <= '0' when sfp_sda_out = '0' else 'Z';
--  sfp_scl_in     <= sfp_mod_def1_b;
--  sfp_sda_in     <= sfp_mod_def2_b;

end architecture top;
