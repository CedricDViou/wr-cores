---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for WR Softcore PLL
---------------------------------------------------------------------------------------
-- File           : spll_wb_slave.vhd
-- Author         : auto-generated by wbgen2 from spll_wb_slave.wb
-- Created        : Thu Dec  3 18:39:19 2015
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE spll_wb_slave.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbgen2_pkg.all;

use work.spll_wbgen2_pkg.all;


entity spll_wb_slave is
  generic (
        g_with_debug_fifo : integer := 1    );
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
    wb_stall_o                               : out    std_logic;
    wb_int_o                                 : out    std_logic;
    irq_tag_i                                : in     std_logic;
    regs_i                                   : in     t_spll_in_registers;
    regs_o                                   : out    t_spll_out_registers
  );
end spll_wb_slave;

architecture syn of spll_wb_slave is

signal spll_eccr_ext_en_int                     : std_logic      ;
signal spll_eccr_ext_ref_pllrst_int             : std_logic      ;
signal spll_occr_out_lock_int                   : std_logic_vector(7 downto 0);
signal spll_deglitch_thr_int                    : std_logic_vector(15 downto 0);
signal spll_dfr_host_rst_n                      : std_logic      ;
signal spll_dfr_host_in_int                     : std_logic_vector(47 downto 0);
signal spll_dfr_host_out_int                    : std_logic_vector(47 downto 0);
signal spll_dfr_host_rdreq_int                  : std_logic      ;
signal spll_dfr_host_rdreq_int_d0               : std_logic      ;
signal spll_trr_rst_n                           : std_logic      ;
signal spll_trr_in_int                          : std_logic_vector(31 downto 0);
signal spll_trr_out_int                         : std_logic_vector(31 downto 0);
signal spll_trr_rdreq_int                       : std_logic      ;
signal spll_trr_rdreq_int_d0                    : std_logic      ;
signal eic_idr_int                              : std_logic_vector(0 downto 0);
signal eic_idr_write_int                        : std_logic      ;
signal eic_ier_int                              : std_logic_vector(0 downto 0);
signal eic_ier_write_int                        : std_logic      ;
signal eic_imr_int                              : std_logic_vector(0 downto 0);
signal eic_isr_clear_int                        : std_logic_vector(0 downto 0);
signal eic_isr_status_int                       : std_logic_vector(0 downto 0);
signal eic_irq_ack_int                          : std_logic_vector(0 downto 0);
signal eic_isr_write_int                        : std_logic      ;
signal spll_dfr_host_full_int                   : std_logic      ;
signal spll_dfr_host_empty_int                  : std_logic      ;
signal spll_dfr_host_usedw_int                  : std_logic_vector(12 downto 0);
signal spll_trr_empty_int                       : std_logic      ;
signal irq_inputs_vector_int                    : std_logic_vector(0 downto 0);
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
-- Some internal signals assignments. For (foreseen) compatibility with other bus standards.
  wrdata_reg <= wb_dat_i;
  bwsel_reg <= wb_sel_i;
  rd_int <= wb_cyc_i and (wb_stb_i and (not wb_we_i));
  wr_int <= wb_cyc_i and (wb_stb_i and wb_we_i);
  allones <= (others => '1');
  allzeros <= (others => '0');
-- 
-- Main register bank access process.
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      ack_sreg <= "0000000000";
      ack_in_progress <= '0';
      rddata_reg <= "00000000000000000000000000000000";
      spll_eccr_ext_en_int <= '0';
      spll_eccr_ext_ref_pllrst_int <= '0';
      regs_o.al_cr_valid_load_o <= '0';
      regs_o.f_dmtd_valid_load_o <= '0';
      regs_o.f_ref_valid_load_o <= '0';
      regs_o.f_ext_valid_load_o <= '0';
      spll_occr_out_lock_int <= "00000000";
      regs_o.rcer_load_o <= '0';
      regs_o.ocer_load_o <= '0';
      regs_o.dac_hpll_wr_o <= '0';
      regs_o.dac_main_value_wr_o <= '0';
      regs_o.dac_main_dac_sel_wr_o <= '0';
      spll_deglitch_thr_int <= "0000000000000000";
      regs_o.dfr_spll_value_wr_o <= '0';
      regs_o.dfr_spll_eos_wr_o <= '0';
      eic_idr_write_int <= '0';
      eic_ier_write_int <= '0';
      eic_isr_write_int <= '0';
      spll_dfr_host_rdreq_int <= '0';
      spll_trr_rdreq_int <= '0';
    elsif rising_edge(clk_sys_i) then
-- advance the ACK generator shift register
      ack_sreg(8 downto 0) <= ack_sreg(9 downto 1);
      ack_sreg(9) <= '0';
      if (ack_in_progress = '1') then
        if (ack_sreg(0) = '1') then
          regs_o.al_cr_valid_load_o <= '0';
          regs_o.f_dmtd_valid_load_o <= '0';
          regs_o.f_ref_valid_load_o <= '0';
          regs_o.f_ext_valid_load_o <= '0';
          regs_o.rcer_load_o <= '0';
          regs_o.ocer_load_o <= '0';
          regs_o.dac_hpll_wr_o <= '0';
          regs_o.dac_main_value_wr_o <= '0';
          regs_o.dac_main_dac_sel_wr_o <= '0';
          regs_o.dfr_spll_value_wr_o <= '0';
          regs_o.dfr_spll_eos_wr_o <= '0';
          eic_idr_write_int <= '0';
          eic_ier_write_int <= '0';
          eic_isr_write_int <= '0';
          ack_in_progress <= '0';
        else
          regs_o.al_cr_valid_load_o <= '0';
          regs_o.f_dmtd_valid_load_o <= '0';
          regs_o.f_ref_valid_load_o <= '0';
          regs_o.f_ext_valid_load_o <= '0';
          regs_o.rcer_load_o <= '0';
          regs_o.ocer_load_o <= '0';
          regs_o.dac_hpll_wr_o <= '0';
          regs_o.dac_main_value_wr_o <= '0';
          regs_o.dac_main_dac_sel_wr_o <= '0';
          regs_o.dfr_spll_value_wr_o <= '0';
          regs_o.dfr_spll_eos_wr_o <= '0';
        end if;
      else
        if ((wb_cyc_i = '1') and (wb_stb_i = '1')) then
          case rwaddr_reg(5 downto 0) is
          when "000000" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(13 downto 8) <= "000000";
            rddata_reg(21 downto 16) <= regs_i.csr_n_ref_i;
            rddata_reg(26 downto 24) <= regs_i.csr_n_out_i;
            rddata_reg(27) <= regs_i.csr_dbg_supported_i;
            rddata_reg(0) <= 'X';
            rddata_reg(1) <= 'X';
            rddata_reg(2) <= 'X';
            rddata_reg(3) <= 'X';
            rddata_reg(4) <= 'X';
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(7) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "000001" => 
            if (wb_we_i = '1') then
              spll_eccr_ext_en_int <= wrdata_reg(0);
              spll_eccr_ext_ref_pllrst_int <= wrdata_reg(31);
            end if;
            rddata_reg(0) <= spll_eccr_ext_en_int;
            rddata_reg(1) <= regs_i.eccr_ext_supported_i;
            rddata_reg(2) <= regs_i.eccr_ext_ref_locked_i;
            rddata_reg(3) <= regs_i.eccr_ext_ref_stopped_i;
            rddata_reg(31) <= spll_eccr_ext_ref_pllrst_int;
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
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "000010" => 
            if (wb_we_i = '1') then
              regs_o.al_cr_valid_load_o <= '1';
            end if;
            rddata_reg(8 downto 0) <= regs_i.al_cr_valid_i;
            rddata_reg(17 downto 9) <= regs_i.al_cr_required_i;
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
          when "000011" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(31 downto 0) <= regs_i.al_cref_i;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "000100" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(31 downto 0) <= regs_i.al_cin_i;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "000101" => 
            if (wb_we_i = '1') then
              regs_o.f_dmtd_valid_load_o <= '1';
            end if;
            rddata_reg(27 downto 0) <= regs_i.f_dmtd_freq_i;
            rddata_reg(28) <= regs_i.f_dmtd_valid_i;
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "000110" => 
            if (wb_we_i = '1') then
              regs_o.f_ref_valid_load_o <= '1';
            end if;
            rddata_reg(27 downto 0) <= regs_i.f_ref_freq_i;
            rddata_reg(28) <= regs_i.f_ref_valid_i;
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "000111" => 
            if (wb_we_i = '1') then
              regs_o.f_ext_valid_load_o <= '1';
            end if;
            rddata_reg(27 downto 0) <= regs_i.f_ext_freq_i;
            rddata_reg(28) <= regs_i.f_ext_valid_i;
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "001000" => 
            if (wb_we_i = '1') then
              spll_occr_out_lock_int <= wrdata_reg(23 downto 16);
            end if;
            rddata_reg(15 downto 8) <= regs_i.occr_out_en_i;
            rddata_reg(23 downto 16) <= spll_occr_out_lock_int;
            rddata_reg(0) <= 'X';
            rddata_reg(1) <= 'X';
            rddata_reg(2) <= 'X';
            rddata_reg(3) <= 'X';
            rddata_reg(4) <= 'X';
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(7) <= 'X';
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
          when "001001" => 
            if (wb_we_i = '1') then
              regs_o.rcer_load_o <= '1';
            end if;
            rddata_reg(31 downto 0) <= regs_i.rcer_i;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "001010" => 
            if (wb_we_i = '1') then
              regs_o.ocer_load_o <= '1';
            end if;
            rddata_reg(7 downto 0) <= regs_i.ocer_i;
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
          when "010000" => 
            if (wb_we_i = '1') then
              regs_o.dac_hpll_wr_o <= '1';
            end if;
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
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "010001" => 
            if (wb_we_i = '1') then
              regs_o.dac_main_value_wr_o <= '1';
              regs_o.dac_main_dac_sel_wr_o <= '1';
            end if;
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
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "010010" => 
            if (wb_we_i = '1') then
              spll_deglitch_thr_int <= wrdata_reg(15 downto 0);
            end if;
            rddata_reg(15 downto 0) <= spll_deglitch_thr_int;
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
              regs_o.dfr_spll_value_wr_o <= '1';
              regs_o.dfr_spll_eos_wr_o <= '1';
            end if;
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
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "011000" => 
            if (wb_we_i = '1') then
              eic_idr_write_int <= '1';
            end if;
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
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "011001" => 
            if (wb_we_i = '1') then
              eic_ier_write_int <= '1';
            end if;
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
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "011010" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(0) <= eic_imr_int(0);
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
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "011011" => 
            if (wb_we_i = '1') then
              eic_isr_write_int <= '1';
            end if;
            rddata_reg(0) <= eic_isr_status_int(0);
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
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "011100" => 
            if (wb_we_i = '1') then
            end if;
            if (spll_dfr_host_rdreq_int_d0 = '0') then
              spll_dfr_host_rdreq_int <= not spll_dfr_host_rdreq_int;
            else
              rddata_reg(31 downto 0) <= spll_dfr_host_out_int(31 downto 0);
              ack_in_progress <= '1';
              ack_sreg(0) <= '1';
            end if;
          when "011101" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(15 downto 0) <= spll_dfr_host_out_int(47 downto 32);
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
          when "011110" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(16) <= spll_dfr_host_full_int;
            rddata_reg(17) <= spll_dfr_host_empty_int;
            rddata_reg(12 downto 0) <= spll_dfr_host_usedw_int;
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
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
          when "011111" => 
            if (wb_we_i = '1') then
            end if;
            if (spll_trr_rdreq_int_d0 = '0') then
              spll_trr_rdreq_int <= not spll_trr_rdreq_int;
            else
              rddata_reg(23 downto 0) <= spll_trr_out_int(23 downto 0);
              rddata_reg(30 downto 24) <= spll_trr_out_int(30 downto 24);
              rddata_reg(31) <= spll_trr_out_int(31);
              ack_in_progress <= '1';
              ack_sreg(0) <= '1';
            end if;
          when "100000" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(17) <= spll_trr_empty_int;
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
-- Number of reference channels (max: 32)
-- Number of output channels (max: 8)
-- Debug queue supported
-- Enable External Clock PLL
  regs_o.eccr_ext_en_o <= spll_eccr_ext_en_int;
-- External Clock Input Available
-- External Clock Reference Present
-- EXT_REF_STOPPED
-- EXT_PLL_RST
  regs_o.eccr_ext_ref_pllrst_o <= spll_eccr_ext_ref_pllrst_int;
-- Aligner sample valid/select on channel
  regs_o.al_cr_valid_o <= wrdata_reg(8 downto 0);
-- Aligner required on channel
-- Aligner reference counter
-- Aligner reference counter
-- FREQ
-- VALID
  regs_o.f_dmtd_valid_o <= wrdata_reg(28);
-- FREQ
-- VALID
  regs_o.f_ref_valid_o <= wrdata_reg(28);
-- FREQ
-- VALID
  regs_o.f_ext_valid_o <= wrdata_reg(28);
-- Output Channel HW enable flag
-- Output Channel locked flag
  regs_o.occr_out_lock_o <= spll_occr_out_lock_int;
-- Reference Channel Enable
  regs_o.rcer_o <= wrdata_reg(31 downto 0);
-- Output Channel Enable
  regs_o.ocer_o <= wrdata_reg(7 downto 0);
-- DAC value
-- pass-through field: DAC value in register: Helper DAC Output
  regs_o.dac_hpll_o <= wrdata_reg(15 downto 0);
-- DAC value
-- pass-through field: DAC value in register: Main DAC Output
  regs_o.dac_main_value_o <= wrdata_reg(15 downto 0);
-- DAC select
-- pass-through field: DAC select in register: Main DAC Output
  regs_o.dac_main_dac_sel_o <= wrdata_reg(19 downto 16);
-- Threshold
  regs_o.deglitch_thr_o <= spll_deglitch_thr_int;
-- Debug Value
-- pass-through field: Debug Value in register: Debug FIFO Register - SPLL side
  regs_o.dfr_spll_value_o <= wrdata_reg(30 downto 0);
-- End-of-Sample
-- pass-through field: End-of-Sample in register: Debug FIFO Register - SPLL side
  regs_o.dfr_spll_eos_o <= wrdata_reg(31);
  genblock_0: if (not (g_with_debug_fifo = 0)) generate
-- extra code for reg/fifo/mem: Debug FIFO Register - Host side
    spll_dfr_host_in_int(31 downto 0) <= regs_i.dfr_host_value_i;
    spll_dfr_host_in_int(47 downto 32) <= regs_i.dfr_host_seq_id_i;
    spll_dfr_host_rst_n <= rst_n_i;
    spll_dfr_host_INST : wbgen2_fifo_sync
      generic map (
        g_size               => 8192,
        g_width              => 48,
        g_usedw_size         => 13
      )
      port map (
        wr_req_i             => regs_i.dfr_host_wr_req_i,
        wr_full_o            => regs_o.dfr_host_wr_full_o,
        wr_empty_o           => regs_o.dfr_host_wr_empty_o,
        wr_usedw_o           => regs_o.dfr_host_wr_usedw_o,
        rd_full_o            => spll_dfr_host_full_int,
        rd_empty_o           => spll_dfr_host_empty_int,
        rd_usedw_o           => spll_dfr_host_usedw_int,
        rd_req_i             => spll_dfr_host_rdreq_int,
        rst_n_i              => spll_dfr_host_rst_n,
        clk_i                => clk_sys_i,
        wr_data_i            => spll_dfr_host_in_int,
        rd_data_o            => spll_dfr_host_out_int
      );
    
  end generate genblock_0;
-- extra code for reg/fifo/mem: Tag Readout Register
  spll_trr_in_int(23 downto 0) <= regs_i.trr_value_i;
  spll_trr_in_int(30 downto 24) <= regs_i.trr_chan_id_i;
  spll_trr_in_int(31) <= regs_i.trr_disc_i;
  spll_trr_rst_n <= rst_n_i;
  spll_trr_INST : wbgen2_fifo_sync
    generic map (
      g_size               => 32,
      g_width              => 32,
      g_usedw_size         => 5
    )
    port map (
      wr_req_i             => regs_i.trr_wr_req_i,
      wr_full_o            => regs_o.trr_wr_full_o,
      wr_empty_o           => regs_o.trr_wr_empty_o,
      rd_empty_o           => spll_trr_empty_int,
      rd_req_i             => spll_trr_rdreq_int,
      rst_n_i              => spll_trr_rst_n,
      clk_i                => clk_sys_i,
      wr_data_i            => spll_trr_in_int,
      rd_data_o            => spll_trr_out_int
    );
  
-- extra code for reg/fifo/mem: Interrupt disable register
  eic_idr_int(0) <= wrdata_reg(0);
-- extra code for reg/fifo/mem: Interrupt enable register
  eic_ier_int(0) <= wrdata_reg(0);
-- extra code for reg/fifo/mem: Interrupt status register
  eic_isr_clear_int(0) <= wrdata_reg(0);
-- extra code for reg/fifo/mem: IRQ_CONTROLLER
  eic_irq_controller_inst : wbgen2_eic
    generic map (
      g_num_interrupts     => 1,
      g_irq00_mode         => 3,
      g_irq01_mode         => 0,
      g_irq02_mode         => 0,
      g_irq03_mode         => 0,
      g_irq04_mode         => 0,
      g_irq05_mode         => 0,
      g_irq06_mode         => 0,
      g_irq07_mode         => 0,
      g_irq08_mode         => 0,
      g_irq09_mode         => 0,
      g_irq0a_mode         => 0,
      g_irq0b_mode         => 0,
      g_irq0c_mode         => 0,
      g_irq0d_mode         => 0,
      g_irq0e_mode         => 0,
      g_irq0f_mode         => 0,
      g_irq10_mode         => 0,
      g_irq11_mode         => 0,
      g_irq12_mode         => 0,
      g_irq13_mode         => 0,
      g_irq14_mode         => 0,
      g_irq15_mode         => 0,
      g_irq16_mode         => 0,
      g_irq17_mode         => 0,
      g_irq18_mode         => 0,
      g_irq19_mode         => 0,
      g_irq1a_mode         => 0,
      g_irq1b_mode         => 0,
      g_irq1c_mode         => 0,
      g_irq1d_mode         => 0,
      g_irq1e_mode         => 0,
      g_irq1f_mode         => 0
    )
    port map (
      clk_i                => clk_sys_i,
      rst_n_i              => rst_n_i,
      irq_i                => irq_inputs_vector_int,
      irq_ack_o            => eic_irq_ack_int,
      reg_imr_o            => eic_imr_int,
      reg_ier_i            => eic_ier_int,
      reg_ier_wr_stb_i     => eic_ier_write_int,
      reg_idr_i            => eic_idr_int,
      reg_idr_wr_stb_i     => eic_idr_write_int,
      reg_isr_o            => eic_isr_status_int,
      reg_isr_i            => eic_isr_clear_int,
      reg_isr_wr_stb_i     => eic_isr_write_int,
      wb_irq_o             => wb_int_o
    );
  
  irq_inputs_vector_int(0) <= irq_tag_i;
-- extra code for reg/fifo/mem: FIFO 'Debug FIFO Register - Host side' data output register 0
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      spll_dfr_host_rdreq_int_d0 <= '0';
    elsif rising_edge(clk_sys_i) then
      spll_dfr_host_rdreq_int_d0 <= spll_dfr_host_rdreq_int;
    end if;
  end process;
  
  
-- extra code for reg/fifo/mem: FIFO 'Debug FIFO Register - Host side' data output register 1
-- extra code for reg/fifo/mem: FIFO 'Tag Readout Register' data output register 0
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      spll_trr_rdreq_int_d0 <= '0';
    elsif rising_edge(clk_sys_i) then
      spll_trr_rdreq_int_d0 <= spll_trr_rdreq_int;
    end if;
  end process;
  
  
  rwaddr_reg <= wb_adr_i;
  wb_stall_o <= (not ack_sreg(0)) and (wb_stb_i and wb_cyc_i);
-- ACK signal generation. Just pass the LSB of ACK counter.
  wb_ack_o <= ack_sreg(0);
end syn;
