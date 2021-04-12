-------------------------------------------------------------------------------
-- Title      : Probe 10MHz refclk rising w.r.t. 125 MHz WR Reference clock)
-- Project    : WR PTP Core and HPSEC
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
--            : https://ohwr.org/project/hpsec/wikis/home
-------------------------------------------------------------------------------
-- File       : probe)10mhz.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2021-04-07
-- Last update: 2021-04-07
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: When a PLL is used to generate 125 MHz from 10 MHz then the PLL
--              can lock on the even or odd 10MHz phase w.r.t. the 1 PPS. This
--              module detects where (even/odd) the lock was achieved.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2021 Nikhef
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

entity probe_10mhz is
  port (
	rst_n_i        : in  std_logic;
    clk_ref_i      : in  std_logic;
    clk_10mhz_a_i  : in  std_logic;
    clk_10mhz_b_i  : in  std_logic;
    aligned_o      : out std_logic
  );
end entity probe_10mhz;

architecture rtl of probe_10mhz is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  signal clk_10mhz_a_del  : std_logic;
  signal clk_10mhz_b_del  : std_logic;
  signal clk_10mhz_a_del1 : std_logic;
  signal clk_10mhz_b_del1 : std_logic;
  signal rise_10mhz_a     : std_logic;
  signal rise_10mhz_b     : std_logic;
  constant c_align_cnt    : integer := 4;

begin  -- architecture rtl

  process (clk_ref_i, rst_n_i)
    variable cnt: integer range 0 to c_align_cnt;
  begin
    if (rst_n_i = '0') then
      clk_10mhz_a_del <= '0';
      clk_10mhz_b_del <= '0';
      clk_10mhz_a_del1 <= '0';
      clk_10mhz_b_del1 <= '0';
      aligned_o <= '0';
      cnt := 0;
    elsif rising_edge(clk_ref_i) then
      clk_10mhz_a_del <= clk_10mhz_a_i;
      clk_10mhz_b_del <= clk_10mhz_b_i;
      clk_10mhz_a_del1 <= clk_10mhz_a_del;
      clk_10mhz_b_del1 <= clk_10mhz_b_del;
      if (clk_10mhz_a_del1 = '0' and clk_10mhz_a_del = '1') then
        rise_10mhz_a <= '1';
      else
        rise_10mhz_a <= '0';
      end if;
      if (clk_10mhz_b_del1 = '0' and clk_10mhz_b_del = '1') then
        rise_10mhz_b <= '1';
      else
        rise_10mhz_b <= '0';
      end if;
      -- each time one or the other 10 MHz has a rising edge...
      if rise_10mhz_a = '1' or rise_10mhz_b = '1' then
        -- ...if rising edges align
        if rise_10mhz_a = '1' and rise_10mhz_b = '1' then
          -- ...if rising edges align then increment counter
          if  cnt /= c_align_cnt then
            cnt := cnt + 1;
          end if;
        else 
          -- not aligned, clear counter
          cnt := 0;
        end if;
      end if;

      -- after succesive alignments
      if cnt = c_align_cnt then
        aligned_o <= '1';
      else
        aligned_o <= '0';
      end if;

    end if;
  end process;

end architecture rtl;
