-------------------------------------------------------------------------------
-- Title      : 10MHz-1PPS even/odd 125 MHz reference clock phase detector  
-- Project    : WR PTP Core and EMPIR 17IND14 WRITE 
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
--            : http://empir.npl.co.uk/write/
-------------------------------------------------------------------------------
-- File       : pps_even_odd_det.vhd
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

entity pps_even_odd_det is
  port (
    clk_ref_i    : in  std_logic;
	rst_n_i      : in  std_logic;
    pps_i        : in  std_logic;
    enable_i     : in  std_logic;
    even_odd_n_o : out std_logic;
    sync_o       : out std_logic
  );
end entity pps_even_odd_det;

architecture rtl of pps_even_odd_det is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  signal rst                : std_logic;
  signal pps_synced_pos     : std_logic;
  signal pps_synced_neg     : std_logic;
  signal pps_synced_pos_del : std_logic;
  signal sync               : std_logic;

begin  -- architecture rtl

  rst <= not rst_n_i;
  
  cmp_iddr: IDDR
  generic map (
    DDR_CLK_EDGE => "SAME_EDGE")
  port map (
  Q1 => pps_synced_pos,
  Q2 => pps_synced_neg,
  C  => clk_ref_i,
  CE => '1',
  D  => pps_i,
  R  => rst,
  S  => '0');  

  -- If rising_edge pps_i is during clk_ref_i = '1' then
  -- pps_synced_pos and pps_synced_neg are asserted at the same time
  -- else pps_synced_pos is asserted before pps_synced_neg in.
  process (clk_ref_i, rst_n_i)
  begin
    if (rst_n_i = '0') then
      pps_synced_pos_del <= '0';
      even_odd_n_o <= '0';
      sync <= '0';
    elsif rising_edge(clk_ref_i) then
	  pps_synced_pos_del <= pps_synced_pos;
	  -- detect a rising edge pps_synced_pos (always 1 clk_ref_i tick
      -- after the clock tick in which ppsi had a rising edge).
	  if (pps_synced_pos_del = '0' and pps_synced_pos = '1') then
        -- detect simultanious assertion of pps_synced_neg
        if (pps_synced_neg = '1') then
          even_odd_n_o <= '0';
		else
          even_odd_n_o <= '1';
        end if;
        sync <= '1';
      else
        sync <= '0';
      end if;
	end if;
  
    if enable_i = '1' then
       sync_o <= sync;
    else
       sync_o <= '0';
    end if;
  end process;
    
end architecture rtl;
