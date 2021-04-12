-------------------------------------------------------------------------------
-- Title      : Xilinx family-7 PLL
--            : based on MMCME2_ADV
-- Project    : WR PTP Core and EMPIR 17IND14 WRITE 
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
--            : http://empir.npl.co.uk/write/
-------------------------------------------------------------------------------
-- File       : pll_62m5_500m.vhd
-- Author(s)  : Peter Jansweijer <peterj@nikhef.nl>
-- Company    : Nikhef
-- Created    : 2018-12-10
-- Last update: 2018-12-10
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: In order to create a 10 MHz output clock that is phase
--              aligned with the 125 MHz reference clock one needs 500 MHz.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2018 Nikhef
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

library unisim;
use unisim.vcomponents.all;

entity pll_62m5_500m is
  port (
    ---------------------------------------------------------------------------`
    -- Clocks/resets
    ---------------------------------------------------------------------------

    areset_n_i : in  std_logic;

    -- 125.000 MHz PLL reference (BUFG copy of GTP/GTX)
    clk_62m5_pllref_i : in  std_logic;             

    -- 500 MHz out
    clk_500m_o        : out std_logic;

    -- PLL Status
    pll_500m_locked_o : out std_logic
    
  );
end entity pll_62m5_500m;

architecture rtl of pll_62m5_500m is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- clock and reset
  signal clk_500m         : std_logic;
  signal clk_sys_fb       : std_logic;
  signal pll_arst         : std_logic;

begin  -- architecture rtl

  -- active high async reset for PLL
  pll_arst <= not areset_n_i;

  -- System PLL (125 MHz -> 62.5 MHz)
  cmp_sys_clk_pll : MMCME2_ADV
    generic map (
      BANDWIDTH            => "OPTIMIZED",
      CLKOUT4_CASCADE      => false,
      COMPENSATION         => "ZHOLD",
      STARTUP_WAIT         => false,
      DIVCLK_DIVIDE        => 1,
      CLKFBOUT_MULT_F      => 16.000,    -- 62.5 MHz x 16 = 1 GHz.
      CLKFBOUT_PHASE       => 0.000,
      CLKFBOUT_USE_FINE_PS => false,

      CLKOUT0_DIVIDE_F    => 2.000,      -- 500 MHz clock
      CLKOUT0_PHASE       => 0.000,
      CLKOUT0_DUTY_CYCLE  => 0.500,
      CLKOUT0_USE_FINE_PS => false,

      CLKIN1_PERIOD => 8.000,            -- 8 ns means 125 MHz
      REF_JITTER1   => 0.010)
    port map (
      -- Output clocks
      CLKFBOUT     => clk_sys_fb,
      CLKOUT0      => clk_500m,
      -- Input clock control
      CLKFBIN      => clk_sys_fb,
      CLKIN1       => clk_62m5_pllref_i,
      CLKIN2       => '0',
      -- Tied to always select the primary input clock
      CLKINSEL     => '1',
      -- Ports for dynamic reconfiguration
      DADDR        => (others => '0'),
      DCLK         => '0',
      DEN          => '0',
      DI           => (others => '0'),
      DO           => open,
      DRDY         => open,
      DWE          => '0',
      -- Ports for dynamic phase shift
      PSCLK        => '0',
      PSEN         => '0',
      PSINCDEC     => '0',
      PSDONE       => open,
      -- Other control and status signals
      LOCKED       => pll_500m_locked_o,
      CLKINSTOPPED => open,
      CLKFBSTOPPED => open,
      PWRDWN       => '0',
      RST          => pll_arst);

  -- System PLL output clock buffer
  cmp_clk_500m_buf_o : BUFG
  port map (
    I => clk_500m,
    O => clk_500m_o);

end architecture rtl;
