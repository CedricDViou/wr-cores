# Create Vivado project
source ./fasec_ref_design.tcl

# Create block design
source ../../top/fasec_ref_design/system_top.tcl

# Generate the wrapper
set design_name [get_bd_designs]
make_wrapper -files [get_files $design_name.bd] -top -import
