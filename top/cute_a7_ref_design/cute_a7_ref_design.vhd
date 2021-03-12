-------------------------------------------------------------------------------
-- Title      : WRPC reference design for cuteA7
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : cute_a7_ref_design.vhd
-- Author(s)  : Hongming Li <lihm.thu@foxmail.com>
--              Grzegorz Daniluk <grzegorz.daniluk@cern.ch>
-- Company    : Tsinghua Univ. (DEP),CERN
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level file for the WRPC reference design on the CUTE.
--
-- This is a reference top HDL that instanciates the WR PTP Core together with
-- its peripherals to be run on a CUTE board.
--
-- There are two main usecases for this HDL file:
-- * let new users easily synthesize a WR PTP Core bitstream that can be run on
--   reference hardware
-- * provide a reference top HDL file showing how the WRPC can be instantiated
--   in HDL projects.
--
-- CUTE:  https://www.ohwr.org/projects/cute-wr-dp
--
-------------------------------------------------------------------------------
-- Copyright (c) 2018 CERN
-------------------------------------------------------------------------------
-- GNU LESSER GENERAL PUBLIC LICENSE
--
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License,or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful,but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not,download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wishbone_pkg.all;
use work.wr_fabric_pkg.all;
use work.endpoint_pkg.all;
use work.streamers_pkg.all;
use work.wr_xilinx_pkg.all;
use work.wr_board_pkg.all;
use work.wishbone_pkg.all;
use work.wr_cute_a7_pkg.all;
use work.etherbone_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity cute_a7_ref_design is
generic(
  -- project name, NORMAL
    g_project_name : string := "NORMAL";
  -- g_gtrefclk_src is 4bits integer
  -- each bit represents GTP ref clock source of each channel(phy)
  -- bit '0' selects PLL0(REF0)
  -- bit '1' selects PLL1(REF1)
    g_gtrefclk_src  : std_logic_vector(3 downto 0):=(others=>'1');
  -- g_ref_clk_sel is 4bits integer
  -- each bit represents the clk_ref_o source of each channel(phy)
  -- bit '0' selects TXOUT
  -- bit '1' selects (GTP ref clock/2)
    g_ref_clk_sel   : std_logic_vector(3 downto 0):=(others=>'1');
    g_num_output_clks  : integer := 2;
    g_with_10M_output : boolean := true;
    g_num_phys : integer := 2;
    g_fabric_iface : t_board_fabric_iface := ETHERBONE;
    g_dpram_initf : string := "../../../../bin/wrpc/wrc_phy16.bram"
);
port(
--    HOLD                : in    std_logic;
    VER0                  : in    std_logic;
    VER1                  : in    std_logic;
    VER2                  : in    std_logic;
    ONE_WIRE              : inout std_logic;
    CLK_62M5_DMTD         : in    std_logic;
    FPGA_GCLK_P           : in    std_logic;
    FPGA_GCLK_N           : in    std_logic;
    MGTREFCLK1_P          : in    std_logic;
    MGTREFCLK1_N          : in    std_logic;
    OE_125M               : out   std_logic;
    MGTREFCLK0_P          : in    std_logic;
    MGTREFCLK0_N          : in    std_logic;

    DAC_LDAC_N            : out   std_logic;
    DAC_SCLK              : out   std_logic;
    DAC_SYNC_N            : out   std_logic;
    DAC_SDI               : out   std_logic;
    DAC_SDO               : in    std_logic;

    DAC_DMTD_LDAC_N       : out   std_logic;
    DAC_DMTD_SCLK         : out   std_logic;
    DAC_DMTD_SYNC_N       : out   std_logic;
    DAC_DMTD_SDI          : out   std_logic;
    DAC_DMTD_SDO          : in    std_logic;

    -------------------------------------------------------------------------
    -- GTP0 pins
    -------------------------------------------------------------------------
    -- SFP_RATE_SELECT       : out   std_logic_vector(1 downto 0);
    SFP_DISABLE_O         : out   std_logic_vector(1 downto 0);
    SFP_O_N               : out   std_logic_vector(1 downto 0);
    SFP_O_P               : out   std_logic_vector(1 downto 0);
    SFP_I_N               : in    std_logic_vector(1 downto 0);
    SFP_I_P               : in    std_logic_vector(1 downto 0);
    SFP_FAULT_I           : in    std_logic_vector(1 downto 0);
    SFP_LOS_I             : in    std_logic_vector(1 downto 0);
    SFP_MOD_DEF0_I        : in    std_logic_vector(1 downto 0);
    SFP_MOD_DEF1_IO       : inout std_logic_vector(1 downto 0);
    SFP_MOD_DEF2_IO       : inout std_logic_vector(1 downto 0);

    led_act_o             : out   std_logic_vector(1 downto 0);
    led_link_o            : out   std_logic_vector(1 downto 0);

    RX                    : in    std_logic;
    TX                    : out   std_logic;
    TEST                  : out   std_logic;
    -- CLK_25M_BAK           : in    std_logic;

    SYNC_DATA0_N          : out   std_logic;
    SYNC_DATA0_P          : out   std_logic;
    SYNC_DATA1_N          : out   std_logic;
    SYNC_DATA1_P          : out   std_logic;
    DELAY_EN              : out   std_logic;
    DELAY_SCLK            : out   std_logic;
    DELAY_SLOAD           : out   std_logic;
    DELAY_SDIN            : out   std_logic;

    QSPI_CS               : out   std_logic;
    QSPI_DQ0              : out   std_logic;
    QSPI_DQ1              : in    std_logic;
    --QSPI_DQ2              : in    std_logic
    --QSPI_DQ3              : in    std_logic

    ------------------------------------------
    -- AD9516 SPI
    ------------------------------------------
    PLL_CS                : out   std_logic;
    PLL_REFSEL            : out   std_logic;
    PLL_RESET             : out   std_logic;
    PLL_SCLK              : out   std_logic;
    PLL_SDO               : out   std_logic;
    PLL_SYNC              : out   std_logic;
    PLL_LOCK              : in    std_logic;
    PLL_SDI               : in    std_logic;
    PLL_STAT              : in    std_logic
);
end cute_a7_ref_design;

architecture rtl of cute_a7_ref_design is

    -- support AD5683
    component cute_a7_serial_dac_arb is
    generic(
        g_invert_sclk    : boolean;
        g_num_data_bits  : integer;
        g_num_extra_bits : integer);
    port(
        clk_i   : in std_logic;
        rst_n_i : in std_logic;
        val_i  : in std_logic_vector(g_num_data_bits-1 downto 0);
        load_i : in std_logic;
        dac_ldac_n_o : out std_logic;
        dac_clr_n_o  : out std_logic;
        dac_sync_n_o : out std_logic;
        dac_sclk_o   : out std_logic;
        dac_din_o    : out std_logic);
    end component cute_a7_serial_dac_arb;

    component reset_gen
      port (
        clk_i            : in  std_logic;
        rst_button_n_a_i : in  std_logic;
        rst_pll_locked_i : in  std_logic;
        rst_n_o          : out std_logic);
    end component;

    signal VERSION           : std_logic_vector(2 downto 0);
    ------------------------------------------------------------------------------
    -- Constants declaration
    ------------------------------------------------------------------------------
    signal local_reset_n     : std_logic;
    signal pll_reset_n       : std_logic;
    signal pll_done          : std_logic;

    signal pllout_fb_ddmtd   : std_logic;
    signal clk_dmtd          : std_logic;
    signal clk_dmtd_i        : std_logic;
    signal clk_pll_dmtd_fb   : std_logic;
    signal clk_pll_dmtd_o    : std_logic;
    signal clk_sys           : std_logic;
    signal clk_ref           : std_logic_vector(g_num_phys-1 downto 0);
    signal clk_ref_locked    : std_logic_vector(g_num_phys-1 downto 0);
    signal clk_serdes        : std_logic;
    signal clk_serdes_i      : std_logic;

    signal sfp_scl_o         : std_logic_vector(g_num_phys-1 downto 0);
    signal sfp_scl_i         : std_logic_vector(g_num_phys-1 downto 0);
    signal sfp_sda_o         : std_logic_vector(g_num_phys-1 downto 0);
    signal sfp_sda_i         : std_logic_vector(g_num_phys-1 downto 0);
    signal sfp_det           : std_logic_vector(g_num_phys-1 downto 0);
    
    signal flash_ncs_o       : std_logic;
    signal flash_qspi_dq0    : std_logic;   
    signal flash_qspi_dq1    : std_logic;   
    signal dac_main_load     : std_logic;
    signal dac_ddmtd_load    : std_logic;
    signal dac_main_data     : std_logic_vector(15 downto 0);
    signal dac_ddmtd_data    : std_logic_vector(15 downto 0);

    signal onewire_in        : std_logic_vector(1 downto 0);
    signal onewire_en        : std_logic_vector(1 downto 0);

    signal uart_txd_o        : std_logic;
    signal uart_rxd_i        : std_logic;
    signal led_act           : std_logic_vector(g_num_phys-1 downto 0);
    signal led_link          : std_logic_vector(g_num_phys-1 downto 0);
    signal pps               : std_logic;
    signal pps_led           : std_logic;
    signal pps_csync         : std_logic;
    signal link_ok           : std_logic_vector(g_num_phys-1 downto 0);
    signal sync_data_p_o     : std_logic;
    signal sync_data_n_o     : std_logic;
    signal tm_time_valid     : std_logic;

    signal phy16_to_wrc      : t_phy_16bits_to_wrc_array(g_num_phys-1 downto 0);
    signal phy16_from_wrc    : t_phy_16bits_from_wrc_array(g_num_phys-1 downto 0);

    signal delay_en_o        : std_logic;
    signal delay_sclk_o      : std_logic;
    signal delay_sdin_o      : std_logic;
    signal delay_sload_o     : std_logic;
    
    signal wb_slave_in  : t_wishbone_slave_in;
    signal wb_slave_out : t_wishbone_slave_out;

    signal wb_eth_master_out : t_wishbone_master_out;
    signal wb_eth_master_in  : t_wishbone_master_in;

begin

    cmp_clk_dmtd_i : IBUFG
    port map (
        O => clk_dmtd,
        I => CLK_62M5_DMTD);

    cmp_clk_serdes : IBUFGDS
    generic map (
        DIFF_TERM    => true,     -- Differential Termination
        IBUF_LOW_PWR => false,    -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        IOSTANDARD   => "DEFAULT"
    )
    port map (
        O  => clk_serdes,
        I  => FPGA_GCLK_P,
        IB => FPGA_GCLK_N
    );

    cmp_clk_serdes_buf_i : BUFG
    port map (
      O => clk_serdes_i,
      I => clk_serdes
    );

    u_reset_gen: reset_gen
    port map (
        clk_i            => clk_dmtd,
        rst_button_n_a_i => '1',
        rst_pll_locked_i => '1',
        rst_n_o          => pll_reset_n
    );

    local_reset_n      <= pll_reset_n;
    PLL_RESET          <= pll_reset_n;
    PLL_REFSEL         <= '0'; -- ref1 (signal low) , ref2 (signal high)
    PLL_SYNC           <= '1';

    cmp_pll_ctrl: wr_pll_ctrl
    generic map (
        g_spi_clk_freq => x"00000004" -- 1 for 25M, 4 for 62.5M
    )
    port map (
        clk_i        => clk_dmtd,
        rst_n_i      => pll_reset_n,
        pll_lock_i   => PLL_LOCK,
        pll_status_i => PLL_STAT,
        pll_cs_n_o   => PLL_CS,
        pll_sck_o    => PLL_SCLK,
        pll_mosi_o   => PLL_SDO,
        pll_miso_i   => PLL_SDI,
        -- spi controller status
        done_o       => open
    );

-----------------------------------------------------------------------------
-- The WR PTP core with optional fabric interface attached
-----------------------------------------------------------------------------
    cmp_board_cute_a7 : xwrc_board_cute_a7
    generic map (
        g_num_phys           => g_num_phys,
        g_aux1_sdb           => c_null_sdb,
        g_etherbone_sdb      => c_etherbone_sdb,
        g_fabric_iface       => g_fabric_iface,
        g_with_10M_output    => g_with_10M_output,
        g_dpram_initf        => g_dpram_initf,
        g_with_external_clock_input => false
    )
    port map (
        clk_sys_i            => clk_sys,
        clk_dmtd_i           => clk_dmtd,
        clk_ref_i            => clk_ref(0),
        rst_n_i              => local_reset_n,
        dac_hpll_load_p1_o   => dac_ddmtd_load,
        dac_hpll_data_o      => dac_ddmtd_data,
        dac_dpll_load_p1_o   => dac_main_load,
        dac_dpll_data_o      => dac_main_data,
        phy16_o              => phy16_from_wrc,
        phy16_i              => phy16_to_wrc,
        sfp_scl_o            => sfp_scl_o,
        sfp_scl_i            => sfp_scl_i,
        sfp_sda_o            => sfp_sda_o,
        sfp_sda_i            => sfp_sda_i,
        sfp_det_i            => sfp_det,
        wb_eth_master_o      => wb_eth_master_out,     
        wb_eth_master_i      => wb_eth_master_in,
        wb_slave_i           => wb_slave_in,
        wb_slave_o           => wb_slave_out,
        flash_spi_ncs_o      => flash_ncs_o,
        flash_spi_mosi_o     => flash_qspi_dq0,
        flash_spi_miso_i     => flash_qspi_dq1,
        uart_rxd_i           => uart_rxd_i,
        uart_txd_o           => uart_txd_o,
        owr_en_o             => onewire_en,
        owr_i                => onewire_in,
        led_act_o            => led_act(g_num_phys-1 downto 0),
        led_link_o           => led_link(g_num_phys-1 downto 0),
        pps_o                => pps,
        pps_csync_o          => pps_csync,
        pps_led_o            => pps_led,
        link_ok_o            => link_ok,
        sync_data_p_o        => sync_data_p_o,
        sync_data_n_o        => sync_data_n_o,
        tm_time_valid_o      => tm_time_valid
    );

    wb_eth_master_in <= wb_slave_out;
    wb_slave_in      <= wb_eth_master_out;

    cmp_xwrc_platform : xwrc_platform_xilinx
    generic map (
        g_fpga_family               => "artix7",
        g_with_external_clock_input => false,
        g_use_default_plls          => false,
        g_gtrefclk_src              => g_gtrefclk_src,
        g_ref_clk_sel               => g_ref_clk_sel,
        g_num_phys                  => g_num_phys,
        g_simulation                => 0)
    port map (
        areset_n_i            => local_reset_n,
        clk_gtp_ref0_p_i      => MGTREFCLK0_P,
        clk_gtp_ref0_n_i      => MGTREFCLK0_N,
        clk_gtp_ref1_p_i      => MGTREFCLK1_P,
        clk_gtp_ref1_n_i      => MGTREFCLK1_N,
        clk_gtp_ref0_locked_i => '1',
        clk_gtp_ref1_locked_i => '1',
        sfp_txp_o             => SFP_O_P(g_num_phys-1 downto 0),
        sfp_txn_o             => SFP_O_N(g_num_phys-1 downto 0),
        sfp_rxp_i             => SFP_I_P(g_num_phys-1 downto 0),
        sfp_rxn_i             => SFP_I_N(g_num_phys-1 downto 0),
        sfp_tx_fault_i        => SFP_FAULT_I(g_num_phys-1 downto 0),
        sfp_los_i             => SFP_LOS_I(g_num_phys-1 downto 0),
        sfp_tx_disable_o      => SFP_DISABLE_O(g_num_phys-1 downto 0),
        clk_sys_i             => clk_ref(0),
        clk_sys_o             => clk_sys,
        clk_ref_o             => clk_ref,
        clk_ref_locked_o      => clk_ref_locked,
        phy16_o               => phy16_to_wrc,
        phy16_i               => phy16_from_wrc
    );

    U_Main_DAC : cute_a7_serial_dac_arb
    generic map (
        g_invert_sclk    => FALSE,
        g_num_data_bits  => 16,
        g_num_extra_bits => 8)
    port map (
        clk_i         => clk_sys,
        rst_n_i       => local_reset_n,
        val_i         => dac_main_data,
        load_i        => dac_main_load,
        dac_sync_n_o  => DAC_SYNC_N,
        dac_ldac_n_o  => DAC_LDAC_N,
        dac_clr_n_o   => open,
        dac_sclk_o    => DAC_SCLK,
        dac_din_o     => DAC_SDI);

    U_DMTD_DAC : cute_a7_serial_dac_arb
    generic map (
        g_invert_sclk    => FALSE,
        g_num_data_bits  => 16,
        g_num_extra_bits => 8)
    port map (
        clk_i         => clk_sys,
        rst_n_i       => local_reset_n,
        val_i         => dac_ddmtd_data,
        load_i        => dac_ddmtd_load,
        dac_sync_n_o  => DAC_DMTD_SYNC_N,
        dac_ldac_n_o  => DAC_DMTD_LDAC_N,
        dac_clr_n_o   => open,
        dac_sclk_o    => DAC_DMTD_SCLK,
        dac_din_o     => DAC_DMTD_SDI);

    gen_SFP_I2C: for i in 0 to g_num_phys-1 generate

        SFP_MOD_DEF1_IO(i) <= '0' when sfp_scl_o(i) = '0' else 'Z';
        SFP_MOD_DEF2_IO(i) <= '0' when sfp_sda_o(i) = '0' else 'Z';
        sfp_scl_i(i) <= SFP_MOD_DEF1_IO(i);
        sfp_sda_i(i) <= SFP_MOD_DEF2_IO(i);
        sfp_det(i)   <= SFP_MOD_DEF0_I(i);

    end generate gen_SFP_I2C;

    SYNC_DATA_0_OBUF : OBUFDS
    port map(
      O  => SYNC_DATA1_P,
      OB => SYNC_DATA1_N,
      I  => pps);

    SYNC_DATA0_P <= sync_data_p_o;
    SYNC_DATA0_N <= sync_data_n_o;

    DELAY_EN    <= delay_en_o;
    DELAY_SCLK  <= delay_sclk_o;
    DELAY_SDIN  <= delay_sdin_o;
    DELAY_SLOAD <= delay_sload_o;

    U_FDLY_CTRL: wr_fdelay_ctrl 
    generic map(
      fdelay_ch0 => (others=>'0'),
      fdelay_ch1 => (others=>'0')
    )
    port map(
      rst_sys_n_i      => local_reset_n,
      clk_sys_i        => clk_sys,
      delay_en_o       => delay_en_o,
      delay_sload_o    => delay_sload_o,
      delay_sdin_o     => delay_sdin_o,
      delay_sclk_o     => delay_sclk_o
    );

    QSPI_CS    <= flash_ncs_o;
    QSPI_DQ0   <= flash_qspi_dq0;
    flash_qspi_dq1 <= QSPI_DQ1;

    ONE_WIRE <= '0' when onewire_en(0) = '1' else 'Z';
    onewire_in(0)  <= ONE_WIRE;
    onewire_in(1)  <= '1';

    VERSION    <= VER2 & VER1 & VER0;
    OE_125M    <= '0';
    TEST       <= pps_led;
    TX         <= uart_txd_o;
    uart_rxd_i <= RX;
    led_link_o <= led_link;
    led_act_o  <= led_act;

end rtl;
