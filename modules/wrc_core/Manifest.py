files = [ "xwr_core.vhd",
          "wr_core.vhd",
          "wrcore_pkg.vhd",
          "wrc_periph.vhd",
          "wrc_syscon_wb.vhd",
          "wrc_syscon_pkg.vhd",
          "wrc_diags_wb.vhd",
          "wrc_diags_pkg.vhd",
          "xwrc_diags_wb.vhd",
	  "wrc_urv_wrapper.vhd",
	  "wrc_cpu_csr_wbgen2_pkg.vhd",
	  "wrc_cpu_csr_wb.vhd"
];


modules = { "local" : [ "../../ip_cores/urv-core" ] };