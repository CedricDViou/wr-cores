-------------------------------------------------------------------------------
-- Title      : RX Clock Alignment FIFO
-- Project    : White Rabbit MAC/Endpoint
-------------------------------------------------------------------------------
-- File       : ep_clock_alignment_fifo.vhd
-- Author     : Tomasz Włostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2010-11-18
-- Last update: 2012-08-28
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Asynchronous FIFO with internal fabric (t_ep_internal_fabric)
-- interface used to pass packet data between the RX clock->system clock
-- domains. 
-------------------------------------------------------------------------------
--
-- Copyright (c) 2009-2011 CERN / BE-CO-HT
--
-- Copyright and related rights are licensed under the Solderpad Hardware
-- License, Version 0.51 (the “License”) (which enables you, at your option,
-- to treat this file as licensed under the Apache License 2.0); you may not
-- use this file except in compliance with the License. You may obtain a copy
-- of the License at http://solderpad.org/licenses/SHL-0.51.
-- Unless required by applicable law or agreed to in writing, software,
-- hardware and materials distributed under this License is distributed on an
-- “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
-- or implied. See the License for the specific language governing permissions
-- and limitations under the License.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.genram_pkg.all;
use work.endpoint_private_pkg.all;
use work.endpoint_pkg.all;

entity ep_clock_alignment_fifo is

  generic(
    g_size                 : integer := 64;
    g_almostfull_threshold : integer := 56);

  port(
    rst_n_rd_i : in std_logic;
    rst_n_wr_i : in std_logic;
    clk_wr_i   : in std_logic;
    clk_rd_i   : in std_logic;

    dreq_i : in  std_logic;
    fab_i  : in  t_ep_internal_fabric;
    fab_o  : out t_ep_internal_fabric;

    full_o       : out std_logic;
    empty_o      : out std_logic;
    almostfull_o : out std_logic;

    -- number of data words which enables the output. Used
    -- to control the minimum latency
    pass_threshold_i : in std_logic_vector(f_log2_size(g_size)-1 downto 0)
    );
end ep_clock_alignment_fifo;

architecture structural of ep_clock_alignment_fifo is
  signal fifo_in   : std_logic_vector(17 downto 0);
  signal fifo_out  : std_logic_vector(17 downto 0);
  signal rx_rdreq  : std_logic;
  signal empty_int : std_logic;
  signal valid_int : std_logic;


  signal fab_int      : t_ep_internal_fabric;
  signal fifo_we      : std_logic;
begin

  f_pack_fifo_contents (fab_i, fifo_in, fifo_we, false);

-- Clock adjustment FIFO
  U_FIFO : generic_async_fifo
    generic map (
      g_data_width             => 18,
      g_size                   => g_size,
      g_with_wr_almost_full    => true,
      g_almost_full_threshold  => g_almostfull_threshold
      )
    port map (
      rst_n_i           => rst_n_wr_i,
      clk_wr_i          => clk_wr_i,
      d_i               => fifo_in,
      we_i              => fifo_we,
      wr_full_o         => full_o,
      wr_almost_full_o  => almostfull_o,
      clk_rd_i          => clk_rd_i,
      q_o               => fifo_out,
      rd_i              => rx_rdreq,
      rd_empty_o        => empty_int);
  

  rx_rdreq <= (not empty_int) and dreq_i; -- and dreq_mask;


  p_readout : process (clk_rd_i)
  begin
    if rising_edge(clk_rd_i) then
      if(rst_n_rd_i = '0') then
        valid_int <= '0';
      else
        valid_int <= rx_rdreq;
      end if;
    end if;
  end process;

  -- FIFO output data formatting
  f_unpack_fifo_contents(fifo_out, valid_int, fab_int, false);

  fab_o   <= fab_int;
  empty_o <= empty_int;
  
end structural;
