library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package wr_arria10_scu4_cmu_pll_pkg is
	component altera_xcvr_cdr_pll_a10 is
		generic (
			enable_pll_reconfig                                          : integer := 0;
			rcfg_jtag_enable                                             : integer := 0;
			rcfg_separate_avmm_busy                                      : integer := 0;
			dbg_embedded_debug_enable                                    : integer := 0;
			dbg_capability_reg_enable                                    : integer := 0;
			dbg_user_identifier                                          : integer := 0;
			dbg_stat_soft_logic_enable                                   : integer := 0;
			dbg_ctrl_soft_logic_enable                                   : integer := 0;
			cdr_pll_silicon_rev                                          : string  := "20nm5es";
			cdr_pll_pma_width                                            : integer := 8;
			cdr_pll_cgb_div                                              : integer := 1;
			cdr_pll_is_cascaded_pll                                      : string  := "false";
			cdr_pll_datarate                                             : string  := "0 bps";
			cdr_pll_lpd_counter                                          : integer := 1;
			cdr_pll_lpfd_counter                                         : integer := 1;
			cdr_pll_n_counter_scratch                                    : integer := 1;
			cdr_pll_output_clock_frequency                               : string  := "0 hz";
			cdr_pll_reference_clock_frequency                            : string  := "0 hz";
			cdr_pll_set_cdr_vco_speed                                    : integer := 1;
			cdr_pll_set_cdr_vco_speed_fix                                : integer := 0;
			cdr_pll_vco_freq                                             : string  := "0 hz";
			cdr_pll_atb_select_control                                   : string  := "atb_off";
			cdr_pll_auto_reset_on                                        : string  := "auto_reset_on";
			cdr_pll_bbpd_data_pattern_filter_select                      : string  := "bbpd_data_pat_off";
			cdr_pll_bw_sel                                               : string  := "low";
			cdr_pll_cdr_odi_select                                       : string  := "sel_cdr";
			cdr_pll_cdr_phaselock_mode                                   : string  := "no_ignore_lock";
			cdr_pll_cdr_powerdown_mode                                   : string  := "power_down";
			cdr_pll_chgpmp_current_pd                                    : string  := "cp_current_pd_setting0";
			cdr_pll_chgpmp_current_pfd                                   : string  := "cp_current_pfd_setting0";
			cdr_pll_chgpmp_replicate                                     : string  := "false";
			cdr_pll_chgpmp_testmode                                      : string  := "cp_test_disable";
			cdr_pll_clklow_mux_select                                    : string  := "clklow_mux_cdr_fbclk";
			cdr_pll_disable_up_dn                                        : string  := "true";
			cdr_pll_fref_clklow_div                                      : integer := 1;
			cdr_pll_fref_mux_select                                      : string  := "fref_mux_cdr_refclk";
			cdr_pll_gpon_lck2ref_control                                 : string  := "gpon_lck2ref_off";
			cdr_pll_initial_settings                                     : string  := "true";
			cdr_pll_lck2ref_delay_control                                : string  := "lck2ref_delay_off";
			cdr_pll_lf_resistor_pd                                       : string  := "lf_pd_setting0";
			cdr_pll_lf_resistor_pfd                                      : string  := "lf_pfd_setting0";
			cdr_pll_lf_ripple_cap                                        : string  := "lf_no_ripple";
			cdr_pll_loop_filter_bias_select                              : string  := "lpflt_bias_off";
			cdr_pll_ltd_ltr_micro_controller_select                      : string  := "ltd_ltr_pcs";
			cdr_pll_m_counter                                            : integer := 16;
			cdr_pll_n_counter                                            : integer := 1;
			cdr_pll_optimal                                              : string  := "false";
			cdr_pll_pd_fastlock_mode                                     : string  := "false";
			cdr_pll_pd_l_counter                                         : integer := 1;
			cdr_pll_pfd_l_counter                                        : integer := 1;
			cdr_pll_primary_use                                          : string  := "cmu";
			cdr_pll_prot_mode                                            : string  := "unused";
			cdr_pll_set_cdr_v2i_enable                                   : string  := "true";
			cdr_pll_set_cdr_vco_reset                                    : string  := "false";
			cdr_pll_set_cdr_vco_speed_pciegen3                           : string  := "cdr_vco_max_speedbin_pciegen3";
			cdr_pll_pm_speed_grade                                       : string  := "e2";
			cdr_pll_sup_mode                                             : string  := "user_mode";
			cdr_pll_tx_pll_prot_mode                                     : string  := "txpll_unused";
			cdr_pll_txpll_hclk_driver_enable                             : string  := "false";
			cdr_pll_vco_overrange_voltage                                : string  := "vco_overrange_off";
			cdr_pll_vco_underrange_voltage                               : string  := "vco_underange_off";
			cdr_pll_fb_select                                            : string  := "direct_fb";
			cdr_pll_uc_ro_cal                                            : string  := "uc_ro_cal_off";
			cdr_pll_iqclk_mux_sel                                        : string  := "power_down";
			cdr_pll_pcie_gen                                             : string  := "non_pcie";
			cdr_pll_set_cdr_input_freq_range                             : integer := 0;
			cdr_pll_chgpmp_current_dn_trim                               : string  := "cp_current_trimming_dn_setting0";
			cdr_pll_chgpmp_up_pd_trim_double                             : string  := "normal_up_trim_current";
			cdr_pll_chgpmp_current_up_pd                                 : string  := "cp_current_pd_up_setting0";
			cdr_pll_chgpmp_current_up_trim                               : string  := "cp_current_trimming_up_setting0";
			cdr_pll_chgpmp_dn_pd_trim_double                             : string  := "normal_dn_trim_current";
			cdr_pll_cal_vco_count_length                                 : string  := "sel_8b_count";
			cdr_pll_chgpmp_current_dn_pd                                 : string  := "cp_current_pd_dn_setting0";
			enable_analog_resets                                         : integer := 0;
			calibration_en                                               : string  := "enable";
			pma_cdr_refclk_select_mux_silicon_rev                        : string  := "";
			pma_cdr_refclk_select_mux_refclk_select                      : string  := "";
			pma_cdr_refclk_select_mux_powerdown_mode                     : string  := "";
			pma_cdr_refclk_select_mux_inclk0_logical_to_physical_mapping : string  := "";
			pma_cdr_refclk_select_mux_inclk1_logical_to_physical_mapping : string  := "";
			pma_cdr_refclk_select_mux_inclk2_logical_to_physical_mapping : string  := "";
			pma_cdr_refclk_select_mux_inclk3_logical_to_physical_mapping : string  := "";
			pma_cdr_refclk_select_mux_inclk4_logical_to_physical_mapping : string  := ""
		);
		port (
			pll_powerdown         : in  std_logic                     := 'X';             -- pll_powerdown
			pll_refclk0           : in  std_logic                     := 'X';             -- clk
			tx_serial_clk         : out std_logic;                                        -- clk
			pll_locked            : out std_logic;                                        -- pll_locked
			pll_cal_busy          : out std_logic;                                        -- pll_cal_busy
			pll_refclk1           : in  std_logic                     := 'X';             -- clk
			pll_refclk2           : in  std_logic                     := 'X';             -- clk
			pll_refclk3           : in  std_logic                     := 'X';             -- clk
			pll_refclk4           : in  std_logic                     := 'X';             -- clk
			reconfig_clk0         : in  std_logic                     := 'X';             -- clk
			reconfig_reset0       : in  std_logic                     := 'X';             -- reset
			reconfig_write0       : in  std_logic                     := 'X';             -- write
			reconfig_read0        : in  std_logic                     := 'X';             -- read
			reconfig_address0     : in  std_logic_vector(9 downto 0)  := (others => 'X'); -- address
			reconfig_writedata0   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			reconfig_readdata0    : out std_logic_vector(31 downto 0);                    -- readdata
			reconfig_waitrequest0 : out std_logic;                                        -- waitrequest
			avmm_busy0            : out std_logic;                                        -- avmm_busy0
			hip_cal_done          : out std_logic                                         -- hip_cal_done
		);
	end component altera_xcvr_cdr_pll_a10;

end wr_arria10_scu4_cmu_pll_pkg;
