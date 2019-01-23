target = "xilinx"
action = "synthesis"

syn_device = "xc6slx45t"
syn_grade = "-3"
syn_package = "csg324"

syn_top = "cute_dp_ref_top"
syn_project = "cute_dp_ref_design.xise"

syn_tool = "ise"

modules = { "local" : "../../top/cute_dp_ref_design/"}
