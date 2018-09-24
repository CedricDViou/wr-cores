set_property PACKAGE_PIN AB8 [get_ports led_act_o]
set_property IOSTANDARD LVCMOS15 [get_ports led_act_o]
set_property PACKAGE_PIN AA8 [get_ports led_link_o]
set_property IOSTANDARD LVCMOS15 [get_ports led_link_o]
set_property PACKAGE_PIN AC9 [get_ports link_ok_o]
set_property IOSTANDARD LVCMOS15 [get_ports link_ok_o]
set_property PACKAGE_PIN AB9 [get_ports pps_led_o]
set_property IOSTANDARD LVCMOS15 [get_ports pps_led_o]

set_property PACKAGE_PIN Y24 [get_ports pps_p_o] 
set_property IOSTANDARD LVCMOS25 [get_ports pps_p_o]
set_property PACKAGE_PIN Y23 [get_ports pps_ext_i]
set_property IOSTANDARD LVCMOS25 [get_ports pps_ext_i]

set_property PACKAGE_PIN M19 [get_ports uart_rxd_i]
set_property IOSTANDARD LVCMOS25 [get_ports uart_rxd_i]
set_property PACKAGE_PIN K24 [get_ports uart_txd_o]
set_property IOSTANDARD LVCMOS25 [get_ports uart_txd_o]

set_property PACKAGE_PIN B22 [get_ports onewire_b]
set_property IOSTANDARD LVCMOS25 [get_ports onewire_b]

set_property PACKAGE_PIN K21 [get_ports i2c_switch_scl_b]
set_property IOSTANDARD LVCMOS25 [get_ports i2c_switch_scl_b]

set_property PACKAGE_PIN L21 [get_ports i2c_switch_sda_b]
set_property IOSTANDARD LVCMOS25 [get_ports i2c_switch_sda_b]

set_property PACKAGE_PIN P23 [get_ports i2c_switch_rst_o]
set_property IOSTANDARD LVCMOS25 [get_ports i2c_switch_rst_o]

set_property PACKAGE_PIN E29 [get_ports dac_refclk_cs_n_o] 
set_property IOSTANDARD LVCMOS25 [get_ports dac_refclk_cs_n_o]
set_property PACKAGE_PIN B27 [get_ports dac_refclk_din_o]
set_property IOSTANDARD LVCMOS25 [get_ports dac_refclk_din_o]
set_property PACKAGE_PIN C20 [get_ports dac_refclk_sclk_o]
set_property IOSTANDARD LVCMOS25 [get_ports dac_refclk_sclk_o]
create_clock -period 33.333 -name dac_refclk_sclk_o -waveform {0.000 16.667} [get_ports dac_refclk_sclk_o]


set_property PACKAGE_PIN H26 [get_ports dac_dmtd_cs_n_o] 
set_property IOSTANDARD LVCMOS25 [get_ports dac_dmtd_cs_n_o]
set_property PACKAGE_PIN C29 [get_ports dac_dmtd_din_o]
set_property IOSTANDARD LVCMOS25 [get_ports dac_dmtd_din_o]
set_property PACKAGE_PIN E19 [get_ports dac_dmtd_sclk_o]
set_property IOSTANDARD LVCMOS25 [get_ports dac_dmtd_sclk_o]
create_clock -period 33.333 -name dac_dmtd_sclk_o -waveform {0.000 16.667} [get_ports dac_dmtd_sclk_o]


set_property PACKAGE_PIN G12 [get_ports areset_i] 
set_property IOSTANDARD LVCMOS25 [get_ports areset_i]

set_property PACKAGE_PIN D27 [get_ports clk_20m_vcxo_n_i]
#set_property IOSTANDARD LVDS_25 [get_ports clk_20m_vcxo_n_i]
set_property PACKAGE_PIN C27 [get_ports clk_20m_vcxo_p_i]
#set_property IOSTANDARD LVDS_25 [get_ports clk_20m_vcxo_p_i]
create_clock -period 50.000 -name clk_20m_vcxo_p_i -waveform {0.000 25.000} [get_ports clk_20m_vcxo_p_i]
create_clock -period 50.000 -name clk_20m_vcxo_n_i -waveform {0.000 25.000} [get_ports clk_20m_vcxo_n_i]


set_property PACKAGE_PIN C8 [get_ports clk_125m_gtp_p_i]
set_property PACKAGE_PIN C7 [get_ports clk_125m_gtp_n_i]
create_clock -period 8.000 -name clk_125m_gtp_p_i -waveform {0.000 4.000} [get_ports clk_125m_gtp_p_i]
create_clock -period 8.000 -name clk_125m_gtp_n_i -waveform {0.000 4.000} [get_ports clk_125m_gtp_n_i]


set_property PACKAGE_PIN K25 [get_ports clk_10m_ext_n_i]
set_property IOSTANDARD LVDS_25 [get_ports clk_10m_ext_n_i]
set_property PACKAGE_PIN L25 [get_ports clk_10m_ext_p_i]
set_property IOSTANDARD LVDS_25 [get_ports clk_10m_ext_p_i]
create_clock -period 100.000 -name clk_10m_ext_n_i -waveform {0.000 50.000} [get_ports clk_10m_ext_p_i]
create_clock -period 100.000 -name clk_10m_ext_p_i -waveform {0.000 50.000} [get_ports clk_10m_ext_n_i]

set_property PACKAGE_PIN B17 [get_ports clk_ref_62m5_n_o]
#set_property IOSTANDARD LVDS_25 [get_ports clk_ref_62m5_n_o]
set_property PACKAGE_PIN C17 [get_ports clk_ref_62m5_p_o]
#set_property IOSTANDARD LVDS_25 [get_ports clk_ref_62m5_p_o]
create_clock -period 16.000 -name clk_ref_62m5_n_o -waveform {0.000 8.000} [get_ports clk_ref_62m5_n_o]
create_clock -period 16.000 -name clk_ref_62m5_p_o -waveform {0.000 8.000} [get_ports clk_ref_62m5_p_o]


set_clock_groups -asynchronous \
-group {clk_sys } \
-group {clk_sys_1 } \
-group {clk_10m_ext_p_i } \
-group {clk_10m_ext_n_i } \
-group {clk_125m_gtp_p_i } \
-group {clk_125m_gtp_n_i } \
-group {clk_20m_vcxo_p_i } \
-group {clk_20m_vcxo_n_i } \
-group {clk_dmtd} \
-group {clk_dmtd_1} \
-group {clk_ext_mul} \
-group {clk_ext_mul_1} 
 
set_property PACKAGE_PIN L26 [get_ports fan]
set_property IOSTANDARD LVCMOS25 [get_ports fan]
 
set_property PACKAGE_PIN D2 [get_ports sfp_txp_o]
set_property PACKAGE_PIN D1 [get_ports sfp_txn_o]
set_property PACKAGE_PIN E4 [get_ports sfp_rxp_i]
set_property PACKAGE_PIN E3 [get_ports sfp_rxn_i]

set_property PACKAGE_PIN D29 [get_ports sfp_det_i]
set_property IOSTANDARD LVCMOS25 [get_ports sfp_det_i]      
set_property PACKAGE_PIN H30 [get_ports sfp_mod_def1_b]
set_property IOSTANDARD LVCMOS25 [get_ports sfp_mod_def1_b] 
set_property PACKAGE_PIN B28 [get_ports sfp_mod_def2_b]
set_property IOSTANDARD LVCMOS25 [get_ports sfp_mod_def2_b]

set_property PACKAGE_PIN A25 [get_ports sfp_tx_fault_i]
set_property IOSTANDARD LVCMOS25 [get_ports sfp_tx_fault_i]
 
set_property PACKAGE_PIN B30 [get_ports sfp_los_i]
set_property IOSTANDARD LVCMOS25 [get_ports sfp_los_i]
     
set_property PACKAGE_PIN G29 [get_ports sfp_tx_enable_o]
set_property IOSTANDARD LVCMOS25 [get_ports sfp_tx_enable_o]
