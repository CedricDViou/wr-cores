-------------------------------------------------------------------------------
-- Title      : Simple dualport switch
-- Project    :
-------------------------------------------------------------------------------
-- File       : xwrf_dp_switch.vhd
-- Author     : lihm
-- Company    : Tsinghua
-- Created    : 2018-12-03
-- Last update: 2018-12-03
-- Platform   : Xilinx Spartan 6
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Simple dualport switch
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
-- 2018-11-3  1.0      lihm            Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wr_fabric_pkg.all;
use work.wishbone_pkg.all;
use work.genram_pkg.all;
use work.endpoint_pkg.all;
use work.endpoint_private_pkg.all;

entity xwrf_dp_switch is
  generic(
    -- g_interface_mode        : t_wishbone_interface_mode      := CLASSIC;
    -- g_address_granularity   : t_wishbone_address_granularity := WORD;
    g_num_ports       : integer := 2 );
  port(
    clk_sys_i         : in  std_logic;
    rst_n_i           : in  std_logic;

    -- wb_i              : in  t_wishbone_slave_in;
    -- wb_o              : out t_wishbone_slave_out;

    port_wrf_snk_i   : in  t_wrf_sink_in_array(g_num_ports-1 downto 0);
    port_wrf_snk_o   : out t_wrf_sink_out_array(g_num_ports-1 downto 0);
    port_wrf_src_o   : out t_wrf_source_out_array(g_num_ports-1 downto 0);
    port_wrf_src_i   : in  t_wrf_source_in_array(g_num_ports-1 downto 0)
    );
end xwrf_dp_switch;

architecture behav of xwrf_dp_switch is
   
  -- signal wb_out : t_wishbone_slave_out;
  -- signal wb_in  : t_wishbone_slave_in;
  -- signal regs_fromwb  : t_dp_switch_out_registers;
  -- signal regs_towb    : t_dp_switch_in_registers;

  type t_dp_switch_rxfsm is (IDLE, PAYLOAD, DROP, FEND);
  type t_dp_switch_rxfsm_array is array (natural range <>) of t_dp_switch_rxfsm;
  signal port_rxfsm : t_dp_switch_rxfsm_array(g_num_ports-1 downto 0);
  type t_dp_switch_txfsm is (IDLE, GET_SIZE, STATUS ,PAYLOAD, EOF);
  type t_dp_switch_txfsm_array is array (natural range <>) of t_dp_switch_txfsm;
  signal port_txfsm : t_dp_switch_txfsm_array(g_num_ports-1 downto 0);

  signal port_fword_valid : std_logic_vector(g_num_ports-1 downto 0);

  signal port_ffifo_wr   : std_logic_vector(g_num_ports-1 downto 0);
  signal port_ffifo_rd   : std_logic_vector(g_num_ports-1 downto 0);
  signal port_ffifo_full : std_logic_vector(g_num_ports-1 downto 0);
  type t_frame_fifo_array is array (natural range <>) of std_logic_vector(15 downto 0);
  signal port_ffifo_in : t_frame_fifo_array(g_num_ports-1 downto 0);
  signal port_ffifo_out : t_frame_fifo_array(g_num_ports-1 downto 0);

  type t_frame_size_array is array (natural range <>) of unsigned(15 downto 0);
  signal port_fsize    : t_frame_size_array(g_num_ports-1 downto 0);
  signal port_txsize   : t_frame_size_array(g_num_ports-1 downto 0);

  signal port_sfifo_wr    : std_logic_vector(g_num_ports-1 downto 0);
  signal port_sfifo_rd    : std_logic_vector(g_num_ports-1 downto 0);
  signal port_sfifo_empty : std_logic_vector(g_num_ports-1 downto 0);
  signal port_sfifo_full  : std_logic_vector(g_num_ports-1 downto 0);
  type t_size_fifo_array is array (natural range <>) of std_logic_vector(15 downto 0);
  signal port_sfifo_in  : t_size_fifo_array(g_num_ports-1 downto 0);
  signal port_sfifo_out : t_size_fifo_array(g_num_ports-1 downto 0);
  
  signal port_src_fab  : t_fab_pipe(g_num_ports-1 downto 0);
  signal port_src_dreq : std_logic_vector(g_num_ports-1 downto 0);

  constant stored_status : t_wrf_status_reg :=
    ('0', '1', '1', '0', '0', (others => '0')); -- has_smac, has_crc

begin

  -------------------------------------------
  --  Standard Wishbone stuff
  -------------------------------------------
  -- U_Slave_adapter : wb_slave_adapter
  --   generic map (
  --     g_master_use_struct  => true,
  --     g_master_mode        => CLASSIC,
  --     g_master_granularity => WORD,
  --     g_slave_use_struct   => true,
  --     g_slave_mode         => g_interface_mode,
  --     g_slave_granularity  => g_address_granularity)
  --   port map (
  --     clk_sys_i  => clk_sys_i,
  --     rst_n_i    => rst_n_i,
  --     slave_i    => wb_i,
  --     slave_o    => wb_o,
  --     master_i   => wb_out,
  --     master_o   => wb_in
  --     );

  -- U_WB_SLAVE: dualport_wishbone_controller
  --   port map(
  --     rst_n_i    => rst_n_i,
  --     clk_sys_i  => clk_sys_i,
  --     wb_adr_i   => wb_in.adr(2 downto 0),
  --     wb_dat_i   => wb_in.dat,
  --     wb_dat_o   => wb_out.dat,
  --     wb_cyc_i   => wb_in.cyc,
  --     wb_sel_i   => wb_in.sel,
  --     wb_stb_i   => wb_in.stb,
  --     wb_we_i    => wb_in.we,
  --     wb_ack_o   => wb_out.ack,
  --     wb_stall_o => wb_out.stall,
  --     regs_i     => regs_towb,
  --     regs_o     => regs_fromwb);

  -- wb_out.rty <= '0';
  -- wb_out.err <= '0';
  -- wb_out.int <= '0';

--------------------------------------------------------------------------------------
--- Dual port Data Switch Part --
--------------------------------------------------------------------------------------    
  -------------------------------------------
  -- FIFO
  -------------------------------------------
  gen_fifo : for i in 0 to g_num_ports-1 generate
  
    FRAME_FIFO : generic_sync_fifo
    generic map(
      g_data_width  => 16,
      g_size        => 1024,
      g_with_empty  => true,
      g_with_full   => true,
      g_with_almost_empty  => false,
      g_with_almost_full   => false,
      g_with_count  => true)
    port map(
      rst_n_i => rst_n_i,
      clk_i   => clk_sys_i,
      d_i     => port_ffifo_in(i),
      we_i    => port_ffifo_wr(i),
      q_o     => port_ffifo_out(i),
      rd_i    => port_ffifo_rd(i),
      empty_o => open,
      full_o  => port_ffifo_full(i));

    SIZE_FIFO : generic_sync_fifo
    generic map(
      g_data_width  => 16,
      g_size        => 8,
      g_show_ahead  => true,
      g_with_empty  => true,
      g_with_full   => true,
      g_with_almost_empty  => false,
      g_with_almost_full   => false,
      g_with_count  => true)
    port map(
      rst_n_i => rst_n_i,
      clk_i   => clk_sys_i,
      d_i     => port_sfifo_in(i),
      we_i    => port_sfifo_wr(i),
      q_o     => port_sfifo_out(i),
      rd_i    => port_sfifo_rd(i),
      empty_o => port_sfifo_empty(i),
      full_o  => port_sfifo_full(i));

  end generate gen_fifo;

  -------------------------------------------
  -- RX FSM
  -------------------------------------------
  gen_rxfsm : for i in 0 to g_num_ports-1 generate

    port_fword_valid(i) <= '1' when(port_wrf_snk_i(i).cyc='1' and port_wrf_snk_i(i).stb='1' and port_wrf_snk_i(i).adr=c_WRF_DATA) else
                           '0';

    RX_FSM_P:process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if(rst_n_i = '0') then
          port_fsize(i)    <= (others=>'0');
          port_ffifo_wr(i) <= '0';
          port_sfifo_wr(i) <= '0';
          port_rxfsm(i)    <= IDLE;
        else
          port_ffifo_wr(i) <= '0';
          port_sfifo_wr(i) <= '0';

          if(port_fword_valid(i) = '1') then
            port_wrf_snk_o(i).ack <= '1';
          else
            port_wrf_snk_o(i).ack <= '0';
          end if;
        
          case port_rxfsm(i) is
            when IDLE =>
              if(port_wrf_snk_i(i).cyc='1' and port_ffifo_full(i)='0' and port_sfifo_full(i)='0') then
                port_rxfsm(i) <= PAYLOAD;
              elsif(port_wrf_snk_i(i).cyc='1') then
                port_rxfsm(i) <= DROP;
              end if;

            when PAYLOAD =>
              if port_fword_valid(i) = '1' then
                if port_ffifo_full(i)='0' then
                  port_ffifo_wr(i) <= '1';
                  port_ffifo_in(i) <= port_wrf_snk_i(i).dat;
                  if port_wrf_snk_i(i).sel = "11" then
                    port_fsize(i) <= port_fsize(i) + 2;
                  else
                    port_fsize(i) <= port_fsize(i) + 1;    
                  end if ;
                else
                  port_fsize(i) <= port_fsize(i)-2; --last write was already unsuccesfull
                  port_rxfsm(i) <= DROP;  
                end if ;
              end if ;

              if(port_wrf_snk_i(i).cyc='0') then
                port_rxfsm(i) <= FEND;
              end if;

            when DROP =>
              if(port_wrf_snk_i(i).cyc='0') then
                port_rxfsm(i) <= FEND;
              end if;

            when FEND =>
              if(port_fsize(i)>0) then
                port_sfifo_wr(i) <= '1';
                port_sfifo_in(i) <= std_logic_vector(port_fsize(i));
                port_fsize(i) <= (others=>'0');
              end if;
              port_rxfsm(i) <= IDLE;
          end case;
        end if;
      end if;
    end process;

    port_wrf_snk_o(i).stall <= '0';
    port_wrf_snk_o(i).rty   <= '0';
    port_wrf_snk_o(i).err   <= '0';

  end generate gen_rxfsm;
  -------------------------------------------
  -- TX FSM
  -------------------------------------------
  gen_txfsm : for i in 0 to g_num_ports-1 generate
    
    WRF_SRC: ep_rx_wb_master
      generic map(
        g_ignore_ack => false,
        g_cyc_on_stall => true)
      port map(
        clk_sys_i  => clk_sys_i,
        rst_n_i    => rst_n_i,
        snk_fab_i  => port_src_fab(i),
        snk_dreq_o => port_src_dreq(i),
        src_wb_i   => port_wrf_src_i(i),
        src_wb_o   => port_wrf_src_o(i));

    port_src_fab(i).has_rx_timestamp <= '0';
    port_src_fab(i).rx_timestamp_valid <= '0';
    port_src_fab(i).error <= '0';
    port_src_fab(i).data <= port_ffifo_out(g_num_ports-1-i) when (port_txfsm(i)=PAYLOAD or port_txfsm(i)=EOF) else
                          f_marshall_wrf_status(stored_status);
    
    TX_FSM_P:process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if(rst_n_i='0') then
          port_txfsm(i) <= IDLE;
          port_txsize(i) <= (others=>'0');
          port_ffifo_rd(g_num_ports-1-i) <= '0';
          port_sfifo_rd(g_num_ports-1-i) <= '0';
          port_src_fab(i).addr <= (others=>'0');
          
        else
          port_sfifo_rd(g_num_ports-1-i) <= '0';
          port_ffifo_rd(g_num_ports-1-i) <= '0';
          port_src_fab(i).sof    <= '0';
          port_src_fab(i).eof    <= '0';
          port_src_fab(i).dvalid <= '0';

          case port_txfsm(i) is
            when IDLE =>
              port_txsize(i)  <= (others=>'0');
              port_src_fab(i).bytesel <= '0';
              port_src_fab(i).addr    <= c_WRF_STATUS;

              if(port_sfifo_empty(g_num_ports-1-i) = '0' and port_src_dreq(i)='1') then
                port_sfifo_rd(g_num_ports-1-i) <= '1';
                port_src_fab(i).sof <= '1';
                port_txfsm(i)       <= GET_SIZE;
              end if;

            when GET_SIZE =>
              port_txsize(i)    <= unsigned(port_sfifo_out(g_num_ports-1-i));
              port_txfsm(i)     <= STATUS;
              port_src_fab(i).dvalid <= '1';
              port_ffifo_rd(g_num_ports-1-i) <= '1';
            
            when STATUS =>
              if(port_src_dreq(i)='1') then
                port_ffifo_rd(g_num_ports-1-i) <= '1';
                port_src_fab(i).addr <= c_WRF_DATA;
                port_txsize(i) <= port_txsize(i) - 2;
                port_src_fab(i).dvalid <= '1';
                port_txfsm(i) <= PAYLOAD;
              end if;
            
            when PAYLOAD =>
              if(port_src_dreq(i)='1' and port_txsize(i)>1) then
                port_txsize(i) <= port_txsize(i) - 2;
                port_src_fab(i).bytesel <= '0';
              elsif(port_src_dreq(i)='1' and port_txsize(i)=1) then
                port_txsize(i) <= port_txsize(i) - 1;
                port_src_fab(i).bytesel <= '1';
              end if;

              if(port_src_dreq(i)='1' and port_txsize(i)>2) then
                port_ffifo_rd(g_num_ports-1-i) <= '1';
                port_src_fab(i).dvalid <= '1';
              elsif( port_src_dreq(i)='1' and port_txsize(i)<=2) then
                port_src_fab(i).dvalid <= '1';
                port_txfsm(i)   <= EOF;
              end if;

            when EOF =>
              if(port_src_dreq(i)='1') then
                port_src_fab(i).eof <= '1';
                port_txfsm(i) <= IDLE;
              end if;

            when others =>
              port_txfsm(i) <= IDLE;
          end case;
        end if;
      end if;
    end process;

  end generate gen_txfsm;

end behav;
