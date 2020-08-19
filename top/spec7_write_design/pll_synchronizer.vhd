-------------------------------------------------------------------------------
-- Title      : PLL synchronizer  
-- Project    : WR PTP Core and EMPIR 17IND14 WRITE 
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
--            : http://empir.npl.co.uk/write/
-------------------------------------------------------------------------------
-- File       : pll_synchronizer.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2020-08-11
-- Last update: 2020-08-11
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: When a PLL is used to generate 125 MHz from 10 MHz then the PLL
--              can lock on the even or odd 10MHz phase w.r.t. the 1 PPS. This
--              module detects where (even/odd) the lock was achieved.
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

library unisim;
use unisim.vcomponents.all;

entity pll_synchronizer is
  port (
    rst_n_i        : in  std_logic;
    clk_ref_i      : in  std_logic;
    clk_10m_ext_i  : in  std_logic;
    clk_sys_62m5_i : in  std_logic;
    pps_i          : in  std_logic;
    enable_sync_i  : in  std_logic;
    sync_done_o    : out std_logic;
    pll_sync_o     : out std_logic
  );
end entity pll_synchronizer;

architecture rtl of pll_synchronizer is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  signal sync               : std_logic;
  signal sync_ext           : std_logic := '0';
  signal pll_sync           : std_logic;
  signal pll_sync_ext       : std_logic;
  signal rising_pps         : std_logic;
  signal rising_clk_10m     : std_logic;
  signal arm_clk_10m_det    : std_logic := '0';
  signal enable_sync        : std_logic;
  signal enable             : std_logic := '0';
  signal done               : std_logic;
  signal sync_done          : std_logic;

begin  -- architecture rtl

  -- detect rising edge PPS
  cmp_pps_rising_edge: gc_sync_ffs
   generic map (
     g_sync_edge => "positive")
   port map (
     clk_i    => clk_ref_i,
     rst_n_i  => rst_n_i,
     data_i   => pps_i,
     ppulse_o => rising_pps);

  -- detect rising edge clk_10m
  cmp_clk_10m_rising_edge: gc_sync_ffs
   generic map (
     g_sync_edge => "positive")
   port map (
     clk_i    => clk_ref_i,
     rst_n_i  => rst_n_i,
     data_i   => clk_10m_ext_i,
     ppulse_o => rising_clk_10m);

  -- After rising edge PPS wait for first rising edge clk_10m and
  -- trigger a sync if enabled.
  process (clk_ref_i)
  begin
    if rst_n_i = '0' then
      arm_clk_10m_det <= '0';
    elsif rising_edge(clk_ref_i) then
      if rising_pps = '1' then
        arm_clk_10m_det <= '1';
      elsif arm_clk_10m_det = '1' and rising_clk_10m = '1' then
        arm_clk_10m_det <= '0';
      end if;
    end if;
  end process;

  sync <= '1' when enable = '1' and arm_clk_10m_det = '1' and rising_clk_10m = '1' else '0';
  
  -- Extend sync at least 13 clk_ref_i ticks such that it can be
  -- caught by the clk_10m_ext_i domain
  cmp_extend_sync : gc_extend_pulse
  generic map (
    g_width => 13)
  port map (
    clk_i      => clk_ref_i,
    rst_n_i    => rst_n_i,
    pulse_i    => sync,
    extended_o => sync_ext);

  -----------------------------------------------------------------------------
  -- Generate pll_sync_o
  -----------------------------------------------------------------------------
  -- pll_sync_o minimal pusle width = 1 ms.
  -- Note: need to use a free running clk (clk_10m_ext_i) since clk_ref_125m
  -- is temporary lost due to sync!
  -- 1 ms = 10000 clk_10m_ext_i ticks.
  cmp_sync_ffs_sync: gc_sync_ffs
    generic map (
      g_sync_edge => "positive")
    port map (
      clk_i    => clk_10m_ext_i,
      rst_n_i  => rst_n_i,
      data_i   => sync_ext,
      ppulse_o => pll_sync);

  U_Extend_pll_sync : gc_extend_pulse
  generic map (
    g_width => 10000)
--    g_width => 8)
  port map (
    clk_i      => clk_10m_ext_i,
    rst_n_i    => rst_n_i,
    pulse_i    => pll_sync,
    extended_o => pll_sync_ext);

  cmp_sync_ffs_pll_sync_ext: gc_sync_ffs
    generic map (
      g_sync_edge => "positive")
    port map (
      clk_i    => clk_10m_ext_i,
      rst_n_i  => rst_n_i,
      data_i   => pll_sync_ext,
      npulse_o => done);

  pll_sync_o <= pll_sync_ext;

  -----------------------------------------------------------------------------
  -- pll_sync sequence enable and done
  -----------------------------------------------------------------------------
  -- synchronize enable_sync_i (clk_sys_62m5_i domain) to clk_10m_ext_i
  cmp_sync_ffs_enable_sync_i: gc_sync_ffs
    generic map (
      g_sync_edge => "positive")
    port map (
      clk_i    => clk_10m_ext_i,
      rst_n_i  => rst_n_i,
      data_i   => enable_sync_i,
      ppulse_o => enable_sync);

  process (clk_10m_ext_i)
  begin
    if rst_n_i = '0' then
        enable <= '0';
    elsif rising_edge(clk_10m_ext_i) then
      if enable_sync = '1' then
        enable    <= '1';
      elsif done = '1' then
        enable <= '0';
      end if;
    end if;
  end process;

  sync_done <= not enable;

  -- synchronize sync_done (clk_10m_ext_i domain) to clk_sys_62m5_i domain
  cmp_sync_ffs_sync_done: gc_sync_ffs
    generic map (
      g_sync_edge => "positive")
    port map (
      clk_i    => clk_sys_62m5_i,
      rst_n_i  => rst_n_i,
      data_i   => sync_done,
      synced_o => sync_done_o);
  
end architecture rtl;
