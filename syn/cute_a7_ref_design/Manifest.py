board  = "cute_a7"
target = "xilinx"
action = "synthesis"

syn_device = "xc7a35t"
syn_grade = "-2"
syn_package = "csg325"

syn_top = "cute_a7_ref_design"
syn_project = "cute_a7_ref_design"

syn_tool = "vivado"

modules = { "local" : ["../../top/cute_a7_ref_design"] }
