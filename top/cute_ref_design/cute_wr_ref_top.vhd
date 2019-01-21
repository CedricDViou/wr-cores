-------------------------------------------------------------------------------
-- Title      : WRPC reference design for CUTE
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : cute_wr_ref_top.vhd
-- Author(s)  : Hongming Li <lihm.thu@foxmail.com>
--              Grzegorz Daniluk <grzegorz.daniluk@cern.ch>
-- Company    : Tsinghua Univ. (DEP), CERN
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level file for the WRPC reference design on the CUTE.
--
-- This is a reference top HDL that instanciates the WR PTP Core together with
-- its peripherals to be run on a CUTE board.
--
-- There are two main usecases for this HDL file:
-- * let new users easily synthesize a WR PTP Core bitstream that can be run on
--   reference hardware
-- * provide a reference top HDL file showing how the WRPC can be instantiated
--   in HDL projects.
--
-- CUTE:  https://www.ohwr.org/projects/cute-wr-dp
--
-------------------------------------------------------------------------------
-- Copyright (c) 2018 CERN
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
use work.wr_cute_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity cute_wr_ref_top is
  generic (
    g_dpram_initf : string := "../../bin/wrpc/wrc_phy8.bram";
    g_sfp0_enable : integer:= 1;
    g_sfp1_enable : integer:= 0;
    g_cute_version       : string:= "2.2";
    g_aux_sdb            : t_sdb_device  := c_xwb_xil_multiboot_sdb;
    g_multiboot_enable   : boolean:= false
  );
  port (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------

    -- Local oscillators
    clk20m_vcxo_i       : in std_logic;           -- 20mhz vcxo clock

    clk_125m_pllref_p_i : in std_logic;           -- 125 MHz PLL reference
    clk_125m_pllref_n_i : in std_logic;

    sfp0_ref_clk_p     : in std_logic;  -- dedicated clock for xilinx gtp transceiver
    sfp0_ref_clk_n     : in std_logic;
    sfp1_ref_clk_p     : in std_logic;  -- dedicated clock for xilinx gtp transceiver
    sfp1_ref_clk_n     : in std_logic;

    ---------------------------------------------------------------------------
    -- SPI interface to DACs
    ---------------------------------------------------------------------------

    plldac_sclk        : out std_logic;
    plldac_din         : out std_logic;
    plldac_clr_n       : out std_logic;
    plldac_load_n      : out std_logic;
    plldac_sync_n      : out std_logic;

    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver
    ---------------------------------------------------------------------------

    sfp0_tx_p          : out   std_logic;
    sfp0_tx_n          : out   std_logic;
    sfp0_rx_p          : in    std_logic;
    sfp0_rx_n          : in    std_logic;
    sfp0_det           : in    std_logic;  -- sfp detect
    sfp0_scl           : inout std_logic;  -- scl
    sfp0_sda           : inout std_logic;  -- sda
    sfp0_tx_fault      : in    std_logic;
    sfp0_tx_disable    : out   std_logic;
    sfp0_los           : in    std_logic;  
    --sfp1_tx_p          : out   std_logic;
    --sfp1_tx_n          : out   std_logic;
    --sfp1_rx_p          : in    std_logic;
    --sfp1_rx_n          : in    std_logic;
    --sfp1_det           : in    std_logic;  -- sfp detect
    --sfp1_scl           : inout std_logic;  -- scl
    --sfp1_sda           : inout std_logic;  -- sda
    --sfp1_tx_fault      : in    std_logic;
    --sfp1_tx_disable    : out   std_logic;
    --sfp1_tx_los        : in    std_logic;
  
    ---------------------------------------------------------------------------
    -- Onewire interface
    ---------------------------------------------------------------------------

    one_wire           : inout std_logic;      -- 1-wire interface to ds18b20
    ---------------------------------------------------------------------------
    -- UART
    ---------------------------------------------------------------------------
    uart_rx            : in  std_logic;
    uart_tx            : out std_logic;

    ---------------------------------------------------------------------------
    -- I2C configuration EEPROM interface
    ---------------------------------------------------------------------------
    eeprom_scl         : inout std_logic;
    eeprom_sda         : inout std_logic;

    ---------------------------------------------------------------------------
    -- Flash memory SPI interface
    ---------------------------------------------------------------------------

    flash_sclk_o       : out std_logic;
    flash_ncs_o        : out std_logic;
    flash_mosi_o       : out std_logic;
    flash_miso_i       : in  std_logic:='1';
    
    ---------------------------------------------------------------------------
    -- Miscellanous I/O pins
    ---------------------------------------------------------------------------
    -- user interface
    sfp0_led           : out std_logic;
    sfp1_led           : out std_logic;
    ext_clk            : out std_logic;
    usr_button         : in  std_logic;
    usr_led1           : out std_logic;
    usr_led2           : out std_logic;
    pps_out            : out std_logic
  );
end cute_wr_ref_top;

architecture rtl of cute_wr_ref_top is
  
  component oserdes_4_to_1 is
    generic(
      sys_w : integer := 1;
      dev_w : integer := 4); 
    port(
      data_out_from_device : in  std_logic_vector(dev_w-1 downto 0); 
      data_out_to_pins     : out std_logic_vector(sys_w-1 downto 0); 

      delay_reset          : in  std_logic;
   
      clk_in     : in std_logic;
      pll_locked : in std_logic;
      clk_div_in : in std_logic;
      io_reset   : in std_logic);
  end component;

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  -- ext 10M clock output
  constant c_DATA_W   : integer := 4; -- parallel data width going to serdes
  constant c_HALF     : integer := 25;-- default high/low width for 10MHz
  signal rst_oserdes  : std_logic;
  signal pll_locked   : std_logic;
  signal sd_out       : std_logic_vector(0 downto 0);

  signal sd_data      : std_logic_vector(c_DATA_W-1 downto 0);
  signal aux_half_high: unsigned(15 downto 0);
  signal aux_half_low : unsigned(15 downto 0);
  signal aux_shift    : unsigned(15 downto 0);
  signal clk_realign  : std_logic;
  signal new_freq     : std_logic;

  -- I2C EEPROM
  signal eeprom_scl_o      : std_logic;
  signal eeprom_scl_i      : std_logic;
  signal eeprom_sda_o      : std_logic;
  signal eeprom_sda_i      : std_logic;

  -- OneWire
  signal onewire_i         : std_logic;
  signal onewire_oen_o     : std_logic;

  -- SFP
  signal sfp0_scl_i        : std_logic;
  signal sfp0_scl_o        : std_logic;
  signal sfp0_sda_i        : std_logic;
  signal sfp0_sda_o        : std_logic;
  signal sfp1_scl_i        : std_logic;
  signal sfp1_scl_o        : std_logic;
  signal sfp1_sda_i        : std_logic;
  signal sfp1_sda_o        : std_logic;
  
  signal pps               : std_logic;
  signal pps_csync         : std_logic;
  attribute maxdelay       : string;
  attribute maxdelay of pps_csync : signal is "500 ps";
  signal tm_tai            : std_logic_vector(39 downto 0);
  signal tm_tai_valid      : std_logic;
  signal tm_tai_valid_d1   : std_logic;
  -- Wishbone buse(s) from masters attached to crossbar
  signal cnx_master_out : t_wishbone_master_out_array(0 downto 0);
  signal cnx_master_in  : t_wishbone_master_in_array(0 downto 0);
  -- Wishbone buse(s) to slaves attached to crossbar
  signal cnx_slave_out : t_wishbone_slave_out_array(0 downto 0);
  signal cnx_slave_in  : t_wishbone_slave_in_array(0 downto 0);

  -- Not needed now, but useful if application cores are added
  signal clk_sys_62m5   : std_logic;
  signal clk_ref_125m   : std_logic;
  signal clk_500m       : std_logic;
  signal rst_sys_62m5_n : std_logic;
  signal rst_ref_125m_n : std_logic;

begin

  u_wr_core : xwrc_board_cute
    generic map(
      g_dpram_initf      => g_dpram_initf,
      g_sfp0_enable      => g_sfp0_enable,
      g_sfp1_enable      => g_sfp1_enable,
      g_aux_sdb          => g_aux_sdb,
      g_cute_version     => g_cute_version,
      g_phy_refclk_sel   => 4,
      g_multiboot_enable => g_multiboot_enable)
    port map (
      areset_n_i          => usr_button,
      clk_20m_vcxo_i      => clk20m_vcxo_i,
      clk_125m_pllref_p_i => clk_125m_pllref_p_i,
      clk_125m_pllref_n_i => clk_125m_pllref_n_i,
      clk_125m_gtp0_p_i   => sfp0_ref_clk_p,
      clk_125m_gtp0_n_i   => sfp0_ref_clk_n,
      clk_125m_gtp1_p_i   => sfp1_ref_clk_p,
      clk_125m_gtp1_n_i   => sfp1_ref_clk_n,
      clk_sys_62m5_o      => clk_sys_62m5,
      clk_ref_125m_o      => clk_ref_125m,
      clk_500m_o          => clk_500m,
      rst_sys_62m5_n_o    => rst_sys_62m5_n,
      rst_ref_125m_n_o    => rst_ref_125m_n,
  
      plldac_sclk_o       => plldac_sclk,
      plldac_din_o        => plldac_din,
      plldac_clr_n_o      => plldac_clr_n,
      plldac_load_n_o     => plldac_load_n,
      plldac_sync_n_o     => plldac_sync_n,
  
      sfp0_txp_o          => sfp0_tx_p,
      sfp0_txn_o          => sfp0_tx_n,
      sfp0_rxp_i          => sfp0_rx_p,
      sfp0_rxn_i          => sfp0_rx_n,
      sfp0_det_i          => sfp0_det,
      sfp0_scl_i          => sfp0_scl_i,
      sfp0_scl_o          => sfp0_scl_o,
      sfp0_sda_i          => sfp0_sda_i,
      sfp0_sda_o          => sfp0_sda_o,
      sfp0_rate_select_o  => open,
      sfp0_tx_fault_i     => sfp0_tx_fault,
      sfp0_tx_disable_o   => sfp0_tx_disable,
      sfp0_los_i          => sfp0_los,
      --sfp1_txp_o          => sfp1_tx_p,
      --sfp1_txn_o          => sfp1_tx_n,
      --sfp1_rxp_i          => sfp1_rx_p,
      --sfp1_rxn_i          => sfp1_rx_n,
      --sfp1_det_i          => sfp1_det,
      --sfp1_scl_i          => sfp1_scl_i,
      --sfp1_scl_o          => sfp1_scl_o,
      --sfp1_sda_i          => sfp1_sda_i,
      --sfp1_sda_o          => sfp1_sda_o,
      --sfp1_rate_select_o  => open,
      --sfp1_tx_fault_i     => sfp1_tx_fault,
      --sfp1_tx_disable_o   => sfp1_tx_disable,
      --sfp1_los_i          => sfp1_tx_los,
  
      eeprom_scl_i        => eeprom_scl_i,
      eeprom_scl_o        => eeprom_scl_o,
      eeprom_sda_i        => eeprom_sda_i,
      eeprom_sda_o        => eeprom_sda_o,
  
      onewire_i           => onewire_i,
      onewire_oen_o       => onewire_oen_o,
  
      uart_rxd_i          => uart_rx,
      uart_txd_o          => uart_tx,
  
      flash_sclk_o        => flash_sclk_o,
      flash_ncs_o         => flash_ncs_o,
      flash_mosi_o        => flash_mosi_o,
      flash_miso_i        => flash_miso_i,

      wb_slave_o          => cnx_slave_out(0),
      wb_slave_i          => cnx_slave_in(0),

      wb_eth_master_o     => cnx_master_out(0),
      wb_eth_master_i     => cnx_master_in(0),
  
      tm_link_up_o        => open,
      tm_time_valid_o     => tm_tai_valid,
      tm_tai_o            => tm_tai,
      tm_cycles_o         => open,
  
      led_act_o           => sfp0_led,
      led_link_o          => sfp1_led,
      pps_p_o             => pps_out,
      pps_led_o           => usr_led1,
      pps_csync_o         => pps_csync,
      pll_locked_o        => pll_locked,
      link_ok_o           => usr_led2);
  
  cnx_slave_in <= cnx_master_out;
  cnx_master_in <= cnx_slave_out;

  -- Tristates for configuration EEPROM
  eeprom_scl  <= '0' when eeprom_scl_o = '0' else 'Z';
  eeprom_sda  <= '0' when eeprom_sda_o = '0' else 'Z';
  eeprom_scl_i  <= eeprom_scl;
  eeprom_sda_i  <= eeprom_sda;

  -- Tristates for SFP EEPROM
  sfp0_scl <= '0' when sfp0_scl_o = '0' else 'Z';
  sfp0_sda <= '0' when sfp0_sda_o = '0' else 'Z';
  sfp0_scl_i <= sfp0_scl;
  sfp0_sda_i <= sfp0_sda;
  --sfp1_scl <= '0' when sfp1_scl_o = '0' else 'Z';
  --sfp1_sda <= '0' when sfp1_sda_o = '0' else 'Z';
  --sfp1_scl_i <= sfp1_scl;
  --sfp1_sda_i <= sfp1_sda;
  
  -- Tristates for Onewire
  one_wire <= '0' when onewire_oen_o = '1' else 'Z';
  onewire_i  <= one_wire;
  
  aux_half_high <= to_unsigned(c_HALF, aux_half_high'length);
  aux_half_low  <= to_unsigned(c_HALF, aux_half_low'length);
  aux_shift     <= to_unsigned(11, aux_half_low'length);
  new_freq      <= '0';
  rst_oserdes <= not pll_locked;
  ext_clk     <= sd_out(0);

  process(clk_ref_125m)
  begin
    if rising_edge(clk_ref_125m) then
      if(rst_ref_125m_n = '0' or pll_locked = '0') then  -- if new_freq or pll lost lock,
        tm_tai_valid_d1 <= '0';
      elsif(pps_csync = '1') then
        tm_tai_valid_d1 <= tm_tai_valid;
      end if;
    end if;
  end process;
  clk_realign <= (not tm_tai_valid_d1) and tm_tai_valid and pps_csync;

  process(clk_ref_125m)
    variable rest  : integer range 0 to 65535;
    variable v_bit : std_logic;
  begin
    if rising_edge(clk_ref_125m) then
      if (rst_ref_125m_n='0' or pll_locked='0' or clk_realign='1') then
          rest := to_integer(aux_half_high - aux_shift);
          v_bit := '1';
      else
        for i in 0 to c_DATA_W-1 loop
          if(rest /= 0) then
            sd_data(i) <= v_bit;
            rest := rest - 1;
          elsif(v_bit = '1') then
            sd_data(i) <= '0';
            v_bit := '0';
            rest := to_integer(aux_half_low-1); -- because here we already wrote first bit
                                    -- from this group
          elsif(v_bit = '0') then
            sd_data(i) <= '1';
            v_bit := '1';
            rest := to_integer(aux_half_high-1);
          end if;
        end loop;
      end if;
    end if;
  end process;

  U_10MHZ_SERDES: oserdes_4_to_1
  generic map(
    dev_w => c_DATA_W)
  port map(
    data_out_from_device => sd_data,
    data_out_to_pins     => sd_out,
    delay_reset          => '0',
    clk_in               => clk_500m,
    pll_locked           => pll_locked,
    clk_div_in           => clk_ref_125m,
    io_reset             => rst_oserdes);

end rtl;
