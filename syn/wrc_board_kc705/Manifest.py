target = "xilinx"
action = "synthesis"

syn_family = "kintex7"
syn_device = "xc7k325t"
syn_grade = "-2"
syn_package = "ffg900"

syn_top = "wrc_board_kc705"
syn_project = "wrc_board_kc705"

syn_tool = "vivado"

modules = { "local" : [
                "../../",
                "../../ip_cores/general-cores/",
                "../../board/kc705/" ] }
