-------------------------------------------------------------------------------
-- Title      : Platform-dependent components needed for WR PTP Core on Xilinx
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : wr_xilinx_pkg.vhd
-- Author     : Maciej Lipinski, Grzegorz Daniluk, Dimitrios Lampridis
-- Company    : CERN
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
--
-- Copyright (c) 2016-2017 CERN / BE-CO-HT
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.endpoint_pkg.all;

package wr_gtp_phy_pkg is

  -- Configuration of used-defined aux PLL clocks
  type t_gtpe2_channel_in is record
    RST_IN               : std_logic;
    RXSYSCLKSEL          : std_logic_vector(1 downto 0);
    TXSYSCLKSEL          : std_logic_vector(1 downto 0);
    DRPADDR_IN           : std_logic_vector(8 downto 0);
    DRPCLK_IN            : std_logic;
    DRPDI_IN             : std_logic_vector(15 downto 0);
    DRPEN_IN             : std_logic;
    DRPWE_IN             : std_logic;
    LOOPBACK             : std_logic_vector(2 downto 0);
    RXUSERRDY            : std_logic;
    RXUSRCLK             : std_logic;
    RXUSRCLK2            : std_logic;
    GTPRXN               : std_logic;
    GTPRXP               : std_logic;
    RXSLIDE              : std_logic;
    RXLPMHFHOLD          : std_logic;
    RXLPMLFHOLD          : std_logic;
    GTRXRESET            : std_logic;
    GTTXRESET            : std_logic;
    TXUSERRDY            : std_logic;
    TXDATA               : std_logic_vector(31 downto 0);
    TXUSRCLK             : std_logic;
    TXUSRCLK2            : std_logic;
    TXCHARISK            : std_logic_vector(3 downto 0);
    TXPRBSSEL            : std_logic_vector(2 downto 0);
  end record t_gtpe2_channel_in;

  type t_gtpe2_channel_in_array is array(integer range <>) of t_gtpe2_channel_in;

  type t_gtpe2_channel_out is record
    RXOUTCLK             : std_logic;
    DRP_BUSY_OUT         : std_logic;
    DRPDO_OUT            : std_logic_vector(15 downto 0);
    DRPRDY_OUT           : std_logic;
    EYESCANDATAERROR     : std_logic;
    RXDATA               : std_logic_vector(31 downto 0);
    RXCHARISCOMMA        : std_logic_vector(3 downto 0);
    RXCHARISK            : std_logic_vector(3 downto 0);
    RXDISPERR            : std_logic_vector(3 downto 0);
    RXNOTINTABLE         : std_logic_vector(3 downto 0);
    RXBYTEISALIGNED      : std_logic;
    RXCOMMADET           : std_logic;
    RXRESETDONE          : std_logic;
    GTPTXN               : std_logic;
    GTPTXP               : std_logic;
    TXOUTCLK             : std_logic;
    TXOUTCLKFABRIC       : std_logic;
    TXOUTCLKPCS          : std_logic;
    TXRESETDONE          : std_logic;
  end record t_gtpe2_channel_out;

  type t_gtpe2_channel_out_array is array(integer range <>) of t_gtpe2_channel_out;

end wr_gtp_phy_pkg;
