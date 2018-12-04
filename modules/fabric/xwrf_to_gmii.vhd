-------------------------------------------------------------------------------
-- Title      : MAC Rx module
-- Project    :
-------------------------------------------------------------------------------
-- File       : xwrf_to_gmii.vhd
-- Author     : lihm
-- Company    : Tsinghua
-- Created    : 2015-01-26
-- Last update: 2016-01-26
-- Platform   : Xilinx Virtex 6
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: convert xwrf signal to gmii signal
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011 CERN
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
-- Revisions  :
-- Date        Version  Author          Description
-- 2015-01-26  1.0      lihm            Created
-- 2016-01-26  2.0      lihm            Add more annotation
-- 2016-03-09  3.0      lihm            Rewrite
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.wr_fabric_pkg.all;
use work.genram_pkg.all;
use work.endpoint_pkg.all;
use work.endpoint_private_pkg.all;

entity xwrf_to_gmii is
port (
    clk_sys_i           : in  std_logic;
    rst_sys_n_i         : in  std_logic;
    clk_ref_i           : in  std_logic;
    rst_ref_n_i         : in  std_logic;

    wrf_src_i           : in  t_wrf_source_in;
    wrf_src_o           : out t_wrf_source_out;
    wrf_snk_i           : in  t_wrf_sink_in;
    wrf_snk_o           : out t_wrf_sink_out;

    gmii_tx_clk_o      : out std_logic := '0';
    gmii_txd_o         : out std_logic_vector(7 downto 0);
    gmii_tx_en_o       : out std_logic;
    gmii_tx_er_o       : out std_logic;
    gmii_rx_clk_i      : in  std_logic                    := '0';
    gmii_rxd_i         : in  std_logic_vector(7 downto 0) := x"00";
    gmii_rx_dv_i       : in  std_logic                    := '0';
    gmii_rx_er_i       : in  std_logic                    := '0';
    -- not used in full-duplex connections
    gmii_crs_i         : in  std_logic                    := '0';
    gmii_col_i         : in  std_logic                    := '0'
);
end entity;

architecture rtl of xwrf_to_gmii is

signal wrf_snk_out: t_wrf_sink_out;

signal rx_fifo_wr_almost_full : std_logic;
signal rx_fifo_rd_almost_full : std_logic;
signal rx_fifo_wrreq : std_logic;
signal rx_fifo_rdreq, rx_fifo_rdempty        : std_logic;
signal rx_fifo_wrdata, rx_fifo_rddata        : std_logic_vector(17-1 downto 0);

signal rx_dvalid      : std_logic;
signal rx_pre_data    : std_logic_vector(15 downto 0);
signal rx_pre_sel     : std_logic;
signal rx_post_data   : std_logic_vector(15 downto 0);
signal rx_post_sel    : std_logic;

signal rx_data_valid  : std_logic;
signal rx_bytesel     : std_logic;
signal rx_data        : std_logic_vector(7 downto 0);

type t_rx_snk_state is(R_IDLE,R_DATA);
signal rx_snk_state : t_rx_snk_state;
type t_rx_state is (S_IDLE,S_WT_START,S_START,S_ODD,S_EVEN,S_END);
signal rx_fsm_state: t_rx_state;

function f_b2s (x : boolean)
    return std_logic is
begin
    if(x) then
        return '1';
    else
        return '0';
    end if;
end function;

type t_tx_state is(T_IDLE,T_ODD,T_EVEN,T_EVEN_END,T_END,T_DROP);
signal tx_state : t_tx_state;
type t_tx_src_state is (T_IDLE, T_GET_SIZE, T_STATUS ,T_PAYLOAD, T_EOF);
signal tx_src_state : t_tx_src_state;

signal gmii_rx_dv_reg       : std_logic;
signal tx_frame_wr          : std_logic;
signal tx_frame_in          : std_logic_vector(15 downto 0);

signal tx_fifo_almost_full  : std_logic;
signal tx_frame_rd          : std_logic;
signal tx_frame_out         : std_logic_vector(15 downto 0);
signal tx_fsize             : unsigned(15 downto 0);
signal tx_fsize_in          : std_logic_vector(15 downto 0);
signal tx_fsize_out         : std_logic_vector(15 downto 0);
signal tx_fsize_wr          : std_logic;
signal tx_fsize_rd          : std_logic;
signal tx_fsize_rd_empty    : std_logic;
signal tx_fsize_reg         : unsigned(15 downto 0);

signal wrf_src_fab  : t_ep_internal_fabric;
signal wrf_src_dreq : std_logic;

constant stored_status : t_wrf_status_reg :=
  ('0', '1', '0', '0', '0', (others => '0')); -- has_smac, has_crc

begin  -- rtl

--------------------------------------------------------------------------------------
---------------------------------------RX to Tx Part---------------------------------------
--------------------------------------------------------------------------------------
wrf_snk_o         <= wrf_snk_out;
wrf_snk_out.stall <= rx_fifo_wr_almost_full;
wrf_snk_out.err   <= '0';
wrf_snk_out.rty   <= '0';

p_gen_ack : process(clk_sys_i)
begin
if rising_edge(clk_sys_i) then
    if rst_sys_n_i = '0' then
        wrf_snk_out.ack <= '0';
    else
        wrf_snk_out.ack <= wrf_snk_i.cyc and wrf_snk_i.stb and wrf_snk_i.we and not wrf_snk_out.stall;
    end if;
end if;
end process;

rx_fifo_wrdata <= rx_pre_sel & rx_pre_data;
rx_dvalid <= f_b2s(wrf_snk_i.adr=C_WRF_DATA) and wrf_snk_i.cyc and wrf_snk_i.stb; -- data valid

p_snk_fsm: process (clk_sys_i)
begin
if rising_edge(clk_sys_i) then
    if rst_sys_n_i = '0' then
        rx_pre_sel <= '0';
        rx_pre_data <= (others=>'0');
        rx_fifo_wrreq <= '0';
    else
        case( rx_snk_state ) is
            when R_IDLE =>
                rx_pre_sel <= '0';
                rx_pre_data <= (others=>'0');
                rx_fifo_wrreq <= '0';
                if rx_dvalid = '1' then
                    rx_pre_data <= wrf_snk_i.dat;
                    rx_fifo_wrreq <= '1';
                    rx_snk_state <= R_DATA;
                    if (wrf_snk_i.sel = "11") then
                        rx_pre_sel <= '0';
                    else
                        rx_pre_sel <= '1';
                    end if;
                end if ;

            when R_DATA =>
                rx_pre_data <= wrf_snk_i.dat;
                if (wrf_snk_i.sel = "11") then
                    rx_pre_sel <= '0';
                else
                    rx_pre_sel <= '1';
                end if;
                rx_fifo_wrreq <= '1';

                if (rx_dvalid = '0') then
                    rx_pre_data <= (others=>'0');
                    rx_pre_sel <= '0';
                    rx_fifo_wrreq <= '0';
                    rx_snk_state <= R_IDLE;
                end if ;

            when others =>
                rx_snk_state <= R_IDLE;
        end case ;
    end if ;
end if ;
end process;

U_rx_fifo : generic_async_fifo
generic map (
    g_data_width             => 17,
    g_size                   => 64,
    g_with_wr_almost_full    => true,
    g_with_rd_empty          => true,
    g_with_rd_almost_empty   => false,
    g_with_rd_count          => false,
    g_with_rd_almost_full    => true,
    g_almost_empty_threshold => 4,
    g_almost_full_threshold  => 32
)
port map (
    rst_n_i           => rst_sys_n_i,
    clk_wr_i          => clk_sys_i,
    d_i               => rx_fifo_wrdata,
    we_i              => rx_fifo_wrreq,
    wr_empty_o        => open,
    wr_full_o         => open,
    wr_almost_empty_o => open,
    wr_almost_full_o  => rx_fifo_wr_almost_full,
    wr_count_o        => open,
    clk_rd_i          => clk_ref_i,
    q_o               => rx_fifo_rddata,
    rd_i              => rx_fifo_rdreq,
    rd_empty_o        => rx_fifo_rdempty,
    rd_full_o         => open,
    rd_almost_empty_o => open,
    rd_almost_full_o  => rx_fifo_rd_almost_full,
    rd_count_o        => open
);

rx_post_data <= rx_fifo_rddata(15 downto 0);
rx_post_sel <=  rx_fifo_rddata(16);

p_rd_fsm:process(clk_ref_i)
begin
if rising_edge(clk_ref_i) then
    if rst_ref_n_i = '0' then
        rx_data <= (others=>'0');
        rx_data_valid <= '0';
        rx_fifo_rdreq <= '0';
    else
        case (rx_fsm_state) is

            when S_IDLE =>
                rx_data <= (others=>'0');
                rx_data_valid <= '0';
                rx_fifo_rdreq <= '0';
                if rx_fifo_rdempty = '0' then
                    rx_fifo_rdreq <= '1';
                    rx_fsm_state <= S_WT_START;
                end if;

            when S_WT_START=>
                rx_fsm_state <= S_START;
                rx_fifo_rdreq <= '0';

            when S_START=>
                rx_data <= rx_post_data(15 downto 8);
                rx_data_valid <= '1';
                rx_fifo_rdreq <= '1';
                rx_fsm_state <= S_ODD;

            when S_EVEN=>
                rx_data <= rx_post_data(15 downto 8);
                rx_data_valid <= '1';
                rx_fifo_rdreq <= '1';
                rx_fsm_state <= S_ODD;
                if rx_fifo_rdempty = '1' then
                    rx_fifo_rdreq <= '0';
                    if rx_post_sel='1' then
                        rx_fsm_state <= S_END;
                    else
                        rx_fsm_state <= S_ODD;
                    end if;
                end if;

            when S_ODD=>
                rx_data <= rx_post_data(7 downto 0);
                rx_data_valid <= '1';
                rx_fifo_rdreq <= '0';
                rx_fsm_state <= S_EVEN;
                if rx_fifo_rdempty = '1' then
                    rx_fsm_state <= S_END;
                    rx_fifo_rdreq <= '0';
                end if;

            when S_END =>
                rx_data <= (others=>'0');
                rx_data_valid <= '0';
                rx_fifo_rdreq <= '0';
                rx_fsm_state <= S_IDLE;

            when others=>
                rx_fsm_state <= S_IDLE;
            end case;
        end if;
    end if;
end process;

gmii_tx_clk_o  <= clk_ref_i;
gmii_txd_o     <= rx_data;
gmii_tx_en_o   <= rx_data_valid;
gmii_tx_er_o   <= rx_fifo_rd_almost_full;

--------------------------------------------------------------------------------------
---------------------------------------TX to Rx Part---------------------------------------
--------------------------------------------------------------------------------------
---------------------------------------------------------------------------
----------------------------- FIFO Write Part -----------------------------
---------------------------------------------------------------------------
tx_fsize_in <= std_logic_vector(tx_fsize);

p_tx_data:process(gmii_rx_clk_i)
begin
  if rising_edge(gmii_rx_clk_i) then
    if rst_ref_n_i = '0' then
      tx_state       <= T_IDLE;
      tx_fsize       <= (others=>'0');
      tx_fsize_wr    <= '0';
      tx_frame_wr    <= '0';
      tx_frame_in    <= (others=>'0');
      gmii_rx_dv_reg <= '0';
    else
      tx_fsize_wr          <= '0';
      tx_frame_wr          <= '0';
      tx_frame_in          <= tx_frame_in(7 downto 0) & gmii_rxd_i;  

      case( tx_state ) is
        when T_IDLE=>
          if( (gmii_rx_dv_i = '1') and (tx_fifo_almost_full='0') ) then
            tx_fsize       <= tx_fsize+1;
            tx_state       <= T_ODD;
          elsif( (gmii_rx_dv_reg = '1') and (tx_fifo_almost_full='0') ) then
            tx_fsize       <= tx_fsize+2;
            tx_frame_wr    <= '1';
            tx_state       <= T_EVEN;
          elsif( (gmii_rx_dv_i = '1' or gmii_rx_dv_reg = '1') and (tx_fifo_almost_full='1') ) then
            tx_state       <= T_DROP;
          end if;
        
        when T_EVEN =>
          gmii_rx_dv_reg   <= '0';
          if gmii_rx_dv_i = '1' then
            if (gmii_rx_er_i = '1') then
                tx_state   <= T_DROP;
            else
                tx_fsize   <= tx_fsize+1;
                tx_state   <= T_ODD;
            end if ;
          else
            tx_fsize_wr    <= '1';
            tx_state       <= T_END;
          end if;

        when T_ODD =>
          gmii_rx_dv_reg   <= '0';
          if gmii_rx_dv_i = '1' then
            if (gmii_rx_er_i = '1') then
                tx_state   <= T_DROP;
            else
                tx_frame_wr<= '1';
                tx_fsize   <= tx_fsize+1;
                tx_state   <= T_EVEN;
            end if;
          else
            tx_fsize_wr    <= '1';
            tx_state       <= T_EVEN_END;  
          end if ;
          
        when T_EVEN_END =>
          tx_frame_wr      <= '1';
          tx_fsize         <= (others=>'0');
          if gmii_rx_dv_i = '1' then
            gmii_rx_dv_reg <= '1';
          end if ;

          tx_state         <= T_IDLE;

        when T_END =>
          tx_fsize <= (others=>'0');
          if gmii_rx_dv_i = '1' then
            gmii_rx_dv_reg <= '1';
          end if ;

          tx_state         <= T_IDLE;

        when T_DROP =>
          gmii_rx_dv_reg   <= '0';
          tx_fsize         <= (others=>'0');
          if gmii_rx_dv_i = '0' then
            tx_state       <= T_IDLE;
          end if ;

      end case ;
    end if;
  end if;
end process; -- p_tx_data

--------------------------------------------------------------------------
----------------------------- FIFO      Part -----------------------------
--------------------------------------------------------------------------
  FRAME_FIFO : generic_async_fifo
  generic map (
      g_data_width             => 16,
      g_size                   => 2048,
      g_with_rd_empty          => false,
      g_with_rd_almost_empty   => false,
      g_with_rd_count          => false,
      g_with_wr_almost_full    => true,
      g_almost_empty_threshold => 2,
      g_almost_full_threshold  => 1024
  )
  port map (
      rst_n_i           => rst_ref_n_i,
      clk_wr_i          => gmii_rx_clk_i,
      d_i               => tx_frame_in,
      we_i              => tx_frame_wr,
      wr_almost_full_o  => tx_fifo_almost_full,
      clk_rd_i          => clk_sys_i,
      q_o               => tx_frame_out,
      rd_i              => tx_frame_rd,
      rd_empty_o        => open
  );

  SIZE_FIFO: generic_async_fifo
    generic map(
      g_data_width             => 16,
      g_size                   => 8,
      g_with_rd_empty          => true,
      g_with_wr_full           => true,
      g_almost_empty_threshold => 1,
      g_almost_full_threshold  => 7)
    port map(
      rst_n_i          => rst_ref_n_i,
      clk_wr_i         => clk_ref_i,
      d_i              => tx_fsize_in,
      we_i             => tx_fsize_wr,
      wr_full_o        => open,
      clk_rd_i         => clk_sys_i,
      q_o              => tx_fsize_out,
      rd_i             => tx_fsize_rd,
      rd_empty_o       => tx_fsize_rd_empty
    );

--------------------------------------------------------------------------
----------------------------- FIFO Read Part -----------------------------
--------------------------------------------------------------------------
TX_FSM_P:process(clk_sys_i)
begin
  if rising_edge(clk_sys_i) then
    if(rst_sys_n_i = '0') then
      tx_src_state       <= T_IDLE;
      tx_fsize_reg       <= (others=>'0');
      tx_fsize_rd        <= '0';
      tx_frame_rd        <= '0';
      wrf_src_fab.addr   <= (others=>'0');
    else
      tx_fsize_rd        <= '0';
      tx_frame_rd        <= '0';
      wrf_src_fab.sof    <= '0';
      wrf_src_fab.eof    <= '0';
      wrf_src_fab.dvalid <= '0';

      case tx_src_state is
        when T_IDLE =>
          tx_fsize_reg   <= (others=>'0');
          wrf_src_fab.addr    <= c_WRF_STATUS;
          wrf_src_fab.bytesel <= '0';

          if(tx_fsize_rd_empty = '0' and wrf_src_dreq='1') then
            tx_fsize_rd       <= '1';
            wrf_src_fab.sof   <= '1';
            tx_src_state      <= T_GET_SIZE;
          end if;

        when T_GET_SIZE =>
          wrf_src_fab.dvalid  <= '1';
          tx_frame_rd         <= '1';
          tx_src_state        <= T_STATUS;
        
        when T_STATUS =>
          if(wrf_src_dreq ='1') then
            tx_frame_rd       <= '1';
            wrf_src_fab.addr  <= c_WRF_DATA;
            tx_fsize_reg      <= unsigned(tx_fsize_out) - 2;
            tx_src_state      <= T_PAYLOAD;
            wrf_src_fab.dvalid<= '1';
          end if;
        
        when T_PAYLOAD =>
          if(wrf_src_dreq = '1' and tx_fsize_reg > 1) then
            tx_fsize_reg        <= tx_fsize_reg - 2;
            wrf_src_fab.bytesel <= '0';
          elsif(wrf_src_dreq = '1' and tx_fsize_reg = 1) then
            tx_fsize_reg        <= tx_fsize_reg-1;
            wrf_src_fab.bytesel <= '1';
          end if;

          if(wrf_src_dreq = '1' and tx_fsize_reg > 2) then
            tx_frame_rd        <= '1';
            wrf_src_fab.dvalid <= '1';
          elsif( wrf_src_dreq = '1' and tx_fsize_reg <= 2) then
            wrf_src_fab.dvalid <= '1';
            tx_src_state       <= T_EOF;
          end if;

        when T_EOF =>
          if(wrf_src_dreq = '1') then
            wrf_src_fab.eof <= '1';
            tx_src_state    <= T_IDLE;
          end if;

        when others =>
          tx_src_state <= T_IDLE;
      end case;
    end if;
  end if;
end process;

wrf_src_fab.has_rx_timestamp <= '0';
wrf_src_fab.rx_timestamp_valid <= '0';
wrf_src_fab.error <= '0';
wrf_src_fab.data <= tx_frame_out when (tx_src_state=T_PAYLOAD or tx_src_state=T_EOF) else
                f_marshall_wrf_status(stored_status);

WRF_SRC: ep_rx_wb_master
  generic map(
    g_ignore_ack   => false,
    g_cyc_on_stall => true)
  port map(
    clk_sys_i  => clk_sys_i,
    rst_n_i    => rst_sys_n_i,
    snk_fab_i  => wrf_src_fab,
    snk_dreq_o => wrf_src_dreq,
    src_wb_i   => wrf_src_i,
    src_wb_o   => wrf_src_o
    );
end rtl;
