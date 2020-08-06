#   ---------------------------------------------------------------------------`
#   -- Clocks/resets
#   ---------------------------------------------------------------------------

#   -- Local oscillators
# Bank 112 -- 125.000 MHz GTX reference
set_property PACKAGE_PIN U6 [get_ports clk_125m_gtx_p_i]
set_property PACKAGE_PIN U5 [get_ports clk_125m_gtx_n_i]
# Bank 111 -- 125.000 MHz GTX reference
#set_property PACKAGE_PIN W6 [get_ports clk_125m_gtx_p_i]
#set_property PACKAGE_PIN W5 [get_ports clk_125m_gtx_n_i]
# Bank 111 -- FMC GBTCLK0_M2C
#set_property PACKAGE_PIN AA6 [get_ports fmc_gbtclk0_m2c_p]
#set_property PACKAGE_PIN AA5 [get_ports fmc_gbtclk0_m2c_n]

# Bank 35 (HP) VCCO - 1.8 V -- 124.992 MHz DMTD clock
set_property PACKAGE_PIN D15 [get_ports clk_125m_dmtd_p_i]
set_property IOSTANDARD LVDS [get_ports clk_125m_dmtd_p_i]
set_property PACKAGE_PIN D14 [get_ports clk_125m_dmtd_n_i]
set_property IOSTANDARD LVDS [get_ports clk_125m_dmtd_n_i]

create_clock -period 8.000 -name clk_125m_gtx -waveform {0.000 4.000} [get_ports clk_125m_gtx_p_i]
create_clock -period 8.000 -name clk_125m_dmtd -waveform {0.000 4.000} [get_ports clk_125m_dmtd_p_i]

# Set divide by 2 property for generated clk_dmtd (platform xilinx: g_direct_dmtd = TRUE)
create_generated_clock -name clk_125m_dmtd_div2 -source [get_ports clk_125m_dmtd_p_i] -divide_by 2 [get_pins cmp_xwrc_board_spec7/cmp_xwrc_platform/gen_default_plls.gen_kintex7_artix7_default_plls.gen_kintex7_artix7_direct_dmtd.clk_dmtd_reg/Q]

# Set divide by 2 property for generated clk_ref (platform xilinx: g_phy_lpcalib = TRUE)
create_generated_clock -name clk_ref_62m5_div2 -source [get_ports clk_125m_gtx_p_i] -divide_by 2 [get_pins cmp_xwrc_board_spec7/cmp_xwrc_platform/gen_phy_kintex7.gen_lp.clk_ref_reg/Q]

# Set 10 -> 62.5 MHz (*25 /4) generated clk_ext_mul (platform xilinx: g_direct_dmtd = TRUE)
#create_generated_clock -name clk_ext_mul -source [get_pins cmp_xwrc_board_spec7/clk_ext_10m] -multiply 25 -divide 4 [get_pins cmp_xwrc_board_spec7/cmp_xwrc_platform/clk_ext_mul_i]

create_clock -period 16.000 -name RXOUTCLK -waveform {0.000 8.000} [get_pins cmp_xwrc_board_spec7/cmp_xwrc_platform/gen_phy_kintex7.gen_lp.cmp_gtx_lp/U_GTX_INST/gtxe2_i/RXOUTCLK]
create_clock -period 16.000 -name TXOUTCLK -waveform {0.000 8.000} [get_pins cmp_xwrc_board_spec7/cmp_xwrc_platform/gen_phy_kintex7.gen_lp.cmp_gtx_lp/U_GTX_INST/gtxe2_i/TXOUTCLK]

create_clock -period 100.000 -name dio_clk -waveform {0.000 50.000} [get_ports dio_clk_p_i]

set_clock_groups -asynchronous \
-group clk_125m_gtx \
-group clk_ref_62m5_div2 \
-group clk_125m_dmtd \
-group clk_125m_dmtd_div2 \
-group RXOUTCLK \
-group TXOUTCLK \
-group clk_sys \
-group dio_clk \
-group clk_ext_mul

# Set BMM_INFO_DESIGN property to avoid ERROR during "Write Bitstream"
set_property BMM_INFO_DESIGN spec7_wr_ref_top_bd.bmm [current_design]

#   ---------------------------------------------------------------------------
#   -- SPI interface to DACs
#   ---------------------------------------------------------------------------

# Bank 35 (HP) VCCO - 1.8 V
set_property PACKAGE_PIN G10 [get_ports dac_dmtd_din_o]
set_property IOSTANDARD LVCMOS18 [get_ports dac_dmtd_din_o]
set_property PACKAGE_PIN E10 [get_ports dac_dmtd_sclk_o]
set_property IOSTANDARD LVCMOS18 [get_ports dac_dmtd_sclk_o]
set_property PACKAGE_PIN F12 [get_ports dac_dmtd_cs_n_o]
set_property IOSTANDARD LVCMOS18 [get_ports dac_dmtd_cs_n_o]
set_property PACKAGE_PIN D11 [get_ports dac_refclk_din_o]
set_property IOSTANDARD LVCMOS18 [get_ports dac_refclk_din_o]
set_property PACKAGE_PIN F10 [get_ports dac_refclk_sclk_o]
set_property IOSTANDARD LVCMOS18 [get_ports dac_refclk_sclk_o]
set_property PACKAGE_PIN D10 [get_ports dac_refclk_cs_n_o]
set_property IOSTANDARD LVCMOS18 [get_ports dac_refclk_cs_n_o]

#   -------------------------------------------------------------------------------
#   -- PLL Control signals
#   -------------------------------------------------------------------------------    
# Bank 35 (HP) VCCO - 1.8 V
set_property PACKAGE_PIN B11 [get_ports pll_status_i]
set_property IOSTANDARD LVCMOS18 [get_ports pll_status_i]
set_property PACKAGE_PIN C14 [get_ports pll_mosi_o]
set_property IOSTANDARD LVCMOS18 [get_ports pll_mosi_o]
set_property PACKAGE_PIN C11 [get_ports pll_miso_i]
set_property IOSTANDARD LVCMOS18 [get_ports pll_miso_i]
set_property PACKAGE_PIN A15 [get_ports pll_sck_o]
set_property IOSTANDARD LVCMOS18 [get_ports pll_sck_o]
set_property PACKAGE_PIN A14 [get_ports pll_cs_n_o]
set_property IOSTANDARD LVCMOS18 [get_ports pll_cs_n_o]
set_property PACKAGE_PIN B14 [get_ports pll_sync_o]
set_property IOSTANDARD LVCMOS18 [get_ports pll_sync_o]
set_property PACKAGE_PIN A12 [get_ports pll_lock_i]
set_property IOSTANDARD LVCMOS18 [get_ports pll_lock_i]
set_property PACKAGE_PIN B12 [get_ports {pll_wr_mode_o[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pll_wr_mode_o[0]}]
set_property PACKAGE_PIN C12 [get_ports {pll_wr_mode_o[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pll_wr_mode_o[1]}]

#   ---------------------------------------------------------------------------
#   -- PCIe 
#   ---------------------------------------------------------------------------
# Bank 112 (GTX2)
set_property PACKAGE_PIN AB3 [get_ports {rxn[0]}]
set_property PACKAGE_PIN AB4 [get_ports {rxp[0]}]
set_property PACKAGE_PIN AA1 [get_ports {txn[0]}]
set_property PACKAGE_PIN AA2 [get_ports {txp[0]}]

set_property PACKAGE_PIN Y3 [get_ports {rxn[1]}]
set_property PACKAGE_PIN Y4 [get_ports {rxp[1]}]
set_property PACKAGE_PIN W1 [get_ports {txn[1]}]
set_property PACKAGE_PIN W2 [get_ports {txp[1]}]

set_property PACKAGE_PIN R6 [get_ports pci_clk_p]
set_property PACKAGE_PIN R5 [get_ports pci_clk_n]
create_clock -period 10.000 -name pci_clk_p [get_ports pci_clk_p]

set_property PACKAGE_PIN D13 [get_ports perst_n]
set_property IOSTANDARD LVCMOS18 [get_ports perst_n]

#   ---------------------------------------------------------------------------
#   -- SFP I/O for transceiver
#   ---------------------------------------------------------------------------

# Bank 112 (GTX2)
set_property PACKAGE_PIN V3 [get_ports sfp_rxn_i]
set_property PACKAGE_PIN V4 [get_ports sfp_rxp_i]
set_property PACKAGE_PIN U1 [get_ports sfp_txn_o]
set_property PACKAGE_PIN U2 [get_ports sfp_txp_o]

# Bank 35 (HP) VCCO - 1.8 V
# sfp detect
set_property PACKAGE_PIN H13 [get_ports sfp_mod_def0_i]
set_property IOSTANDARD LVCMOS18 [get_ports sfp_mod_def0_i]
# scl
set_property PACKAGE_PIN E11 [get_ports sfp_mod_def1_b]
set_property IOSTANDARD LVCMOS18 [get_ports sfp_mod_def1_b]
# sda
set_property PACKAGE_PIN G11 [get_ports sfp_mod_def2_b]
set_property IOSTANDARD LVCMOS18 [get_ports sfp_mod_def2_b]
set_property PACKAGE_PIN F13 [get_ports sfp_rate_select_o]
set_property IOSTANDARD LVCMOS18 [get_ports sfp_rate_select_o]
set_property PACKAGE_PIN J13 [get_ports sfp_tx_fault_i]
set_property IOSTANDARD LVCMOS18 [get_ports sfp_tx_fault_i]
set_property PACKAGE_PIN G12 [get_ports sfp_tx_disable_o]
set_property IOSTANDARD LVCMOS18 [get_ports sfp_tx_disable_o]
set_property PACKAGE_PIN K13 [get_ports sfp_los_i]
set_property IOSTANDARD LVCMOS18 [get_ports sfp_los_i]

#   ---------------------------------------------------------------------------
#   -- UART
#   ---------------------------------------------------------------------------

# Signal uart_txd_o is an output in the design and must be connected to pin 20/12 (RXD_I) of CP2105GM
# Signal uart_rxd_i is an input in the design and must be connected to pin 21/13 (TXD_O) of CP2105GM
# Rx signals are pulled down so the USB on the CLB and the USB on the G-Board can be OR-ed
# Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN W14 [get_ports uart_rxd_i]
set_property IOSTANDARD LVCMOS25 [get_ports uart_rxd_i]
set_property PACKAGE_PIN W17 [get_ports uart_txd_o]
set_property IOSTANDARD LVCMOS25 [get_ports uart_txd_o]

#   ---------------------------------------------------------------------------
#   -- Miscellaneous spec7 pins
#   ---------------------------------------------------------------------------

# Bank 13 (HR) VCCO - 2.5 V
# LED_TOP
set_property PACKAGE_PIN AA25 [get_ports led_link_o]
set_property IOSTANDARD LVCMOS25 [get_ports led_link_o]
# LED_BOT
set_property PACKAGE_PIN AB25 [get_ports led_act_o]
set_property IOSTANDARD LVCMOS25 [get_ports led_act_o]
# LED_0
set_property PACKAGE_PIN AC26 [get_ports led_pps_o]
set_property IOSTANDARD LVCMOS25 [get_ports led_pps_o]
# LED_1
#set_property PACKAGE_PIN AB26 [get_ports led_1]
#set_property IOSTANDARD LVCMOS25 [get_ports led_1]
# LED_2
#set_property PACKAGE_PIN AE26 [get_ports led_2]
#set_property IOSTANDARD LVCMOS25 [get_ports led_2]
# LED_3
#set_property PACKAGE_PIN AE25 [get_ports led_3]
#set_property IOSTANDARD LVCMOS25 [get_ports led_3]

# Button
# Bank 13 (HR) VCCO - 2.5 V
#set_property PACKAGE_PIN V18 [get_ports button]
#set_property IOSTANDARD LVCMOS25 [get_ports button]

# Fans
# Bank 13 (HR) VCCO - 2.5 V
#set_property PACKAGE_PIN AD26 [get_ports fan_zynq_en]
#set_property IOSTANDARD LVCMOS25 [get_ports fan_zynq_en]
#set_property PACKAGE_PIN AD25 [get_ports fan_fmc_en]
#set_property IOSTANDARD LVCMOS25 [get_ports fan_fmc_en]

# Reset
# Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AA20 [get_ports reset_n_i]
set_property IOSTANDARD LVCMOS25 [get_ports reset_n_i]

# Suicide & Watchdog
# Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AC22 [get_ports suicide_n_o]
set_property IOSTANDARD LVCMOS25 [get_ports suicide_n_o]
set_property PACKAGE_PIN AC21 [get_ports wdog_n_o]
set_property IOSTANDARD LVCMOS25 [get_ports wdog_n_o]
set_property PACKAGE_PIN V19 [get_ports prsnt_m2c_l_i]
set_property IOSTANDARD LVCMOS25 [get_ports prsnt_m2c_l_i]

# SI570
# Bank 12 (HR) VCCO - 2.5 V
#set_property PACKAGE_PIN AD14 [get_ports si570_clk_n]
#set_property IOSTANDARD LVCMOS25 [get_ports si570_clk_n]
#set_property PACKAGE_PIN AC14 [get_ports si570_clk_p]
#set_property IOSTANDARD LVCMOS25 [get_ports si570_clk_p]
#set_property PACKAGE_PIN Y15 [get_ports si570_sda]
#set_property IOSTANDARD LVCMOS25 [get_ports si570_sda]
#set_property PACKAGE_PIN Y16 [get_ports si570_scl]
#set_property IOSTANDARD LVCMOS25 [get_ports si570_scl]
#set_property PACKAGE_PIN W15 [get_ports si570_oe]
#set_property IOSTANDARD LVCMOS25 [get_ports si570_oe]
#set_property PACKAGE_PIN W16 [get_ports si570_tune]
#set_property IOSTANDARD LVCMOS25 [get_ports si570_tune]

# I2C interface for accessing
# EEPROM    (24AA64       Addr 1010.000x) and
# Unique ID (24AA025EU48, Addr 1010.001x).
# Bank 35 (HP) VCCO - 1.8 V
set_property PACKAGE_PIN B17 [get_ports scl_b]
set_property IOSTANDARD LVCMOS18 [get_ports scl_b]
set_property PACKAGE_PIN A17 [get_ports sda_b]
set_property IOSTANDARD LVCMOS18 [get_ports sda_b]

#   ---------------------------------------------------------------------------
#   -- Bulls-Eye connector
#   ---------------------------------------------------------------------------

# PPS_OUT
# Bulls-Eye A01, A02
# Bank 35 (HP) VCCO - 1.8 V
set_property PACKAGE_PIN G16 [get_ports pps_p_o]
set_property IOSTANDARD LVDS [get_ports pps_p_o]
# Bank 35 (HP) VCCO - 1.8 V
set_property PACKAGE_PIN G15 [get_ports pps_n_o]
set_property IOSTANDARD LVDS [get_ports pps_n_o]

# 10MHz_out
# Bulls-Eye A03, A04
# Bank 35 (HP) VCCO - 1.8 V
#set_property PACKAGE_PIN F15 [get_ports clk_10m_p_o]
#set_property IOSTANDARD LVDS [get_ports clk_10m_p_o]
# Bank 35 (HP) VCCO - 1.8 V
#set_property PACKAGE_PIN E15 [get_ports clk_10m_n_o]
#set_property IOSTANDARD LVDS [get_ports clk_10m_n_o]

# 125MHz Reference Clock Out
# Bulls-Eye A05, A06 (connected to AD9516)

# TX Spare GTX Out (Bank 112 GTX3)
# Bulls-Eye A07, A08
#set_property PACKAGE_PIN R2 [get_ports BE_TXP]
#set_property PACKAGE_PIN R1 [get_ports BE_TXN]

# ABSCAL_TXTS
# Bulls-Eye A09, A10
# Bank 35 (HP) VCCO - 1.8 V
set_property PACKAGE_PIN C17 [get_ports abscal_txts_p_o]
set_property IOSTANDARD LVDS [get_ports abscal_txts_p_o]
# Bank 35 (HP) VCCO - 1.8 V
set_property PACKAGE_PIN C16 [get_ports abscal_txts_n_o]
set_property IOSTANDARD LVDS [get_ports abscal_txts_n_o]

# General Purpose Spare Out
# Bulls-Eye A11, A12
# Bank 35 (HP) VCCO - 1.8 V
#set_property PACKAGE_PIN K15 [get_ports spare_p_o]
#set_property IOSTANDARD LVDS [get_ports spare_p_o]
# Bank 35 (HP) VCCO - 1.8 V
#set_property PACKAGE_PIN J15 [get_ports spare_n_o]
#set_property IOSTANDARD LVDS [get_ports spare_n_o]

# PPS_IN
# Bulls-Eye B01, B02
# Bank 35 (HP) VCCO - 1.8 V
#set_property PACKAGE_PIN G14 [get_ports pps_p_i]
#set_property IOSTANDARD LVDS [get_ports pps_p_i]
# Bank 35 (HP) VCCO - 1.8 V
#set_property PACKAGE_PIN F14 [get_ports pps_n_i]
#set_property IOSTANDARD LVDS [get_ports pps_n_i]

# 10MHZ_IN
# Bulls-Eye B03, B04
# Bank 35 (HP) VCCO - 1.8 V
#set_property PACKAGE_PIN AF24 [get_ports clk_10m_p_i]
#set_property IOSTANDARD LVDS [get_ports clk_10m_p_i]
# Bank 35 (HP) VCCO - 1.8 V
#set_property PACKAGE_PIN AF25 [get_ports clk_10m_n_i]
#set_property IOSTANDARD LVDS [get_ports clk_10m_n_i]

# Reference Clock In (Bank 111)
# Bulls-Eye B05, B06
#set_property PACKAGE_PIN W6 [get_ports BE_REFCLK_P]
#set_property PACKAGE_PIN W5 [get_ports BE_REFCLK_N]

# RX Spare GTX Out (Bank 112 GTX3)
# Bulls-Eye B07, B08
#set_property PACKAGE_PIN T4 [get_ports BE_RXP]
#set_property PACKAGE_PIN T3 [get_ports BE_RXN]

# CLK_DMTD In (Debug purposes only)
# Bulls-Eye B09, B10
# Bank 35 (HP) VCCO - 1.8 V
#set_property PACKAGE_PIN J14 [get_ports clk_dmtd_p_i]
#set_property IOSTANDARD LVDS [get_ports clk_dmtd_p_i]
# Bank 35 (HP) VCCO - 1.8 V
#set_property PACKAGE_PIN H14 [get_ports clk_dmtd_n_i]
#set_property IOSTANDARD LVDS [get_ports clk_dmtd_n_i]

# Bank 13 (HR) VCCO - 2.5 V
# Bulls-Eye B11 (PPS Single Ended)
#set_property PACKAGE_PIN AE23 [get_ports pps_i]
#set_property IOSTANDARD LVCMOS25 [get_ports pps_i]

#   ---------------------------------------------------------------------------
#   -- Digital I/O FMC Pins
#   -- used in this design to output WR-aligned 1-PPS (in Slave mode) and input
#   -- 10MHz & 1-PPS from external reference (in GrandMaster mode).
#   ---------------------------------------------------------------------------

#   -- Clock input from LEMO 5 on the mezzanine front panel. Used as 10MHz
#   -- external reference input.
# CLK1_M2C_Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AC23 [get_ports dio_clk_p_i]
set_property IOSTANDARD LVDS_25 [get_ports dio_clk_p_i]
# CLK1_M2C_N Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AC24 [get_ports dio_clk_n_i]
set_property IOSTANDARD LVDS_25 [get_ports dio_clk_n_i]

#   -- Differential inputs, dio_p_i(N) inputs the current state of I/O (N+1) on
#   -- the mezzanine front panel.
# LA00_CC_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AC12 [get_ports {dio_p_i[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_p_i[4]}]
# LA00_CC_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AD11 [get_ports {dio_n_i[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_n_i[4]}]
# LA03_P Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AA24 [get_ports {dio_p_i[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_p_i[3]}]
# LA03_N Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AB24 [get_ports {dio_n_i[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_n_i[3]}]
# LA16_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AA15 [get_ports {dio_p_i[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_p_i[2]}]
# LA16_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AA14 [get_ports {dio_n_i[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_n_i[2]}]
# LA20_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN W13 [get_ports {dio_p_i[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_p_i[1]}]
# LA20_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN Y13 [get_ports {dio_n_i[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_n_i[1]}]
# LA33_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AE10 [get_ports {dio_p_i[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_p_i[0]}]
# LA33_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AD10 [get_ports {dio_n_i[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_n_i[0]}]

#   -- Differential outputs. When the I/O (N+1) is configured as output (i.e. when
#   -- dio_oe_n_o(N) = 0), the value of dio_p_o(N) determines the logic state
#   -- of I/O (N+1) on the front panel of the mezzanine
# LA04_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AE16 [get_ports {dio_p_o[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_p_o[4]}]
# LA04_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AE15 [get_ports {dio_n_o[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_n_o[4]}]
# LA07_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AB17 [get_ports {dio_p_o[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_p_o[3]}]
# LA07_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AB16 [get_ports {dio_n_o[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_n_o[3]}]
# LA08_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN Y17 [get_ports {dio_p_o[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_p_o[2]}]
# LA08_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AA17 [get_ports {dio_n_o[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_n_o[2]}]
# LA28_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AE12 [get_ports {dio_p_o[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_p_o[1]}]
# LA28_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AF12 [get_ports {dio_n_o[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_n_o[1]}]
# LA29_P Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AF19 [get_ports {dio_p_o[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_p_o[0]}]
# LA29_N Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AF20 [get_ports {dio_n_o[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {dio_n_o[0]}]

#   -- Output enable. When dio_oe_n_o(N) is 0, connector (N+1) on the front
#   -- panel is configured as an output.
# LA05_P Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN W20 [get_ports {dio_oe_n_o[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dio_oe_n_o[4]}]
# LA11_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AF15 [get_ports {dio_oe_n_o[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dio_oe_n_o[3]}]
# LA15_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AD15 [get_ports {dio_oe_n_o[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dio_oe_n_o[2]}]
# LA24_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AF13 [get_ports {dio_oe_n_o[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dio_oe_n_o[1]}]
# LA30_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AE11 [get_ports {dio_oe_n_o[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dio_oe_n_o[0]}]

#   -- Termination enable. When dio_term_en_o(N) is 1, connector (N+1) on the front
#   -- panel is 50-ohm terminated
# LA09_N Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AB19 [get_ports {dio_term_en_o[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dio_term_en_o[4]}]
# LA09_P Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AA19 [get_ports {dio_term_en_o[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dio_term_en_o[3]}]
# LA05_N Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN Y20 [get_ports {dio_term_en_o[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dio_term_en_o[2]}]
# LA06_N Bank 13 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN W19 [get_ports {dio_term_en_o[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dio_term_en_o[1]}]
# LA30_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AF10 [get_ports {dio_term_en_o[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {dio_term_en_o[0]}]

#    -- Two LEDs on the mezzanine panel. Only Top one is currently used - to
#    -- blink 1-PPS.
# LA01_CC_P Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AB15 [get_ports dio_led_top_o]
set_property IOSTANDARD LVCMOS25 [get_ports dio_led_top_o]
# LA01_CC_N Bank 12 (HR) VCCO - 2.5 V
set_property PACKAGE_PIN AB14 [get_ports dio_led_bot_o]
set_property IOSTANDARD LVCMOS25 [get_ports dio_led_bot_o]

#   -- I2C interface for accessing FMC EEPROM.
# Bank 13 (HR) VCCO - 2.5 V
#set_property PACKAGE_PIN AE21 [get_ports dio_scl_b]
#set_property IOSTANDARD LVCMOS25 [get_ports dio_scl_b]
#set_property PACKAGE_PIN AE20 [get_ports dio_sda_b]
#set_property IOSTANDARD LVCMOS25 [get_ports dio_sda_b]

#   ---------------------------------------------------------------------------
#   -- FMC connector
#   ---------------------------------------------------------------------------
# FMC SIGNALS CLK LPC
# Bank 12 VCCO - 2.5 V
#set_property PACKAGE_PIN AC13 [get_ports fmc_clk0_m2c_p]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_clk0_m2c_p]
#set_property DIFF_TERM TRUE [get_ports fmc_clk0_m2c_p]
#set_property PACKAGE_PIN AD13 [get_ports fmc_clk0_m2c_n]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_clk0_m2c_n]
#set_property DIFF_TERM TRUE [get_ports fmc_clk0_m2c_n]
# Bank 13 VCCO - 2.5 V
#set_property PACKAGE_PIN AC23 [get_ports fmc_clk1_m2c_p]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_clk1_m2c_p]
#set_property DIFF_TERM TRUE [get_ports fmc_clk1_m2c_p]
#set_property PACKAGE_PIN AC24 [get_ports fmc_clk1_m2c_n]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_clk1_m2c_n]
#set_property DIFF_TERM TRUE [get_ports fmc_clk1_m2c_n]

# Bank 13 VCCO - 2.5 V
#set_property PACKAGE_PIN V19 [get_ports fmc_prsnt_m2c_l]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_prsnt_m2c_l]

# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 1
#set_property PACKAGE_PIN AC12 [get_ports fmc_la00_cc_p]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_la00_cc_p]
#set_property DIFF_TERM TRUE [get_ports fmc_la00_cc_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 3
#set_property PACKAGE_PIN AD11 [get_ports fmc_la00_cc_n]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_la00_cc_n]
#set_property DIFF_TERM TRUE [get_ports fmc_la00_cc_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 5
#set_property PACKAGE_PIN AB15 [get_ports fmc_la01_cc_p]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_la01_cc_p]
#set_property DIFF_TERM TRUE [get_ports fmc_la01_cc_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 7
#set_property PACKAGE_PIN AB14 [get_ports fmc_la01_cc_n]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_la01_cc_n]
#set_property DIFF_TERM TRUE [get_ports fmc_la01_cc_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 9
#set_property PACKAGE_PIN AE17 [get_ports fmc_la02_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la02_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 11
#set_property PACKAGE_PIN AF17 [get_ports fmc_la02_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la02_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 13
#set_property PACKAGE_PIN AA24 [get_ports fmc_la03_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la03_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 15
#set_property PACKAGE_PIN AB24 [get_ports fmc_la03_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la03_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 17
#set_property PACKAGE_PIN AE16 [get_ports fmc_la04_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la04_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 19
#set_property PACKAGE_PIN AE15 [get_ports fmc_la04_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la04_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 21
#set_property PACKAGE_PIN W20 [get_ports fmc_la05_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la05_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 23
#set_property PACKAGE_PIN Y20 [get_ports fmc_la05_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la05_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 25
#set_property PACKAGE_PIN W18 [get_ports fmc_la06_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la06_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 27
#set_property PACKAGE_PIN W19 [get_ports fmc_la06_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la06_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 29
#set_property PACKAGE_PIN AB17 [get_ports fmc_la07_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la07_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 31
#set_property PACKAGE_PIN AB16 [get_ports fmc_la07_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la07_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 33
#set_property PACKAGE_PIN Y17 [get_ports fmc_la08_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la08_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 35
#set_property PACKAGE_PIN AA17 [get_ports fmc_la08_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la08_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 37
#set_property PACKAGE_PIN AA19 [get_ports fmc_la09_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la09_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 39
#set_property PACKAGE_PIN AB19 [get_ports fmc_la09_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la09_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 2
#set_property PACKAGE_PIN Y18 [get_ports fmc_la10_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la10_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 4
#set_property PACKAGE_PIN AA18 [get_ports fmc_la10_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la10_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 6
#set_property PACKAGE_PIN AF15 [get_ports fmc_la11_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la11_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 8
#set_property PACKAGE_PIN AF14 [get_ports fmc_la11_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la11_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 10
#set_property PACKAGE_PIN AC17 [get_ports fmc_la12_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la12_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 12
#set_property PACKAGE_PIN AC16 [get_ports fmc_la12_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la12_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 14
#set_property PACKAGE_PIN AA22 [get_ports fmc_la13_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la13_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 16
#set_property PACKAGE_PIN AA23 [get_ports fmc_la13_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la13_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 18
#set_property PACKAGE_PIN AB21 [get_ports fmc_la14_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la14_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 20
#set_property PACKAGE_PIN AB22 [get_ports fmc_la14_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la14_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 22
#set_property PACKAGE_PIN AD16 [get_ports fmc_la15_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la15_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 24
#set_property PACKAGE_PIN AD15 [get_ports fmc_la15_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la15_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 26
#set_property PACKAGE_PIN AA15 [get_ports fmc_la16_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la16_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 28
#set_property PACKAGE_PIN AA14 [get_ports fmc_la16_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la16_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 30
#set_property PACKAGE_PIN AD20 [get_ports fmc_la17_cc_p]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_la17_cc_p]
#set_property DIFF_TERM TRUE [get_ports fmc_la17_cc_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 32
#set_property PACKAGE_PIN AD21 [get_ports fmc_la17_cc_n]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_la17_cc_n]
#set_property DIFF_TERM TRUE [get_ports fmc_la17_cc_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 34
#set_property PACKAGE_PIN AD23 [get_ports fmc_la18_cc_p]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_la18_cc_p]
#set_property DIFF_TERM TRUE [get_ports fmc_la18_cc_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J1 pin 36
#set_property PACKAGE_PIN AD24 [get_ports fmc_la18_cc_n]
#set_property IOSTANDARD LVDS_25 [get_ports fmc_la18_cc_n]
#set_property DIFF_TERM TRUE [get_ports fmc_la18_cc_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 38
#set_property PACKAGE_PIN Y12 [get_ports fmc_la19_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la19_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J1 pin 40
#set_property PACKAGE_PIN Y11 [get_ports fmc_la19_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la19_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J20 pin 1
#set_property PACKAGE_PIN W13 [get_ports fmc_la20_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la20_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J20 pin 3
#set_property PACKAGE_PIN Y13 [get_ports fmc_la20_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la20_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J20 pin 5
#set_property PACKAGE_PIN AA13 [get_ports fmc_la21_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la21_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J20 pin 7
#set_property PACKAGE_PIN AA12 [get_ports fmc_la21_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la21_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J20 pin 9
#set_property PACKAGE_PIN Y10 [get_ports fmc_la22_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la22_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J20 pin 11
#set_property PACKAGE_PIN AA10 [get_ports fmc_la22_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la22_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J20 pin 13
#set_property PACKAGE_PIN AE22 [get_ports fmc_la23_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la23_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J20 pin 15
#set_property PACKAGE_PIN AF22 [get_ports fmc_la23_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la23_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J20 pin 2
#set_property PACKAGE_PIN AE13 [get_ports fmc_la24_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la24_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J20 pin 4
#set_property PACKAGE_PIN AF13 [get_ports fmc_la24_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la24_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J20 pin 6
#set_property PACKAGE_PIN AB11 [get_ports fmc_la25_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la25_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J20 pin 8
#set_property PACKAGE_PIN AB10 [get_ports fmc_la25_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la25_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J20 pin 10
#set_property PACKAGE_PIN AD18 [get_ports fmc_la26_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la26_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J20 pin 12
#set_property PACKAGE_PIN AD19 [get_ports fmc_la26_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la26_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J20 pin 14
#set_property PACKAGE_PIN AC18 [get_ports fmc_la27_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la27_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J20 pin 16
#set_property PACKAGE_PIN AC19 [get_ports fmc_la27_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la27_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J16 pin 5
#set_property PACKAGE_PIN AE12 [get_ports fmc_la28_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la28_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J16 pin 7
#set_property PACKAGE_PIN AF12 [get_ports fmc_la28_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la28_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J16 pin 9
#set_property PACKAGE_PIN AF19 [get_ports fmc_la29_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la29_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J16 pin 11
#set_property PACKAGE_PIN AF20 [get_ports fmc_la29_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la29_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J16 pin 6
#set_property PACKAGE_PIN AE11 [get_ports fmc_la30_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la30_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J16 pin 8
#set_property PACKAGE_PIN AF10 [get_ports fmc_la30_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la30_n]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J16 pin 10
#set_property PACKAGE_PIN AE18 [get_ports fmc_la31_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la31_p]
# Bank 13 VCCO - 2.5 V  FMC_XM105 J16 pin 12
#set_property PACKAGE_PIN AF18 [get_ports fmc_la31_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la31_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J15 pin 3
#set_property PACKAGE_PIN AB12 [get_ports fmc_la32_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la32_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J15 pin 4
#set_property PACKAGE_PIN AC11 [get_ports fmc_la32_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la32_n]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J15 pin 5
#set_property PACKAGE_PIN AE10 [get_ports fmc_la33_p]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la33_p]
# Bank 12 VCCO - 2.5 V  FMC_XM105 J15 pin 6
#set_property PACKAGE_PIN AD10 [get_ports fmc_la33_n]
#set_property IOSTANDARD LVCMOS25 [get_ports fmc_la33_n]
