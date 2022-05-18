set_global_assignment -entity "wr_arria10_scu4_rst_ctl" -library "lib_wr_arria10_scu4_rst_ctl" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "wr_arria10_scu4_rst_ctl" -library "lib_wr_arria10_scu4_rst_ctl" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "wr_arria10_scu4_rst_ctl" -library "lib_wr_arria10_scu4_rst_ctl" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name SPD_FILE [file join $::quartus(sip_path) "wr_arria10_scu4_rst_ctl.spd"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "../wr_arria10_scu4_rst_ctl.qsys"]

set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "sim/wr_arria10_scu4_rst_ctl.v"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/altera_xcvr_functions.sv"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/mentor/altera_xcvr_functions.sv"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/alt_xcvr_resync.sv"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/mentor/alt_xcvr_resync.sv"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/altera_xcvr_reset_control.sv"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/alt_xcvr_reset_counter.sv"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/mentor/altera_xcvr_reset_control.sv"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/mentor/alt_xcvr_reset_counter.sv"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/plain_files.txt"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/mentor_files.txt"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/cadence_files.txt"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/synopsys_files.txt"]
set_global_assignment -library "lib_wr_arria10_scu4_rst_ctl" -name MISC_FILE [file join $::quartus(sip_path) "altera_xcvr_reset_control_181/sim/aldec_files.txt"]
