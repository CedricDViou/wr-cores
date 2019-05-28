-------------------------------------------------------------------------------
-- Title      : Deterministic Altera PHY wrapper - Arria 10
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : wr_arria10_e3p1_phy.vhd
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

entity wr_arria10_e3p1_transceiver is
  generic (
    g_use_atx_pll     : boolean := true;
    g_use_cmu_pll     : boolean := false;
    g_use_det_phy     : boolean := true;
    g_use_sfp_los_rst : boolean := true;
    g_use_tx_lcr_dbg  : boolean := false;
    g_use_rx_lcr_dbg  : boolean := false;
    g_use_ext_loop    : boolean := true;
    g_use_ext_rst     : boolean := true);
  port (
    clk_ref_i              : in  std_logic := '0';                                -- Input clock from WR extension [125Mhz]
    clk_phy_i              : in  std_logic := '0';                                -- Input clock from WR extension [125Mhz]
    reconfig_write_i       : in  std_logic_vector(0 downto 0) := (others => '0');
    reconfig_read_i        : in  std_logic_vector(0 downto 0) := (others => '0');
    reconfig_address_i     : in  std_logic_vector(9 downto 0) := (others => '0');
    reconfig_writedata_i   : in  std_logic_vector(31 downto 0) := (others => '0');
    reconfig_readdata_o    : out std_logic_vector(31 downto 0);
    reconfig_waitrequest_o : out std_logic_vector(0 downto 0);
    reconfig_clk_i         : in  std_logic_vector(0 downto 0) := (others => '0');
    reconfig_reset_i       : in  std_logic_vector(0 downto 0) := (others => '0');
    ready_o                : out std_logic;                                       -- TX and RX ready
    drop_link_i            : in  std_logic := '0';                                -- Drop link (reset)
    loopen_i               : in  std_logic := '0';                                -- Loop enable
    sfp_los_i              : in  std_logic := '0';                                -- SFP LOS
    tx_clk_o               : out std_logic;                                       -- TX clock to WR core
    tx_data_i              : in  std_logic_vector(7 downto 0) := (others => '0'); -- Data from WR core
    tx_ready_o             : out std_logic;                                       -- TX ready
    tx_disparity_o         : out std_logic;                                       -- Always zero
    tx_enc_err_o           : out std_logic;                                       -- Always zero
    tx_data_k_i            : in  std_logic := '0';                                -- TX data k
    rx_clk_o               : out std_logic;                                       -- RX clock to WR core
    rx_data_o              : out std_logic_vector(7 downto 0);                    -- Data to WR core
    rx_ready_o             : out std_logic;                                       -- RX ready
    rx_data_k_o            : out std_logic;                                       -- RX data k
    rx_enc_err_o           : out std_logic;                                       -- RX Enc. error
    rx_bitslide_o          : out std_logic_vector(3 downto 0);                    -- RX bitslide
    debug_o                : out std_logic;                                       -- For debugging
    debug_i                : in  std_logic_vector(7 downto 0) := (others => '0'); -- For debugging
    pad_txp_o              : out std_logic;                                       -- SFP out
    pad_rxp_i              : in  std_logic := '0'                                 -- SFP in
  );
end wr_arria10_e3p1_transceiver;

architecture rtl of wr_arria10_e3p1_transceiver is

  signal s_pll_select              : std_logic_vector(0 downto 0);
  signal s_cal_busy                : std_logic_vector(0 downto 0);

  signal s_rx_clk                  : std_logic;
  signal s_tx_clk                  : std_logic;

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
  signal s_phy_rx_is_lockedtoref   : std_logic_vector(0 downto 0);
  signal s_phy_rx_disperr          : std_logic_vector(0 downto 0);
  signal s_phy_rx_errdetect        : std_logic_vector(0 downto 0);

  signal s_reconfig_write          : std_logic_vector(0 downto 0);
  signal s_reconfig_read           : std_logic_vector(0 downto 0);
  signal s_reconfig_address        : std_logic_vector(9 downto 0);
  signal s_reconfig_writedata      : std_logic_vector(31 downto 0);
  signal s_reconfig_readdata       : std_logic_vector(31 downto 0);
  signal s_reconfig_waitrequest    : std_logic_vector(0 downto 0);

  signal s_rx_std_wa_patternalign  : std_logic;
  signal s_rx_std_wa_pa_ext        : std_logic;
  signal s_syncstatus              : std_logic;
  signal s_patterndetect           : std_logic;
  signal s_patterndetect_prev      : std_logic;
  signal s_patterndetect_ready     : std_logic;
  signal s_reset_aligner           : std_logic;
  signal s_scan_cnt                : std_logic_vector (5 downto 0);
  signal s_scan_wdg                : std_logic_vector (7 downto 0);
  signal s_rx_non_idle_count       : std_logic_vector (9 downto 0);
  signal s_rx_unexpected_count     : std_logic_vector (9 downto 0);
  signal s_tx_non_idle_count       : std_logic_vector (9 downto 0);
  signal s_tx_unexpected_count     : std_logic_vector (9 downto 0);
  signal s_rx_bit_slip             : std_logic;
  signal s_rx_bit_slip_ext         : std_logic;
  signal s_tx_data                 : std_logic_vector(7 downto 0);
  signal s_rx_data                 : std_logic_vector(7 downto 0);
  signal s_rx_data_k               : std_logic;
  signal s_tx_data_k               : std_logic;
  signal s_rx_data_delayed         : std_logic_vector(7 downto 0);
  signal s_rx_data_delayed_prev    : std_logic_vector(7 downto 0);
  signal s_found_std_idle_pattern  : std_logic;
  signal s_wait_cnt                : std_logic_vector (3 downto 0);
  signal s_wait_cnt_limit          : std_logic_vector (3 downto 0);
  signal s_k28_7_cnt               : std_logic_vector (3 downto 0);
  signal s_found_k28_7_pattern     : std_logic;
  signal s_extent_rx_bit_slip      : std_logic;
  signal s_loop_en                 : std_logic;

  signal s_debug_reset             : std_logic;
  signal s_sfp_los_reset           : std_logic;
  signal s_ext_reset               : std_logic;
  signal s_rx_idle_missed          : std_logic;
  signal s_tx_idle_missed          : std_logic;

  signal s_reconf_dirty_sync_count : std_logic_vector (9 downto 0);

  type   t_state is (SCAN_K28_5, BITSLIP, BITSLIP_EXTENT_ONE, IDLE, SYNC);
  signal bit_slip_state : t_state := SCAN_K28_5;

  type   lcr_fake_state is (IDLE, FOUND_K28_5, FAKE_FD, FAKE_ACK);
  signal s_rx_fake_link_state : lcr_fake_state := IDLE;
  signal s_tx_fake_link_state : lcr_fake_state := IDLE;

  constant c_d21_5 : std_logic_vector(7 downto 0) := "10110101"; -- 0xb5
  constant c_d2_2  : std_logic_vector(7 downto 0) := "01000010"; -- 0x42
  constant c_d5_6  : std_logic_vector(7 downto 0) := "11000101"; -- 0xc5
  constant c_d16_2 : std_logic_vector(7 downto 0) := "01010000"; -- 0x50

  constant c_k28_5 : std_logic_vector(7 downto 0) := "10111100"; -- 0xbc
  constant c_k23_7 : std_logic_vector(7 downto 0) := "11110111"; -- 0xf7
  constant c_k27_7 : std_logic_vector(7 downto 0) := "11111011"; -- 0xfb
  constant c_k29_7 : std_logic_vector(7 downto 0) := "11111101"; -- 0xfd
  constant c_k30_7 : std_logic_vector(7 downto 0) := "11111110"; -- 0xfe
  constant c_k28_7 : std_logic_vector(7 downto 0) := "11111100"; -- 0xfc

begin

  reconf_dirty_sync : process(clk_phy_i, s_rst_ctl_rst) is
  begin
    if s_rst_ctl_rst = '1' then
      s_reconf_dirty_sync_count <= (others => '0');
      s_reconfig_write          <= (others => '0');
      s_reconfig_read           <= (others => '0');
      s_reconfig_address        <= (others => '0');
      s_reconfig_writedata      <= (others => '0');
    elsif rising_edge(clk_phy_i) then
      s_reconf_dirty_sync_count <= std_logic_vector(unsigned(s_reconf_dirty_sync_count) + 1);
      if s_reconf_dirty_sync_count = "1111111111" then
        s_reconfig_write     <= reconfig_write_i;
        s_reconfig_read      <= reconfig_read_i;
        s_reconfig_address   <= reconfig_address_i;
        s_reconfig_writedata <= reconfig_writedata_i;
      end if;
    end if;
  end process;
  reconfig_readdata_o    <= s_reconfig_readdata;
  reconfig_waitrequest_o <= s_reconfig_waitrequest;

  std_phy : if not g_use_det_phy generate

  -- Transceiver
  inst_phy : wr_arria10_e3p1_phy
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
  atx_pll : if g_use_atx_pll and not(g_use_cmu_pll) generate
    inst_atx_pll : wr_arria10_e3p1_atx_pll
      port map (
        pll_refclk0   => clk_ref_i,
        pll_powerdown => s_rst_ctl_powerdown(0),
        pll_locked    => s_tx_pll_625m_locked(0),
        tx_serial_clk => s_tx_pll_625m_serial_clk,
        pll_cal_busy  => s_tx_pll_625m_cal_busy
      );
  end generate atx_pll;

  -- CMU PLL
  cmu_pll : if not(g_use_atx_pll) and g_use_cmu_pll generate
    s_tx_pll_625m_locked(0)  <= '0';
    s_tx_pll_625m_serial_clk <= '0';
    s_tx_pll_625m_cal_busy   <= '0';
  end generate cmu_pll;

  -- TX fPLL
  tx_fpll : if not(g_use_atx_pll) and not(g_use_cmu_pll) generate
    inst_tx_pll : wr_arria10_e3p1_tx_pll
      port map (
        pll_refclk0   => clk_ref_i,
        pll_powerdown => s_rst_ctl_powerdown(0),
        pll_locked    => s_tx_pll_625m_locked(0),
        tx_serial_clk => s_tx_pll_625m_serial_clk,
        pll_cal_busy  => s_tx_pll_625m_cal_busy
      );
  end generate tx_fpll;

  -- No PLL
  no_pll : if g_use_atx_pll and g_use_cmu_pll generate
    s_tx_pll_625m_locked(0)  <= '0';
    s_tx_pll_625m_serial_clk <= '0';
    s_tx_pll_625m_cal_busy   <= '0';
  end generate no_pll;

  s_cal_busy(0) <= s_phy_tx_cal_busy(0) or s_tx_pll_625m_cal_busy;

  -- Reset controller
  inst_rst_ctl : wr_arria10_e3p1_rst_ctl
    port map (
      clock              => clk_ref_i,
      reset              => s_rst_ctl_rst,
      pll_powerdown      => s_rst_ctl_powerdown,
      tx_analogreset     => s_rst_ctl_tx_analogreset,
      tx_digitalreset    => s_rst_ctl_tx_digitalreset,
      tx_ready           => s_rst_ctl_tx_ready,
      pll_locked         => s_tx_pll_625m_locked,
      pll_select         => s_pll_select,
      tx_cal_busy        => s_cal_busy,
      rx_analogreset     => s_rst_ctl_rx_analogreset,
      rx_digitalreset    => s_rst_ctl_rx_digitalreset,
      rx_ready           => s_rst_ctl_rx_ready,
      rx_is_lockedtodata => s_phy_rx_is_lockedtodata,
      rx_cal_busy        => s_phy_rx_cal_busy
    );

  end generate std_phy;

  det_phy : if g_use_det_phy generate
    inst_phy : wr_arria10_e3p1_det_phy
      port map (
        tx_analogreset(0)                     => s_rst_ctl_tx_analogreset(0),
        tx_digitalreset(0)                    => s_rst_ctl_tx_digitalreset(0),
        rx_analogreset(0)                     => s_rst_ctl_rx_analogreset(0),
        rx_digitalreset(0)                    => s_rst_ctl_rx_digitalreset(0),
        tx_cal_busy(0)                        => s_phy_tx_cal_busy(0),
        rx_cal_busy(0)                        => s_phy_rx_cal_busy(0),
        tx_serial_clk0(0)                     => s_tx_pll_625m_serial_clk,
        rx_cdr_refclk0                        => clk_phy_i,
        tx_serial_data(0)                     => pad_txp_o,
        rx_serial_data(0)                     => pad_rxp_i,
        rx_is_lockedtoref                     => s_phy_rx_is_lockedtoref,
        rx_is_lockedtodata                    => s_phy_rx_is_lockedtodata,
        tx_coreclkin(0)                       => clk_ref_i,
        rx_coreclkin(0)                       => clk_ref_i,
        tx_clkout(0)                          => s_tx_clk,
        rx_clkout(0)                          => s_rx_clk,
        tx_parallel_data                      => s_tx_data,
        rx_parallel_data                      => s_rx_data,
        rx_datak                              => s_rx_data_k,
        rx_disperr                            => s_phy_rx_disperr(0),
        rx_errdetect                          => s_phy_rx_errdetect(0),
        rx_patterndetect                      => s_patterndetect,
        rx_runningdisp                        => open,
        rx_syncstatus                         => s_syncstatus,
        tx_datak                              => s_tx_data_k,
        rx_std_wa_patternalign(0)             => s_rx_std_wa_patternalign,
        reconfig_clk(0)                       => clk_phy_i,
        reconfig_reset(0)                     => s_rst_ctl_rst,
        reconfig_write                        => s_reconfig_write,
        reconfig_read                         => s_reconfig_read,
        reconfig_address                      => s_reconfig_address,
        reconfig_writedata                    => s_reconfig_writedata,
        reconfig_readdata                     => s_reconfig_readdata,
        reconfig_waitrequest                  => s_reconfig_waitrequest,
        rx_std_bitslipboundarysel(3 downto 0) => rx_bitslide_o(3 downto 0),
        rx_seriallpbken(0)                    => s_loop_en
      );

      -- Debug settings:
      -- debug_i(0) -> [DIP 1]: Allow drop_link_i input from WR [1=On, 0=Off]
      -- debug_i(1) -> [DIP 2]: RX CFG REG fake unit [1=On, 0=Off]
      -- debug_i(2) -> [DIP 2]: TX CFG REG fake unit [1=On, 0=Off]
      -- debug_i(3) -> [DIP 3]: Word alignment pattern unit [1=On, 0=Off]
      -- debug_i(4) -> [DIP 4]: Bitslip unit (turned off by synthesis) [1=On, 0=Off]
      -- debug_i(5) -> [DIP 5]: Reset everything [1=On, 0=Off]
      -- debug_i(6) -> [DIP 6]: Enable loop [1=On, 0=Off]
      -- debug_i(7) -> [DIP 7]: Phy ready AFTER WAP is done [1=On, 0=Off]

      tx_clk_o <= s_tx_clk;
      rx_clk_o <= s_rx_clk;

      tx_lcr_dbg_yes : if g_use_tx_lcr_dbg generate
      tx_data_sync_delay : process(s_tx_clk, s_rst_ctl_rst) is
        begin
          if s_rst_ctl_rst = '1' then
            s_tx_fake_link_state  <= IDLE;
            s_tx_idle_missed      <= '0';
            s_tx_data             <= (others => '0');
            s_tx_data_k           <= '0';
            s_tx_non_idle_count   <= (others => '0');
            s_tx_unexpected_count <= (others => '0');
          elsif rising_edge(s_tx_clk) then
            if debug_i(2) = '1' then
              case s_tx_fake_link_state is

                when IDLE =>
                  if tx_data_i = c_k28_5 then
                    s_tx_fake_link_state <= FOUND_K28_5;
                  else
                    s_tx_idle_missed <= not(s_tx_idle_missed);
                    s_tx_non_idle_count <= std_logic_vector(unsigned(s_tx_non_idle_count) + 1);
                  end if;
                  s_tx_data <= tx_data_i;

                when FOUND_K28_5 =>
                  if tx_data_i = c_d21_5 then
                    s_tx_fake_link_state <= FAKE_FD;
                  elsif tx_data_i = c_d2_2 then
                    s_tx_fake_link_state <= FAKE_FD;
                  else
                    s_tx_fake_link_state  <= IDLE;
                    s_tx_unexpected_count <= std_logic_vector(unsigned(s_tx_unexpected_count) + 1);
                  end if;
                  s_tx_data <= tx_data_i;

                when FAKE_FD =>
                  if tx_data_i = "00000000" or tx_data_i = "00100000" then
                    s_tx_fake_link_state <= FAKE_ACK;
                    s_tx_data <= "00100000"; -- Fill FD field
                  else
                    s_tx_unexpected_count <= std_logic_vector(unsigned(s_tx_unexpected_count) + 1);
                    s_tx_fake_link_state <= IDLE;
                    s_tx_data            <= tx_data_i;
                  end if;

                when FAKE_ACK =>
                  if tx_data_i = "00000000" or tx_data_i = "01000000" then
                    s_tx_data  <= "01000000"; -- Fill Ack field
                  else
                    s_tx_unexpected_count <= std_logic_vector(unsigned(s_tx_unexpected_count) + 1);
                    s_tx_data  <= tx_data_i;
                  end if;
                  s_tx_fake_link_state <= IDLE;

              end case;
              s_tx_data_k <= tx_data_k_i;
            else
              s_tx_data   <= tx_data_i;
              s_tx_data_k <= tx_data_k_i;
            end if; -- debug
          end if; -- Rising edge or reset
        end process;
      end generate tx_lcr_dbg_yes;

      tx_lcr_dbg_no : if not(g_use_tx_lcr_dbg) generate
        s_tx_data   <= tx_data_i;
        s_tx_data_k <= tx_data_k_i;
      end generate tx_lcr_dbg_no;

      rx_lcr_dbg_no : if g_use_rx_lcr_dbg generate
      rx_data_config_reg_faker : process(s_rx_clk, s_rst_ctl_rst) is
      begin
        if s_rst_ctl_rst = '1' then
          s_rx_fake_link_state  <= IDLE;
          s_rx_idle_missed      <= '0';
          rx_data_o             <= (others => '0');
          rx_data_k_o           <= '0';
          s_rx_non_idle_count   <= (others => '0');
          s_rx_unexpected_count <= (others => '0');
        elsif rising_edge(s_rx_clk) then
          if debug_i(1) = '1' then
            case s_rx_fake_link_state is

              when IDLE =>
                if s_rx_data = c_k28_5 then
                  s_rx_fake_link_state <= FOUND_K28_5;
                else
                  s_rx_idle_missed <= not(s_rx_idle_missed);
                  s_rx_non_idle_count <= std_logic_vector(unsigned(s_rx_non_idle_count) + 1);
                end if;
                rx_data_o <= s_rx_data;

              when FOUND_K28_5 =>
                if s_rx_data = c_d21_5 then
                  s_rx_fake_link_state <= FAKE_FD;
                elsif s_rx_data = c_d2_2 then
                  s_rx_fake_link_state <= FAKE_FD;
                else
                  s_rx_fake_link_state <= IDLE;
                  s_rx_unexpected_count <= std_logic_vector(unsigned(s_rx_unexpected_count) + 1);
                end if;
                rx_data_o  <= s_rx_data;

              when FAKE_FD =>
                if s_rx_data = "00000000" or s_rx_data = "00100000" then
                  s_rx_fake_link_state <= FAKE_ACK;
                  rx_data_o         <= "00100000"; -- Fill FD field
                else
                  s_rx_unexpected_count <= std_logic_vector(unsigned(s_rx_unexpected_count) + 1);
                  s_rx_fake_link_state  <= IDLE;
                  rx_data_o             <= s_rx_data;
                end if;

              when FAKE_ACK =>
                if s_rx_data = "00000000" or s_rx_data = "01000000" then
                  rx_data_o <= "01000000"; -- Fill Ack field
                else
                  s_rx_unexpected_count <= std_logic_vector(unsigned(s_rx_unexpected_count) + 1);
                  rx_data_o  <= s_rx_data;
                end if;
                s_rx_fake_link_state <= IDLE;

            end case;
            rx_data_k_o <= s_rx_data_k;
          else
            rx_data_o   <= s_rx_data;
            rx_data_k_o <= s_rx_data_k;
          end if;
        end if;
      end process;
    end generate rx_lcr_dbg_no;

    rx_lcr_dbg_yes : if not(g_use_rx_lcr_dbg) generate
      rx_data_o   <= s_rx_data;
      rx_data_k_o <= s_rx_data_k;
    end generate rx_lcr_dbg_yes;


      --rx_data_delay : process(s_rx_clk, s_rst_ctl_rst) is -- generic!
      --  begin
      --    if s_rst_ctl_rst = '1' then
      --      s_rx_data_delayed      <= (others => '0');
      --      s_rx_data_delayed_prev <= (others => '0');
      --    elsif rising_edge(s_rx_clk) then
      --      s_rx_data_delayed      <= s_rx_data;
      --      s_rx_data_delayed_prev <= s_rx_data_delayed;
      --    end if;
      --end process;

      s_rx_std_wa_pa_ext <= '0'; -- debug_i(6);
      s_rx_bit_slip_ext  <= '0'; -- debug_i(7);

      -- Pattern align watchdog
      pattern_align_wdg : process(s_rx_clk, s_rst_ctl_rst) is -- generic!
      begin
        if s_rst_ctl_rst = '1' then
          s_reset_aligner <= '0';
          s_scan_wdg      <= (others => '0');
        elsif rising_edge(s_rx_clk) then
          if s_rst_ctl_rx_digitalreset(0) = '0' and debug_i(3) = '1' then
            s_scan_wdg      <= std_logic_vector(unsigned(s_scan_wdg) + 1);
            if (s_scan_wdg = "11111111" and s_patterndetect_ready = '0') then
              s_reset_aligner <= '1';
            else
              s_reset_aligner <= '0';
            end if;
          end if;
        end if;
      end process;

      -- Bug: What happens in stuff is already aligned? handle this somehow
      pattern_align : process(s_rx_clk, s_rst_ctl_rst) is -- generic!
      begin
        if s_rst_ctl_rst = '1' then
          s_rx_std_wa_patternalign <= '0';
          s_scan_cnt               <= (others => '0');
        elsif rising_edge(s_rx_clk) then
          if s_rst_ctl_rx_digitalreset(0) = '0' and debug_i(3) = '1' then
            s_scan_cnt <= std_logic_vector(unsigned(s_scan_cnt) + 1);
            if s_scan_cnt = "000000" then
              if s_patterndetect_ready = '0' then
                s_rx_std_wa_patternalign <= '1' or s_rx_std_wa_pa_ext;
              else
                s_rx_std_wa_patternalign <= '0' or s_rx_std_wa_pa_ext;
              end if;
            elsif s_scan_cnt = "000001" then
              if s_rx_std_wa_patternalign = '1' then
                s_rx_std_wa_patternalign <= '1' or s_rx_std_wa_pa_ext;
              else
                s_rx_std_wa_patternalign <= '0' or s_rx_std_wa_pa_ext;
              end if;
            else
              s_rx_std_wa_patternalign <= '0' or s_rx_std_wa_pa_ext;
            end if;
          else
            s_rx_std_wa_patternalign <= '0' or s_rx_std_wa_pa_ext;
            s_scan_cnt <= (others => '0');
          end if; -- RST/CLK
        end if; --Rising CLK
      end process;

      patterndetect_extend : process(s_rx_clk, s_rst_ctl_rst) is -- generic!
        begin
          if s_rst_ctl_rst = '1' then
            s_patterndetect_ready <= '0';
          elsif rising_edge(s_rx_clk) then
            if s_rst_ctl_rx_digitalreset(0) = '0' then
              if debug_i(7) = '1' then
                if s_syncstatus = '1' and s_patterndetect = '1' then
                  s_patterndetect_ready <= '1';
                end if;
              else
                s_patterndetect_ready <= '1';
              end if;
            end if;
          end if;
      end process;

      bit_slip_wait_cnt : process(s_rx_clk, s_rst_ctl_rst) is -- generic!
        begin
          if s_rst_ctl_rst = '1' then
            s_wait_cnt <= (others => '0');
          elsif rising_edge(s_rx_clk) then
            if s_rst_ctl_rx_digitalreset(0) = '0' and debug_i(4) = '1' then
              s_wait_cnt <= std_logic_vector(unsigned(s_wait_cnt) + 1);
            end if;
          end if;
      end process;

      bit_slip : process(s_rx_clk, s_rst_ctl_rst) is -- generic!
      begin
        if s_rst_ctl_rst = '1' then
          bit_slip_state           <= SCAN_K28_5;
          s_found_std_idle_pattern <= '0';
          s_found_k28_7_pattern    <= '0';
          s_extent_rx_bit_slip     <= '0';
          s_k28_7_cnt              <= (others => '0');
          s_wait_cnt_limit         <= (others => '0');
        elsif rising_edge(s_rx_clk) then
          -- enabled?
          if s_rst_ctl_rx_digitalreset(0) = '0' and debug_i(4) = '1' then
            case bit_slip_state is
              when SCAN_K28_5 =>
                if s_wait_cnt = "1111" and s_found_k28_7_pattern = '0' then
                  bit_slip_state <= BITSLIP;
                else
                  if s_rx_data = c_k28_5 and s_found_k28_7_pattern = '0' then
                    s_found_k28_7_pattern <= '1';
                    bit_slip_state        <= SYNC;
                  else
                    s_found_k28_7_pattern <= '0';
                  end if;
                end if;

              when BITSLIP =>
                s_rx_bit_slip  <= '1';
                bit_slip_state <= BITSLIP_EXTENT_ONE;

              when BITSLIP_EXTENT_ONE =>
                s_rx_bit_slip  <= '1';
                bit_slip_state <= IDLE;

              when IDLE =>
                s_rx_bit_slip  <= '0';
                bit_slip_state <= SCAN_K28_5;

              when SYNC =>
                if s_phy_rx_disperr(0) = '1' or s_phy_rx_errdetect(0) = '1' then
                  bit_slip_state        <= SCAN_K28_5;
                  s_found_k28_7_pattern <= '0';
                else
                  bit_slip_state <= SYNC;
                end if;

            end case;
          end if; -- IF DEBUG(3)
        end if; -- RST/CLK
      end process;

    inst_rst_ctl : wr_arria10_e3p1_rst_ctl
      port map (
        clock                 => clk_ref_i,
        reset                 => s_rst_ctl_rst,
        pll_powerdown(0)      => s_rst_ctl_powerdown(0), -- Missing at Intel documentation -> Connection Guidelines for a CPRI PHY Design
        tx_analogreset(0)     => s_rst_ctl_tx_analogreset(0),
        tx_digitalreset(0)    => s_rst_ctl_tx_digitalreset(0),
        tx_ready(0)           => s_rst_ctl_tx_ready(0),
        pll_locked(0)         => s_tx_pll_625m_locked(0),
        pll_select(0)         => s_pll_select(0),
        tx_cal_busy(0)        => s_cal_busy(0),
        rx_analogreset(0)     => s_rst_ctl_rx_analogreset(0),
        rx_digitalreset(0)    => s_rst_ctl_rx_digitalreset(0),
        rx_ready(0)           => s_rst_ctl_rx_ready(0),
        rx_is_lockedtodata(0) => s_phy_rx_is_lockedtodata(0),
        rx_cal_busy(0)        => s_phy_rx_cal_busy(0)
      );

    inst_atx_pll : wr_arria10_e3p1_atx_pll
      port map (
        pll_refclk0   => clk_phy_i,
        pll_powerdown => s_rst_ctl_powerdown(0), -- Missing at Intel documentation -> Connection Guidelines for a CPRI PHY Design
        pll_locked    => s_tx_pll_625m_locked(0),
        tx_serial_clk => s_tx_pll_625m_serial_clk,
        pll_cal_busy  => s_tx_pll_625m_cal_busy
      );

      s_cal_busy(0) <= s_phy_tx_cal_busy(0) or s_tx_pll_625m_cal_busy;
  end generate det_phy;

  phy_rst_ext : if g_use_ext_rst generate
    s_ext_reset <= drop_link_i and debug_i(0); -- TBD: CLOCK CROSSING!
  end generate phy_rst_ext;

  phy_rst_int : if not g_use_ext_rst generate
    s_ext_reset <='0';
  end generate phy_rst_int;

  phy_rst_los : if g_use_sfp_los_rst generate
    s_sfp_los_reset <= sfp_los_i; -- TBD: CLOCK CROSSING!
  end generate phy_rst_los;

  phy_rst_ignore_los : if not g_use_sfp_los_rst generate
    s_sfp_los_reset <= '0';
  end generate phy_rst_ignore_los;

  phy_ext_loop_yes : if g_use_ext_loop generate
    s_loop_en <= loopen_i or debug_i(6); -- TBD: CLOCK CROSSING!
  end generate phy_ext_loop_yes;

  phy_ext_loop_no : if not g_use_ext_loop generate
    s_loop_en <= '0';
  end generate phy_ext_loop_no;

  s_debug_reset <= debug_i(5);
  s_rst_ctl_rst <= s_debug_reset or s_sfp_los_reset or s_ext_reset or s_reset_aligner;

  s_pll_select <= (others => '0');

  -- Additional outputs
  tx_ready_o     <= s_rst_ctl_tx_ready(0);
  rx_ready_o     <= s_rst_ctl_rx_ready(0);
  ready_o        <= (s_rst_ctl_tx_ready(0) and s_rst_ctl_rx_ready(0)) and ((s_patterndetect_ready and debug_i(3)) or (s_found_k28_7_pattern and debug_i(4)));
  tx_disparity_o <= '0';
  tx_enc_err_o   <= '0';
  rx_enc_err_o   <= s_phy_rx_disperr(0) or s_phy_rx_errdetect(0);

  -- remove or set to zero
  debug_o        <= (s_phy_rx_is_lockedtoref(0) and s_phy_rx_is_lockedtodata(0) and s_found_std_idle_pattern and s_found_k28_7_pattern
                    and s_k28_7_cnt(0) and s_k28_7_cnt(1) and s_k28_7_cnt(2) and s_k28_7_cnt(3) and s_rx_non_idle_count(9) and s_rx_unexpected_count(9) and s_tx_non_idle_count(9) and s_tx_unexpected_count(9)) or s_patterndetect_ready or s_rx_idle_missed or s_tx_idle_missed;

end rtl;
