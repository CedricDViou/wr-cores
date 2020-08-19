-------------------------------------------------------------------------------
-- Title      : 10MHz-1PPS even/odd 125 MHz reference clock phase detector  
-- Project    : WR PTP Core and EMPIR 17IND14 WRITE 
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
--            : http://empir.npl.co.uk/write/
-------------------------------------------------------------------------------
-- File       : even_odd_det.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2020-08-24
-- Last update: 2020-08-24
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

entity even_odd_det is
  port (
	rst_n_i        : in  std_logic;
    clk_ref_i      : in  std_logic;
    clk_10m_ext_i  : in  std_logic;
    clk_sys_62m5_i : in  std_logic;
    pps_i          : in  std_logic;
    even_odd_n_o   : out std_logic;
    enable_sync_i  : in  std_logic;
    sync_done_o    : out std_logic;
    sync_o         : out std_logic
  );
end entity even_odd_det;

architecture rtl of even_odd_det is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  signal rst                 : std_logic;
  signal clk_10m_ext_pos     : std_logic;
  signal clk_10m_ext_neg     : std_logic;
  signal clk_10m_ext_pos_del : std_logic;
  signal rising_pps          : std_logic;
  signal rising_clk_10m      : std_logic;
  signal arm_clk_10m_det     : std_logic;
  signal even_odd_n          : std_logic;
  signal enable_sync        : std_logic;
  signal enable             : std_logic;
  signal sync_done          : std_logic;

begin  -- architecture rtl

  rst <= not rst_n_i;
  
  cmp_iddr: IDDR
  generic map (
    DDR_CLK_EDGE => "SAME_EDGE")
  port map (
  Q1 => clk_10m_ext_pos,
  Q2 => clk_10m_ext_neg,
  C  => clk_ref_i,
  CE => '1',
  D  => clk_10m_ext_i,
  R  => rst,
  S  => '0');  

  -- If rising_edge clk_10m_ext_i is during clk_ref_i = '1' ("even") then
  -- clk_10m_ext_pos and clk_10m_ext_neg are asserted at the same time
  -- else ("odd") clk_10m_ext_pos is asserted before clk_10m_ext_neg in.
  process (clk_ref_i, rst_n_i)
  begin
    if (rst_n_i = '0') then
      clk_10m_ext_pos_del <= '0';
      even_odd_n <= '0';
    elsif rising_edge(clk_ref_i) then
	  clk_10m_ext_pos_del <= clk_10m_ext_pos;
	  -- detect a rising edge clk_10m_ext_pos (always 1 clk_ref_i tick
      -- after the clock tick in which ppsi had a rising edge).
	  if (clk_10m_ext_pos_del = '0' and clk_10m_ext_pos = '1') then
        -- detect simultanious assertion of clk_10m_ext_neg
        if clk_10m_ext_neg = '1' then
          even_odd_n <= '1';
        else
          even_odd_n <= '0';
        end if;
      end if;
	end if;
  end process;

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

  -----------------------------------------------------------------------------
  -- After rising edge PPS wait for first rising edge clk_10m and
  -- trigger a sync clk_ref_62m5 divider if enabled.
  -----------------------------------------------------------------------------
  process (clk_ref_i, rst_n_i)
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

  -- update even_odd_n and synchronize clk_ref div2 divider if enabled
  process (clk_ref_i, rst_n_i)
  begin
    if rst_n_i = '0' then
      even_odd_n_o <= '0';
      sync_o <= '0';
    elsif rising_edge(clk_ref_i) then
      sync_o <= '0';
      if arm_clk_10m_det = '1' and rising_clk_10m = '1' then
        even_odd_n_o <= even_odd_n;
        if enable = '1' then
          sync_o <= '1';
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sync sequence enable and done
  -----------------------------------------------------------------------------
  -- synchronize enable_sync_i (clk_sys_62m5_i domain) to clk_ref_i
  cmp_sync_ffs_enable_sync_i: gc_sync_ffs
    generic map (
      g_sync_edge => "positive")
    port map (
      clk_i    => clk_ref_i,
      rst_n_i  => rst_n_i,
      data_i   => enable_sync_i,
      ppulse_o => enable_sync);

  process (clk_ref_i, rst_n_i)
  begin
    if rst_n_i = '0' then
        enable <= '0';
    elsif rising_edge(clk_ref_i) then
      if enable_sync = '1' then
        enable    <= '1';
      elsif arm_clk_10m_det = '1' and rising_clk_10m = '1' then
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
