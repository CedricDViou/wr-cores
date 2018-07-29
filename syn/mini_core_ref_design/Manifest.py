target = "xilinx"
action = "synthesis"

syn_device = "xc6slx45t"
syn_grade = "-3"
syn_package = "csg324"

syn_top = "mini_core_ref_top"
syn_project = "mini_core_ref.xise"

syn_tool = "ise"

modules = { "local" : "../../top/mini_ref_design/"}
