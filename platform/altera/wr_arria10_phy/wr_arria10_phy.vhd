-------------------------------------------------------------------------------
-- Title      : Deterministic Altera PHY wrapper - Arria 10
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : wr_arria10_phy.vhd
-- Authors    : A. Hahn
-- Company    : GSI
-- Created    : 2018-12-04
-- Last update: 2018-12-04
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Single channel wrapper for deterministic PHY
-------------------------------------------------------------------------------
--
-- Copyright (c) 2018 GSI / A. Hahn
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
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.endpoint_pkg.all;
use work.wr_altera_pkg.all;
use work.gencores_pkg.all;
use work.altera_networks_pkg.all;

entity wr_arria10_transceiver is
  generic (
    g_use_atx_pll : boolean := TRUE);
  port (
    clk_ref_i      : in  std_logic := '0';                                 -- Input clock from WR extension [125Mhz]
    tx_clk_o       : out std_logic;                                       -- TX clock to WR core
    tx_data_i      : in  std_logic_vector(7 downto 0) := (others => '0'); -- Data from WR core
    rx_clk_o       : out std_logic;                                       -- RX clock to WR core
    rx_data_o      : out std_logic_vector(7 downto 0) := (others => '0'); -- Data to WR core
    pad_txp_o      : out std_logic;                                       -- SFP out
    pad_rxp_i      : in  std_logic := '0'                                 -- SFP in
  );
end wr_arria10_transceiver;

architecture rtl of wr_arria10_transceiver is

  signal s_pll_select              : std_logic_vector(0 downto 0);

  signal s_tx_pll_625m_serial_clk  : std_logic;
  signal s_tx_pll_625m_locked      : std_logic_vector(0 downto 0);
  signal s_tx_pll_625m_cal_busy    : std_logic;

  signal s_rst_ctl_powerdown       : std_logic_vector(0 downto 0);
  signal s_rst_ctl_rst             : std_logic;
  signal s_rst_ctl_tx_analogreset  : std_logic_vector(0 downto 0);
  signal s_rst_ctl_tx_digitalreset : std_logic_vector(0 downto 0);
  signal s_rst_ctl_rx_analogreset  : std_logic_vector(0 downto 0);
  signal s_rst_ctl_rx_digitalreset : std_logic_vector(0 downto 0);
  signal s_rst_ctl_tx_ready        : std_logic_vector(0 downto 0);
  signal s_rst_ctl_rx_ready        : std_logic_vector(0 downto 0);

  signal s_phy_tx_cal_busy         : std_logic_vector(0 downto 0);
  signal s_phy_rx_cal_busy         : std_logic_vector(0 downto 0);
  signal s_phy_rx_is_lockedtodata  : std_logic_vector(0 downto 0);

begin

  -- Transceiver
  inst_phy : wr_arria10_phy
    port map (
      rx_analogreset          => s_rst_ctl_rx_analogreset,
      rx_cal_busy             => s_phy_rx_cal_busy,
      rx_cdr_refclk0          => clk_ref_i,
      rx_clkout(0)            => rx_clk_o,
      rx_coreclkin(0)         => clk_ref_i,
      rx_digitalreset         => s_rst_ctl_rx_digitalreset,
      rx_is_lockedtodata      => open,
      rx_is_lockedtoref       => open,
      rx_parallel_data        => rx_data_o,
      rx_serial_data(0)       => pad_rxp_i,
      tx_analogreset          => s_rst_ctl_tx_analogreset,
      tx_cal_busy             => s_phy_tx_cal_busy,
      tx_clkout(0)            => tx_clk_o,
      tx_coreclkin(0)         => clk_ref_i,
      tx_digitalreset         => s_rst_ctl_tx_digitalreset,
      tx_parallel_data        => tx_data_i,
      tx_serial_clk0(0)       => s_tx_pll_625m_serial_clk,
      tx_serial_data(0)       => pad_txp_o,
      rx_set_locktodata       => s_phy_rx_is_lockedtodata,
      rx_set_locktoref        => open,
      unused_tx_parallel_data => open,
      unused_rx_parallel_data => open
    );

  -- ATX PLL
  atx_pll : if g_use_atx_pll generate
    inst_atx_pll : wr_arria10_atx_pll
      port map (
        pll_refclk0   => clk_ref_i,
        pll_powerdown => s_rst_ctl_powerdown(0),
        pll_locked    => s_tx_pll_625m_locked(0),
        tx_serial_clk => s_tx_pll_625m_serial_clk,
        pll_cal_busy  => s_tx_pll_625m_cal_busy
      );
  end generate atx_pll;

  -- TX fPLL
  tx_fpll : if not(g_use_atx_pll) generate
    inst_tx_pll : wr_arria10_tx_pll
      port map (
        pll_refclk0   => clk_ref_i,
        pll_powerdown => s_rst_ctl_powerdown(0),
        pll_locked    => s_tx_pll_625m_locked(0),
        tx_serial_clk => s_tx_pll_625m_serial_clk,
        pll_cal_busy  => s_tx_pll_625m_cal_busy
      );
  end generate tx_fpll;

  s_rst_ctl_rst <= '0';
  s_pll_select  <= (others => '0');

  -- Reset controller
  inst_rst_ctl : wr_arria10_rst_ctl
    port map (
      clock              => clk_ref_i,
      reset              => s_rst_ctl_rst,
      pll_powerdown      => s_rst_ctl_powerdown,
      tx_analogreset     => s_rst_ctl_tx_analogreset,
      tx_digitalreset    => s_rst_ctl_tx_digitalreset,
      tx_ready           => s_rst_ctl_tx_ready,
      pll_locked         => s_tx_pll_625m_locked,
      pll_select         => s_pll_select,
      tx_cal_busy        => s_phy_tx_cal_busy,
      rx_analogreset     => s_rst_ctl_rx_analogreset,
      rx_digitalreset    => s_rst_ctl_rx_digitalreset,
      rx_ready           => s_rst_ctl_rx_ready,
      rx_is_lockedtodata => s_phy_rx_is_lockedtodata,
      rx_cal_busy        => s_phy_rx_cal_busy
    );

end rtl;
