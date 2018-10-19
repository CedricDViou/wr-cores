---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for WR Transmission control, status and debug
---------------------------------------------------------------------------------------
-- File           : wr_streamers_wb.vhd
-- Author         : auto-generated by wbgen2 from wr_streamers_wb.wb
-- Created        : Fri Oct 19 19:28:20 2018
-- Version        : 0x00000001
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE wr_streamers_wb.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wr_streamers_wbgen2_pkg.all;


entity wr_streamers_wb is
port (
  rst_n_i                                  : in     std_logic;
  clk_sys_i                                : in     std_logic;
  wb_adr_i                                 : in     std_logic_vector(5 downto 0);
  wb_dat_i                                 : in     std_logic_vector(31 downto 0);
  wb_dat_o                                 : out    std_logic_vector(31 downto 0);
  wb_cyc_i                                 : in     std_logic;
  wb_sel_i                                 : in     std_logic_vector(3 downto 0);
  wb_stb_i                                 : in     std_logic;
  wb_we_i                                  : in     std_logic;
  wb_ack_o                                 : out    std_logic;
  wb_err_o                                 : out    std_logic;
  wb_rty_o                                 : out    std_logic;
  wb_stall_o                               : out    std_logic;
  regs_i                                   : in     t_wr_streamers_in_registers;
  regs_o                                   : out    t_wr_streamers_out_registers
);
end wr_streamers_wb;

architecture syn of wr_streamers_wb is

signal wr_streamers_ver_id_int                  : std_logic_vector(31 downto 0);
signal wr_streamers_sscr1_rst_stats_dly0        : std_logic      ;
signal wr_streamers_sscr1_rst_stats_int         : std_logic      ;
signal wr_streamers_sscr1_rst_seq_id_dly0       : std_logic      ;
signal wr_streamers_sscr1_rst_seq_id_int        : std_logic      ;
signal wr_streamers_sscr1_snapshot_stats_int    : std_logic      ;
signal wr_streamers_tx_cfg0_ethertype_int       : std_logic_vector(15 downto 0);
signal wr_streamers_tx_cfg1_mac_local_lsb_int   : std_logic_vector(31 downto 0);
signal wr_streamers_tx_cfg2_mac_local_msb_int   : std_logic_vector(15 downto 0);
signal wr_streamers_tx_cfg3_mac_target_lsb_int  : std_logic_vector(31 downto 0);
signal wr_streamers_tx_cfg4_mac_target_msb_int  : std_logic_vector(15 downto 0);
signal wr_streamers_tx_cfg5_qtag_ena_int        : std_logic      ;
signal wr_streamers_tx_cfg5_qtag_vid_int        : std_logic_vector(11 downto 0);
signal wr_streamers_tx_cfg5_qtag_prio_int       : std_logic_vector(2 downto 0);
signal wr_streamers_rx_cfg0_ethertype_int       : std_logic_vector(15 downto 0);
signal wr_streamers_rx_cfg0_accept_broadcast_int : std_logic      ;
signal wr_streamers_rx_cfg0_filter_remote_int   : std_logic      ;
signal wr_streamers_rx_cfg1_mac_local_lsb_int   : std_logic_vector(31 downto 0);
signal wr_streamers_rx_cfg2_mac_local_msb_int   : std_logic_vector(15 downto 0);
signal wr_streamers_rx_cfg3_mac_remote_lsb_int  : std_logic_vector(31 downto 0);
signal wr_streamers_rx_cfg4_mac_remote_msb_int  : std_logic_vector(15 downto 0);
signal wr_streamers_rx_cfg5_fixed_latency_int   : std_logic_vector(27 downto 0);
signal wr_streamers_cfg_or_tx_ethtype_int       : std_logic      ;
signal wr_streamers_cfg_or_tx_mac_loc_int       : std_logic      ;
signal wr_streamers_cfg_or_tx_mac_tar_int       : std_logic      ;
signal wr_streamers_cfg_or_tx_qtag_int          : std_logic      ;
signal wr_streamers_cfg_or_rx_ethertype_int     : std_logic      ;
signal wr_streamers_cfg_or_rx_mac_loc_int       : std_logic      ;
signal wr_streamers_cfg_or_rx_mac_rem_int       : std_logic      ;
signal wr_streamers_cfg_or_rx_acc_broadcast_int : std_logic      ;
signal wr_streamers_cfg_or_rx_ftr_remote_int    : std_logic      ;
signal wr_streamers_cfg_or_rx_fix_lat_int       : std_logic      ;
signal wr_streamers_dbg_ctrl_mux_int            : std_logic      ;
signal wr_streamers_dbg_ctrl_start_byte_int     : std_logic_vector(7 downto 0);
signal wr_streamers_rstr_rst_sw_dly0            : std_logic      ;
signal wr_streamers_rstr_rst_sw_int             : std_logic      ;
signal ack_sreg                                 : std_logic_vector(9 downto 0);
signal rddata_reg                               : std_logic_vector(31 downto 0);
signal wrdata_reg                               : std_logic_vector(31 downto 0);
signal bwsel_reg                                : std_logic_vector(3 downto 0);
signal rwaddr_reg                               : std_logic_vector(5 downto 0);
signal ack_in_progress                          : std_logic      ;
signal wr_int                                   : std_logic      ;
signal rd_int                                   : std_logic      ;
signal allones                                  : std_logic_vector(31 downto 0);
signal allzeros                                 : std_logic_vector(31 downto 0);

begin
-- Some internal signals assignments
wrdata_reg <= wb_dat_i;
-- 
-- Main register bank access process.
process (clk_sys_i, rst_n_i)
begin
  if (rst_n_i = '0') then 
    ack_sreg <= "0000000000";
    ack_in_progress <= '0';
    rddata_reg <= "00000000000000000000000000000000";
    wr_streamers_ver_id_int <= "00000000000000000000000000000001";
    wr_streamers_sscr1_rst_stats_int <= '0';
    wr_streamers_sscr1_rst_seq_id_int <= '0';
    wr_streamers_sscr1_snapshot_stats_int <= '0';
    wr_streamers_tx_cfg0_ethertype_int <= "0000000000000000";
    wr_streamers_tx_cfg1_mac_local_lsb_int <= "00000000000000000000000000000000";
    wr_streamers_tx_cfg2_mac_local_msb_int <= "0000000000000000";
    wr_streamers_tx_cfg3_mac_target_lsb_int <= "00000000000000000000000000000000";
    wr_streamers_tx_cfg4_mac_target_msb_int <= "0000000000000000";
    wr_streamers_tx_cfg5_qtag_ena_int <= '0';
    wr_streamers_tx_cfg5_qtag_vid_int <= "000000000000";
    wr_streamers_tx_cfg5_qtag_prio_int <= "000";
    wr_streamers_rx_cfg0_ethertype_int <= "0000000000000000";
    wr_streamers_rx_cfg0_accept_broadcast_int <= '0';
    wr_streamers_rx_cfg0_filter_remote_int <= '0';
    wr_streamers_rx_cfg1_mac_local_lsb_int <= "00000000000000000000000000000000";
    wr_streamers_rx_cfg2_mac_local_msb_int <= "0000000000000000";
    wr_streamers_rx_cfg3_mac_remote_lsb_int <= "00000000000000000000000000000000";
    wr_streamers_rx_cfg4_mac_remote_msb_int <= "0000000000000000";
    wr_streamers_rx_cfg5_fixed_latency_int <= "0000000000000000000000000000";
    wr_streamers_cfg_or_tx_ethtype_int <= '0';
    wr_streamers_cfg_or_tx_mac_loc_int <= '0';
    wr_streamers_cfg_or_tx_mac_tar_int <= '0';
    wr_streamers_cfg_or_tx_qtag_int <= '0';
    wr_streamers_cfg_or_rx_ethertype_int <= '0';
    wr_streamers_cfg_or_rx_mac_loc_int <= '0';
    wr_streamers_cfg_or_rx_mac_rem_int <= '0';
    wr_streamers_cfg_or_rx_acc_broadcast_int <= '0';
    wr_streamers_cfg_or_rx_ftr_remote_int <= '0';
    wr_streamers_cfg_or_rx_fix_lat_int <= '0';
    wr_streamers_dbg_ctrl_mux_int <= '0';
    wr_streamers_dbg_ctrl_start_byte_int <= "00000000";
    wr_streamers_rstr_rst_sw_int <= '0';
  elsif rising_edge(clk_sys_i) then
-- advance the ACK generator shift register
    ack_sreg(8 downto 0) <= ack_sreg(9 downto 1);
    ack_sreg(9) <= '0';
    if (ack_in_progress = '1') then
      if (ack_sreg(0) = '1') then
        wr_streamers_sscr1_rst_stats_int <= '0';
        wr_streamers_sscr1_rst_seq_id_int <= '0';
        wr_streamers_rstr_rst_sw_int <= '0';
        ack_in_progress <= '0';
      else
      end if;
    else
      if ((wb_cyc_i = '1') and (wb_stb_i = '1')) then
        case rwaddr_reg(5 downto 0) is
        when "000000" => 
          if (wb_we_i = '1') then
            wr_streamers_ver_id_int <= wrdata_reg(31 downto 0);
          end if;
          rddata_reg(31 downto 0) <= wr_streamers_ver_id_int;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "000001" => 
          if (wb_we_i = '1') then
            wr_streamers_sscr1_rst_stats_int <= wrdata_reg(0);
            wr_streamers_sscr1_rst_seq_id_int <= wrdata_reg(1);
            wr_streamers_sscr1_snapshot_stats_int <= wrdata_reg(2);
          end if;
          rddata_reg(0) <= '0';
          rddata_reg(1) <= '0';
          rddata_reg(2) <= wr_streamers_sscr1_snapshot_stats_int;
          rddata_reg(3) <= regs_i.sscr1_rx_latency_acc_overflow_i;
          rddata_reg(31 downto 4) <= regs_i.sscr1_rst_ts_cyc_i;
          ack_sreg(2) <= '1';
          ack_in_progress <= '1';
        when "000010" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.sscr2_rst_ts_tai_lsb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "000011" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(7 downto 0) <= regs_i.sscr3_rst_ts_tai_msb_i;
          rddata_reg(8) <= 'X';
          rddata_reg(9) <= 'X';
          rddata_reg(10) <= 'X';
          rddata_reg(11) <= 'X';
          rddata_reg(12) <= 'X';
          rddata_reg(13) <= 'X';
          rddata_reg(14) <= 'X';
          rddata_reg(15) <= 'X';
          rddata_reg(16) <= 'X';
          rddata_reg(17) <= 'X';
          rddata_reg(18) <= 'X';
          rddata_reg(19) <= 'X';
          rddata_reg(20) <= 'X';
          rddata_reg(21) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(24) <= 'X';
          rddata_reg(25) <= 'X';
          rddata_reg(26) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "000100" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(27 downto 0) <= regs_i.rx_stat0_rx_latency_max_i;
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "000101" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(27 downto 0) <= regs_i.rx_stat1_rx_latency_min_i;
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "000110" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.tx_stat2_tx_sent_cnt_lsb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "000111" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.tx_stat3_tx_sent_cnt_msb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "001000" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.rx_stat4_rx_rcvd_cnt_lsb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "001001" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.rx_stat5_rx_rcvd_cnt_msb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "001010" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.rx_stat6_rx_loss_cnt_lsb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "001011" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.rx_stat7_rx_loss_cnt_msb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "001100" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.rx_stat8_rx_lost_block_cnt_lsb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "001101" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.rx_stat9_rx_lost_block_cnt_msb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "001110" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.rx_stat10_rx_latency_acc_lsb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "001111" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.rx_stat11_rx_latency_acc_msb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "010000" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.rx_stat12_rx_latency_acc_cnt_lsb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "010001" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.rx_stat13_rx_latency_acc_cnt_msb_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "010010" => 
          if (wb_we_i = '1') then
            wr_streamers_tx_cfg0_ethertype_int <= wrdata_reg(15 downto 0);
          end if;
          rddata_reg(15 downto 0) <= wr_streamers_tx_cfg0_ethertype_int;
          rddata_reg(16) <= 'X';
          rddata_reg(17) <= 'X';
          rddata_reg(18) <= 'X';
          rddata_reg(19) <= 'X';
          rddata_reg(20) <= 'X';
          rddata_reg(21) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(24) <= 'X';
          rddata_reg(25) <= 'X';
          rddata_reg(26) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "010011" => 
          if (wb_we_i = '1') then
            wr_streamers_tx_cfg1_mac_local_lsb_int <= wrdata_reg(31 downto 0);
          end if;
          rddata_reg(31 downto 0) <= wr_streamers_tx_cfg1_mac_local_lsb_int;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "010100" => 
          if (wb_we_i = '1') then
            wr_streamers_tx_cfg2_mac_local_msb_int <= wrdata_reg(15 downto 0);
          end if;
          rddata_reg(15 downto 0) <= wr_streamers_tx_cfg2_mac_local_msb_int;
          rddata_reg(16) <= 'X';
          rddata_reg(17) <= 'X';
          rddata_reg(18) <= 'X';
          rddata_reg(19) <= 'X';
          rddata_reg(20) <= 'X';
          rddata_reg(21) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(24) <= 'X';
          rddata_reg(25) <= 'X';
          rddata_reg(26) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "010101" => 
          if (wb_we_i = '1') then
            wr_streamers_tx_cfg3_mac_target_lsb_int <= wrdata_reg(31 downto 0);
          end if;
          rddata_reg(31 downto 0) <= wr_streamers_tx_cfg3_mac_target_lsb_int;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "010110" => 
          if (wb_we_i = '1') then
            wr_streamers_tx_cfg4_mac_target_msb_int <= wrdata_reg(15 downto 0);
          end if;
          rddata_reg(15 downto 0) <= wr_streamers_tx_cfg4_mac_target_msb_int;
          rddata_reg(16) <= 'X';
          rddata_reg(17) <= 'X';
          rddata_reg(18) <= 'X';
          rddata_reg(19) <= 'X';
          rddata_reg(20) <= 'X';
          rddata_reg(21) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(24) <= 'X';
          rddata_reg(25) <= 'X';
          rddata_reg(26) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "010111" => 
          if (wb_we_i = '1') then
            wr_streamers_tx_cfg5_qtag_ena_int <= wrdata_reg(0);
            wr_streamers_tx_cfg5_qtag_vid_int <= wrdata_reg(19 downto 8);
            wr_streamers_tx_cfg5_qtag_prio_int <= wrdata_reg(26 downto 24);
          end if;
          rddata_reg(0) <= wr_streamers_tx_cfg5_qtag_ena_int;
          rddata_reg(19 downto 8) <= wr_streamers_tx_cfg5_qtag_vid_int;
          rddata_reg(26 downto 24) <= wr_streamers_tx_cfg5_qtag_prio_int;
          rddata_reg(1) <= 'X';
          rddata_reg(2) <= 'X';
          rddata_reg(3) <= 'X';
          rddata_reg(4) <= 'X';
          rddata_reg(5) <= 'X';
          rddata_reg(6) <= 'X';
          rddata_reg(7) <= 'X';
          rddata_reg(20) <= 'X';
          rddata_reg(21) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "011000" => 
          if (wb_we_i = '1') then
            wr_streamers_rx_cfg0_ethertype_int <= wrdata_reg(15 downto 0);
            wr_streamers_rx_cfg0_accept_broadcast_int <= wrdata_reg(16);
            wr_streamers_rx_cfg0_filter_remote_int <= wrdata_reg(17);
          end if;
          rddata_reg(15 downto 0) <= wr_streamers_rx_cfg0_ethertype_int;
          rddata_reg(16) <= wr_streamers_rx_cfg0_accept_broadcast_int;
          rddata_reg(17) <= wr_streamers_rx_cfg0_filter_remote_int;
          rddata_reg(18) <= 'X';
          rddata_reg(19) <= 'X';
          rddata_reg(20) <= 'X';
          rddata_reg(21) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(24) <= 'X';
          rddata_reg(25) <= 'X';
          rddata_reg(26) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "011001" => 
          if (wb_we_i = '1') then
            wr_streamers_rx_cfg1_mac_local_lsb_int <= wrdata_reg(31 downto 0);
          end if;
          rddata_reg(31 downto 0) <= wr_streamers_rx_cfg1_mac_local_lsb_int;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "011010" => 
          if (wb_we_i = '1') then
            wr_streamers_rx_cfg2_mac_local_msb_int <= wrdata_reg(15 downto 0);
          end if;
          rddata_reg(15 downto 0) <= wr_streamers_rx_cfg2_mac_local_msb_int;
          rddata_reg(16) <= 'X';
          rddata_reg(17) <= 'X';
          rddata_reg(18) <= 'X';
          rddata_reg(19) <= 'X';
          rddata_reg(20) <= 'X';
          rddata_reg(21) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(24) <= 'X';
          rddata_reg(25) <= 'X';
          rddata_reg(26) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "011011" => 
          if (wb_we_i = '1') then
            wr_streamers_rx_cfg3_mac_remote_lsb_int <= wrdata_reg(31 downto 0);
          end if;
          rddata_reg(31 downto 0) <= wr_streamers_rx_cfg3_mac_remote_lsb_int;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "011100" => 
          if (wb_we_i = '1') then
            wr_streamers_rx_cfg4_mac_remote_msb_int <= wrdata_reg(15 downto 0);
          end if;
          rddata_reg(15 downto 0) <= wr_streamers_rx_cfg4_mac_remote_msb_int;
          rddata_reg(16) <= 'X';
          rddata_reg(17) <= 'X';
          rddata_reg(18) <= 'X';
          rddata_reg(19) <= 'X';
          rddata_reg(20) <= 'X';
          rddata_reg(21) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(24) <= 'X';
          rddata_reg(25) <= 'X';
          rddata_reg(26) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "011101" => 
          if (wb_we_i = '1') then
            wr_streamers_rx_cfg5_fixed_latency_int <= wrdata_reg(27 downto 0);
          end if;
          rddata_reg(27 downto 0) <= wr_streamers_rx_cfg5_fixed_latency_int;
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "011110" => 
          if (wb_we_i = '1') then
            wr_streamers_cfg_or_tx_ethtype_int <= wrdata_reg(0);
            wr_streamers_cfg_or_tx_mac_loc_int <= wrdata_reg(1);
            wr_streamers_cfg_or_tx_mac_tar_int <= wrdata_reg(2);
            wr_streamers_cfg_or_tx_qtag_int <= wrdata_reg(3);
            wr_streamers_cfg_or_rx_ethertype_int <= wrdata_reg(16);
            wr_streamers_cfg_or_rx_mac_loc_int <= wrdata_reg(17);
            wr_streamers_cfg_or_rx_mac_rem_int <= wrdata_reg(18);
            wr_streamers_cfg_or_rx_acc_broadcast_int <= wrdata_reg(19);
            wr_streamers_cfg_or_rx_ftr_remote_int <= wrdata_reg(20);
            wr_streamers_cfg_or_rx_fix_lat_int <= wrdata_reg(21);
          end if;
          rddata_reg(0) <= wr_streamers_cfg_or_tx_ethtype_int;
          rddata_reg(1) <= wr_streamers_cfg_or_tx_mac_loc_int;
          rddata_reg(2) <= wr_streamers_cfg_or_tx_mac_tar_int;
          rddata_reg(3) <= wr_streamers_cfg_or_tx_qtag_int;
          rddata_reg(16) <= wr_streamers_cfg_or_rx_ethertype_int;
          rddata_reg(17) <= wr_streamers_cfg_or_rx_mac_loc_int;
          rddata_reg(18) <= wr_streamers_cfg_or_rx_mac_rem_int;
          rddata_reg(19) <= wr_streamers_cfg_or_rx_acc_broadcast_int;
          rddata_reg(20) <= wr_streamers_cfg_or_rx_ftr_remote_int;
          rddata_reg(21) <= wr_streamers_cfg_or_rx_fix_lat_int;
          rddata_reg(4) <= 'X';
          rddata_reg(5) <= 'X';
          rddata_reg(6) <= 'X';
          rddata_reg(7) <= 'X';
          rddata_reg(8) <= 'X';
          rddata_reg(9) <= 'X';
          rddata_reg(10) <= 'X';
          rddata_reg(11) <= 'X';
          rddata_reg(12) <= 'X';
          rddata_reg(13) <= 'X';
          rddata_reg(14) <= 'X';
          rddata_reg(15) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(24) <= 'X';
          rddata_reg(25) <= 'X';
          rddata_reg(26) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "011111" => 
          if (wb_we_i = '1') then
            wr_streamers_dbg_ctrl_mux_int <= wrdata_reg(0);
            wr_streamers_dbg_ctrl_start_byte_int <= wrdata_reg(15 downto 8);
          end if;
          rddata_reg(0) <= wr_streamers_dbg_ctrl_mux_int;
          rddata_reg(15 downto 8) <= wr_streamers_dbg_ctrl_start_byte_int;
          rddata_reg(1) <= 'X';
          rddata_reg(2) <= 'X';
          rddata_reg(3) <= 'X';
          rddata_reg(4) <= 'X';
          rddata_reg(5) <= 'X';
          rddata_reg(6) <= 'X';
          rddata_reg(7) <= 'X';
          rddata_reg(16) <= 'X';
          rddata_reg(17) <= 'X';
          rddata_reg(18) <= 'X';
          rddata_reg(19) <= 'X';
          rddata_reg(20) <= 'X';
          rddata_reg(21) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(24) <= 'X';
          rddata_reg(25) <= 'X';
          rddata_reg(26) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "100000" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.dbg_data_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "100001" => 
          if (wb_we_i = '1') then
          end if;
          rddata_reg(31 downto 0) <= regs_i.dummy_dummy_i;
          ack_sreg(0) <= '1';
          ack_in_progress <= '1';
        when "100010" => 
          if (wb_we_i = '1') then
            wr_streamers_rstr_rst_sw_int <= wrdata_reg(0);
          end if;
          rddata_reg(0) <= '0';
          rddata_reg(0) <= 'X';
          rddata_reg(1) <= 'X';
          rddata_reg(2) <= 'X';
          rddata_reg(3) <= 'X';
          rddata_reg(4) <= 'X';
          rddata_reg(5) <= 'X';
          rddata_reg(6) <= 'X';
          rddata_reg(7) <= 'X';
          rddata_reg(8) <= 'X';
          rddata_reg(9) <= 'X';
          rddata_reg(10) <= 'X';
          rddata_reg(11) <= 'X';
          rddata_reg(12) <= 'X';
          rddata_reg(13) <= 'X';
          rddata_reg(14) <= 'X';
          rddata_reg(15) <= 'X';
          rddata_reg(16) <= 'X';
          rddata_reg(17) <= 'X';
          rddata_reg(18) <= 'X';
          rddata_reg(19) <= 'X';
          rddata_reg(20) <= 'X';
          rddata_reg(21) <= 'X';
          rddata_reg(22) <= 'X';
          rddata_reg(23) <= 'X';
          rddata_reg(24) <= 'X';
          rddata_reg(25) <= 'X';
          rddata_reg(26) <= 'X';
          rddata_reg(27) <= 'X';
          rddata_reg(28) <= 'X';
          rddata_reg(29) <= 'X';
          rddata_reg(30) <= 'X';
          rddata_reg(31) <= 'X';
          ack_sreg(2) <= '1';
          ack_in_progress <= '1';
        when others =>
-- prevent the slave from hanging the bus on invalid address
          ack_in_progress <= '1';
          ack_sreg(0) <= '1';
        end case;
      end if;
    end if;
  end if;
end process;


-- Drive the data output bus
wb_dat_o <= rddata_reg;
-- Version identifier
regs_o.ver_id_o <= wr_streamers_ver_id_int;
-- Reset statistics
process (clk_sys_i, rst_n_i)
begin
  if (rst_n_i = '0') then 
    wr_streamers_sscr1_rst_stats_dly0 <= '0';
    regs_o.sscr1_rst_stats_o <= '0';
  elsif rising_edge(clk_sys_i) then
    wr_streamers_sscr1_rst_stats_dly0 <= wr_streamers_sscr1_rst_stats_int;
    regs_o.sscr1_rst_stats_o <= wr_streamers_sscr1_rst_stats_int and (not wr_streamers_sscr1_rst_stats_dly0);
  end if;
end process;


-- Reset tx seq id
process (clk_sys_i, rst_n_i)
begin
  if (rst_n_i = '0') then 
    wr_streamers_sscr1_rst_seq_id_dly0 <= '0';
    regs_o.sscr1_rst_seq_id_o <= '0';
  elsif rising_edge(clk_sys_i) then
    wr_streamers_sscr1_rst_seq_id_dly0 <= wr_streamers_sscr1_rst_seq_id_int;
    regs_o.sscr1_rst_seq_id_o <= wr_streamers_sscr1_rst_seq_id_int and (not wr_streamers_sscr1_rst_seq_id_dly0);
  end if;
end process;


-- Snapshot statistics
regs_o.sscr1_snapshot_stats_o <= wr_streamers_sscr1_snapshot_stats_int;
-- Latency accumulator overflow
-- Reset timestamp cycles
-- Reset timestamp 32 LSB of TAI
-- Reset timestamp 8 MSB of TAI
-- WR Streamer frame latency
-- WR Streamer frame latency
-- WR Streamer frame sent count (LSB)
-- WR Streamer frame sent count (MSB)
-- WR Streamer frame received count (LSB)
-- WR Streamer frame received count (MSB)
-- WR Streamer frame loss count (LSB)
-- WR Streamer frame loss count (MSB)
-- WR Streamer block loss count (LSB)
-- WR Streamer block loss count (MSB)
-- WR Streamer frame latency (LSB)
-- WR Streamer frame latency (MSB)
-- WR Streamer frame latency counter (LSB)
-- WR Streamer frame latency counter (MSB)
-- Ethertype
regs_o.tx_cfg0_ethertype_o <= wr_streamers_tx_cfg0_ethertype_int;
-- MAC Local LSB
regs_o.tx_cfg1_mac_local_lsb_o <= wr_streamers_tx_cfg1_mac_local_lsb_int;
-- MAC Local MSB
regs_o.tx_cfg2_mac_local_msb_o <= wr_streamers_tx_cfg2_mac_local_msb_int;
-- MAC Target LSB
regs_o.tx_cfg3_mac_target_lsb_o <= wr_streamers_tx_cfg3_mac_target_lsb_int;
-- MAC Target MSB
regs_o.tx_cfg4_mac_target_msb_o <= wr_streamers_tx_cfg4_mac_target_msb_int;
-- Enable tagging with Qtags
regs_o.tx_cfg5_qtag_ena_o <= wr_streamers_tx_cfg5_qtag_ena_int;
-- VLAN ID
regs_o.tx_cfg5_qtag_vid_o <= wr_streamers_tx_cfg5_qtag_vid_int;
-- Priority
regs_o.tx_cfg5_qtag_prio_o <= wr_streamers_tx_cfg5_qtag_prio_int;
-- Ethertype
regs_o.rx_cfg0_ethertype_o <= wr_streamers_rx_cfg0_ethertype_int;
-- Accept Broadcast
regs_o.rx_cfg0_accept_broadcast_o <= wr_streamers_rx_cfg0_accept_broadcast_int;
-- Filter Remote
regs_o.rx_cfg0_filter_remote_o <= wr_streamers_rx_cfg0_filter_remote_int;
-- MAC Local LSB
regs_o.rx_cfg1_mac_local_lsb_o <= wr_streamers_rx_cfg1_mac_local_lsb_int;
-- MAC Local MSB
regs_o.rx_cfg2_mac_local_msb_o <= wr_streamers_rx_cfg2_mac_local_msb_int;
-- MAC Remote LSB
regs_o.rx_cfg3_mac_remote_lsb_o <= wr_streamers_rx_cfg3_mac_remote_lsb_int;
-- MAC Remote MSB
regs_o.rx_cfg4_mac_remote_msb_o <= wr_streamers_rx_cfg4_mac_remote_msb_int;
-- Fixed Latency
regs_o.rx_cfg5_fixed_latency_o <= wr_streamers_rx_cfg5_fixed_latency_int;
-- Tx Ethertype
regs_o.cfg_or_tx_ethtype_o <= wr_streamers_cfg_or_tx_ethtype_int;
-- Tx MAC Local
regs_o.cfg_or_tx_mac_loc_o <= wr_streamers_cfg_or_tx_mac_loc_int;
-- Tx MAC Target
regs_o.cfg_or_tx_mac_tar_o <= wr_streamers_cfg_or_tx_mac_tar_int;
-- QTAG
regs_o.cfg_or_tx_qtag_o <= wr_streamers_cfg_or_tx_qtag_int;
-- Rx Ethertype
regs_o.cfg_or_rx_ethertype_o <= wr_streamers_cfg_or_rx_ethertype_int;
-- Rx MAC Local
regs_o.cfg_or_rx_mac_loc_o <= wr_streamers_cfg_or_rx_mac_loc_int;
-- Rx MAC Remote
regs_o.cfg_or_rx_mac_rem_o <= wr_streamers_cfg_or_rx_mac_rem_int;
-- Rx Accept Broadcast
regs_o.cfg_or_rx_acc_broadcast_o <= wr_streamers_cfg_or_rx_acc_broadcast_int;
-- Rx Filter Remote
regs_o.cfg_or_rx_ftr_remote_o <= wr_streamers_cfg_or_rx_ftr_remote_int;
-- Rx Fixed Latency 
regs_o.cfg_or_rx_fix_lat_o <= wr_streamers_cfg_or_rx_fix_lat_int;
-- Debug Tx (0) or Rx (1)
regs_o.dbg_ctrl_mux_o <= wr_streamers_dbg_ctrl_mux_int;
-- Debug Start byte
regs_o.dbg_ctrl_start_byte_o <= wr_streamers_dbg_ctrl_start_byte_int;
-- Debug content
-- DUMMY value to read
-- Software reset streamers
process (clk_sys_i, rst_n_i)
begin
  if (rst_n_i = '0') then 
    wr_streamers_rstr_rst_sw_dly0 <= '0';
    regs_o.rstr_rst_sw_o <= '0';
  elsif rising_edge(clk_sys_i) then
    wr_streamers_rstr_rst_sw_dly0 <= wr_streamers_rstr_rst_sw_int;
    regs_o.rstr_rst_sw_o <= wr_streamers_rstr_rst_sw_int and (not wr_streamers_rstr_rst_sw_dly0);
  end if;
end process;


rwaddr_reg <= wb_adr_i;
wb_stall_o <= (not ack_sreg(0)) and (wb_stb_i and wb_cyc_i);
wb_err_o <= '0';
wb_rty_o <= '0';
-- ACK signal generation. Just pass the LSB of ACK counter.
wb_ack_o <= ack_sreg(0);
end syn;
